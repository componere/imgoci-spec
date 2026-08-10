---
id: 003
title: Incus VM format and projection proof
date: 2026-08-10
status: complete
repos_touched: [imgoci-spec]
related_sessions: [002]
---

## Goal
Establish how imgoci should support Incus VM images before the first specification release. Prove the design with a real QCOW2 plus metadata image, avoid making SimpleStreams a specification dependency, and land the smallest normative format change justified by the proof.

## Outcome
The requested spike and normative slice were completed. A disposable Lima/Incus environment proved that an imgoci release can carry exact Incus metadata and disk bytes, project them into a generated SimpleStreams catalog, and launch the resulting VM without adding catalog concepts to imgoci. The minimal `incus` target and coordinated `incus-vm` representation were then merged. The broader pre-release goal remains partial until CUE enforcement, conformance cases, and a final Incus 7.0 acceptance rerun are completed.

## Key Decisions
- Model an Incus VM as coordinated `metadata` and `disk` roles under `representation=incus-vm` and `target=incus` so normal resolution returns the complete pair.
- Define decoded `metadata` content as the exact XZ-compressed Incus metadata tar archive. Native entries use `compression=none`; optional outer compression must decode to the identical XZ stream.
- Keep SimpleStreams terminology, catalogs, aliases, and policy outside the specification. The one-time projection demonstrated that the imgoci object model already contains the intrinsic image facts needed to generate a catalog.
- Remove Fedora CoreOS provenance and references from the target registry so the normative registry is self-contained and does not require special historical explanations for Incus.

## Changes
- `spec.md` - added the `incus` target, `incus-vm` representation, public `metadata` role, coordinated-role requirements, target coupling, exact metadata byte semantics, and the Incus 7.0 normative reference.
- `spec.md` - removed the Fedora CoreOS provenance paragraph and its informative references.
- `CHANGELOG.md` - recorded the Incus VM representation and self-contained target registry.
- Disposable spike only - proved OCI publication, generated-catalog verification, Incus remote listing, exact combined fingerprint preservation, and a successful Alpine ARM64 VM launch; no spike code or environment was retained.

## Open Threads
- Slice 3: enforce `disk` plus `metadata` roles and the `incus-vm`/`incus` coupling in CUE, regenerate the JSON Schema projection, and add focused accepted and rejected fixtures.
- Slice 4: rerun the real import and launch proof against Incus 7.0, then run local and hosted gates before the first release.
- Release PR #3 remains open and green; do not merge it until the remaining Incus slices establish release readiness.

## References
- [PR #5: feat(spec): define Incus VM representation](https://github.com/componere/imgoci-spec/pull/5)
- [Squash commit `0438a9e`](https://github.com/componere/imgoci-spec/commit/0438a9e4b30d0ff5c56b82e10be900a441f6fe38)
- [PR #6: docs(spec): make target registry self-contained](https://github.com/componere/imgoci-spec/pull/6)
- [Squash commit `2467b50`](https://github.com/componere/imgoci-spec/commit/2467b5050498a8ec6048297ab817b768b7e4539d)
- [Post-merge validation run](https://github.com/componere/imgoci-spec/actions/runs/31442135225)
- [Release PR #3](https://github.com/componere/imgoci-spec/pull/3)

## Lessons
- Lima 2.0.3 with VZ exposed nested KVM on Apple Silicon and was sufficient for an Incus VM compatibility spike.
- The exact Incus combined fingerprint survived OCI storage, multipart QCOW2 transport, catalog projection, and remote import; imgoci did not need additional intrinsic image fields.
- Ubuntu 24.04's Incus 6.0 package expected generic OVMF filenames while its ARM firmware package supplied AAVMF names, requiring two disposable compatibility symlinks before QEMU became operational.
