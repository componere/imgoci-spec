# Contributing

Contributions should keep [`spec.md`](spec.md) as the sole source of normative
requirements. The CUE schema is the canonical machine-readable schema derived
from those requirements. The generated JSON Schema is a best-effort
compatibility layer. Conformance cases, examples, and repository tooling must
also be derived from the specification and must not introduce requirements of
their own.

Security vulnerabilities must be reported privately according to
[`SECURITY.md`](SECURITY.md), not through public issues or pull requests.

## Reporting a specification defect

Use the specification-defect issue form for contradictory text, ambiguity,
incorrect references, or a mismatch between `spec.md` and an informative
artifact. Identify the affected section and explain the interoperability or
implementation impact.

## Proposing a specification change

Use the specification-change issue form for new or changed normative behavior.
Describe the use case, the affected sections, alternatives, and compatibility
impact before preparing a large change.

## Pull requests

Keep each pull request focused and classify it as one or more of:

- editorial changes to `spec.md` that do not change requirements;
- normative changes to `spec.md`;
- canonical CUE schema, generated JSON Schema, or conformance changes derived
  from existing text; or
- repository process and automation changes.

When a pull request changes normative text, update any affected informative
artifacts in the same change or explain why no update is required. When an
informative artifact changes, cite the specification sections from which the
change is derived.

Before requesting review:

1. Confirm that no normative requirement exists only outside `spec.md`.
2. Run `mise trust --all`, then install the locked toolchain with
   `mise install`.
3. Run `mise exec -- moon run root:check --summary minimal` from the repository
   root. This includes CUE formatting and validation, generated-schema drift,
   repository metadata, conformance declarations, exact fixture bytes, and
   local links.
4. When intentionally changing the CUE projection, regenerate
   `release-index-v1.schema.json` as described in
   [`schema/README.md`](schema/README.md).
5. Preserve exact bytes in cases that test canonical encoding.
6. Update [`CHANGELOG.md`](CHANGELOG.md) when the change will affect a
   publication.
7. Ensure the repository validation workflow passes.

Do not copy implementation-specific APIs, error strings, or Go data structures
into the specification artifacts. Conformance expectations should be stated in
language-neutral terms.
