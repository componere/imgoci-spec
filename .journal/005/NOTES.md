---
id: 005
title: OCI-native file manifest type descriptors
started: 2026-08-10
---

## 2026-08-10 20:33 — Kickoff
Goal for the session: Replace the private `io.imgoci.file.manifest-type` annotation with required OCI descriptor `artifactType`, update the complete specification surface, and open a pull request.
Current state of the world: `master` is clean at `0910eba`; imgoci currently bans descriptor `artifactType`, requires the private annotation, and has not published a release tag. Analysis found that OCI Distribution 1.1 and ORAS use descriptor `artifactType` for the referenced manifest's top-level artifact type despite the narrower wording in OCI Image Spec 1.1.1.
Plan: Create an isolated Worktrunk branch, migrate the normative text and machine-readable/conformance artifacts, run the focused validation gate, then commit, push, and open a PR outside the pending governance process.

## 2026-08-10 20:40 — Descriptor migration validated
Created `feat/oci-descriptor-artifact-type` from fetched `origin/master`. The specification now requires file-entry descriptor `artifactType`, explicitly follows the OCI Distribution manifest-type convention, removes `io.imgoci.file.manifest-type`, and preserves pre-fetch capability filtering plus retrieval-time equality checks.

Updated the CUE schema, generated JSON Schema, exact-byte fixtures, schema/conformance documentation, changelog, and focused mutations. Added rejection coverage for the retired annotation. `mise exec -- moon run root:cue --summary minimal` passes, as does `git diff --check`.

## 2026-08-10 20:41 — PR opened and green
Committed the implementation as `eaf8c6d` (`feat(spec): use OCI descriptor artifact types`), pushed `feat/oci-descriptor-artifact-type`, and opened ready PR #9: https://github.com/componere/imgoci-spec/pull/9.

GitHub Actions validation passed at the exact PR head. The implementation worktree is clean. Session 005 remains open for review follow-up or explicit closeout.

## 2026-08-10 20:47 — PR merged
After explicit approval, verified PR #9 remained open, mergeable, clean, and green at exact head `eaf8c6d`. Squash-merged it through GitHub without an admin bypass.

The change is on `origin/master` as `84371bd` (`feat(spec): use OCI descriptor artifact types (#9)`). It landed after independently merged PR #8 without conflict. Post-merge Validate run 31456423447 and Release Please run 31456423446 both completed successfully. Session 005 remains open pending explicit closeout.
