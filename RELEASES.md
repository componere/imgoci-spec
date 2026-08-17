# Releases

An imgoci-spec release is an immutable publication of `spec.md` together with
the schema and conformance artifacts at the same commit, and the licensing and
governance files that state the terms it is published under. The schema and
corpus do not have independent release versions.

Repository publication versions, the `.v1` imgoci artifact type, OCI
`schemaVersion`, and releases of the Go implementation are separate version
axes. A repository tag does not change the wire-format identifier unless
`spec.md` does so explicitly.

## Preparing a release

Release Please maintains a release pull request from Conventional Commits on
`master` and proposes stable `vX.Y.Z` versions. The specification does not use a
prerelease series.

1. Land release-worthy changes on `master` using Conventional Commit subjects.
2. Review the Release Please pull request, including its proposed version and
   [`CHANGELOG.md`](CHANGELOG.md) update.
3. Run the validation workflow against the exact release commit and review
   `spec.md`, the canonical CUE schema, the generated JSON Schema, every listed
   conformance case, and their authority labels together.
4. Merge the release pull request. Release Please creates the immutable `v*`
   tag and a draft GitHub release.
5. Let the tag-triggered release workflow build and attest the source
   publication archive, upload it to the draft, and publish the GitHub release.
6. Download the archive and verify its build-provenance attestation with
   GitHub CLI:

   ```sh
   gh release verify <tag> -R imgoci/spec
   gh release verify-asset <tag> <archive> -R imgoci/spec
   gh attestation verify <archive> \
     -R imgoci/spec \
     --signer-workflow imgoci/spec/.github/workflows/release.yml \
     --source-ref refs/tags/<tag> \
     --deny-self-hosted-runners
   ```

Manual dispatch of the release workflow is a rehearsal: it validates, packages,
and attests an artifact without publishing a GitHub release.

Release Please authenticates as the `imgoci-release-please` GitHub App so
its tags trigger the publication workflow. The App installation requires
`contents`, `issues`, and `pull requests` write permissions. The repository
stores its client ID in `IMGOCI_RELEASE_APP_CLIENT_ID` and its private key in
the `IMGOCI_RELEASE_APP_PRIVATE_KEY` Actions secret.

`force-tag-creation` in
[`release-please-config.json`](release-please-config.json) makes Release Please
push the `v*` tag itself, which is what starts the publication workflow. `draft`
keeps the GitHub release unpublished until that workflow attaches the attested
archive; it does not mark the release a prerelease.

Published tags must not be moved or replaced. Corrections are published from a
new commit under a new tag.

The project has not established a release cadence or a supported-version
window.
