# Releases

An imgoci-spec release is an immutable publication of `spec.md` together with
the schema and conformance artifacts at the same commit. The schema and corpus
do not have independent release versions.

Repository publication versions, the `.v1` imgoci artifact type, OCI
`schemaVersion`, and releases of the Go implementation are separate version
axes. A repository tag does not change the wire-format identifier unless
`spec.md` does so explicitly.

## Preparing a release

1. Choose a SemVer tag, using a prerelease suffix while the specification is a
   draft.
2. Update [`CHANGELOG.md`](CHANGELOG.md) for the publication.
3. Run the validation workflow against the exact release commit.
4. Review `spec.md`, the JSON Schema, every listed conformance case, and their
   authority labels together.
5. Create and push an immutable `v*` tag for that commit.
6. Let the release workflow build and attest the source publication archive,
   then publish the GitHub release.
7. Download the archive and verify its build-provenance attestation with
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

Published tags must not be moved or replaced. Corrections are published from a
new commit under a new tag.

The project has not established a release cadence or a supported-version
window.
