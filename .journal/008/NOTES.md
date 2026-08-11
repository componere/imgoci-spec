---
id: 008
title: Simplify conformance fixtures and harness
started: 2026-08-11
---

## 2026-08-11 09:48 — Kickoff
Goal for the session: Replace the Python-heavy conformance checks with explicit passing and failing release-index manifests, a simple harness, and publish the implementation in a pull request.
Current state of the world: `master` is clean at `2d8b381`; CUE remains the canonical parsed-value schema, while the current Python script mixes repository checks with dynamically generated fixture mutations and the conformance metamodel is largely unexecuted by CI.
Plan: Create an isolated Worktrunk branch, materialize the current accepted and rejected CUE cases, replace Python and uv with a small shell check, update documentation and locked tools, validate locally and in CI, then open a draft PR.

## 2026-08-11 09:53 — Refactor implemented and locally validated
Created `feat/simple-conformance-fixtures` from fetched `master`. Replaced the dynamic Python fixture construction and unused case metamodel with 12 passing and 21 failing complete release-index documents, `conformance/check.sh`, and a small schema/projection wrapper. Removed Python and uv from the pinned toolchain and updated repository guidance. The focused `root:cue` task and forced full Moon CI both pass. During editing, the patch helper initially targeted the clean `master` checkout; the exact scoped diff was transferred into the feature worktree and `master` was restored clean before validation.

Next: Review the final diff, commit and push the feature branch, open a draft PR, and verify hosted checks.
