# Releases

An imgoci-spec release is an immutable publication of `spec.md` together with
the schema and conformance artifacts at the same commit. The schema and corpus
do not have independent release versions.

Repository publication versions, the `.v1` imgoci artifact type, OCI
`schemaVersion`, and releases of the Go implementation are separate version
axes. A repository tag does not change the wire-format identifier unless
`spec.md` does so explicitly.

## Preparing a release

Release Please maintains a release pull request from Conventional Commits on
`master`. While the specification remains a draft, it proposes versions with a
`draft.N` prerelease suffix, beginning with `v0.1.0-draft.1`.

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
   gh release verify <tag> -R componere/imgoci-spec
   gh release verify-asset <tag> <archive> -R componere/imgoci-spec
   gh attestation verify <archive> \
     -R componere/imgoci-spec \
     --signer-workflow componere/imgoci-spec/.github/workflows/release.yml \
     --source-ref refs/tags/<tag> \
     --deny-self-hosted-runners
   ```

Manual dispatch of the release workflow is a rehearsal: it validates, packages,
and attests an artifact without publishing a GitHub release.

Release Please authenticates as the `componere-release-please` GitHub App so
its tags trigger the publication workflow. The App installation requires
`contents`, `issues`, and `pull requests` write permissions. The repository
stores its client ID in `COMPONERE_RELEASE_APP_CLIENT_ID` and its private key in
the `COMPONERE_RELEASE_APP_PRIVATE_KEY` Actions secret.

When the specification becomes stable, set `prerelease` to `false` in
[`release-please-config.json`](release-please-config.json); the next release
promotes the current draft to a stable version.

Published tags must not be moved or replaced. Corrections are published from a
new commit under a new tag.

The project has not established a release cadence or a supported-version
window.
