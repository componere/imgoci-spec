# Changelog

This file records notable changes to specification publications and their
associated schema and conformance artifacts.

## 0.1.0 (2026-08-17)


### Changes

* **conformance:** replace generated cases with fixtures ([#14](https://github.com/imgoci/spec/issues/14)) ([c71096d](https://github.com/imgoci/spec/commit/c71096d82d41cd488cc63705488af593fbeb6c31))
* **schema:** add canonical CUE release index ([#2](https://github.com/imgoci/spec/issues/2)) ([d106faa](https://github.com/imgoci/spec/commit/d106faa69279f9c8d9efecb44f28731e1cf30b02))
* **spec:** add deliverable usage selector ([#17](https://github.com/imgoci/spec/issues/17)) ([46d18b7](https://github.com/imgoci/spec/commit/46d18b74cc407ac7d61ded7692fc42b644f4d1e2))
* **spec:** define Incus VM representation ([#5](https://github.com/imgoci/spec/issues/5)) ([0438a9e](https://github.com/imgoci/spec/commit/0438a9e4b30d0ff5c56b82e10be900a441f6fe38))
* **spec:** prefer single-layer OCI file manifests ([#7](https://github.com/imgoci/spec/issues/7)) ([0910eba](https://github.com/imgoci/spec/commit/0910eba7c9b30eb07edfd447425b5b7152837194))
* **spec:** require canonical encoding for standard file manifests ([#8](https://github.com/imgoci/spec/issues/8)) ([26cb1af](https://github.com/imgoci/spec/commit/26cb1af038a4b57ad0a92f741c26333942e8e860))
* **spec:** use OCI descriptor artifact types ([#9](https://github.com/imgoci/spec/issues/9)) ([84371bd](https://github.com/imgoci/spec/commit/84371bdeddd3707f649fc6a2e91c514391e6574d))


### Fixes

* **spec:** align consumer interoperability rules ([#11](https://github.com/imgoci/spec/issues/11)) ([e90db17](https://github.com/imgoci/spec/commit/e90db17a417a39a0ffe0f198555d2805d0c509ed))
* **spec:** clarify retrieval and publication requirements ([#13](https://github.com/imgoci/spec/issues/13)) ([2d8b381](https://github.com/imgoci/spec/commit/2d8b3818a66368deef56de4e43cefb269b8cfb17))
* **spec:** include usage in shared-digest and reuse rules ([#20](https://github.com/imgoci/spec/issues/20)) ([a0e61fd](https://github.com/imgoci/spec/commit/a0e61fdd522d0315911fecfa5445f712c6341080))
* **spec:** replace PXE with Linux netboot ([#12](https://github.com/imgoci/spec/issues/12)) ([72e7a34](https://github.com/imgoci/spec/commit/72e7a343babb8c1c699ed2d45254ea512d724973))
* **spec:** resolve public review findings ([#10](https://github.com/imgoci/spec/issues/10)) ([cf2c181](https://github.com/imgoci/spec/commit/cf2c181e0619640cdd54b6e038e8371005050991))
* **spec:** resolve public-readiness findings ([#15](https://github.com/imgoci/spec/issues/15)) ([6480ace](https://github.com/imgoci/spec/commit/6480ace2ce7f99a90d23ab23619ccc313847b304))


### Documentation

* **governance:** add usage to the public-value registry ([#19](https://github.com/imgoci/spec/issues/19)) ([6700066](https://github.com/imgoci/spec/commit/6700066af3e426c24bf14b7ae943e9c91ba22cfe))
* **governance:** adopt Community Specification License 1.0 and define governance ([#4](https://github.com/imgoci/spec/issues/4)) ([da153d8](https://github.com/imgoci/spec/commit/da153d8d11fdf0eb3b4bd3c67393fec190397764))
* **readme:** explain what imgoci is and why it exists ([#18](https://github.com/imgoci/spec/issues/18)) ([1cbf200](https://github.com/imgoci/spec/commit/1cbf200aa9232f24933f9d68c8c1a85f362a501f))
* **readme:** list imgoci/go as the reference implementation ([#22](https://github.com/imgoci/spec/issues/22)) ([9638a9d](https://github.com/imgoci/spec/commit/9638a9dc1cedaa77a6e60f8134543c932d9d7469))
* **release:** declare the specification stable for v0.1.0 ([#21](https://github.com/imgoci/spec/issues/21)) ([b3ccd4f](https://github.com/imgoci/spec/commit/b3ccd4fe20c8b8ca2633636678cf98bd1ca40180))
* **spec:** make target registry self-contained ([#6](https://github.com/imgoci/spec/issues/6)) ([2467b50](https://github.com/imgoci/spec/commit/2467b5050498a8ec6048297ab817b768b7e4539d))

## 0.0.0 - Development baseline

This section records work completed before automated releases were enabled.

### Added

- Initial repository structure based on the imgoci release format v1 draft.
- Defined the Incus target and coordinated metadata-plus-QCOW2 virtual-machine
  representation.

### Changed

- Added canonical serialization for deliverable usage sets with `live`,
  `install`, and `install-offline` values, exact resolution, and subset
  discovery.
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
- Made strict root, descriptor, and standard-manifest member sets producer
  rules while consumers ignore additional members when interpreting objects.
- Replaced the overloaded OCI title annotation with `io.imgoci.filename` for
  decoded output names.
- Limited defined annotation syntax to the object location where each
  annotation is defined.
- Required OCI Distribution media negotiation and response media-type checks,
  and made tag pinning conditional on a tag reference.
- Placed representation-internal content validation outside imgoci validation
  and retrieval.
- Replaced the fixed three-file PXE representation with a Linux network-boot
  representation that requires a kernel and selects every present role by
  default.
- Required `Accept-Encoding: identity` for manifest and blob retrieval, assigned
  same-repository publication to producers, and clarified imgoci's whole-file
  verification of BigOCI assemblies.
- Required tagged release indexes to remain retrievable by their SHA-256 digest
  and allowed a response to state `Content-Encoding: identity` explicitly.
- Made a present role list select exactly those roles and expressed selection
  failures in language-neutral terms.
- Replaced generated Python validation cases and unused case metadata with
  explicit passing and failing release-index fixtures and a small shell harness.

### Documentation

- Explained the OCI `artifactType` rule used by imgoci and pinned the XZ format
  reference.
- Removed an outdated claim about the checks run against the conformance corpus.
- Clarified the draft specification language without changing normative intent.
- Made the public target registry self-contained.
- Updated the BigOCI reference to its canonical repository and clarified that
  the canonical Go implementation is not yet public.
