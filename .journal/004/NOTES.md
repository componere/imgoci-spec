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
