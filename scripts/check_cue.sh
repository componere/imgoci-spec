#!/bin/sh

set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
schema="$root/schema"
generated=$(mktemp)
trap 'rm -f "$generated"' EXIT

(
	cd "$schema"
	cue fmt --check --files .
	cue mod tidy --check
	cue vet -c ./...
	cue def --force --out jsonschema \
		-e '#ReleaseIndexJSONSchema' \
		-o "$generated" \
		.
)

if ! diff -u "$schema/release-index-v1.schema.json" "$generated"; then
	echo 'generated JSON Schema is stale' >&2
	exit 1
fi

sh "$root/conformance/check.sh"
echo 'CUE schema, generated projection, and fixture corpus are valid'
