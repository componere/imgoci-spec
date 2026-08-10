# imgoci release format v1

Status: draft, 2026-08-10

This document defines the imgoci release format.

The words `must`, `must not`, `should`, and `may` state requirements,
prohibitions, recommendations, and permissions.

## 1. Scope

imgoci describes a release made of one or more OS-image files. It stores the
release and its files in one OCI repository.

The format lets a consumer:

- find a deliverable by architecture, target, and representation;
- find each file in that deliverable by role;
- choose among stored encodings of the same file;
- verify the size and SHA-256 digest of the decoded content; and
- use one-part or multi-part BigOCI files without changing the release shape.

This specification does not define:

- integration with an existing image reader or engine;
- a compatibility adapter for another catalog or schema;
- image conversion, installation, or boot behavior;
- the contents of a disk image, filesystem image, or boot artifact;
- a signature format, attestation format, trust policy, or key format;
- tag discovery, version ordering, or a channel catalog;
- sparse-file restoration, delta transfer, update policy, or revocation; or
- an index that groups several releases.

Another catalog may be mapped into imgoci. That mapping does not mean that the
catalog's existing reader can read imgoci objects.

## 2. Terms

Examples are illustrative. They do not define new selector values.

| Term | Meaning | Examples |
|---|---|---|
| Release | One named and versioned set of deliverables. | `ExampleOS` version `42.1`. |
| Release index | The OCI image index that describes a release. | The index at `registry.example.com/os/example:42.1`. |
| Deliverable | All file entries with the same architecture, target, and representation. | `amd64`, `qemu`, and `qcow2`. |
| File entry | One descriptor in the release index. | A descriptor for the `disk` role using `zstd` compression. |
| File | All transport alternatives with the same deliverable key and role. | The `disk` role across its `none` and `zstd` alternatives. |
| Transport alternative | One stored encoding of a file. It is selected by compression. | The `zstd` encoding of a `disk` file. |
| Architecture | The CPU instruction set required by a deliverable. | `amd64` or `arm64`. |
| Target | The boot or import environment for which a deliverable was built. | `qemu` or `metal`. |
| Representation | The form requested by a consumer, such as a disk format or a coordinated network-boot set. | `qcow2` or `pxe`. |
| Role | The purpose of one file in a deliverable. | `disk`, `kernel`, or `initramfs`. |
| Stored file | The bytes assembled from a BigOCI manifest. These bytes may be compressed. | A zstd stream reconstructed from BigOCI parts. |
| Content | The bytes produced after decoding the stored file. | The qcow2 bytes produced by decoding a zstd stored file. |
| Reference | An OCI tag or digest supplied by the caller. | `registry.example.com/os/example:42.1` or a digest reference. |

The deliverable key is:

~~~text
(architecture, target, representation)
~~~

The file key is:

~~~text
(architecture, target, representation, role)
~~~

## 3. Object model

~~~text
release tag or digest
        |
        v
OCI image index
artifactType: application/vnd.imgoci.release.v1
        |
        +-- one descriptor for each transport alternative
                    |
                    v
             BigOCI v1 file manifest
             one or more ordered parts
~~~

A release index must contain only imgoci file entries. It must not mix file
entries with container images or compatibility descriptors.

Every file entry must point to a manifest that conforms to BigOCI File Format
v1. BigOCI uses one part for a small file and several parts for a large file.
imgoci defines no other leaf format.

The release index, file manifests, and blobs must be in the same OCI
repository.

A file-entry descriptor must not contain an OCI `platform` object.
`io.imgoci.architecture` is the only architecture value used by this format.
This rule prevents two sources of architecture metadata. It does not make a
claim about how a general OCI image client handles the index.

## 4. Media types

| Use | Field | Required value |
|---|---|---|
| Release index | `mediaType` | `application/vnd.oci.image.index.v1+json` |
| Release index | `artifactType` | `application/vnd.imgoci.release.v1` |
| File-entry descriptor | `mediaType` | `application/vnd.oci.image.manifest.v1+json` |
| BigOCI file manifest | `artifactType` | `application/vnd.bigoci.file.v1` |
| BigOCI part | `mediaType` | `application/vnd.bigoci.file.part.v1` |

`application/vnd.imgoci.release.v1` is the only type identifier defined by
imgoci v1. The `.v1` suffix is the schema version. A breaking change requires
a new type identifier.

BigOCI manifests use the media types and encoding defined by BigOCI File Format
v1. imgoci must not rewrite a BigOCI manifest.

## 5. Release index

### 5.1 Root object

A release index must contain these members:

| Member | Rule |
|---|---|
| `schemaVersion` | Must be the number `2`. |
| `mediaType` | Must use the release-index media type in section 4. |
| `artifactType` | Must use the release artifact type in section 4. |
| `manifests` | Must be a non-empty array of valid file-entry descriptors. |
| `annotations` | Must contain the two annotations below. |

A v1 release index must not contain other top-level members.

The required index annotations are:

| Annotation | Value |
|---|---|
| `io.imgoci.name` | Stable product identifier shared by its releases. |
| `org.opencontainers.image.version` | Producer-assigned release version. |

`io.imgoci.name` must be a basic token as defined in section 5.3.

`org.opencontainers.image.version` must contain 1 to 128 printable ASCII
characters. It must not contain whitespace or control characters. The version
is metadata. This specification does not define how it maps to a tag or how
two versions are ordered.

The canonical release-index digest identifies the encoded release. The name
and version label that object.

### 5.2 File-entry descriptor

A file-entry descriptor must contain only these members:

- `mediaType`;
- `digest`;
- `size`; and
- `annotations`.

The descriptor must not contain `artifactType`, `data`, `platform`, or `urls`.

`digest` must be `sha256:` followed by 64 lowercase hexadecimal digits.

`size` must be a JSON integer from 1 through 9007199254740991. It is the byte
length of the BigOCI manifest, not the file content.

Every file-entry descriptor must contain these annotations:

| Annotation | Value |
|---|---|
| `io.imgoci.architecture` | Architecture selector. |
| `io.imgoci.target` | Target selector. |
| `io.imgoci.representation` | Deliverable representation selector. |
| `io.imgoci.role` | File role. |
| `io.imgoci.compression` | Decoder applied to the stored file. |
| `io.imgoci.content.digest` | SHA-256 digest of the decoded content. |
| `io.imgoci.content.size` | Byte length of the decoded content. |
| `org.opencontainers.image.title` | Safe basename for the decoded content. |

A missing or invalid required annotation makes the whole release index
invalid.

Other annotation keys are allowed on the release index and file-entry
descriptors. Keys beginning with `io.imgoci.` are reserved for this
specification. An imgoci v1 object must not use an undefined key in that
namespace. Other annotations do not affect selection, but they affect the
release-index digest. A producer that needs a reproducible digest should not
add annotations whose values change.

### 5.3 Value syntax

A basic token contains 1 to 128 ASCII bytes and must match:

~~~text
^[a-z0-9]+([._-][a-z0-9]+)*$
~~~

`target`, `representation`, `role`, and `compression` values must be
basic tokens.

An architecture value must contain either one basic token or two basic tokens
separated by `/`. For a public first token, a producer must use the OCI Image
Index `platform.architecture` spelling. For a public second token, it must use
the OCI `platform.variant` spelling. A producer-defined architecture must use
a private `x-` token. Examples include `amd64`, `arm64`, and `arm/v7`.
Consumers validate architecture values by syntax, not by a fixed list.

`io.imgoci.content.digest` must be `sha256:` followed by 64 lowercase
hexadecimal digits.

`io.imgoci.content.size` must be a string matching
`^(0|[1-9][0-9]*)$`. Its value must be no greater than
9223372036854775807.

Public selector values adopted by imgoci are append-only. Their meanings must
not change. Public values are defined only in this specification or a later
imgoci addendum. A producer must use a public value when it has a matching
meaning. It must not define a private synonym for that value. Other
producer-defined selector values must use `x-<owner>-<name>`. This naming rule
does not apply to `io.imgoci.name` or the release version.

Producer conformance uses the public-value registry. Consumer validation does
not use it as an allowlist. A consumer must accept every syntactically valid
value and compare values exactly. During discovery, it must preserve and return
unknown values. An operation that must interpret an unknown value may report
the value as unsupported.

There are no wildcard values in imgoci v1. Omitting a query field is the only
way to make that field broad. A producer must not assign special wildcard
meaning to `any`, `*`, or another token.

To classify one file for more than one architecture or target, a producer emits
one descriptor for each value. Those descriptors may share one BigOCI digest.

A title must match:

~~~text
^[a-z0-9]([a-z0-9._+-]{0,253}[a-z0-9])?$
~~~

A title is one path component. It must not be `.` or `..`. A consumer must
not parse a title to discover architecture, target, representation, role, or
compression.

### 5.4 Standard selector values

The tables in this section define the initial public-value registry. A later
compatible revision or addendum may add a public value without changing the
release-index shape. A new public value must follow section 5.3.

The initial target names come from platform identifiers used by Fedora CoreOS.
This table defines those identifiers as imgoci values. Fedora CoreOS is not a
normative or runtime dependency. Later changes to Fedora CoreOS do not change
these definitions.

#### Targets

| Value | Environment |
|---|---|
| `aliyun` | Alibaba Cloud. |
| `applehv` | Apple Virtualization framework on macOS. |
| `aws` | Amazon Elastic Compute Cloud. |
| `azure` | Microsoft Azure. |
| `azurestack` | Microsoft Azure Stack. |
| `digitalocean` | DigitalOcean. |
| `exoscale` | Exoscale. |
| `gcp` | Google Compute Engine. |
| `hetzner` | Hetzner Cloud. |
| `hyperv` | Microsoft Hyper-V. |
| `ibmcloud` | IBM Cloud. |
| `kubevirt` | KubeVirt. |
| `metal` | Bare metal. |
| `nutanix` | Nutanix AHV. |
| `openstack` | OpenStack. |
| `oraclecloud` | Oracle Cloud Infrastructure. |
| `powervs` | IBM Power Virtual Server. |
| `proxmoxve` | Proxmox Virtual Environment. |
| `qemu` | QEMU or QEMU/KVM, directly or through libvirt. |
| `virtualbox` | Oracle VirtualBox. |
| `vmware` | VMware ESXi, Fusion, and Workstation. |
| `vultr` | Vultr. |

These values name environment families. They do not promise compatibility
with every version or configuration of the named environment. If a known
difference affects boot or import and architecture or representation does not
express it, a producer must use a more specific target. The registry does not
restrict target, architecture, and representation combinations. A producer may
use any combination that describes the deliverable.

#### Representations

| Value | Required roles | Required decoded form |
|---|---|---|
| `raw` | `disk` | One raw disk image for a disk with 512-byte logical sectors. |
| `raw-4kn` | `disk` | One raw disk image for a 4K-native disk with 4096-byte logical sectors. |
| `qcow2` | `disk` | One standalone QCOW2 version 2 or 3 disk image with no backing file or external data file. |
| `iso` | `disk` | One optical-disc image that conforms to ECMA-119. |
| `pxe` | `kernel`, `initramfs`, `rootfs` | One coordinated network-boot set. |

A deliverable using a standard representation must contain every required role
listed for that representation. It may contain additional roles. Additional
roles do not change the representation and are not required to consume it. An
addendum that defines another representation must define its decoded form and
required roles.

Representation and compression are separate. A compound source label such as
`qcow2.xz` does not become an imgoci representation value.

A wrapper that remains part of the selected deliverable form is part of the
representation, not its compression. When the stored file has no additional
outer transform, the entry uses `compression=none`. The entry may use private
representation and role values until an imgoci addendum defines public values
for that form.

#### Compression

The standard compression values are:

| Value | Decoded content |
|---|---|
| `none` | The stored file without a transform. |
| `gzip` | The output of one gzip member. |
| `xz` | The output of one xz stream. |
| `zstd` | The output of one non-skippable Zstandard frame. |

A stored file using `gzip`, `xz`, or `zstd` must contain exactly one member,
stream, or frame. A decoder must consume the complete stored file. It must
reject concatenated units, stream padding, skippable frames, and trailing
bytes.

#### Roles

The following standard roles are defined:

| Value | Meaning |
|---|---|
| `disk` | A disk or optical-media image. |
| `kernel` | A boot kernel. |
| `initramfs` | An initial RAM filesystem. |
| `rootfs` | A root filesystem used with other boot files. |

Roles are extensible. A new role does not require a new release media type.

### 5.5 Value meaning

Architecture identifies the CPU instruction set. It does not identify a
hypervisor, cloud, firmware, or disk format.

Target identifies the intended boot or import environment. A target value must
distinguish known environment differences that affect whether a deliverable
can be used and that architecture or representation does not express. OS
product identity does not belong in a target value.

Representation identifies the form requested by a consumer. It may describe
one file, such as `qcow2`, or a coordinated file set, such as `pxe`.
A representation may describe more than a byte-container format.

Role identifies one file inside a deliverable. Two distinct files in one
deliverable must use distinct roles.

Compression describes only the transform between the stored file and the
content. It must not select a different logical file.

## 6. Release validity

A consumer must validate the complete release index before it selects a
deliverable.

The release index is invalid if any of these conditions is true:

1. The root object breaks section 5.1.
2. A descriptor breaks section 5.2.
3. A required value breaks section 5.3.
4. A deliverable using a standard representation is missing a required role
   listed in section 5.4.
5. Two entries have the same
   `(architecture, target, representation, role, compression)` tuple.
6. Transport alternatives for one file have different content digests,
   content sizes, or titles.
7. Two different roles in one deliverable have the same title.
8. Two descriptors with the same BigOCI manifest digest disagree on
   descriptor media type, descriptor size, compression, content digest,
   or content size.
9. The descriptor array is not in the canonical order defined in section 9.
10. The index bytes are not in the canonical form defined in section 9.

Descriptors that share a BigOCI manifest digest may differ in architecture,
target, representation, role, and title. This allows one stored file to be
classified for more than one deliverable without copying it.

A consumer must reject the whole invalid index. It must not ignore a bad entry
and continue with the remaining entries.

## 7. Discovery and selection

Discovery and resolution are separate operations. A broad query returns
matches. It does not choose one.

### 7.1 Fetch the release

The caller supplies an OCI reference.

Before fetching the release, a consumer must validate the query. Every query
value must follow section 5.3. If present, a role list must be non-empty and
must not contain duplicates. A resolve query's accepted-compression list must
be non-empty and must not contain duplicates.

A consumer must:

1. fetch the referenced release index;
2. compute the SHA-256 digest of the exact response bytes;
3. require that digest to match when the caller supplied a digest reference;
4. when the registry provides a manifest digest, require it to be the computed
   SHA-256 digest;
5. use the computed digest to pin a tag reference;
6. validate the complete release index; and
7. use digest references for all later fetches.

Selection requires one release-index retrieval after registry authentication.
It may require more than one network round trip.

### 7.2 List deliverables

A list query may contain:

- architecture;
- target;
- representation; and
- one or more roles.

Every supplied value is an exact, case-sensitive filter. An omitted scalar
field matches every value.

A deliverable matches a role filter only if it contains every requested role.

The result must include every matching deliverable, its roles, and the
available compression values for each role. Deliverables must be sorted by
their keys. Roles within a deliverable must be sorted by role. Compression
values within a role must be sorted by compression. Each comparison uses
ascending UTF-8 byte order.

An empty list is a valid result.

For example, a query that supplies only `representation=qcow2` lists every
deliverable with that representation.

### 7.3 Resolve one deliverable

A resolve query must contain an exact architecture, target, and
representation. It may contain a role list. It must contain a non-empty,
ordered list of accepted compression values.

A consumer must:

1. find the deliverable with the exact requested key;
2. return `deliverable not found` if it does not exist;
3. when the role list is omitted, select the required roles defined by this
   specification or a supported addendum, or every role when no required-role
   definition is known;
4. require every requested role when a role list is present;
5. return `role not found` without a partial result when a requested role is
   absent;
6. inspect the transport alternatives for each selected role;
7. choose the first accepted compression that exists for that role; and
8. return `compression not available` without a partial result when a role
   has no accepted alternative.

A one-item accepted-compression list is an exact compression request.
Different roles may select different compressions.

The producer does not mark one compression as preferred. Every transport
alternative for a file produces the same content digest, size, and title.

Before decoding content, a consumer must stop if it does not support the
selected compression. An operation that needs to interpret a representation
or role may also report an unsupported value. A consumer may still list,
mirror, or verify stored files with unknown semantic selector values.

## 8. Retrieval and verification

A consumer must fetch each selected BigOCI manifest by digest.

For each selected file, the consumer must:

1. compare the fetched manifest's SHA-256 digest and byte length with the
   descriptor digest and size;
2. validate the manifest against BigOCI File Format v1;
3. fetch the parts in any order and verify each part digest and size;
4. assemble the parts in manifest order;
5. verify the assembled stored-file digest and size required by BigOCI;
6. apply the declared compression decoder to the complete stored file;
7. count and hash decoded bytes while writing them;
8. stop if decoded output exceeds `io.imgoci.content.size`; and
9. require the final decoded size and SHA-256 digest to equal the file-entry
   annotations.

When `compression=none`, the BigOCI whole-file digest and size must equal the
imgoci content digest and size.

The file-entry title names the decoded output. The BigOCI title remains
informational and has no imgoci meaning.

A consumer must not treat a file as verified until that file has passed every
required check. A decoding or integrity failure is not a selection miss. This
specification does not define retry or fallback policy.

## 9. Deterministic encoding

BigOCI leaves use the canonical encoding defined by BigOCI File Format v1.
imgoci must not add fields to them or re-encode them.

Before encoding a release index, a producer must validate rules 1 through 8 in
section 6.

The producer must sort `manifests` by this tuple:

~~~text
(architecture, target, representation, role, compression)
~~~

Each tuple field is compared by ascending UTF-8 byte order.

The producer must then encode the full release index with the JSON
Canonicalization Scheme in RFC 8785. The compact canonical bytes are the bytes
sent to the registry.

A consumer must validate all ten rules in section 6 and reject an index whose
descriptor order or JSON encoding is not canonical.

The same release-index fields, descriptors, and annotations produce the same
index bytes and digest. Equal decoded content can still produce different OCI
graphs. The resulting digests also depend on BigOCI part size, BigOCI title,
compressed bytes, descriptor metadata, and additional annotations.

## 10. References and tags

The caller supplies a tag or digest. imgoci v1 does not derive a tag from
`org.opencontainers.image.version`.

A digest reference used by imgoci v1 must use SHA-256.

A tag is a lookup name. It is not release identity.

Version comparison, tag escaping, tag enumeration, and multi-release catalogs
are outside this specification.

## 11. External OCI artifacts

Release indexes and BigOCI file manifests are content-addressed OCI objects.
Another OCI artifact may name either digest as its subject.

imgoci does not define that artifact's format, discovery, verification, copy
behavior, or trust policy. External artifacts do not change the meaning of an
imgoci release.

## 12. Conformance

A conforming producer must emit objects that satisfy this document. A
conforming consumer must reject objects that do not satisfy it.

Non-normative conformance artifacts may include a JSON Schema and positive and
negative fixtures. A JSON Schema can check structure and field syntax.
Fixtures can cover cross-entry rules, canonical bytes, selection, BigOCI
validation, and decoded-content verification.

## 13. Non-normative examples

This example is pretty-printed for reading. Its digests are placeholders with
valid syntax. A producer sends the compact RFC 8785 form.

~~~json
{
  "annotations": {
    "io.imgoci.name": "exampleos",
    "org.opencontainers.image.version": "42.1"
  },
  "artifactType": "application/vnd.imgoci.release.v1",
  "manifests": [
    {
      "annotations": {
        "io.imgoci.architecture": "amd64",
        "io.imgoci.compression": "xz",
        "io.imgoci.content.digest": "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        "io.imgoci.content.size": "8589934592",
        "io.imgoci.representation": "qcow2",
        "io.imgoci.role": "disk",
        "io.imgoci.target": "qemu",
        "org.opencontainers.image.title": "exampleos-42.1.qcow2"
      },
      "digest": "sha256:1111111111111111111111111111111111111111111111111111111111111111",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "size": 812
    }
  ],
  "mediaType": "application/vnd.oci.image.index.v1+json",
  "schemaVersion": 2
}
~~~

The descriptor may point to a one-part or multi-part BigOCI manifest. The
release-index shape is the same.

A coordinated network-boot deliverable uses three entries with one deliverable
key and three roles:

| Architecture | Target | Representation | Role |
|---|---|---|---|
| `amd64` | `metal` | `pxe` | `kernel` |
| `amd64` | `metal` | `pxe` | `initramfs` |
| `amd64` | `metal` | `pxe` | `rootfs` |

Each row is a separate file entry. Each role may have one or more compression
alternatives.

## 14. Normative references

- [OCI Image Format, image index](https://github.com/opencontainers/image-spec/blob/v1.1.1/image-index.md)
- [OCI Image Format, descriptor](https://github.com/opencontainers/image-spec/blob/v1.1.1/descriptor.md)
- [OCI Distribution Specification v1.1.1](https://github.com/opencontainers/distribution-spec/blob/v1.1.1/spec.md)
- [BigOCI File Format v1](https://github.com/componere/bigoci/blob/v0.1.0/docs/docs/reference/format.md)
- [RFC 1952: GZIP file format](https://www.rfc-editor.org/rfc/rfc1952.html)
- [XZ file format](https://tukaani.org/xz/xz-file-format.txt)
- [RFC 8878: Zstandard compression](https://www.rfc-editor.org/rfc/rfc8878.html)
- [RFC 8785: JSON Canonicalization Scheme](https://www.rfc-editor.org/rfc/rfc8785.html)
- [QEMU v11.0.3 QCOW2 Image File Format](https://gitlab.com/qemu-project/qemu/-/blob/v11.0.3/docs/interop/qcow2.rst)
- [ECMA-119, 6th edition](https://ecma-international.org/wp-content/uploads/ECMA-119_6th_edition_december_2025.pdf)

## 15. Informative references

- [Fedora CoreOS stable stream metadata, 2026-08-05](https://github.com/coreos/fedora-coreos-streams/blob/e914682fffa20695c07cf0960ee0d94b7b13de56/streams/stable.json)
- [Fedora CoreOS supported platforms, 2026-08-06](https://github.com/coreos/fedora-coreos-docs/blob/afda1621b344c17b98f1216d35cf8104ffe6e1ff/modules/ROOT/pages/platforms.adoc)
- [Fedora CoreOS bare-metal images, 2026-08-06](https://github.com/coreos/fedora-coreos-docs/blob/afda1621b344c17b98f1216d35cf8104ffe6e1ff/modules/ROOT/pages/bare-metal.adoc)
- [Fedora CoreOS live ISO and PXE reference, 2026-08-06](https://github.com/coreos/fedora-coreos-docs/blob/afda1621b344c17b98f1216d35cf8104ffe6e1ff/modules/ROOT/pages/live-reference.adoc)
