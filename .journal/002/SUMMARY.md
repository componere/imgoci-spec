---
id: 002
title: Canonical CUE schema and release automation
date: 2026-08-10
status: complete
repos_touched: [imgoci-spec]
related_sessions: [001]
---

## Goal
Define the release index as a modern, thoroughly documented CUE schema with helpful `error()` diagnostics, while retaining generated JSON Schema as a best-effort compatibility layer. Establish focused, reproducible schema enforcement and automate the repository's draft release process.

## Outcome
The goals were met. CUE is now the canonical machine-readable schema without being limited to JSON Schema's constraint surface, the generated JSON Schema remains a documented compatibility projection, and locked mise/Moon/uv tooling enforces CUE formatting, validation, fixtures, and generation drift. Release Please is configured with a GitHub App for draft releases. PR #2 passed local and hosted validation and was squash-merged as `d106faa`.

## Key Decisions
- Kept `spec.md` as the sole normative authority and described CUE as the canonical machine-readable schema so the machine-readable hierarchy remains precise.
- Split the JSON-compatible projection from CUE-only semantic constraints so unsupported generation behavior does not weaken the authoritative CUE definition.
- Used modern CUE `error()` branches and retained cross-field, uniqueness, ordering, namespace, and numeric constraints even when JSON Schema cannot express them faithfully.
- Limited repository enforcement to the requested CUE surface after removing broader file-layout, metadata, Markdown, and exact-byte repository gates.
- Pinned CUE and supporting tools with mise, exposed one CI-enabled Moon task, and kept the nontrivial enforcement logic in a self-contained uv script.
- Configured Release Please to begin at `v0.1.0-draft.1` and made the tag-triggered publisher wait for the matching Release Please draft before uploading and publishing artifacts.

## Changes
- `schema/cue.mod/module.cue` and `schema/release-index-v1.cue` - added the scoped CUE module, canonical schema, compatibility projection, spec-aligned comments, and user-facing errors.
- `schema/release-index-v1.schema.json` and `schema/README.md` - regenerated the compatibility schema and documented authority plus known projection losses.
- `mise.toml`, `mise.lock`, `.moon/`, `moon.yml`, and `scripts/check_cue.py` - added locked local/CI tooling and focused CUE enforcement.
- `.github/workflows/validate.yml` - reduced CI to mise installation followed by Moon-only execution.
- `.github/workflows/release-please.yml`, `release-please-config.json`, and `.release-please-manifest.json` - added manifest-mode draft release automation using the Componere release App.
- `.github/workflows/release.yml` and `RELEASES.md` - connected Release Please drafts to the attested publication workflow and documented the release process.
- Repository documentation and `CHANGELOG.md` - documented canonical schema usage, validation, compatibility boundaries, and the pre-bootstrap changelog baseline.

## Open Threads
- Release Please opened PR #3 for `v0.1.0-draft.1`. It is green and intentionally remains open for separate release review and approval; after merge, verify the tag-triggered attested publication.

## References
- [PR #2: feat(schema): add canonical CUE release index](https://github.com/componere/imgoci-spec/pull/2)
- [Squash commit `d106faa`](https://github.com/componere/imgoci-spec/commit/d106faa69279f9c8d9efecb44f28731e1cf30b02)
- [PR-head validation run](https://github.com/componere/imgoci-spec/actions/runs/31432927642)
- [Post-merge validation run](https://github.com/componere/imgoci-spec/actions/runs/31432993799)
- [Post-merge Release Please run](https://github.com/componere/imgoci-spec/actions/runs/31432993651)
- [Release PR #3: chore(master): release 0.1.0-draft.1](https://github.com/componere/imgoci-spec/pull/3)

## Lessons
- Release Please 17.6.0 accepts `prerelease-type` at package scope rather than the top level in manifest configuration.
- A force-created tag can race draft creation; the publication workflow must require and wait for the Release Please draft instead of creating a fallback release.
