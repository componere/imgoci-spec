---
id: 006
title: Public review corrections
started: 2026-08-10
---

## 2026-08-10 21:45 — Kickoff
Goal for the session: Apply the agreed correctness and consistency fixes from the full specification review, validate them, and open a pull request from a new branch.
Current state of the world: The draft is on `master` at `84371bd`. The review found needed changes in the normative text, CUE enforcement, conformance fixtures, and supporting documentation. The OCI `artifactType` choice will remain, with its compatibility rule stated directly. The Incus metadata architecture concern is out of scope, and removed conformance machinery will not return.
Plan: Create an isolated Worktrunk branch. Update the specification and its machine-readable artifacts in small slices. Run focused and full checks, review the wording for plain language, record a journal checkpoint, and open a pull request.

## 2026-08-10 22:05 — Implementation and validation
Implemented the agreed review changes on `feat/spec-review-fixes`. The specification now states the OCI `artifactType` choice, separates producer rules from consumer validation, accepts unknown annotations, supports extension file-manifest types, compares media types without regard to letter case, validates registry digests with their named algorithm, defines accepted compression as supported compression, and requires dictionary-free Zstandard decoding. It also scopes the imgoci registry, pins XZ 1.2.1, and corrects the example size.

Updated CUE and its focused checks for Incus VM roles and target, unknown annotations, and media-type comparison. The generated JSON Schema keeps portable case-insensitive checks for fixed media types. Removed the final newline from four fixtures marked as canonical. Replaced the outdated conformance CI claim without restoring the removed corpus checks.

The locked `moon ci` task passed. A separate read-only check validated the case inventory, case metadata, RFC 8785 byte state, declared JSON Schema outcomes, mixed-case media types, and the 427-byte example manifest. The pinned XZ URL returned HTTP 200. Three independent review passes found no remaining contradiction after the final annotation and digest wording fixes.

Next: Commit the reviewed files, push the branch, open the pull request, and record its URL.

## 2026-08-10 22:07 — Pull request opened
Committed the completed patch as `34491f8` with subject `fix(spec): resolve public review findings`. Pushed `feat/spec-review-fixes` and opened [PR #10](https://github.com/componere/imgoci-spec/pull/10). The hosted `Validate` workflow completed successfully at the exact PR head. The session remains open for review and merge follow-up.
