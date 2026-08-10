# imgoci specification

This repository contains the imgoci release format specification and its
language-neutral validation artifacts. The format describes releases of OS
image files stored in an OCI repository.

The specification is currently a draft.

## Authority

| Artifact | Status |
|---|---|
| [`spec.md`](spec.md) | Sole normative authority for the imgoci format. |
| [`schema/`](schema/) | Official, informative structural-validation aid. |
| [`conformance/`](conformance/) | Official, informative examples and test cases derived from the specification. |
| Repository documentation and automation | Informative project process and publication support. |

If the specification, JSON Schema, conformance cases, or implementation
behavior disagree, `spec.md` controls. A disagreement is a defect to correct
in a later repository revision; it does not transfer authority to another
artifact.

## Repository contents

- [`spec.md`](spec.md) defines the format and required behavior.
- [`schema/release-index-v1.schema.json`](schema/release-index-v1.schema.json)
  checks release-index structure and local field syntax.
- [`conformance/v1/cases.json`](conformance/v1/cases.json) inventories the
  initial language-neutral conformance cases.
- [`RELEASES.md`](RELEASES.md) describes publication mechanics.
- [`CHANGELOG.md`](CHANGELOG.md) records changes to published artifacts.

Passing JSON Schema validation alone does not establish conformance. Rules
that depend on relationships between entries, exact encoded bytes, selection,
retrieval, or BigOCI remain defined by `spec.md` and may be exercised by the
conformance corpus.

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
