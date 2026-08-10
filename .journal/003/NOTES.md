---
id: 003
title: Awaiting substantive request
started: 2026-08-10
---

## 2026-08-10 14:42 — Kickoff
Goal for the session: Start a fresh journal session; the substantive goal has not yet been provided.
Current state of the world: Sessions 001 and 002 are complete, the repository default branch is at `d106faa`, and release PR #3 remains open for separate review and approval.
Plan: Wait for the actual request, inspect the exact target, and proceed iteratively from the smallest useful slice.

## 2026-08-10 14:48 — Incus support analysis
Goal clarified: Add Incus support before the first imgoci release, covering the split VM image shape and optionally a logical SimpleStreams compatibility check.
Current findings: imgoci already models standalone QCOW2 but not Incus's coordinated metadata-plus-disk deliverable. Incus supports unified and split images; the split VM form is a metadata tarball plus a QCOW2 disk and is the better fit for a multi-consumer format. Incus's SimpleStreams client expects catalog metadata plus either a unified image or the split `incus.tar.xz` and `disk-kvm.img` pair, with an image fingerprint over the concatenated metadata and disk bytes.
Recommended direction: Add public `incus` target and `incus-vm` coordinated representation values with required `metadata` and `disk` roles. Keep SimpleStreams out of the core OCI object model; define an optional projection/validation profile that checks architecture mapping, metadata fields, transport availability, hashes, sizes, and the combined fingerprint. Prove the shape with one real image and Incus import/launch before finalizing normative prose and CUE constraints. Release PR #3 is still open and should remain unmerged until this work lands.
