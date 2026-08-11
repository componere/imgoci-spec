---
id: 004
title: Standard OCI file layout and BigOCI precedence
started: 2026-08-10
---

## 2026-08-10 17:51 — Kickoff
Goal for the session: Loosen imgoci's mandatory BigOCI coupling through a targeted PR that standardizes on a single-layer OCI file manifest and reserves BigOCI for genuinely large files, with that order of precedence reflected throughout the specification.
Current state of the world: The draft requires every file entry to reference a BigOCI v1 manifest. A completed disposable spike proved that the same Incus QCOW2 can be stored as one ordinary OCI layer, served from one registry blob URL with byte ranges, imported by Incus 7.0.1, and booted successfully; multipart BigOCI remains useful but requires reconstruction.
Plan: Define the smallest coherent normative model, update the canonical CUE schema and generated JSON Schema where needed, adjust conformance fixtures and documentation, run focused and full validation, and publish a targeted pull request.
