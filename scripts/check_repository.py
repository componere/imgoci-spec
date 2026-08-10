#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.14,<3.15"
# dependencies = [
#   "check-jsonschema==0.38.0",
#   "jsonschema==4.25.1",
#   "rfc8785==0.1.4",
# ]
# ///
"""Validate repository metadata, conformance declarations, and local links."""

from __future__ import annotations

import json
import pathlib
import re
import shutil
import subprocess
import sys
import urllib.parse
from typing import Any

import rfc8785
from jsonschema import Draft202012Validator


ROOT = pathlib.Path(__file__).resolve().parents[1]
CORPUS_ROOT = ROOT / "conformance" / "v1"


class CheckFailure(RuntimeError):
    """Report an actionable validation failure without a Python traceback."""


def run(command: list[str]) -> None:
    """Run one metadata validator from the repository root."""

    result = subprocess.run(command, cwd=ROOT, check=False)
    if result.returncode != 0:
        raise CheckFailure(f"command failed: {' '.join(command)}")


def relative_strings(paths: list[pathlib.Path]) -> list[str]:
    """Return stable repository-relative arguments for external validators."""

    return [str(path.relative_to(ROOT)) for path in sorted(paths)]


def check_metadata_schemas() -> None:
    """Validate workflows, issue forms, JSON Schemas, and case metadata."""

    if shutil.which("check-jsonschema") is None:
        raise CheckFailure("check-jsonschema is missing from the uv script environment")

    workflows = relative_strings(list((ROOT / ".github" / "workflows").glob("*.yml")))
    issue_forms = relative_strings(list((ROOT / ".github" / "ISSUE_TEMPLATE").glob("*.yml")))
    case_metadata = relative_strings(list((CORPUS_ROOT / "cases").glob("*/case.json")))
    if not workflows or not issue_forms or not case_metadata:
        raise CheckFailure("workflow, issue-form, and case-metadata inputs must not be empty")

    run(["check-jsonschema", "--builtin-schema", "vendor.github-workflows", *workflows])
    run(["check-jsonschema", "--builtin-schema", "vendor.github-issue-forms", *issue_forms])
    run(
        [
            "check-jsonschema",
            "--check-metaschema",
            "schema/release-index-v1.schema.json",
            "conformance/case.schema.json",
        ]
    )
    run(
        [
            "check-jsonschema",
            "--schemafile",
            "conformance/case.schema.json",
            *case_metadata,
        ]
    )


def load_json(path: pathlib.Path) -> Any:
    """Load UTF-8 JSON from a repository path."""

    return json.loads(path.read_text(encoding="utf-8"))


def confined_path(base: pathlib.Path, relative: str, *, label: str) -> pathlib.Path:
    """Resolve a fixture path and reject traversal outside its allowed root."""

    path = (base / relative).resolve()
    try:
        path.relative_to(base.resolve())
    except ValueError as error:
        raise CheckFailure(f"{label} escapes {base}: {relative}") from error
    return path


def check_corpus() -> int:
    """Validate corpus inventory, declarations, parsed values, and exact bytes."""

    inventory_path = CORPUS_ROOT / "cases.json"
    inventory = load_json(inventory_path)
    if set(inventory) != {"cases"}:
        raise CheckFailure("conformance/v1/cases.json must contain only 'cases'")

    listed = inventory["cases"]
    if not isinstance(listed, list) or not listed:
        raise CheckFailure("conformance/v1/cases.json must list at least one case")
    if listed != sorted(listed):
        raise CheckFailure("case inventory must be sorted")
    if len(listed) != len(set(listed)):
        raise CheckFailure("case inventory contains duplicate paths")

    actual = sorted(
        str(path.relative_to(CORPUS_ROOT))
        for path in CORPUS_ROOT.glob("cases/*/case.json")
    )
    if listed != actual:
        raise CheckFailure(
            f"case inventory differs from case directories: listed={listed!r} actual={actual!r}"
        )

    case_schema = load_json(ROOT / "conformance" / "case.schema.json")
    index_schema = load_json(ROOT / "schema" / "release-index-v1.schema.json")
    case_validator = Draft202012Validator(case_schema)
    index_validator = Draft202012Validator(index_schema)

    section_pattern = re.compile(r"^#{2,6} ([0-9]+(?:\.[0-9]+)*)\b", re.MULTILINE)
    spec_sections = set(section_pattern.findall((ROOT / "spec.md").read_text(encoding="utf-8")))

    seen_ids: set[str] = set()
    for relative_case in listed:
        case_path = confined_path(CORPUS_ROOT, relative_case, label="case path")
        if not case_path.is_file():
            raise CheckFailure(f"missing case metadata: {relative_case}")

        case = load_json(case_path)
        case_validator.validate(case)

        case_id = case["id"]
        if case_id in seen_ids:
            raise CheckFailure(f"duplicate case id: {case_id}")
        seen_ids.add(case_id)
        if case_path.parent.name != case_id:
            raise CheckFailure(f"case directory must match id: {relative_case}")

        for reference in case["references"]:
            if reference["section"] not in spec_sections:
                raise CheckFailure(
                    f"{case_id} references missing section {reference['section']}"
                )

        index_path = confined_path(
            case_path.parent,
            case["input"]["index"],
            label=f"{case_id} index path",
        )
        raw_index = index_path.read_bytes()
        parsed_index = json.loads(raw_index)

        schema_valid = not list(index_validator.iter_errors(parsed_index))
        if schema_valid != case["expected"]["schemaValid"]:
            raise CheckFailure(f"{case_id} schema validity differs from expected metadata")

        canonical_json = raw_index == rfc8785.dumps(parsed_index)
        if canonical_json != case["expected"]["canonicalJson"]:
            raise CheckFailure(f"{case_id} canonical JSON state differs from expected metadata")

        result_name = case["expected"].get("result")
        if result_name is not None:
            result_path = confined_path(
                case_path.parent,
                result_name,
                label=f"{case_id} result path",
            )
            load_json(result_path)

    return len(listed)


def markdown_files() -> list[pathlib.Path]:
    """List tracked and non-ignored untracked Markdown without entering worktrees."""

    result = subprocess.run(
        ["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )
    return sorted(
        ROOT / pathlib.Path(raw.decode())
        for raw in result.stdout.split(b"\0")
        if raw and raw.decode().endswith(".md")
    )


def prose_without_code(document: pathlib.Path) -> str:
    """Remove fenced blocks and inline code before scanning Markdown links."""

    prose: list[str] = []
    fence: str | None = None
    for line in document.read_text(encoding="utf-8").splitlines():
        stripped = line.lstrip()
        if fence is not None:
            if stripped.startswith(fence):
                fence = None
            continue
        if stripped.startswith("~~~"):
            fence = "~~~"
            continue
        if stripped.startswith("```"):
            fence = "```"
            continue
        prose.append(line)
    return re.sub(r"`[^`]*`", "", "\n".join(prose))


def check_local_links() -> None:
    """Reject local Markdown links that escape the repository or target no file."""

    link_pattern = re.compile(r"(?<!!)\[[^\]]+\]\(([^)]+)\)")
    errors: list[str] = []

    for document in markdown_files():
        for target in link_pattern.findall(prose_without_code(document)):
            target = target.strip().strip("<>")
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            path_text = urllib.parse.unquote(target.split("#", 1)[0])
            if not path_text:
                continue
            resolved = (document.parent / path_text).resolve()
            try:
                resolved.relative_to(ROOT)
            except ValueError:
                errors.append(
                    f"{document.relative_to(ROOT)}: path escapes repository: {target}"
                )
                continue
            if not resolved.exists():
                errors.append(
                    f"{document.relative_to(ROOT)}: missing link target: {target}"
                )

    if errors:
        raise CheckFailure("\n".join(errors))


def main() -> int:
    """Run the complete repository enforcement surface."""

    check_metadata_schemas()
    case_count = check_corpus()
    check_local_links()
    print(f"repository metadata, {case_count} conformance cases, and local links are valid")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except CheckFailure as error:
        print(error, file=sys.stderr)
        raise SystemExit(1) from None
