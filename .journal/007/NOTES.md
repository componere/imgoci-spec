---
id: 007
title: Public review interoperability fixes
started: 2026-08-11
---

## 2026-08-11 07:30 — Kickoff

Goal for the session: Apply the agreed specification, schema, and retrieval fixes from the public-readiness review, validate them, and open a pull request.

Current state of the world: Sessions 001–006 are complete. Clean `master` and `origin/master` are at `cf2c181`. The agreed scope is five changes and preserves prior decisions about `artifactType`, Incus payload inspection, and conformance-corpus automation.

Plan: Create an isolated implementation branch, update the normative specification and machine-readable artifacts with focused regression coverage, run focused and full validation, then commit, push, and open a pull request.
