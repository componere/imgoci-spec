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

- Separated producer rules from consumer validation so unknown annotations and
  extension file-manifest types remain acceptable to consumers.
- Required lowercase producer spellings for defined media types and
  case-insensitive consumer comparison of type and subtype.
- Made accepted compression values the consumer's supported decoders in
  preference order.
- Scoped the imgoci public-value registry to targets, representations,
  compression values, and roles. Architecture continues to use OCI spellings.
- Made Zstandard files independent of external or preset dictionaries and
  aligned optional registry digest checks with the algorithm named by the
  registry.
- Enforced the Incus VM role and target rules in CUE.
- Corrected canonical fixture bytes and the linked manifest size in the example.
- Made a standard single-layer OCI file manifest the default storage format and
  reserved multipart BigOCI manifests for files that cannot be handled reliably
  as one blob.
- Advertised each file manifest's type in its release-index descriptor so a
  consumer can remove unsupported formats before choosing a compression.
- Replaced the private file-manifest-type annotation with the standard OCI
  descriptor `artifactType` field.

### Documentation

- Explained the OCI `artifactType` rule used by imgoci and pinned the XZ format
  reference.
- Removed an outdated claim about the checks run against the conformance corpus.
- Clarified the draft specification language without changing normative intent.
- Made the public target registry self-contained.
