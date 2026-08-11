---
id: 007
title: Public review interoperability fixes
started: 2026-08-11
---

## 2026-08-11 07:30 — Kickoff

Goal for the session: Apply the agreed specification, schema, and retrieval fixes from the public-readiness review, validate them, and open a pull request.

Current state of the world: Sessions 001–006 are complete. Clean `master` and `origin/master` are at `cf2c181`. The agreed scope is five changes and preserves prior decisions about `artifactType`, Incus payload inspection, and conformance-corpus automation.

Plan: Create an isolated implementation branch, update the normative specification and machine-readable artifacts with focused regression coverage, run focused and full validation, then commit, push, and open a pull request.

## 2026-08-11 07:42 — Implementation checkpoint

Created `feat/public-review-followups` from clean `master` in its own Worktrunk worktree. The draft now separates fixed producer member sets from tolerant consumer parsing, limits annotation semantics to their defined object location, replaces the overloaded OCI title with required `io.imgoci.filename`, completes OCI Distribution fetch checks and conditional tag resolution, and states the boundary around representation-internal payload validation.

Updated CUE, regenerated JSON Schema, canonical fixtures, schema documentation, changelog, and focused checks. Added regressions for consumer-ignored members, misplaced known annotations, filename syntax and requiredness, and JSON Schema projection shape. The focused Moon gate passes. Independent checks confirm fixture canonical bytes, case metadata, declared JSON Schema outcomes, and both CUE and JSON Schema behavior for the new boundaries.

The implementation preserves the prior decisions about descriptor `artifactType`, Incus metadata inspection, one-part BigOCI, compression framing, and the broader conformance harness.

## 2026-08-11 07:45 — Pull request opened

Committed the clean implementation as `2daf7c4` (`fix(spec): align consumer interoperability rules`) and pushed `feat/public-review-followups`. Opened ready PR #11: https://github.com/componere/imgoci-spec/pull/11.

GitHub validated the exact PR head in Actions run `31503212034`; the `validate` job passed. The implementation worktree is clean. Session 007 remains in progress while the PR is open for review.
