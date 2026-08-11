---
id: 005
title: OCI-native file manifest type descriptors
started: 2026-08-10
---

## 2026-08-10 20:33 — Kickoff
Goal for the session: Replace the private `io.imgoci.file.manifest-type` annotation with required OCI descriptor `artifactType`, update the complete specification surface, and open a pull request.
Current state of the world: `master` is clean at `0910eba`; imgoci currently bans descriptor `artifactType`, requires the private annotation, and has not published a release tag. Analysis found that OCI Distribution 1.1 and ORAS use descriptor `artifactType` for the referenced manifest's top-level artifact type despite the narrower wording in OCI Image Spec 1.1.1.
Plan: Create an isolated Worktrunk branch, migrate the normative text and machine-readable/conformance artifacts, run the focused validation gate, then commit, push, and open a PR outside the pending governance process.
