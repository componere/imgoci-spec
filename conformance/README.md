# Conformance cases

This directory contains official, informative cases derived from
[`spec.md`](../spec.md). The specification is normative and controls if a case,
the canonical CUE schema, or case metadata disagrees with the text.

`v1/cases.json` is the complete inventory for the initial corpus. Each listed
directory contains:

- `case.json`: language-neutral case metadata;
- `index.json`: the exact release-index input bytes; and
- `expected.json`: a minimal expected observation, when the operation returns
  a selection.

`case.schema.json` validates case metadata only. It is not a schema for an
imgoci object.

## Harness boundary

The draft does not define serialized validator, query, or result APIs. Fields
such as `operation`, `input`, `expected`, and `selections` are corpus
bookkeeping that lets implementations map the cases into their own APIs. They
are not imgoci wire-format members and do not add requirements to the
specification.

Cases assert document validity, whole-index rejection, or the selected role,
compression, file-manifest type, and manifest digest. They do not assert
implementation error strings.

Repository CI checks the case inventory, metadata schemas, referenced files,
declared JSON Schema result, canonical CUE validation for applicable parsed
values, and declared RFC 8785 byte state. It does not execute resolution cases.
A consumer conformance runner must execute those outcomes through the
consumer's own API.

`schemaValid` records whether the generated release-index JSON Schema is
expected to accept the parsed value. It does not record canonical CUE validity.
`canonicalJson` records whether the original bytes are expected to equal their
RFC 8785 encoding. These observations are separate because JSON Schema cannot
test cross-entry relationships or original byte encoding.

## Exact bytes

Canonical `index.json` fixtures end immediately after the final `}` with no
trailing newline. The non-canonical fixture deliberately preserves readable
whitespace and a final newline. Tools must inspect the original bytes before
parsing or reserializing them.

## Initial scope

The five initial cases cover:

- one structurally and canonically valid release index;
- one missing required annotation;
- one duplicate selector tuple;
- one non-canonical JSON encoding; and
- file-manifest capability filtering before compression preference during
  resolution.

They exercise the corpus shape; they do not establish complete producer or
consumer conformance. In particular, they do not include a producer input
model, referenced file manifests, agreement between file-manifest-type
annotations and referenced `artifactType` values, standard file layers, BigOCI
parts, decoding, or retrieval graphs. Those should be added only when they can
be derived from specification text and represented without defining a new
implementation API.

The corpus is released with the specification and has no independent version.
