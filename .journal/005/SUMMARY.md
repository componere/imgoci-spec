---
id: 005
title: OCI-native file manifest type descriptors
date: 2026-08-10
status: complete
repos_touched: [imgoci-spec]
related_sessions: [004]
---

## Goal
Replace the private `io.imgoci.file.manifest-type` annotation with OCI descriptor `artifactType` across the normative specification and machine-readable artifacts, validate the migration, and land it for review.

## Outcome
The goal was met. PR #9 replaced the private annotation with required OCI descriptor `artifactType`, retained pre-fetch capability filtering and retrieval-time equality checks, and updated the CUE schema, generated JSON Schema, fixtures, conformance metadata, and documentation. The PR passed local and hosted validation and was squash-merged as `84371bd`; post-merge validation and Release Please also passed.

## Key Decisions
- Use the standard OCI descriptor field as the single authority for the referenced manifest's type instead of duplicating it in an imgoci annotation. This improves interoperability with generic registry and artifact tooling without changing selection determinism.
- Define a file-entry descriptor's `artifactType` as exactly equal to the referenced manifest's required top-level `artifactType`, following the OCI Distribution manifest-type convention used by referrers tooling.
- Do not fall back to the referenced manifest's config media type. Both supported file layouts require a top-level `artifactType`, so fallback would make the contract ambiguous.
- Preserve the existing behavior: broad discovery accepts unknown syntactically valid types, capability filtering occurs before compression preference, and retrieval fails the complete result if the fetched manifest does not match its descriptor.
- Reject the retired `io.imgoci.file.manifest-type` annotation through the reserved imgoci annotation namespace rather than supporting two representations.

## Changes
- `spec.md`, `README.md`, and `CHANGELOG.md` - replaced the annotation contract, documented the OCI interoperability rationale, and updated selection, retrieval, and examples.
- `schema/release-index-v1.cue`, generated `schema/release-index-v1.schema.json`, and `schema/README.md` - required descriptor `artifactType`, retained media-type syntax and same-digest consistency checks, and removed the annotation.
- `conformance/` - migrated exact-byte fixtures and resolve-case metadata to descriptor `artifactType`.
- `scripts/check_cue.py` - migrated accepted and rejected mutations and added explicit rejection coverage for the retired annotation.

## Open Threads
- Downstream producer and consumer implementations must emit and read descriptor `artifactType` before the first draft release.

## References
- [PR #9: feat(spec): use OCI descriptor artifact types](https://github.com/componere/imgoci-spec/pull/9)
- [Squash commit `84371bd`](https://github.com/componere/imgoci-spec/commit/84371bdeddd3707f649fc6a2e91c514391e6574d)
- [Post-merge validation](https://github.com/componere/imgoci-spec/actions/runs/31456423447)
- [Post-merge Release Please run](https://github.com/componere/imgoci-spec/actions/runs/31456423446)
- [Session 004](../004/SUMMARY.md)

## Lessons
- OCI Image Specification descriptor wording and the OCI Distribution referrers convention leave an ecosystem seam around manifest type. Aligning with established distribution tooling is the more universal choice, but the specification needs to state that interpretation explicitly.
