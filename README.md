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
- [`conformance/v1/pass`](conformance/v1/pass) and
  [`conformance/v1/fail`](conformance/v1/fail) contain complete release indexes
  that CUE must accept or reject.
- [`RELEASES.md`](RELEASES.md) describes publication mechanics.
- [`CHANGELOG.md`](CHANGELOG.md) records changes to published artifacts.

Passing CUE or JSON Schema validation alone does not establish conformance.
The schemas model rules that a consumer can apply to a parsed release index.
They do not establish producer conformance. Producer-only fixed member sets,
registry, namespace, and lowercase media-type spelling rules remain in
`spec.md`.

CUE checks more relationships between file entries than JSON Schema. Rules
that depend on exact encoded bytes, referenced objects, selection, or retrieval
remain defined by `spec.md` and may be exercised by the conformance corpus.

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

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for issue and pull-request guidance.
[`GOVERNANCE.md`](GOVERNANCE.md) defines project decision making and the
public-value registry policy. Participation is covered by the
[`Code of Conduct`](CODE_OF_CONDUCT.md). Report security vulnerabilities
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
