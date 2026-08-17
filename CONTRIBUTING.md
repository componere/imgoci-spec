# Contributing

Contributions should keep [`spec.md`](spec.md) as the sole source of normative
requirements. The CUE schema is the canonical machine-readable schema derived
from those requirements. The generated JSON Schema is a best-effort
compatibility layer. Conformance cases, examples, and repository tooling must
also be derived from the specification and must not introduce requirements of
their own.

Security vulnerabilities must be reported privately according to
[`SECURITY.md`](SECURITY.md), not through public issues or pull requests.

Project decision making, review rules, and the public-value registry policy
are defined in [`GOVERNANCE.md`](GOVERNANCE.md). Participation is covered by
the [Code of Conduct](CODE_OF_CONDUCT.md).

Licensing is split by artifact: contributions to `spec.md` or an addendum are
made under the Community Specification License 1.0
([`LICENSE-COMMUNITY-SPEC`](LICENSE-COMMUNITY-SPEC)); contributions to every
other artifact are dual licensed Apache-2.0 OR MIT.

## Conventional Commits

Use the `type(scope): subject` format for pull request titles. Pull requests are
squash-merged, so the pull request title becomes the commit subject.

Release Please groups these types in `CHANGELOG.md`:

| Type | Changelog section |
|---|---|
| `feat` | Changes |
| `fix` | Fixes |
| `refactor` | Changes |
| `docs` | Documentation |
| `revert` | Reverts |

Changes with the `ci` and `chore` types are not included in the changelog.

## Reporting a specification defect

Use the specification-defect issue form for contradictory text, ambiguity,
incorrect references, or a mismatch between `spec.md` and an informative
artifact. Identify the affected section and explain the interoperability or
implementation impact.

## Proposing a specification change

Use the specification-change issue form for new or changed normative behavior.
Describe the use case, the affected sections, alternatives, and compatibility
impact before preparing a large change.

## Proposing a public selector value

Use the public-value issue form to propose a new target, representation,
usage, role, or compression value for the section 5.4 registry. The acceptance
criteria are in [`GOVERNANCE.md`](GOVERNANCE.md). Private `x-<owner>-<name>`
values need no proposal.

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
2. Leave changes to normative text, the canonical schema, or governance open
   for the public review window defined in
   [`GOVERNANCE.md`](GOVERNANCE.md).
3. Run `mise trust --all`, then install the locked toolchain with
   `mise install`.
4. Run `mise exec -- moon run root:cue --summary minimal` from the repository
   root. This checks CUE formatting and module state, validates every passing
   and failing fixture, and detects generated-schema drift.
5. When intentionally changing the CUE projection, regenerate
   `release-index-v1.schema.json` as described in
   [`schema/README.md`](schema/README.md).
6. Add a complete release index under `conformance/v1/pass` or
   `conformance/v1/fail` when changing parsed-value validation behavior.
7. Do not edit [`CHANGELOG.md`](CHANGELOG.md) manually. Release Please
   generates it from commit subjects, so write an accurate pull request title.
8. Ensure the CUE validation workflow passes.

Do not copy implementation-specific APIs, error strings, or Go data structures
into the specification artifacts. Conformance expectations should be stated in
language-neutral terms.
