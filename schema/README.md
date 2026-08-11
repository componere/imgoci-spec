# Release-index schemas

`release-index-v1.cue` is the canonical machine-readable schema for a parsed
imgoci v1 release index. [`spec.md`](../spec.md) remains the sole normative
authority for the format. If the CUE schema and specification differ, the
specification controls.

The CUE module is scoped to this directory as
`github.com/componere/imgoci-spec/schema@v0`. It uses CUE v0.17.1 and enables
the `explicitopen` experiment so closed structs translate predictably.

## Validate a release index

From this directory, run:

```sh
mise exec -- cue vet -c -d '#ReleaseIndex' . path/to/index.json
```

`#ReleaseIndex` models the rules that a consumer can apply to a parsed release
index. It checks the closed release-index and file-entry descriptor shapes,
required annotations, local syntax, case-insensitive media-type consistency,
and these release-wide rules from Sections 5, 6, and 9:

- each architecture token has no more than 128 ASCII bytes;
- decoded content size does not exceed `9223372036854775807`;
- standard representations contain their required roles;
- `incus-vm` deliverables use the `incus` target;
- a transport alternative tuple occurs only once;
- transport alternatives for one file have the same content digest, content
  size, and title;
- different roles in one deliverable have different titles;
- descriptors for one file manifest have media and artifact types that compare
  equal without regard to letter case. They also agree on descriptor size,
  compression, content digest, and content size; and
- file-entry descriptors use the canonical order.

CUE validates a parsed value. It cannot inspect the original JSON bytes, fetch
referenced objects, or observe repository state. RFC 8785 encoding, agreement
between a file-entry descriptor's `artifactType` and the fetched manifest's
top-level `artifactType`, file-manifest validation, same-repository
requirements, retrieval, decoding, and content verification remain separate
conformance checks.

The schema does not enforce producer-only rules. These include public and
private selector ownership, the reserved `io.imgoci.` namespace, lowercase
producer media-type spelling, and whether an extension type has its own rules.
It also cannot verify that `io.imgoci.name` stays stable across releases.

For consumer compatibility, CUE accepts unknown selector values, unknown
annotation keys including `io.imgoci.` keys, and syntactically valid unknown
file-manifest types.

## Generate the JSON Schema compatibility layer

`release-index-v1.schema.json` is generated from
`#ReleaseIndexJSONSchema`, the JSON-compatible projection in the CUE source:

```sh
mise exec -- cue fmt --check --files .
mise exec -- cue mod tidy --check
mise exec -- cue def --force --out jsonschema \
  -e '#ReleaseIndexJSONSchema' \
  -o release-index-v1.schema.json \
  .
```

The generated schema uses JSON Schema Draft 2020-12. CUE comments become JSON
Schema descriptions. `mise.toml` and `mise.lock` pin CUE v0.17.1 for local and
CI use. The `root:cue` Moon task fails when the committed JSON Schema differs
from regenerated output. Run it from the repository root with
`mise exec -- moon run root:cue --summary minimal`.

JSON Schema is a best-effort compatibility layer. It does not carry the exact
architecture-component and string-encoded content-size bounds, constraints on
unknown annotation values, or release-wide CUE constraints. It also cannot
check the external conformance requirements listed above. Neither schema
enforces producer-only registry, namespace, or lowercase spelling rules. When
CUE and JSON Schema validation differ, CUE controls.

Neither schema uses the imgoci public-value registry as an allowlist. Consumer
validation accepts unknown syntactically valid selector values, file-manifest
types, and annotation names, as Section 5 requires.

The schemas are released with the specification and conformance corpus. They
have no independent release version. The `v1` filenames correspond to the
imgoci v1 format. Retrieve them from an immutable imgoci-spec release when
reproducibility matters.
