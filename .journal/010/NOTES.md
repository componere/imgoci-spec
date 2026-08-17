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

## 2026-08-17 13:20 — PR #21 opened with the readiness fixes
Maintainer decisions: add `Scope.md` and `Notices.md` now (wording to be
reviewed), untrack the agent harness before the tag, and rehearse the tag
trigger before the real release.

Landed in worktree `.wt/chore-release-v0-1-0-readiness` (branch
`chore/release-v0-1-0-readiness`), PR #21, `validate` green:
- `release-please-config.json`: `initial-version` `0.1.0`; removed `versioning`,
  `prerelease`, `prerelease-type`; kept `force-tag-creation` and `draft: true`;
  added `refactor` to `changelog-sections`.
- New root `Scope.md` and `Notices.md`; `GOVERNANCE.md` switched to CSL's
  `Draft Specification`/`Approved Specification` and repointed notices at
  `Notices.md`. All claims traced to CSL sections 2.1, 2.1.3.3, 2.2, 2.3, 3.1,
  3.2, 9.2, 9.6, 9.7, 9.13.
- `release.yml` archive now ships `GOVERNANCE.md`, `Scope.md`, `Notices.md`, and
  `LICENSE-COMMUNITY-SPEC`; staging reproduced locally (8 root files + schema +
  conformance, 43 fixtures).
- `spec.md` `Status: stable, 2026-08-17` and `should not` added to the normative
  keywords; README, RELEASES, CONTRIBUTING, SECURITY, PR/issue templates
  de-drafted; new `.github/ISSUE_TEMPLATE/config.yml` disables blank issues.
- Four new fail fixtures (`wrong-schema-version`, `missing-schema-version`,
  `empty-manifests`, `missing-manifests`); gate now 14 pass / 29 fail, green.
- Untracked `.agents/`, `.claude/`, `.session.md`, `AGENTS.md`, `CLAUDE.md` and
  added them to `.gitignore`. Consequence: a fresh clone no longer carries the
  session protocol; it stays on disk locally only.

Correction to the earlier rehearsal plan: a hand-pushed `v0.0.1-rehearsal` tag
does not test the App-token question, because pushes by a human always trigger
workflows. It also leaves `publish` red, since `release.yml:101-118` polls for a
draft release that only Release Please creates. A rehearsal that proves the
publish path end to end needs a matching draft release created by hand.

Next: maintainer reviews PR #21 wording, then merge #21, let Release Please
retitle PR #3 to `release 0.1.0` and verify its manifest diff, optionally
rehearse, then merge #3.

## 2026-08-17 13:10 — PR #21 merged and full-path rehearsal
PR #21 squash-merged as `b3ccd4f`; `master` fast-forwarded. `gh pr merge` failed
during local cleanup again (`master` checked out in another worktree) after the
remote merge succeeded — same lesson as session 008.

Gotcha worth remembering: the ff-merge deleted the untracked-by-design harness
files from the main checkout, because they were still tracked there. Restored
with `git checkout a0e61fd -- .agents .claude .session.md AGENTS.md CLAUDE.md`
followed by `git restore --staged`, so they now sit on disk as ignored files.

Release Please retitled PR #3 to `chore(master): release 0.1.0`, its manifest
diff writes `".": "0.1.0"`, and the generated changelog now includes the
`refactor` entry (#14) that the added changelog section unhid.

Rehearsal used tag `vrehearsal-1` (non-semver suffix so Release Please cannot
read it as a version) plus a hand-created draft release:
- Release run 32063657510 succeeded end to end: validate, package, attest,
  publish. The release ended `draft:false`, `prerelease:false`, with
  `imgoci-spec-rehearsal-1.tar.gz` attached.
- `gh attestation verify --signer-workflow imgoci/spec/.github/workflows/release.yml`
  passed: `sourceRepositoryDigest b3ccd4f`, `ref refs/tags/vrehearsal-1`,
  `runnerEnvironment github-hosted`.
- Published archive contains the 8 root files (including `Scope.md`,
  `Notices.md`, `LICENSE-COMMUNITY-SPEC`, `GOVERNANCE.md`), `schema/`,
  `conformance/` with 43 fixtures, and `spec.md` reading `Status: stable`.

Two new facts the rehearsal surfaced:
- Ruleset `Default tags` (id 20880519) covers `~ALL` tags with `update`,
  `deletion`, `required_signatures`, and `non_fast_forward`, and has no bypass
  actors. Tag deletion is therefore refused, so `vrehearsal-1` and the
  `rehearsal-api-2` probe tag cannot be removed without relaxing the ruleset.
- The probe answered the real question: a lightweight tag ref created through
  the API, with no signature of its own, is accepted because the target squash
  commit `b3ccd4f` is GitHub-signed and verified. Release Please's
  `git.createRef refs/tags/v0.1.0` will therefore pass the ruleset.

## 2026-08-17 13:30 — Rehearsal tags removed, release on hold
Cleaned up with maintainer approval: captured ruleset 20880519 to
`/tmp/tagruleset-orig.json`, set enforcement `disabled`, deleted
`refs/tags/vrehearsal-1` and `refs/tags/rehearsal-api-2`, then restored the
original payload. Verified afterward: enforcement `active`, same four rules,
zero bypass actors, `~ALL` conditions; `git ls-remote --tags origin` and
`gh release list` are both empty again.

Maintainer chose to hold the release. PR #3 (`chore(master): release 0.1.0`) is
open, MERGEABLE, `validate` SUCCESS, awaiting their own review of the retitled
PR and generated changelog. Nothing else is pending on my side.

## 2026-08-17 13:55 — README implementations section
Maintainer wanted `github.com/imgoci/go` linked as a canonical implementation.
PR #21 had already added the link, but it sat under `## Implementation` at line
193, below Repository contents and Validation.

Pushed back on "canonical" and used "reference implementation" instead:
`README.md:158,166-169` makes `spec.md` the sole normative authority and says
implementation behavior yields to it, so "canonical" invites the opposite
reading, and today it would be false given the five Go deviations the parity
audit found. "One of the canonical implementations" is also self-contradictory.

PR #22, `validate` green: lead paragraph now links the section, `##
Implementation` becomes `## Implementations` as an extensible list, the section
states that a disagreement is an implementation defect, and `imgoci/go` is
described as a library and command-line tool (verified `cli/main.go` exists in a
separate `cli/go.mod` module).

Observed while checking the Go repo: its HEAD is `885feee` ("pin the new spec
revision"), but `testdata/conformance/SPEC_COMMIT` still reads `46d18b74`, so the
corpus pin is still behind spec `master`. Implementation-side follow-up, not this
repo's work.

Merging PR #22 refreshes release PR #3; it stays `release 0.1.0` and gains this
entry under Documentation.

## 2026-08-17 14:05 — PR #22 merged
Squash-merged as `9638a9d`; `master` fast-forwarded and the feature worktree and
branch are gone. The harness files stayed on disk this time because the merge
only touched `README.md`.

Release Please refreshed PR #3 (branch now `04551a0`): still
`chore(master): release 0.1.0`, MERGEABLE, `validate` SUCCESS, and its generated
changelog now carries both `docs(readme): list imgoci/go as the reference
implementation` (#22) and `docs(release): declare the specification stable for
v0.1.0` (#21) under Documentation.

Noticed two stale remote branches unrelated to this session: `docs/governance`
and `feat/canonical-file-manifest`.

Next: PR #3 remains held for the maintainer.

## 2026-08-17 14:10 — Stale branch cleanup
Deleted the two outdated remote branches with maintainer approval. Both were
squash-merged, so their tips were not ancestors of `master`; recorded here in
case a tip is ever needed again:
- `docs/governance` `a78f264` (2 commits, squash-merged as PR #4)
- `feat/canonical-file-manifest` `e9ccd02` (1 commit, squash-merged as PR #8)

Remaining remote heads: `master` `9638a9d`, `journal/jmgilman`, and the Release
Please branch. Local worktrees: `master` and the journal root only.

## 2026-08-17 14:20 — v0.1.0 published
PR #3 squash-merged as `8083159`. The whole chain ran unattended:
- Release Please run 32068742518 (success) pushed `refs/tags/v0.1.0` at
  `8083159` and created the draft release.
- That App-token tag push DID trigger `Release` (run 32068756636, tag
  `v0.1.0`), which closes the one link the rehearsal could not prove. All three
  jobs green; `publish` uploaded the archive and flipped the release public.

Verified afterward:
- Release `v0.1.0`: `draft:false`, `prerelease:false`, published
  2026-08-17T21:00:07Z, asset `imgoci-spec-0.1.0.tar.gz` (41404 bytes,
  sha256 `9c610fb2031893430e99c8061dec925f72c79ae7eb030743f129cfbed1b17ab0`).
- `gh attestation verify --signer-workflow imgoci/spec/.github/workflows/release.yml`
  passed: ref `refs/tags/v0.1.0`, digest `8083159`, runner `github-hosted`.
- Archive contents: 8 root files including `Scope.md`, `Notices.md`,
  `LICENSE-COMMUNITY-SPEC`, `GOVERNANCE.md`; `schema/`; `conformance/` with 43
  fixtures; `spec.md` reading `Status: stable, 2026-08-17`.
- Ran the published corpus straight out of the tarball: 14 passing and 29
  failing indexes validated.
- `git ls-remote --tags origin` shows exactly one tag, `v0.1.0` at `8083159`.

New follow-up found while verifying: the archive ships `conformance/check.sh`
and `schema/README.md`, whose commands are written as `mise exec -- ...`, but it
does not ship `mise.toml` or `mise.lock`. Running `check.sh` from the extracted
tarball picked up the host CUE v0.16.1 and failed with `language version
"v0.17.1" ... too new`; it passed once the pinned v0.17.1 binary was on PATH.
`schema/README.md:9` does state CUE v0.17.1, so this is a packaging nit, not a
correctness problem. Options for a later release: ship `mise.toml`/`mise.lock`
in the archive, or reword the archived commands to plain `cue` with a stated
minimum version.
