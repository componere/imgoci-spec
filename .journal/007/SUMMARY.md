---
id: 007
title: Public review interoperability fixes
date: 2026-08-11
status: complete
repos_touched: [imgoci-spec]
related_sessions: [005, 006]
---

## Goal

Apply the agreed correctness and interoperability changes from the public-readiness review. Keep the previously settled `artifactType`, Incus payload-inspection, compression, BigOCI, and conformance-harness decisions intact.

## Outcome

The goal was met. PR #11 aligned the normative specification, CUE schema, generated JSON Schema, canonical fixtures, tests, and supporting documentation. It passed focused, full, independent, and hosted validation and was squash-merged as `e90db17`. Local `master` was fast-forwarded to the merge, and the integrated feature worktree plus local and remote branches were removed. Post-merge Validate and Release Please workflows passed.

## Key Decisions

- Keep fixed root, descriptor, and standard-manifest member sets as producer rules. Consumers accept additional members for forward compatibility but retain them in canonical bytes and digest calculations.
- Apply an annotation's imgoci syntax and meaning only at the object location where imgoci defines it. The same key elsewhere is an opaque string for consumer validation.
- Replace the human-readable OCI title annotation with required `io.imgoci.filename`. Its syntax prevents path components but does not promise validity on every local filesystem.
- Require OCI Distribution `Accept` negotiation, response `Content-Type` and body `mediaType` agreement, exact manifest-byte digest and size checks, and conditional tag resolution.
- Require producers to label decoded content truthfully while keeping representation-internal format inspection outside imgoci validation and retrieval.
- Preserve the existing descriptor `artifactType`, Incus, compression framing, multipart BigOCI, and conformance-runner decisions.

## Changes

- `spec.md` - clarified producer and consumer member rules, annotation locations, filename semantics, representation-validation scope, OCI Distribution retrieval, and tag resolution.
- `schema/release-index-v1.cue` and generated `schema/release-index-v1.schema.json` - opened consumer root and descriptor shapes, constrained annotations by location, and required `io.imgoci.filename`.
- `scripts/check_cue.py` - added regression coverage for additional members, misplaced annotations, filename migration, and JSON Schema projection structure.
- `conformance/v1/cases/` - migrated canonical and noncanonical release-index fixtures to `io.imgoci.filename` without changing their intended outcomes.
- `README.md`, `schema/README.md`, and `CHANGELOG.md` - documented the new consumer, schema, retrieval, and payload-validation boundaries.

## Open Threads

- The broader conformance case metamodel and execution harness remain deferred for a future overhaul.
- Repeat the real Incus 7.0 import and launch proof before the first release.
- Release PR #3 remains open, mergeable, and green for `v0.1.0-draft.1`; its release decision is separate from this session.

## References

- [PR #11: fix(spec): align consumer interoperability rules](https://github.com/componere/imgoci-spec/pull/11)
- [Squash commit `e90db17`](https://github.com/componere/imgoci-spec/commit/e90db17a417a39a0ffe0f198555d2805d0c509ed)
- [PR-head validation](https://github.com/componere/imgoci-spec/actions/runs/31503212034)
- [Post-merge validation](https://github.com/componere/imgoci-spec/actions/runs/31504345762)
- [Post-merge Release Please](https://github.com/componere/imgoci-spec/actions/runs/31504345376)
- [Release PR #3](https://github.com/componere/imgoci-spec/pull/3)
- [Session 006](../006/SUMMARY.md)

## Lessons

- A broad CUE `[string]: string` pattern can collapse named annotation properties in generated JSON Schema. Complement patterns preserve location-defined properties, and a projection-shape assertion prevents silent recurrence.
- Consumer tolerance must distinguish ignored semantic meaning from exact-byte, digest, and canonical-encoding effects.
