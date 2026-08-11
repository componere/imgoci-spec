---
id: 004
title: Standard OCI file layout and BigOCI precedence
date: 2026-08-10
status: complete
repos_touched: [imgoci-spec]
related_sessions: [003]
---

## Goal
Loosen imgoci's mandatory BigOCI coupling through a targeted specification change. Make a standard single-layer OCI file manifest the default, reserve BigOCI for genuinely multipart files, and let consumers reject unsupported layouts before retrieval.

## Outcome
The goal was met. PR #7 defined the standard one-layer manifest, made it the required consumer baseline, retained BigOCI as an optional multipart fallback, and added pre-fetch manifest-type capability filtering. The CUE schema, generated JSON Schema, fixtures, conformance metadata, and focused validation were updated with the normative text. The PR passed local and hosted checks and was squash-merged as `0910eba`.

## Key Decisions
- Store the complete stored file in one `application/octet-stream` layer under an ordinary OCI image manifest with the OCI empty config. This gives standard consumers one repository blob without assembly.
- Require the standard layout whenever one-blob delivery is practical. Permit BigOCI only with at least two parts when the stored bytes after imgoci compression are too large for that path; v1 sets no numeric threshold because repository limits vary.
- Keep OCI descriptor `artifactType` forbidden because OCI defines it from the referenced image manifest's config media type. Declare the top-level file-manifest type with required annotation `io.imgoci.file.manifest-type` instead.
- Treat manifest type as capability metadata, not a selector. Broad discovery exposes every alternative; resolution removes unsupported types for every selected role before applying compression preference and returns no partial result.
- Require the fetched manifest's top-level `artifactType` to match the descriptor annotation. A mismatch fails the complete result without selecting another transport alternative.
- Accept syntactically valid unknown manifest types during consumer discovery while restricting base-v1 producers to the standard imgoci and BigOCI values. This leaves room for later addenda without invalidating the release index.
- Use normal OCI JSON encoding and optional OCI members for the standard manifest rather than adding JCS or a closed shape. The release descriptor digest and size already pin the exact bytes.

## Changes
- `spec.md`, `README.md`, and `CHANGELOG.md` - defined the standard manifest, BigOCI precedence, capability filtering, retrieval checks, examples, and compatibility boundaries.
- `schema/release-index-v1.cue`, generated `schema/release-index-v1.schema.json`, and `schema/README.md` - required RFC 6838 manifest-type syntax, enforced same-digest consistency, and documented external verification boundaries.
- `conformance/` - added the required annotation to all fixtures, extended resolve-case metadata with supported manifest types, and proved that a standard-only consumer removes a preferred BigOCI alternative before compression selection.
- `scripts/check_cue.py` - added accepted BigOCI and unknown-type cases plus rejected missing, malformed, and shared-digest-disagreement mutations.

## Open Threads
- Before the first release, add the deferred Incus role/target CUE constraints and fixtures from session 003, then repeat the real import and launch proof against Incus 7.0.
- Referenced-manifest, layer/part, decoding, and retrieval-graph conformance remain outside the initial corpus.
- Release PR #3 remains open and green at `0f0953d`; review it only after the remaining pre-release acceptance work is complete.

## References
- [PR #7: feat(spec): prefer single-layer OCI file manifests](https://github.com/componere/imgoci-spec/pull/7)
- [Squash commit `0910eba`](https://github.com/componere/imgoci-spec/commit/0910eba7c9b30eb07edfd447425b5b7152837194)
- [PR-head validation](https://github.com/componere/imgoci-spec/actions/runs/31449859285)
- [Post-merge validation](https://github.com/componere/imgoci-spec/actions/runs/31451675842)
- [Post-merge Release Please run](https://github.com/componere/imgoci-spec/actions/runs/31451675862)
- [Session 003](../003/SUMMARY.md)

## Lessons
- Making BigOCI optional only at retrieval time still forces a consumer to fetch an unsupported manifest. Capability metadata must be visible in the release index and applied before compression selection.
- OCI descriptor `artifactType` and an image manifest's top-level `artifactType` are different fields with different meanings; using a dedicated descriptor annotation avoids contradicting OCI semantics.
