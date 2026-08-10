# JSON Schema

`release-index-v1.schema.json` is an official, informative validation aid for
the imgoci release-index structure. The normative requirements are defined by
[`spec.md`](../spec.md) in the same repository revision. If the schema and
specification differ, the specification controls.

The schema checks the closed release-index and descriptor shapes, required
annotations, fixed media types, and most local lexical constraints defined in
Sections 4 and 5. Passing schema validation does not establish imgoci
conformance.

Full validation also requires requirements that cannot be represented by this
schema, including:

- OCI requirements incorporated by the specification;
- the exact numeric bounds for string-encoded content size;
- the per-token length bound for slash-separated architectures;
- selector registry and private-name rules;
- required roles and other relationships between entries;
- descriptor order and RFC 8785 canonical bytes;
- BigOCI validation and same-repository requirements; and
- discovery, selection, retrieval, decoding, and verification behavior.

The schema deliberately does not enumerate targets, representations, roles, or
compression values. An imgoci consumer validates selector syntax rather than
using the public-value registry as an allowlist.

The schema uses JSON Schema Draft 2020-12. It is released with the specification
and conformance corpus and has no independent release version. The `v1`
filename corresponds to the imgoci v1 format. Retrieve it from an immutable
imgoci-spec release when reproducibility matters.

This schema is maintained in imgoci-spec. It is not generated from the Go
implementation.
