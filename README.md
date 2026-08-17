# imgoci

imgoci is a format for publishing operating-system images in an OCI registry.
One release is one OCI image index. Each descriptor in that index says what its
file is: the CPU architecture, the environment it was built for, the form it
takes, what it can be used for, its role in the deliverable, and how it is
compressed. A consumer reads the index, picks the files it wants, fetches only
those, and checks the decoded bytes against the digest and size the producer
declared.

The specification is a draft. [`spec.md`](spec.md) is the normative document.

## The problem

An OS product does not ship one artifact. It ships a matrix: qcow2 disks for
QEMU, raw disks for cloud imports, ISOs for installers, kernel and initramfs
pairs for network boot, split metadata and disk pairs for Incus, each per
architecture, often in several compressions. Those files are usually served
from a directory tree over HTTP and described, if at all, by an
ecosystem-specific catalog or by convention in the filenames. Consumers end up
parsing names, hardcoding paths, and verifying checksums out of band.

OCI registries already solve the storage half of that problem: content
addressing, digests, mirroring, garbage collection, and authentication. What
OCI does not define is which file is which. An OCI image index describes
container images, and its `platform` object carries only OS and architecture.
Nothing in it separates a qcow2 built for QEMU from a raw disk built for AWS,
a live ISO from an offline installer ISO, marks a kernel as belonging with a
specific initramfs, or says that the zstd and xz entries are two encodings of
the same content.

imgoci defines that description layer and stops there. It adds an
`artifactType` and a fixed set of annotations to an ordinary OCI image index,
so an OS release can be stored, mirrored, and pulled by digest through the
registry a project already runs.

## What a release looks like

```text
release tag or digest
        |
        v
OCI image index
artifactType: application/vnd.imgoci.release.v1
        |
        +-- one descriptor for each transport alternative
                    |
                    v
             file manifest
                    |
                    +-- standard imgoci v1: one file layer
                    |
                    +-- BigOCI v1: two or more ordered parts
```

A release index with a single entry, pretty-printed, with placeholder digests:

```json
{
  "annotations": {
    "io.imgoci.name": "exampleos",
    "org.opencontainers.image.version": "42.1"
  },
  "artifactType": "application/vnd.imgoci.release.v1",
  "manifests": [
    {
      "annotations": {
        "io.imgoci.architecture": "amd64",
        "io.imgoci.compression": "xz",
        "io.imgoci.content.digest": "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        "io.imgoci.content.size": "8589934592",
        "io.imgoci.filename": "exampleos-42.1.qcow2",
        "io.imgoci.representation": "qcow2",
        "io.imgoci.role": "disk",
        "io.imgoci.target": "qemu"
      },
      "artifactType": "application/vnd.imgoci.file.v1",
      "digest": "sha256:1111111111111111111111111111111111111111111111111111111111111111",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "size": 427
    }
  ],
  "mediaType": "application/vnd.oci.image.index.v1+json",
  "schemaVersion": 2
}
```

Five annotations do the addressing work:

| Annotation | Answers | Examples |
|---|---|---|
| `io.imgoci.architecture` | Which CPU instruction set the files need | `amd64`, `arm64`, `arm/v7` |
| `io.imgoci.target` | Which boot or import environment they were built for | `qemu`, `aws`, `metal`, `incus` |
| `io.imgoci.representation` | Which form they take | `qcow2`, `raw`, `iso`, `linux-netboot`, `incus-vm` |
| `io.imgoci.usage` | What the deliverable can do | `live`, `install`, `install-offline` |
| `io.imgoci.role` | Which file this is within the deliverable | `disk`, `kernel`, `initramfs`, `metadata`, `rootfs` |

The first four identify a deliverable; the fifth identifies one file inside it.
`io.imgoci.usage` is the only optional one. Its value is a comma-separated set
in byte order, and omitting the annotation means the empty set, as in the
example above. It is what separates a live ISO from an offline installer ISO
that is otherwise identical, and `install-offline` requires `install` in the
same set. Usage values are producer assertions: imgoci verifies their syntax
and set relationships, not that the deliverable behaves that way.

Entries that agree on all five are the same file stored differently, and
`io.imgoci.compression` distinguishes them. Every one of those alternatives
declares the same `io.imgoci.content.digest` and `io.imgoci.content.size`,
because they decode to identical bytes.

The default file manifest holds the complete stored file as one OCI blob.
BigOCI is the optional multipart fallback for files that a repository or
delivery path cannot carry reliably as a single blob. The descriptor's
`artifactType` names the layout up front, so a consumer can rule out an
alternative it cannot read without fetching it.

More examples, including `linux-netboot` and `incus-vm` deliverables and
usage-set variants, are in [`conformance/v1/pass`](conformance/v1/pass).

## What a consumer does

1. Fetch the release by tag or digest and validate the whole index before
   selecting anything.
2. List deliverables with any subset of architecture, target, representation,
   usage values, and roles. A deliverable matches a usage or role filter only
   if it contains every requested value. The result reports every match with
   its exact usage set, roles, compressions, and file-manifest types, in a
   defined sort order.
3. Resolve one deliverable by exact architecture, target, representation, and
   complete usage set, plus the compressions the consumer can decode. Usage
   matching here is set equality, not containment, and the requested set may be
   empty. Resolution drops unsupported manifest layouts, then takes the first
   accepted compression per role. It returns a complete set of roles or fails;
   there are no partial results and no post-fetch fallback.
4. Retrieve each selected file manifest by digest, decode the stored file, and
   verify the decoded content against the declared digest and size.

Selection is defined by exact value comparison. There are no wildcards, and a
consumer accepts unknown annotation keys and unknown selector values rather
than rejecting the release.

## What imgoci does not define

- signature, attestation, trust policy, or key formats; another OCI artifact
  may reference a release-index digest as its subject
- tag discovery, version ordering, or channels
- image conversion, or the implementation of installation or boot behavior;
  `io.imgoci.usage` records what a deliverable can do, not how it does it
- internal structure of decoded content beyond each representation's stated
  form
- an index that groups several releases, or an adapter that makes an existing
  catalog reader understand imgoci objects

## Repository contents

| Path | What it is |
|---|---|
| [`spec.md`](spec.md) | The format and its required behavior. Sole normative authority. |
| [`schema/release-index-v1.cue`](schema/release-index-v1.cue) | Canonical machine-readable schema for parsed release-index values. |
| [`schema/release-index-v1.schema.json`](schema/release-index-v1.schema.json) | Generated, best-effort JSON Schema compatibility layer. |
| [`conformance/`](conformance/) | Complete release indexes that the CUE schema must accept ([`v1/pass`](conformance/v1/pass)) or reject ([`v1/fail`](conformance/v1/fail)). Informative. |
| [`RELEASES.md`](RELEASES.md) | Publication mechanics. |
| [`CHANGELOG.md`](CHANGELOG.md) | Changes to published artifacts. |
| [`GOVERNANCE.md`](GOVERNANCE.md) | Decision making and the public-value registry policy. |

The CUE schema controls when it and the generated JSON Schema differ. If the
specification, CUE schema, conformance cases, or implementation behavior
disagree, `spec.md` controls. A disagreement is a defect to correct in a later
repository revision; it does not transfer authority to another artifact.

Passing CUE or JSON Schema validation alone does not establish conformance.
The schemas model rules that a consumer can apply to a parsed release index.
Producer-only fixed member sets, registry, namespace, and lowercase media-type
spelling rules remain in `spec.md`, as do rules that depend on exact encoded
bytes, referenced objects, selection, or retrieval. CUE checks more
relationships between file entries than JSON Schema.

## Validation

Tool versions are pinned for local and CI use in `mise.toml` and `mise.lock`.
After cloning the repository or creating a worktree, run:

```sh
mise trust --all
mise install
mise exec -- moon run root:cue --summary minimal
```

Moon checks CUE formatting and module state, validates every passing and failing
fixture, and verifies that the generated JSON Schema is current. CI installs the
same locked tools and runs the same Moon task.

## Implementation

The canonical Go implementation is under development and is not yet public.
The specification repository does not depend on, execute, or generate normative
material from that implementation.

## Contributing

The format is a draft, so changes to normative text are still on the table.
Useful contributions include implementation reports, review of `spec.md`
against a real publishing or consuming workflow, new conformance fixtures, and
proposals for public target, representation, usage, role, or compression
values.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for issue and pull-request guidance.
[`GOVERNANCE.md`](GOVERNANCE.md) defines project decision making and the
procedure a new public selector value must follow. Participation is covered by
the [`Code of Conduct`](CODE_OF_CONDUCT.md). Report security vulnerabilities
according to [`SECURITY.md`](SECURITY.md).

## License

The specification text ([`spec.md`](spec.md) and its addenda) is licensed
under the Community Specification License 1.0
([`LICENSE-COMMUNITY-SPEC`](LICENSE-COMMUNITY-SPEC)).

All other repository content, including the schema, conformance corpus,
scripts, and documentation, is licensed under either of

- Apache License, Version 2.0 ([`LICENSE-APACHE`](LICENSE-APACHE)); or
- MIT License ([`LICENSE-MIT`](LICENSE-MIT))

at your option.

Unless explicitly stated otherwise, contributions intentionally submitted for
inclusion in this work are licensed under the same split: specification-text
contributions under the Community Specification License 1.0, and all other
contributions dual licensed Apache-2.0 OR MIT.
