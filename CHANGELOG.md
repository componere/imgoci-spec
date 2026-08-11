# Changelog

This file records notable changes to specification publications and their
associated schema and conformance artifacts.

## 0.0.0 - Development baseline

This section records work completed before automated releases were enabled.

### Added

- Initial repository structure based on the imgoci release format v1 draft.
- Defined the Incus target and coordinated metadata-plus-QCOW2 virtual-machine
  representation.

### Changed

- Made a standard single-layer OCI file manifest the default storage format and
  reserved multipart BigOCI manifests for files that cannot be handled reliably
  as one blob.

### Documentation

- Clarified the draft specification language without changing normative intent.
- Made the public target registry self-contained.
