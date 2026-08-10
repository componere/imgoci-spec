---
id: 002
title: Canonical CUE schema
started: 2026-08-10
---

## 2026-08-10 12:24 — Kickoff
Goal for the session: Start a new journal session and wait for the user's actual request.
Current state of the world: The repository session protocol is installed, the implementation checkout is clean on `master`, and no substantive task has been specified yet.
Plan: Receive the request, inspect the relevant repository state, work incrementally, and checkpoint meaningful progress.

## 2026-08-10 12:34 — Canonical CUE schema requested
Goal for the session: Define the imgoci release index canonically in modern CUE, including helpful `error()` constraints and thorough spec-aligned comments, then generate JSON Schema as a best-effort compatibility layer.
Current state of the world: `spec.md` and a handwritten `schema/release-index-v1.schema.json` exist on `master`; no CUE module exists yet. A clean implementation worktree was created at `feat/canonical-cue-schema` from `origin/master`.
Plan: Map the normative specification, prototype the scoped CUE module and generation path, validate representative conforming and nonconforming values, then tighten comments and documentation against the specification.

## 2026-08-10 13:04 — Canonical schema implemented
Implemented a CUE v0.17.1 module scoped to `schema/`, with `#ReleaseIndex` as the canonical machine-readable schema and `#ReleaseIndexJSONSchema` as its best-effort compatibility projection. The CUE schema uses spec-aligned comments and custom `error()` diagnostics, and enforces local syntax plus required roles, duplicate tuples, cross-entry metadata consistency, unique role titles, shared-manifest consistency, descriptor ordering, exact architecture-token bounds, content-size bounds, and the reserved annotation namespace.

Regenerated `schema/release-index-v1.schema.json`, documented the authority and compatibility boundaries, and extended CI with pinned CUE setup, generation-drift detection, existing conformance cases, and nine focused CUE-only regression mutations. Verified CUE formatting/module/vet, byte-for-byte generation, accepted and rejected fixture matrices, JSON and workflow schemas, conformance metadata and RFC 8785 bytes, local Markdown links, and diff hygiene. Independent review found no remaining actionable issues.

Implementation checkpoint: `092061a feat(schema): add canonical CUE release index` on `feat/canonical-cue-schema`. The session remains open for user review or follow-up.

## 2026-08-10 13:29 — Validation moved to mise and Moon
Introduced the same locked mise and Moon workflow used by the sibling Meigma template: mise now pins Python 3.14.3, uv 0.11.0, CUE 0.17.1, and Moon 2.3.5 for Linux and macOS on x86-64 and ARM64. Moon owns the CUE and repository enforcement graph, while two self-contained, uv-locked Python scripts preserve the former validation behavior and the focused CUE-only regression matrix.

Reduced the validation workflow to a SHA-pinned checkout, SHA-pinned mise setup, and the single enforcement command `moon ci --force --summary minimal`. Updated contributor documentation for the shared local flow and Worktrunk-safe `mise trust --all`. Verified locked tool installation, both uv script locks, all 16 mise platform resolutions, byte-exact JSON Schema generation, the full Moon CI graph, and diff hygiene. Independent review found no remaining actionable issues.

Implementation checkpoint: `e070ebf ci: manage validation with mise and Moon` on `feat/canonical-cue-schema`. The session remains open for user review or follow-up.

## 2026-08-10 13:39 — Validation narrowed to CUE
Removed the repository-wide enforcement that had exceeded the requested schema scope. Deleted the repository validator and its uv lock, including workflow and issue-form schema checks, conformance inventory and path rules, RFC 8785 byte checks, result-file parsing, and Markdown link checks.

Moon now exposes one CI-enabled `root:cue` task with no repository input inventory. It runs only CUE formatting, module consistency, schema validation, generated JSON Schema byte-drift detection, and focused CUE constraint fixtures. Updated validation documentation to match and restored the unrelated pull-request-template wording. Both `mise exec -- moon run root:cue --summary minimal` and `mise exec -- moon ci --force --summary minimal` pass, as do the remaining uv lock and diff checks.

Correction checkpoint: `ff344cd ci: limit validation to CUE` on `feat/canonical-cue-schema`. The session remains open for user review or follow-up.

## 2026-08-10 14:10 — Release Please automation
Added manifest-mode Release Please automation modeled on the sibling Meigma template. The new workflow authenticates as the `componere-release-please` GitHub App, maintains a release pull request from Conventional Commits on `master`, and begins the draft specification series at `v0.1.0-draft.1`. Release Please creates a draft release and force-creates its tag; the existing tag-triggered publication workflow now waits for that exact draft before uploading the attested archive and publishing it, avoiding a tag/release race.

Added the Release Please config and manifest, established the pre-bootstrap changelog baseline, and documented the release and stable-promotion process. Config and workflow schemas pass, the complete Moon CUE gate passes, and an authenticated Release Please 17.6.0 local dry run proposes exactly one `0.1.0-draft.1` release pull request with the canonical CUE change in its generated changelog. Independent review found no remaining repository changes.

Configured repository variable `COMPONERE_RELEASE_APP_CLIENT_ID` and Actions secret `COMPONERE_RELEASE_APP_PRIVATE_KEY` directly from the `componere-release-please` item in the 1Password `Componere` vault without displaying either value. The installed GitHub App still has only metadata read plus issues and pull requests write permissions. Its registration must be granted `Contents: Read and write`, and the resulting installation permission update must be approved, before the new workflow can mint a usable token.

Implementation checkpoint: `f730654 ci(release): add Release Please automation` on `feat/canonical-cue-schema`. The session remains open, with GitHub App permission approval as the only external blocker.

## 2026-08-10 14:16 — Canonical schema merged
Confirmed that the `componere-release-please` App installation now has contents, issues, and pull requests write permissions. Published the clean feature branch, opened PR #2 with head `f730654`, waited for its hosted validation, and squash-merged the exact reviewed head as `d106faa feat(schema): add canonical CUE release index (#2)`.

The post-merge Validate and Release Please workflows both passed. Release Please successfully opened PR #3, `chore(master): release 0.1.0-draft.1`, whose validation also passed. Fast-forwarded the local `master` checkout to `d106faa`, removed the integrated Worktrunk feature worktree and local branch, and deleted the remote feature branch. The generated release PR remains open for separate review; session 002 remains open.
