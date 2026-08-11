#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.14,<3.15"
# dependencies = []
# ///
"""Validate the canonical CUE schema and its JSON Schema projection."""

from __future__ import annotations

import copy
import difflib
import json
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
SCHEMA = ROOT / "schema"
CASES = ROOT / "conformance" / "v1" / "cases"
GENERATED_SCHEMA = SCHEMA / "release-index-v1.schema.json"


class CheckFailure(RuntimeError):
    """Report an actionable validation failure without a Python traceback."""


def run(command: list[str], *, cwd: Path = SCHEMA) -> subprocess.CompletedProcess[str]:
    """Run a command and retain its output for a useful failure message."""

    result = subprocess.run(
        command,
        cwd=cwd,
        check=False,
        text=True,
        capture_output=True,
    )
    if result.returncode != 0:
        rendered = " ".join(command)
        output = "\n".join(part.rstrip() for part in (result.stdout, result.stderr) if part)
        raise CheckFailure(f"command failed: {rendered}\n{output}")
    return result


def cue_vet(index_path: Path) -> subprocess.CompletedProcess[str]:
    """Validate one parsed release-index value against #ReleaseIndex."""

    return subprocess.run(
        ["cue", "vet", "-c", "-d", "#ReleaseIndex", ".", str(index_path)],
        cwd=SCHEMA,
        check=False,
        text=True,
        capture_output=True,
    )


def check_cue_source() -> None:
    """Check formatting, module state, and definition consistency."""

    run(["cue", "fmt", "--check", "--files", "."])
    run(["cue", "mod", "tidy", "--check"])
    run(["cue", "vet", "-c", "./..."])


def check_generated_schema() -> None:
    """Regenerate the compatibility projection and reject committed drift."""

    with tempfile.TemporaryDirectory(prefix="imgoci-cue-") as directory:
        generated = Path(directory) / GENERATED_SCHEMA.name
        run(
            [
                "cue",
                "def",
                "--out",
                "jsonschema",
                "-e",
                "#ReleaseIndexJSONSchema",
                "-o",
                str(generated),
                ".",
            ]
        )

        expected_bytes = GENERATED_SCHEMA.read_bytes()
        actual_bytes = generated.read_bytes()
        if actual_bytes != expected_bytes:
            expected_text = expected_bytes.decode("utf-8", errors="replace")
            actual_text = actual_bytes.decode("utf-8", errors="replace")
            diff = "".join(
                difflib.unified_diff(
                    expected_text.splitlines(keepends=True),
                    actual_text.splitlines(keepends=True),
                    fromfile=str(GENERATED_SCHEMA.relative_to(ROOT)),
                    tofile="regenerated release-index-v1.schema.json",
                )
            )
            raise CheckFailure(f"generated JSON Schema is stale:\n{diff}")


def load_index(case_id: str) -> dict[str, Any]:
    """Load a conformance release index as a mutable JSON value."""

    return json.loads((CASES / case_id / "index.json").read_text(encoding="utf-8"))


def write_index(path: Path, value: dict[str, Any]) -> None:
    """Write a temporary parsed-value fixture; exact JSON bytes are irrelevant here."""

    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def incus_vm_index(*, target: str = "incus") -> dict[str, Any]:
    """Build one Incus VM deliverable with its required disk and metadata roles."""

    value = load_index("valid-minimal")
    disk = value["manifests"][0]
    disk_annotations = disk["annotations"]
    disk_annotations["io.imgoci.target"] = target
    disk_annotations["io.imgoci.representation"] = "incus-vm"
    disk_annotations["io.imgoci.role"] = "disk"
    disk_annotations["org.opencontainers.image.title"] = "disk.qcow2"

    metadata = copy.deepcopy(disk)
    metadata["digest"] = (
        "sha256:2222222222222222222222222222222222222222222222222222222222222222"
    )
    metadata_annotations = metadata["annotations"]
    metadata_annotations["io.imgoci.content.digest"] = (
        "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    )
    metadata_annotations["io.imgoci.role"] = "metadata"
    metadata_annotations["org.opencontainers.image.title"] = "metadata.tar.xz"
    value["manifests"].append(metadata)
    return value


def invalid_mutations() -> list[tuple[str, dict[str, Any]]]:
    """Build focused values that each violate one release-index rule."""

    base = load_index("valid-minimal")
    alternatives = load_index("resolve-compression-order")
    mutations: list[tuple[str, dict[str, Any]]] = []

    value = copy.deepcopy(base)
    value["manifests"][0]["annotations"]["io.imgoci.representation"] = "raw"
    mutations.append(("missing-disk-role", value))

    value = copy.deepcopy(base)
    value["manifests"][0]["annotations"]["io.imgoci.representation"] = "pxe"
    value["manifests"][0]["annotations"]["io.imgoci.role"] = "kernel"
    mutations.append(("missing-pxe-roles", value))

    value = incus_vm_index()
    value["manifests"] = value["manifests"][:1]
    mutations.append(("missing-incus-metadata-role", value))

    value = incus_vm_index()
    value["manifests"] = value["manifests"][1:]
    mutations.append(("missing-incus-disk-role", value))

    value = incus_vm_index(target="qemu")
    mutations.append(("wrong-incus-target", value))

    value = copy.deepcopy(alternatives)
    value["manifests"][1]["annotations"]["io.imgoci.content.digest"] = (
        "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    )
    mutations.append(("inconsistent-file-content", value))

    value = copy.deepcopy(alternatives)
    value["manifests"] = value["manifests"][:2]
    value["manifests"][1]["annotations"]["io.imgoci.role"] = "x-test-other"
    mutations.append(("duplicate-role-title", value))

    value = copy.deepcopy(alternatives)
    value["manifests"][1]["digest"] = value["manifests"][0]["digest"]
    mutations.append(("inconsistent-shared-manifest", value))

    value = copy.deepcopy(base)
    shared = copy.deepcopy(value["manifests"][0])
    shared["annotations"]["io.imgoci.architecture"] = "arm64"
    shared["artifactType"] = "application/vnd.bigoci.file.v1"
    value["manifests"].append(shared)
    mutations.append(("inconsistent-shared-artifact-type", value))

    value = copy.deepcopy(alternatives)
    value["manifests"].reverse()
    mutations.append(("noncanonical-order", value))

    value = copy.deepcopy(base)
    value["manifests"][0]["annotations"]["io.imgoci.architecture"] = "a" * 129 + "/v7"
    mutations.append(("overlong-architecture-token", value))

    value = copy.deepcopy(base)
    value["manifests"][0]["annotations"]["io.imgoci.content.size"] = "9223372036854775808"
    mutations.append(("oversized-content", value))

    value = copy.deepcopy(base)
    del value["manifests"][0]["artifactType"]
    mutations.append(("missing-artifact-type", value))

    value = copy.deepcopy(base)
    value["manifests"][0]["artifactType"] = "application"
    mutations.append(("malformed-artifact-type", value))

    value = copy.deepcopy(base)
    value["mediaType"] = "application/json"
    mutations.append(("wrong-index-media-type", value))

    value = copy.deepcopy(base)
    value["artifactType"] = "application/vnd.example.release.v1"
    mutations.append(("wrong-index-artifact-type", value))

    value = copy.deepcopy(base)
    value["manifests"][0]["mediaType"] = "application/json"
    mutations.append(("wrong-descriptor-media-type", value))

    return mutations


def check_fixture_matrix() -> None:
    """Exercise existing fixtures, focused failures, and exact accepted bounds."""

    accepted = (
        "valid-minimal",
        "resolve-compression-order",
        "invalid-noncanonical-json",
    )
    rejected = (
        "invalid-missing-annotation",
        "invalid-duplicate-tuple",
    )

    for case_id in accepted:
        result = cue_vet(CASES / case_id / "index.json")
        if result.returncode != 0:
            raise CheckFailure(f"CUE unexpectedly rejected {case_id}:\n{result.stderr}")

    for case_id in rejected:
        result = cue_vet(CASES / case_id / "index.json")
        if result.returncode == 0:
            raise CheckFailure(f"CUE unexpectedly accepted {case_id}")

    with tempfile.TemporaryDirectory(prefix="imgoci-cue-cases-") as directory:
        temporary = Path(directory)

        incus_vm = incus_vm_index()
        incus_vm_path = temporary / "accepted-incus-vm.json"
        write_index(incus_vm_path, incus_vm)
        result = cue_vet(incus_vm_path)
        if result.returncode != 0:
            raise CheckFailure(f"CUE unexpectedly rejected accepted Incus VM:\n{result.stderr}")

        bigoci = load_index("valid-minimal")
        bigoci["manifests"][0]["artifactType"] = "application/vnd.bigoci.file.v1"
        bigoci_path = temporary / "accepted-bigoci-file-manifest.json"
        write_index(bigoci_path, bigoci)
        result = cue_vet(bigoci_path)
        if result.returncode != 0:
            raise CheckFailure(
                f"CUE unexpectedly rejected accepted BigOCI file manifest:\n{result.stderr}"
            )

        unknown = load_index("valid-minimal")
        unknown["manifests"][0]["artifactType"] = "application/vnd.example.file.v1"
        unknown_path = temporary / "accepted-unknown-file-manifest.json"
        write_index(unknown_path, unknown)
        result = cue_vet(unknown_path)
        if result.returncode != 0:
            raise CheckFailure(
                f"CUE unexpectedly rejected unknown file manifest type:\n{result.stderr}"
            )

        unknown_annotations = load_index("valid-minimal")
        unknown_annotations["annotations"]["io.imgoci.future"] = "x"
        unknown_annotations["manifests"][0]["annotations"][
            "io.imgoci.file.manifest-type"
        ] = "application/vnd.imgoci.file.v1"
        unknown_annotations_path = temporary / "accepted-unknown-annotations.json"
        write_index(unknown_annotations_path, unknown_annotations)
        result = cue_vet(unknown_annotations_path)
        if result.returncode != 0:
            raise CheckFailure(
                f"CUE unexpectedly rejected unknown imgoci annotations:\n{result.stderr}"
            )

        media_type_case = load_index("valid-minimal")
        media_type_case["mediaType"] = "Application/Vnd.Oci.Image.Index.V1+Json"
        media_type_case["artifactType"] = "Application/Vnd.Imgoci.Release.V1"
        descriptor = media_type_case["manifests"][0]
        descriptor["mediaType"] = "Application/Vnd.Oci.Image.Manifest.V1+Json"
        descriptor["artifactType"] = "Application/Vnd.Imgoci.File.V1"
        shared = copy.deepcopy(descriptor)
        shared["annotations"]["io.imgoci.architecture"] = "arm64"
        shared["mediaType"] = "application/vnd.oci.image.manifest.v1+json"
        shared["artifactType"] = "application/vnd.imgoci.file.v1"
        media_type_case["manifests"].append(shared)
        media_type_case_path = temporary / "accepted-media-type-case.json"
        write_index(media_type_case_path, media_type_case)
        result = cue_vet(media_type_case_path)
        if result.returncode != 0:
            raise CheckFailure(
                f"CUE unexpectedly rejected case-insensitive media types:\n{result.stderr}"
            )

        for case_name, value in invalid_mutations():
            path = temporary / f"{case_name}.json"
            write_index(path, value)
            if cue_vet(path).returncode == 0:
                raise CheckFailure(f"CUE unexpectedly accepted {case_name}")

        boundary = load_index("valid-minimal")
        boundary["manifests"][0]["annotations"]["io.imgoci.architecture"] = (
            "a" * 128 + "/" + "b" * 128
        )
        boundary["manifests"][0]["annotations"]["io.imgoci.content.size"] = (
            "9223372036854775807"
        )
        boundary["annotations"]["org.example.note"] = "extension"
        boundary_path = temporary / "accepted-boundaries.json"
        write_index(boundary_path, boundary)
        result = cue_vet(boundary_path)
        if result.returncode != 0:
            raise CheckFailure(f"CUE unexpectedly rejected accepted boundaries:\n{result.stderr}")


def main() -> int:
    """Run the complete CUE enforcement surface."""

    if shutil.which("cue") is None:
        raise CheckFailure("cue is not on PATH; run `mise install`")

    check_cue_source()
    check_generated_schema()
    check_fixture_matrix()
    print("CUE schema, generated projection, and fixture matrix are valid")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except CheckFailure as error:
        print(error, file=sys.stderr)
        raise SystemExit(1) from None
