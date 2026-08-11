---
id: 006
title: Public review corrections
started: 2026-08-10
---

## 2026-08-10 21:45 — Kickoff
Goal for the session: Apply the agreed correctness and consistency fixes from the full specification review, validate them, and open a pull request from a new branch.
Current state of the world: The draft is on `master` at `84371bd`. The review found needed changes in the normative text, CUE enforcement, conformance fixtures, and supporting documentation. The OCI `artifactType` choice will remain, with its compatibility rule stated directly. The Incus metadata architecture concern is out of scope, and removed conformance machinery will not return.
Plan: Create an isolated Worktrunk branch. Update the specification and its machine-readable artifacts in small slices. Run focused and full checks, review the wording for plain language, record a journal checkpoint, and open a pull request.
