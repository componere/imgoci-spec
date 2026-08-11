# Technical Notes

## Schema authority and enforcement

- `spec.md` is the sole normative authority. `schema/release-index-v1.cue` is the canonical machine-readable schema, and `schema/release-index-v1.schema.json` is a generated best-effort compatibility projection.
- The CUE module is `github.com/componere/imgoci-spec/schema@v0`, scoped to `schema/` and using CUE v0.17.1. Keep semantic constraints in CUE even when JSON Schema cannot represent them; the known projection losses are documented in `schema/README.md`.
- `#ReleaseIndex` models consumer validation. It accepts unknown selector values, unknown annotation keys, annotations outside their defined object location, additional root and descriptor members, and valid extension file-manifest types. Producer-only fixed member sets, registry, namespace, and lowercase spelling rules remain normative prose.
- Run the focused local gate with `mise exec -- moon run root:cue --summary minimal`. CI runs the same task through `moon ci --force --summary minimal`; `scripts/check_cue.py` owns formatting, module consistency, vetting, generation drift, and focused accepted/rejected fixtures.
- File entries use required `io.imgoci.filename` for decoded output names. It is not a portable filesystem-safety guarantee; consumers apply destination-specific filename rules. OCI `org.opencontainers.image.title` has no imgoci filename meaning.

## Releases

- Release Please uses repository variable `COMPONERE_RELEASE_APP_CLIENT_ID` and Actions secret `COMPONERE_RELEASE_APP_PRIVATE_KEY`. The `componere-release-please` App installation requires contents, issues, and pull requests write permissions.
- Draft specification versions use the `draft.N` prerelease series beginning at `v0.1.0-draft.1`. Merging a release PR creates the tag and draft GitHub release; the tag-triggered workflow waits for that draft, uploads the attested archive, and publishes it.

## File manifest layouts

- `application/vnd.imgoci.file.v1` is the required baseline: an OCI image manifest with the OCI empty config and exactly one `application/octet-stream` layer containing the complete stored file. BigOCI is optional, must contain at least two parts, and is reserved for stored bytes that cannot be handled reliably as one blob; v1 has no numeric threshold.
- Every file-entry descriptor uses OCI descriptor `artifactType` to declare the referenced file manifest's required top-level `artifactType`. imgoci follows the OCI Distribution manifest-type convention rather than the narrower OCI Image descriptor wording. An imgoci addendum or private extension may define another valid RFC 6838 file-manifest type.
- Broad listing exposes every manifest type. Resolution removes types the consumer does not support across all selected roles before applying compression preference. Manifest requests advertise the expected OCI object media type with `Accept`; retrieval compares response `Content-Type`, body `mediaType`, and descriptor `mediaType`, then requires fetched top-level and descriptor `artifactType` equality. A tag is resolved to the computed SHA-256 digest only when the caller supplied a tag. A mismatch fails the complete result without fallback. CUE checks syntax and same-digest consistency; fetched-object equality and layout validation remain external checks.

## Incus VM representation

- An Incus VM release uses `target=incus`, `representation=incus-vm`, and coordinated `metadata` plus `disk` roles. The root disk is QCOW2 and remains outside the metadata archive.
- Decoded `metadata` content is the exact XZ-compressed Incus metadata tar archive. Use `compression=none` for native bytes; any imgoci outer compression must decode back to that exact XZ stream.
- SimpleStreams is not part of the specification. A disposable end-to-end proof showed that an imgoci release can be projected into a working catalog without new intrinsic image fields; catalog names, aliases, and policy remain external.
- CUE enforces the required `disk` and `metadata` roles and the `target=incus` pairing. Before the first release, repeat the real import and launch proof against Incus 7.0.
- Standard representation forms constrain producer labeling. Consumer validation and retrieval verify transport structure, decoding, size, and digest but do not parse QCOW2, ISO, Incus metadata, or other representation-internal formats.
