# CUE validation fixtures

This directory contains complete release indexes derived from
[`spec.md`](../spec.md). The specification remains normative, and the canonical
CUE schema controls machine-readable validation.

The expected result is expressed by directory membership:

- `v1/pass/*.json` must be accepted by `#ReleaseIndex`;
- `v1/fail/*.json` must be rejected by `#ReleaseIndex`.

Each filename describes the behavior it covers. There is no inventory or case
metadata to keep synchronized.

Run every fixture from the repository root with:

```sh
mise exec -- sh conformance/check.sh
```

## Boundary

Pass and fail mean acceptance or rejection of a parsed release-index value.
CUE cannot inspect the original JSON bytes, fetch referenced objects, perform
selection or retrieval, decode file content, or observe repository state.
Those remain separate consumer and producer conformance concerns defined by
the specification.

To add coverage, copy the closest fixture into the appropriate directory,
change one behavior, and give the new file a descriptive name. Fixtures do not
assert implementation error text.

The corpus is released with the specification and has no independent version.
