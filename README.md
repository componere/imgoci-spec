# imgoci specification

This repository contains the imgoci release format specification and its
language-neutral validation artifacts. The format describes releases of OS
image files stored in an OCI repository.

The specification is currently a draft.

## Authority

| Artifact | Status |
|---|---|
| [`spec.md`](spec.md) | Sole normative authority for the imgoci format. |
| [`schema/release-index-v1.cue`](schema/release-index-v1.cue) | Canonical machine-readable schema for parsed release-index values. |
| [`schema/release-index-v1.schema.json`](schema/release-index-v1.schema.json) | Generated, best-effort JSON Schema compatibility layer. |
| [`conformance/`](conformance/) | Official, informative examples and test cases derived from the specification. |
| Repository documentation and automation | Informative project process and publication support. |

The CUE schema controls when it and the generated JSON Schema differ. If the
specification, CUE schema, conformance cases, or implementation behavior
disagree, `spec.md` controls. A disagreement is a defect to correct in a later
repository revision; it does not transfer authority to another artifact.

## Repository contents

- [`spec.md`](spec.md) defines the format and required behavior.
- [`schema/release-index-v1.cue`](schema/release-index-v1.cue) defines the
  canonical machine-readable constraints for a parsed release index.
- [`schema/release-index-v1.schema.json`](schema/release-index-v1.schema.json)
  provides generated compatibility for JSON Schema consumers.
- [`conformance/v1/cases.json`](conformance/v1/cases.json) inventories the
  initial language-neutral conformance cases.
- [`RELEASES.md`](RELEASES.md) describes publication mechanics.
- [`CHANGELOG.md`](CHANGELOG.md) records changes to published artifacts.

Passing CUE or JSON Schema validation alone does not establish conformance.
CUE checks more relationships between file entries than JSON Schema. Rules
that depend on exact encoded bytes, selection, retrieval, or BigOCI remain
defined by `spec.md` and may be exercised by the conformance corpus.

## Validation

Tool versions are pinned for local and CI use in `mise.toml` and `mise.lock`.
After cloning the repository or creating a worktree, run:

```sh
mise trust --all
mise install
mise exec -- moon run root:check --summary minimal
```

Moon runs the CUE checks, verifies that the generated JSON Schema is current,
and validates repository metadata, conformance declarations, canonical fixture
bytes, and local documentation links. CI installs the same locked tools and
runs the same Moon tasks.

## Implementation

[`componere/imgoci`](https://github.com/componere/imgoci) is the canonical Go
implementation. The specification repository does not depend on, execute, or
generate normative material from that implementation.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for issue and pull-request guidance.
Report security vulnerabilities according to [`SECURITY.md`](SECURITY.md).

## License

Licensed under either of

- Apache License, Version 2.0 ([`LICENSE-APACHE`](LICENSE-APACHE)); or
- MIT License ([`LICENSE-MIT`](LICENSE-MIT))

at your option.

Unless explicitly stated otherwise, contributions intentionally submitted for
inclusion in this work are dual licensed under the same terms.
