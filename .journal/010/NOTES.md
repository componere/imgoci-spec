---
id: 010
title: Session 010
started: 2026-08-17
---

## 2026-08-17 12:17 — Kickoff
Goal for the session: not yet stated; the user asked to start a new session and
will define the task next.
Current state of the world: `master` is at `a0e61fd`
("fix(spec): include usage in shared-digest and reuse rules (#20)") and clean.
Journal branch `journal/jmgilman` is clean and in sync with `origin`. Sessions
001-008 are closed with summaries; 009 remains `in-progress` and untouched by
this session. Durable context loaded from `TECH_NOTES.md`: `spec.md` is the sole
normative authority with canonical CUE schema plus generated JSON Schema, the
conformance corpus is explicit pass/fail fixtures validated by
`conformance/check.sh` via `scripts/check_cue.sh`, and the focused local gate is
`mise exec -- moon run root:cue --summary minimal`. Known open threads from
recent summaries: repeat the real Incus 7.0 import/launch proof before the first
release, and the first draft release (`v0.1.0-draft.1`) decision is still
outstanding.
Plan: wait for the user's task, then work in an isolated Worktrunk worktree off
fetched `master`, integrate via a squash-merged GitHub PR, and checkpoint
progress here.

## 2026-08-17 12:45 — Readiness check for a stable v0.1.0
Task: cut the first release as non-draft `v0.1.0` (not `v0.1.0-draft.1`);
readiness check first, no merges yet. Ran five parallel read-only audits
(release automation, spec/docs, validation gate, Go implementation parity,
community/governance).

State of the world: no tags, no GitHub releases, manifest `".": "0.0.0"`;
release PR #3 (`chore(master): release 0.1.0-draft.1`) is open and MEREGEABLE;
`master` at `a0e61fd`; hosted Validate green.

Findings that matter:
- Version comes only from `release-please-config.json:5` `initial-version`,
  because release-please v17.6.0 treats manifest `0.0.0` as never-released and
  returns `initial-version` verbatim. Flipping `draft`/`prerelease` alone still
  ships `0.1.0-draft.1`. Required: set `initial-version` to `0.1.0`, delete
  `prerelease`, `versioning`, `prerelease-type`; keep `force-tag-creation`
  (App-token tag push is what triggers `release.yml`) and keep `draft: true`
  (transient staging so no release is public without its attested archive).
  Merge order is load-bearing: config change lands on `master` first, then
  PR #3 retitles to `release 0.1.0`.
- CSL 1.0 gaps that bind at the tag: no root `Scope.md` (patent grant silently
  falls back to per-contribution Necessary Claims, non-retroactive), no root
  `Notices.md` (exclusion notices, withdrawal, and one implementer acceptance
  route all point at it), and `release.yml:52` archive omits
  `LICENSE-COMMUNITY-SPEC` and `GOVERNANCE.md`.
- Draft language to flip: `spec.md:3` status line, `README.md:11`, `:201`,
  `RELEASES.md:14-16`, `:50-52`, `GOVERNANCE.md:46-55` (also uses "Approved
  Deliverable" instead of CSL's defined "Approved Specification").
  `README.md:195` falsely says the Go implementation is not public.
- Validation is green: `mise exec -- moon run root:cue --summary minimal` passes,
  14 pass / 25 fail fixtures, no JSON Schema drift, CUE module and pins
  consistent. Gap: no negative fixture for wrong/missing `schemaVersion` or
  empty/missing `manifests`.
- Implementation parity: no spec defect found. Go repo pins spec commit
  `46d18b74` (stale vs `a0e61fd`) and is missing the 14th pass fixture; its own
  deviations (4 MiB manifest ceiling, 128 MiB decompression window, post-fetch
  query validation, `tag@digest` references, unvalidated Incus content) are
  implementation-side follow-ups.
- Tracked agent plumbing (`.agents/`, `.claude/`, `.session.md`, 15 files) ships
  in the public tag archive while `.gitignore` claims `.agents/`/`.claude/` are
  ignored.

Next: get maintainer decisions on Scope.md wording, Notices.md, and untracking
agent plumbing, then land the fixes in one PR before touching PR #3.
