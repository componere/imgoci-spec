---
id: 004
title: Standard OCI file layout and BigOCI precedence
started: 2026-08-10
---

## 2026-08-10 17:51 — Kickoff
Goal for the session: Loosen imgoci's mandatory BigOCI coupling through a targeted PR that standardizes on a single-layer OCI file manifest and reserves BigOCI for genuinely large files, with that order of precedence reflected throughout the specification.
Current state of the world: The draft requires every file entry to reference a BigOCI v1 manifest. A completed disposable spike proved that the same Incus QCOW2 can be stored as one ordinary OCI layer, served from one registry blob URL with byte ranges, imported by Incus 7.0.1, and booted successfully; multipart BigOCI remains useful but requires reconstruction.
Plan: Define the smallest coherent normative model, update the canonical CUE schema and generated JSON Schema where needed, adjust conformance fixtures and documentation, run focused and full validation, and publish a targeted pull request.

## 2026-08-10 18:00 — Normative shape selected
The release-index descriptor shape remains unchanged. OCI descriptor `artifactType` describes an image manifest's config media type, so it cannot truthfully advertise either top-level file-manifest artifact type while both layouts use the OCI empty config. Consumers instead fetch and verify the referenced manifest, then dispatch on its top-level `artifactType`.

The standard `application/vnd.imgoci.file.v1` manifest uses the OCI empty config and exactly one `application/octet-stream` layer containing the complete stored file. Every consumer supports this path. BigOCI remains an optional consumer capability and a producer fallback only when the repository or delivery path cannot handle the stored file reliably as one blob; imgoci rejects one-part BigOCI manifests and requires at least two parts.

Because the release-index wire shape does not change, the canonical CUE schema needs only layout-neutral comments and diagnostics. Referenced-manifest validation remains outside the parsed-index schema boundary.

## 2026-08-10 18:05 — Targeted specification change validated
The implementation branch now defines the standard one-layer manifest as the required baseline, makes BigOCI an optional multipart capability, prohibits one-part BigOCI, and deliberately sets no numeric size threshold because registry and delivery limits vary. The choice is based on stored bytes after imgoci compression.

The standard manifest follows ordinary OCI image-manifest encoding instead of adding JCS or a closed JSON shape. OCI-permitted optional manifest and descriptor members remain valid, preserving interoperability with normal OCI artifact tooling while digest and size still pin the exact bytes. The release index and its conformance fixtures require no wire-format changes.

Validation passed with `mise exec -- moon run root:cue --summary minimal`; this covers CUE formatting, module tidiness, CUE vetting, generated JSON Schema drift, and the fixture matrix. `git diff --check` also passed.

## 2026-08-10 18:07 — Pull request opened
Committed the targeted change as `bd619a1` (`feat(spec): prefer single-layer OCI file manifests`) on `feat/oci-file-layout` and opened https://github.com/componere/imgoci-spec/pull/7 as a ready pull request. GitHub's `validate` check passed on that exact head.

## 2026-08-10 18:32 — Pre-fetch capability filtering added
Review exposed a gap in the first PR revision: a standard-only consumer could discover a BigOCI manifest type only after selecting and fetching that manifest. This supersedes the earlier conclusion that the release-index wire shape needed no change.

Each file-entry descriptor now requires `io.imgoci.file.manifest-type`, which declares the referenced manifest's top-level `artifactType`. Producers using base v1 choose the standard imgoci or BigOCI value. Consumer validation accepts other syntactically valid RFC 6838 media types so discovery remains forward-compatible; resolution removes unsupported types for every selected role before applying compression preference. Broad listing still exposes all alternatives. Fetching a selected manifest must confirm exact equality with the annotation, and a mismatch fails the complete result without fallback.

CUE, generated JSON Schema, all fixtures, and focused mutations cover the required annotation, media-type syntax, BigOCI, an unknown valid type, missing and malformed values, and same-digest disagreement. The existing resolution case now proves that a standard-only consumer skips a preferred BigOCI alternative and selects the next supported compression. The repository gate, canonical fixture byte checks, conformance metadata schema validation, and `git diff --check` pass.

## 2026-08-10 18:37 — Pull request amendment published
Committed the amendment as `2bad70b` (`feat(spec): advertise file manifest capabilities`) and pushed it to PR #7. Corrected the PR description to replace the obsolete no-wire-change claim with the required annotation and capability-filter contract. GitHub's `validate` check passed on exact head `2bad70be8a899e40a7983fdbfbceacf085ca7e03`, and the PR is merge-clean.

## 2026-08-10 19:13 — Pull request merged
Squash-merged PR #7 into `master` as `0910eba7c9b30eb07edfd447425b5b7152837194` (`feat(spec): prefer single-layer OCI file manifests (#7)`). The merged tree exactly matches reviewed head `2bad70be8a899e40a7983fdbfbceacf085ca7e03`. Fast-forwarded the clean local `master` worktree to the merge commit. Post-merge Validate run 31451675842 and Release Please run 31451675862 both passed. Session 004 remains active pending an explicit close request.
