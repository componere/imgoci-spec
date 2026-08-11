---
id: 006
title: Public review corrections
date: 2026-08-10
status: complete
repos_touched: [imgoci-spec]
related_sessions: [003, 004, 005]
---

## Goal

Apply the agreed correctness and consistency fixes from the full specification review. Validate the specification, schema, fixtures, and supporting documentation, then merge the result.

## Outcome

The goal was met. PR #10 resolved the agreed review findings and aligned the normative text, CUE schema, generated JSON Schema, fixtures, checks, and documentation. It passed local and hosted validation and was squash-merged as `cf2c181`. Post-merge Validate and Release Please workflows also passed.

## Key Decisions

- Keep descriptor `artifactType` equal to the referenced manifest's top-level `artifactType`. State that imgoci follows the OCI Distribution convention because OCI Image Specification 1.1.1 contains conflicting guidance.
- Separate producer requirements from consumer validation. Consumers accept unknown annotation keys, selector values, and valid extension file-manifest types. Producers still follow the imgoci registry, reserved namespace, and lowercase spelling rules.
- Compare media types without regard to ASCII letter case. Require an accepted compression to be one the consumer can decode.
- When `Docker-Content-Digest` is used, verify the response against the algorithm named by that digest. The caller or internal descriptor still uses SHA-256 as required by imgoci.
- Require dictionary-free Zstandard streams. Pin the XZ format reference to version 1.2.1.
- Keep internal Incus metadata inspection outside this specification. Enforce the release-index roles and target that imgoci directly controls.
- Do not restore the removed conformance-corpus CI checks. Correct the documentation so it describes the focused checks that CI actually runs.

## Changes

- `spec.md`, `README.md`, and `CHANGELOG.md` - clarified standards use, producer and consumer rules, media-type comparison, digest validation, compression support, registry scope, and examples.
- `schema/release-index-v1.cue`, generated `schema/release-index-v1.schema.json`, and `schema/README.md` - added Incus VM constraints and matched the revised consumer-validation rules.
- `scripts/check_cue.py` - updated focused accepted and rejected cases, including portable media-type checks in the generated JSON Schema.
- `conformance/` - restored exact RFC 8785 bytes for canonical fixtures and removed outdated claims about checks that CI no longer runs.

## Open Threads

- Repeat the real Incus 7.0 import and launch proof before the first release.
- Release PR #3 remains open for the first draft release.

## References

- [PR #10: fix(spec): resolve public review findings](https://github.com/componere/imgoci-spec/pull/10)
- [Squash commit `cf2c181`](https://github.com/componere/imgoci-spec/commit/cf2c181e0619640cdd54b6e038e8371005050991)
- [PR-head validation](https://github.com/componere/imgoci-spec/actions/runs/31460603722)
- [Post-merge validation](https://github.com/componere/imgoci-spec/actions/runs/31461112371)
- [Post-merge Release Please run](https://github.com/componere/imgoci-spec/actions/runs/31461112362)
- [Release PR #3](https://github.com/componere/imgoci-spec/pull/3)
- [Session 003](../003/SUMMARY.md)
- [Session 004](../004/SUMMARY.md)
- [Session 005](../005/SUMMARY.md)

## Lessons

- OCI Image Specification 1.1.1 has conflicting `artifactType` guidance. A profile that chooses one interpretation should state that choice directly.
- Consumer schemas must not enforce producer-only registry and namespace rules.
- A trailing newline makes an otherwise valid JSON fixture fail exact RFC 8785 byte comparison, even when parsed schema checks pass.
