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
