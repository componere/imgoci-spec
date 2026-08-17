# Scope

This file defines the Scope referenced by section 9.13 of the Community
Specification License 1.0 for the imgoci Working Group described in
[`GOVERNANCE.md`](GOVERNANCE.md).

## In Scope

The Scope is the subject matter of the imgoci specification: representing and
distributing machine images and related deliverables as OCI artifacts. It
includes the release index format; its selectors, annotations, and roles; the
standard imgoci and BigOCI file-manifest layouts; and the retrieval and
validation rules in [`spec.md`](spec.md). The Scope covers that subject matter
in `spec.md`, its addenda, and its language-neutral validation artifacts.

## Out of Scope

The Scope does not include implementation APIs or tooling; operation of OCI
registries; external catalog or policy systems such as SimpleStreams; or
representation-internal file formats such as QCOW2 and Incus metadata internals,
beyond the representation requirements stated in `spec.md`.

## Changes

Section 9.13 of the Community Specification License 1.0 states that changes to
Scope do not apply retroactively. Changes to this file follow the same ordinary
pull request and review rules as other governance changes described in
`GOVERNANCE.md`.
