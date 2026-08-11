---
id: 008
title: Simplify conformance fixtures and harness
date: 2026-08-11
status: complete
repos_touched: [imgoci-spec]
related_sessions: [002, 006, 007]
---

## Goal

Replace the Python-heavy conformance checks with explicit passing and failing
release-index manifests, a simple validation harness, and land the refactor
through review.

## Outcome

The goal was met. PR #14 replaced the dynamic Python mutation matrix and unused
case metamodel with 12 passing and 21 failing complete release-index fixtures,
small POSIX shell checks, and a reduced pinned toolchain. Focused, full, hosted,
and post-merge validation passed, and the PR was squash-merged as `c71096d`.

## Key Decisions

- Express each expected result through `conformance/v1/pass` or
  `conformance/v1/fail` directory membership so fixtures need no inventory or
  metadata schema.
- Materialize complete JSON documents rather than generating mutations from a
  shared base, making each behavior directly reviewable.
- Define the corpus as parsed-value CUE validation only. Exact JSON bytes,
  selection, retrieval, referenced objects, and decoded content remain outside
  this harness instead of being represented by metadata CI does not execute.
- Keep schema formatting, module validation, and generated JSON Schema drift
  checks in a small wrapper while keeping the fixture loop independently
  runnable.
- Remove Python and uv from the pinned toolchain because the shell and CUE
  checks require neither.

## Changes

- `conformance/v1/pass/` and `conformance/v1/fail/` - added explicit complete
  release indexes for every accepted and rejected behavior previously checked.
- `conformance/check.sh` - added the pass/fail CUE harness.
- `scripts/check_cue.sh` - replaced the Python repository check with CUE-native
  formatting, module, schema-generation drift, and corpus checks.
- `conformance/case.schema.json`, `conformance/v1/cases*`, and
  `scripts/check_cue.py*` - removed the unused metamodel and dynamic runner.
- `mise.toml` and `mise.lock` - removed Python and uv.
- Repository guidance and changelog - documented the simpler corpus and its
  parsed-value boundary.

## Open Threads

- Byte-level canonical encoding, selection, retrieval, file-manifest, and
  decoded-content conformance remain future consumer or producer harness work
  when a concrete implementation API needs them.
- The first draft release decision remains separate from this refactor.

## References

- [PR #14: refactor(conformance): replace generated cases with fixtures](https://github.com/componere/imgoci-spec/pull/14)
- [Squash commit `c71096d`](https://github.com/componere/imgoci-spec/commit/c71096d82d41cd488cc63705488af593fbeb6c31)
- [Post-merge Validate](https://github.com/componere/imgoci-spec/actions/runs/31515075505)
- [Post-merge Release Please](https://github.com/componere/imgoci-spec/actions/runs/31515075481)

## Lessons

- `gh pr merge --delete-branch` can complete the remote squash merge and then
  fail during local branch cleanup when the base branch is checked out in
  another worktree. Verify the remote PR state before retrying, then perform
  scoped local and remote branch cleanup separately.
