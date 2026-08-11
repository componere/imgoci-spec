#!/bin/sh

set -u

root=$(cd "$(dirname "$0")/.." && pwd)
schema="$root/schema"
fixture_result=0
pass_count=0
fail_count=0

for fixture in "$root"/conformance/v1/pass/*.json; do
	pass_count=$((pass_count + 1))
	if ! (cd "$schema" && cue vet -c -d '#ReleaseIndex' . "$fixture"); then
		echo "unexpected rejection: $fixture" >&2
		fixture_result=1
	fi
done

for fixture in "$root"/conformance/v1/fail/*.json; do
	fail_count=$((fail_count + 1))
	if (cd "$schema" && cue vet -c -d '#ReleaseIndex' . "$fixture") >/dev/null 2>&1; then
		echo "unexpected acceptance: $fixture" >&2
		fixture_result=1
	fi
done

if test "$fixture_result" -eq 0; then
	printf 'validated %s passing and %s failing release indexes\n' \
		"$pass_count" "$fail_count"
fi

exit "$fixture_result"
