# Governance

This document defines who decides what in the imgoci specification project and
how the public-value registry in `spec.md` section 5.4 grows. It is an
informative project document. It does not change the authority order in
[`README.md`](README.md).

## Working group

The imgoci specification project, meaning this repository and its maintainers,
is the Working Group for the purposes of the Community Specification License
1.0 ([`LICENSE-COMMUNITY-SPEC`](LICENSE-COMMUNITY-SPEC)). The Working Group's
scope is the imgoci release format: the specification in
[`spec.md`](spec.md), its addenda, and its language-neutral validation
artifacts.

## Effective date

The licensing terms in this document apply immediately on merge, including
the Community Specification License terms for specification contributions.

The process rules take effect at the project's first publication: the first
tag created by the release process in [`RELEASES.md`](RELEASES.md). Until
that publication, the maintainer may change any repository content, including
the specification and this document, through ordinary pull requests without
the review windows and registry procedure below. Changes merged during this
bootstrap period are recorded in history like any other change.

## Licensing

| Artifact | License |
|---|---|
| `spec.md` and its addenda | Community Specification License 1.0 |
| All other repository content (schema, conformance corpus, scripts, documentation, automation) | Apache-2.0 OR MIT, at your option |

The specification text uses the Community Specification License because
implementers need patent commitments from specification contributors, and code
licenses do not clearly provide them for independent implementations. The
machine-readable artifacts stay dual licensed so implementations can copy them
into a codebase under either license.

Contributions follow the same split. A contribution to `spec.md` or an
addendum is made under the Community Specification License 1.0. A contribution
to any other artifact is dual licensed Apache-2.0 OR MIT.

## Deliverable status

Under the Community Specification License:

- a `draft.N` prerelease publication (see [`RELEASES.md`](RELEASES.md)) is a
  Draft Deliverable; and
- a stable, non-prerelease publication is an Approved Deliverable.

Approval happens through the release process in `RELEASES.md` and is decided
by the maintainers.

## Patent exclusion notices

The Community Specification License defines a process for excluding
identified patent claims from a contributor's licensing commitment. File a
notice by opening a public issue and a pull request that records the notice in
this section within the window the License defines.

No patent exclusion notices have been filed.

## Maintainers

Maintainers steward the specification.

| Maintainer | GitHub |
|---|---|
| Joshua Gilman | [@jmgilman](https://github.com/jmgilman) |

The project currently has one maintainer. The rules below state that plainly
and define, in advance, how they change as the project grows.

## Decision making

- Anyone may open issues and pull requests. Decisions are made in public, in
  issues and pull requests. There is no private decision channel.
- A change is non-trivial when it changes normative text, the canonical
  schema, or this document. Editorial and process changes are trivial unless a
  maintainer says otherwise.
- While the project has one maintainer, that maintainer decides. A
  non-trivial change must stay open for review for at least 14 calendar days
  before it merges, so the public record carries the change and its
  discussion. Trivial changes may merge without a waiting period.
- Once the project has two or more maintainers, a non-trivial change also
  requires approval from at least one maintainer who is not the author.
  Maintainers decide by consensus. When consensus is unclear, a simple
  majority of maintainers decides.

## Becoming a maintainer

A contributor becomes a maintainer by invitation after:

- three or more merged substantive contributions (normative text, schema, or
  conformance);
- sustained review participation over at least three months; and
- agreement of all current maintainers.

These criteria are published in advance so the first outside contributors
know the path before they arrive.

## Stepping down and removal

A maintainer may step down at any time. The remaining maintainers may move a
maintainer who has been inactive for twelve months to emeritus status.
Removal for cause, including Code of Conduct violations, requires agreement
of all other maintainers.

## Public-value registry

`spec.md` section 5.4 defines the public selector values: targets,
representations, roles, and compression values. The registry grows by
addendum under this policy, which follows the specification-required model of
[RFC 8126](https://www.rfc-editor.org/rfc/rfc8126.html).

A proposal uses the public-value issue form and must show:

1. **Syntax.** The value follows the token rules in `spec.md` section 5.3.
2. **Distinctness.** The value is not a synonym of an existing public value.
3. **Definition.**
   - A target names an environment family and identifies a boot or import
     difference that architecture and representation do not express.
   - A representation defines its decoded form with a stable, publicly
     available normative reference, and its exact role set.
   - A role defines the purpose of one file in a deliverable.
   - A compression value defines its decoder with a normative reference.
4. **Use.** At least one producer publishes, or concretely intends to
   publish, deliverables using the value.

The maintainers act as the designated experts. An accepted value lands as a
compatible addendum through a normal pull request and release. Public values
are append-only; a published meaning never changes (`spec.md` section 5.3).

A rejected proposal is closed with the reason recorded in the issue. A
producer may use an `x-<owner>-<name>` value without any proposal.

## Changing this document

Governance changes use ordinary pull requests and the review rules for
non-trivial changes.

## Relocation

The specification's identity is its name and version, not its hosting. If the
project later moves to neutral hosting or a foundation, the version history,
numbering, and this governance record move with it, and the old location
redirects.
