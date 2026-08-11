# imgoci release format v1

Status: draft, 2026-08-10

This document defines the imgoci release format.

The words `must`, `must not`, `should`, and `may` state requirements,
prohibitions, recommendations, and permissions.

## 1. Scope

An imgoci release contains one or more OS image files. The release and its
files are stored in one OCI repository.

The format lets a consumer:

- find a deliverable by architecture, target, and representation;
- find each file in that deliverable by role;
- choose among stored encodings of the same file;
- verify the size and SHA-256 digest of the decoded content; and
- store a file as one OCI blob by default and use BigOCI when multipart storage
  is needed.

This specification does not define:

- integration with an existing image reader or engine;
- a compatibility adapter for another catalog or schema;
- image conversion, installation, or boot behavior;
- the contents of a disk image, filesystem image, or boot artifact;
- a signature format, attestation format, trust policy, or key format;
- tag discovery, version ordering, or a channel catalog;
- sparse-file restoration, delta transfer, update policy, or revocation; or
- an index that groups several releases.

Another catalog may be mapped into imgoci. This does not make that catalog's
reader compatible with imgoci objects.

## 2. Terms

Examples do not define new selector values.

| Term | Meaning | Examples |
|---|---|---|
| Release | One named and versioned set of deliverables. | `ExampleOS` version `42.1`. |
| Release index | The OCI image index that describes a release. | The index at `registry.example.com/os/example:42.1`. |
| Deliverable | All file entries with the same architecture, target, and representation. | `amd64`, `qemu`, and `qcow2`. |
| File entry | One descriptor in the release index. | A descriptor for the `disk` role using `zstd` compression. |
| File | All transport alternatives with the same deliverable key and role. | The `disk` role across its `none` and `zstd` alternatives. |
| Transport alternative | One stored encoding of a file. A consumer first filters by supported file-manifest type, then selects by compression. | The `zstd` encoding of a `disk` file. |
| Architecture | The CPU instruction set required by a deliverable. | `amd64` or `arm64`. |
| Target | The boot or import environment for which a deliverable was built. | `qemu` or `metal`. |
| Representation | The form a consumer requests, such as a disk format or a coordinated network-boot set. | `qcow2` or `pxe`. |
| Role | The purpose of one file in a deliverable. | `disk`, `kernel`, or `initramfs`. |
| File manifest | An OCI image manifest that describes one stored file. | A standard imgoci file manifest or a BigOCI file manifest. |
| Stored file | The bytes referenced by a standard file manifest or assembled from a BigOCI file manifest. These bytes may be compressed. | A zstd stream stored as one OCI blob. |
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
             file manifest
                    |
                    +-- standard imgoci v1: one file layer
                    |
                    +-- BigOCI v1: two or more ordered parts
~~~

A release index must contain only imgoci file entries. It must not mix file
entries with container images or compatibility descriptors.

Every file entry emitted by an imgoci v1 producer must point to either a
standard imgoci file manifest or a BigOCI File Format v1 manifest. A consumer
must support the standard format. BigOCI support is optional.

The standard imgoci file manifest is the default. A producer should use it
when the selected repository and delivery path can store and retrieve the
stored file as one blob. A producer may use BigOCI when the stored file is too
large for that path to handle reliably as one blob. An imgoci BigOCI manifest
must contain at least two parts. A producer must use the standard file manifest
instead of a one-part BigOCI manifest.

imgoci v1 does not set a numeric threshold for BigOCI. Repository limits and
delivery conditions vary. The layout decision uses the stored-file size after
any imgoci compression, not the decoded-content size.

The producer chooses one file-manifest format for each transport alternative.
The file-entry descriptor declares that format with
`io.imgoci.file.manifest-type`. The annotation is capability metadata, not a
selector. It does not change file or deliverable identity and does not permit
two entries with the same selector tuple. A producer must set it to the exact
top-level `artifactType` of the referenced manifest.

The release index, file manifests, and blobs must be in the same OCI
repository.

A file-entry descriptor must not contain an OCI `platform` object.
`io.imgoci.architecture` is the only architecture value used by this format.
This leaves one source of architecture metadata. This specification does not
define how a general OCI image client handles the index.

### 3.1 Standard file manifest

A standard imgoci file manifest stores the complete stored file as one OCI
blob. It must conform to the OCI image manifest and contain only these
members:

- `schemaVersion` with the number `2`;
- `mediaType` with `application/vnd.oci.image.manifest.v1+json`;
- `artifactType` with `application/vnd.imgoci.file.v1`;
- `config` with the OCI empty descriptor; and
- `layers` with exactly one file-layer descriptor.

The `config` member must identify the OCI empty descriptor with only these
members:

~~~json
{
  "digest": "sha256:44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a",
  "mediaType": "application/vnd.oci.empty.v1+json",
  "size": 2
}
~~~

The referenced config blob contains the two bytes `{}`.

The file-layer descriptor must contain only `mediaType`, `digest`, and
`size`. Its `mediaType` must be `application/octet-stream`. Its `digest` must
be `sha256:` followed by 64 lowercase hexadecimal digits. Its `size` must be a
JSON integer from 0 through 9007199254740991.

The manifest, its config descriptor, and its file-layer descriptor must not
contain other members. The complete member set is fixed, so a standard file
manifest is a function of its layer digest and layer size alone. Section 9
defines its canonical encoding.

The layer references the stored file without a wrapper, split, or transform
beyond the compression declared by the file entry. Its repository blob URL
identifies the complete stored file without assembly. When `compression=none`,
those bytes are also the decoded content.

## 4. Media types

| Use | Field | Required value |
|---|---|---|
| Release index | `mediaType` | `application/vnd.oci.image.index.v1+json` |
| Release index | `artifactType` | `application/vnd.imgoci.release.v1` |
| File-entry descriptor | `mediaType` | `application/vnd.oci.image.manifest.v1+json` |
| Standard file manifest | `artifactType` | `application/vnd.imgoci.file.v1` |
| Standard file config | `mediaType` | `application/vnd.oci.empty.v1+json` |
| Standard file layer | `mediaType` | `application/octet-stream` |
| BigOCI file manifest | `artifactType` | `application/vnd.bigoci.file.v1` |
| BigOCI part | `mediaType` | `application/vnd.bigoci.file.part.v1` |

`application/vnd.imgoci.release.v1` and `application/vnd.imgoci.file.v1` are
the type identifiers defined by imgoci v1. The `.v1` suffix is the schema
version. A breaking change requires a new type identifier.

Standard file manifests use the shape in section 3.1.
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
| `io.imgoci.name` | Stable product identifier shared by all releases of that product. |
| `org.opencontainers.image.version` | Producer-assigned release version. |

`io.imgoci.name` must be a basic token as defined in section 5.3.

`org.opencontainers.image.version` must contain 1 to 128 printable ASCII
characters. It must not contain whitespace or control characters. The version
is metadata. This specification does not define a tag mapping or version
order.

The canonical release-index digest identifies the encoded release. The name
and version label that object.

### 5.2 File-entry descriptor

A file-entry descriptor must contain only these members:

- `mediaType`;
- `digest`;
- `size`; and
- `annotations`.

The descriptor must not contain `artifactType`, `data`, `platform`, or `urls`.
The `io.imgoci.file.manifest-type` annotation declares the referenced
manifest's top-level `artifactType` before the consumer fetches it.
A producer must set the annotation to the exact value in the referenced
manifest.

`digest` must be `sha256:` followed by 64 lowercase hexadecimal digits.

`size` must be a JSON integer from 1 through 9007199254740991. It is the byte
length of the referenced file manifest, not the file content.

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
| `io.imgoci.file.manifest-type` | Top-level `artifactType` of the referenced file manifest. |
| `org.opencontainers.image.title` | Safe basename for the decoded content. |

A missing or invalid required annotation makes the whole release index
invalid.

Other annotation keys are allowed on the release index and file-entry
descriptors. Keys beginning with `io.imgoci.` are reserved for this
specification. An imgoci v1 object must not use an undefined key in that
namespace. Other annotations do not affect selection, but they affect the
release-index digest. A producer that needs a reproducible digest should not
add annotations whose values can differ across otherwise identical release
indexes.

### 5.3 Value syntax

A basic token contains 1 to 128 ASCII bytes and must match:

~~~text
^[a-z0-9]+([._-][a-z0-9]+)*$
~~~

`target`, `representation`, `role`, and `compression` values must be
basic tokens.

An architecture value must contain either one basic token or two basic tokens
separated by `/`. For a public first token, a producer must use the OCI Image
Index `platform.architecture` spelling. For a public second token, the producer
must use the OCI `platform.variant` spelling. A producer-defined architecture
must use a private `x-` token. Examples include `amd64`, `arm64`, and `arm/v7`.
Consumers validate architecture values by syntax, not by a fixed list.

`io.imgoci.content.digest` must be `sha256:` followed by 64 lowercase
hexadecimal digits.

`io.imgoci.content.size` must be a string matching
`^(0|[1-9][0-9]*)$`. Its value must not exceed 9223372036854775807.

`io.imgoci.file.manifest-type` must contain a media type that conforms to RFC
6838. An imgoci v1 producer must use `application/vnd.imgoci.file.v1` or
`application/vnd.bigoci.file.v1`. A consumer must preserve any other
syntactically valid value during discovery and treat it as unsupported during
resolution unless a supported addendum defines it.

Public selector values are append-only, and their meanings must not change.
They are defined only in this specification or a later imgoci addendum. When a
public value matches the producer's intended meaning, the producer must use it.
The producer must not define a private synonym for that value. Other
producer-defined selector values must use `x-<owner>-<name>`. This naming rule
does not apply to `io.imgoci.name` or the release version.

The public-value registry applies to producer conformance, not to consumer
validation of selector values. A consumer must accept every syntactically valid
value and compare values exactly. During discovery, it must preserve and return
unknown values. An operation that must interpret an unknown value may report
the value as unsupported.

imgoci v1 has no wildcard values. A query matches every value for a field only
when it omits that field. A producer must not assign special wildcard meaning
to `any`, `*`, or another token.

To classify one file for more than one architecture or target, a producer emits
one descriptor for each value. Those descriptors may share one file-manifest
digest.

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
release-index shape. A new public value must satisfy section 5.3.

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
| `incus` | Incus. |
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

These values identify environment families. They do not guarantee
compatibility with every version or configuration of the named environment. If
a known difference affects whether the deliverable can be booted or imported
and neither architecture nor representation expresses it, a producer must use
a more specific target. A producer may use any combination of target,
architecture, and representation that describes the deliverable.

#### Representations

| Value | Required roles | Required decoded form |
|---|---|---|
| `raw` | `disk` | One raw disk image for a disk with 512-byte logical sectors. |
| `raw-4kn` | `disk` | One raw disk image for a 4K-native disk with 4096-byte logical sectors. |
| `qcow2` | `disk` | One standalone QCOW2 version 2 or 3 disk image with no backing file or external data file. |
| `incus-vm` | `disk`, `metadata` | One split Incus virtual-machine image. `disk` is a standalone QCOW2 version 2 or 3 disk image with no backing file or external data file. `metadata` is an XZ-compressed Incus metadata tar archive. |
| `iso` | `disk` | One optical-disc image that conforms to ECMA-119. |
| `pxe` | `kernel`, `initramfs`, `rootfs` | One coordinated network-boot set. |

An `incus-vm` deliverable must use `target=incus`. Its metadata tar archive and
contents must conform to the Incus Image Format. The archive must contain
`metadata.yaml` at its root and may contain a `templates/` directory. It must
not contain the root disk; the `disk` role carries that file.

The XZ stream is part of the decoded `metadata` content. An entry that stores
the XZ stream directly uses `compression=none`. If an entry applies an imgoci
compression, decoding it must produce the exact XZ stream.

A deliverable using a standard representation must contain every required role
listed for that representation. It may contain other roles. Those roles do not
change the representation. A consumer does not need them to consume the
representation. An addendum that defines another representation must define
its decoded form and required roles.

Representation and compression are separate. A compound source label such as
`qcow2.xz` does not become an imgoci representation value.

If a wrapper remains part of the selected deliverable form, it is part of the
representation, not the compression. If the stored file has no outer transform
beyond the representation, the entry uses `compression=none`. The entry may use
private representation and role values until an imgoci addendum defines public
values for that form.

#### Compression

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

| Value | Meaning |
|---|---|
| `disk` | A disk or optical-media image. |
| `kernel` | A boot kernel. |
| `initramfs` | An initial RAM filesystem. |
| `metadata` | Metadata and templates required to import or run the other files in a deliverable. |
| `rootfs` | A root filesystem used with other boot files. |

Adding a role does not require a new release media type.

### 5.5 Value meaning

Architecture identifies the CPU instruction set. It does not identify a
hypervisor, cloud, firmware, or disk format.

Target identifies the intended boot or import environment. A target value must
distinguish known environment differences that affect whether a deliverable
can be used and are not properties of architecture or representation. OS
product identity does not belong in a target value.

Representation identifies the form requested by a consumer. It may describe
one file, such as `qcow2`, or a coordinated file set, such as `pxe`.

Role identifies one file inside a deliverable. Two files in one deliverable
must use different roles.

Compression describes only the transform between the stored file and the
content. It must not select a different logical file.

## 6. Release validity

A consumer must validate the complete release index before it selects a
deliverable.

Release-index validation checks `io.imgoci.file.manifest-type` syntax and
cross-entry consistency without fetching referenced manifests. The consumer
checks the declared type against each selected manifest during retrieval as
required by section 8.

The release index is invalid if any of these conditions is true:

1. The root object does not satisfy section 5.1.
2. A descriptor does not satisfy section 5.2.
3. A required value does not satisfy section 5.3.
4. A deliverable using a standard representation is missing a required role or
   uses a target forbidden by that representation in section 5.4.
5. Two entries have the same
   `(architecture, target, representation, role, compression)` tuple.
6. Transport alternatives for one file have different content digests,
   content sizes, or titles.
7. Two different roles in one deliverable have the same title.
8. Two descriptors with the same file-manifest digest disagree on
   descriptor media type, descriptor size, file-manifest type, compression,
   content digest, or content size.
9. The descriptor array is not in the canonical order defined in section 9.
10. The index bytes are not in the canonical form defined in section 9.

Descriptors that share a file-manifest digest may differ in architecture,
target, representation, role, and title. This allows one stored file to be
classified for more than one deliverable without copying it.

If an index is invalid, a consumer must reject the entire index. It must not
ignore an invalid entry and continue with the remaining entries.

## 7. Discovery and selection

Discovery and resolution are separate operations. A broad query returns
matches. It does not choose one.

A consumer's supported file-manifest types are a capability set. The set must
contain `application/vnd.imgoci.file.v1`. It contains
`application/vnd.bigoci.file.v1` only when the consumer supports BigOCI. A
supported addendum may add other values to the set. A consumer can compare
this set with `io.imgoci.file.manifest-type` without fetching the referenced
manifests.

### 7.1 Fetch the release

The caller supplies an OCI reference.

Before fetching the release, a consumer must validate the query. Every query
value must satisfy section 5.3. If present, a role list must be non-empty and
must not contain duplicates. For a resolve query, the accepted-compression
list must be non-empty and contain no duplicates.

A consumer must:

1. fetch the referenced release index;
2. compute the SHA-256 digest of the exact response bytes;
3. if the caller supplied a digest reference, require the computed digest to
   match the digest in that reference;
4. if the registry provides a manifest digest, require that digest to match the
   computed SHA-256 digest;
5. use the computed digest to pin a tag reference;
6. validate the complete release index; and
7. use digest references for all later fetches.

Selection requires one release-index retrieval after registry authentication.
It can require more than one network round trip.

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
available transport alternatives for each role. Each alternative includes its
compression and file-manifest type. Deliverables must be sorted by their keys.
Roles within a deliverable must be sorted by role. Alternatives within a role
must be sorted by compression. Each comparison uses ascending UTF-8 byte order.

Listing must not remove alternatives because the consumer does not support
their file-manifest type. It exposes those types so the caller can filter or
report them without fetching the file manifests.

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
   specification or a supported addendum. If no such definition is known,
   select every role;
4. require every requested role when a role list is present;
5. return `role not found` without a partial result when a selected role is
   absent;
6. inspect the transport alternatives for each selected role;
7. remove alternatives whose `io.imgoci.file.manifest-type` is not in the
   consumer's supported file-manifest types;
8. return `file manifest type not supported` without a partial result when a
   selected role has no remaining alternative;
9. choose the first accepted compression that exists among the remaining
   alternatives for that role; and
10. return `compression not available` without a partial result when a role
    has no accepted alternative.

For steps 6 through 10, the consumer must complete each step for every selected
role before starting the next step. Any failure returns no roles.

An accepted-compression list with one item is an exact compression request. A
consumer may select different compressions for different roles.

For example, a standard-only consumer removes a BigOCI `zstd` alternative
before compression selection. If the next accepted compression uses the
standard manifest type, the consumer selects it. This is selection, not
post-retrieval fallback.

The producer does not mark one compression as preferred. Every transport
alternative for a file has the same content digest, size, and title.

Before decoding content, a consumer must stop if it does not support the
selected compression. An operation that needs to interpret a representation or
role may report the representation or role value as unsupported. A consumer may
still list, mirror, or verify stored files whose selector values it does not
understand.

## 8. Retrieval and verification

A consumer must fetch each selected file manifest by digest. It must verify the
fetched manifest's SHA-256 digest against the file-entry descriptor digest and
its byte length against the descriptor size.

The consumer must require the manifest's top-level `artifactType` to equal the
descriptor's `io.imgoci.file.manifest-type`. A mismatch is invalid producer
output and fails the complete resolved result.

The consumer must then inspect the manifest's `artifactType` and recover the
stored file as follows:

1. For `application/vnd.imgoci.file.v1`, validate the manifest against section
   3.1 and reject it if its bytes are not in the canonical form defined in
   section 9. Fetch its file layer and verify the layer digest and size. The
   layer bytes are the stored file.
2. For `application/vnd.bigoci.file.v1`, validate the manifest against BigOCI
   File Format v1 and require at least two parts. Fetch the parts in any order,
   verify each part's digest and size, assemble them in manifest order, and
   verify the assembled digest and size as required by BigOCI. The assembled
   bytes are the stored file.
3. For another syntactically valid value, use the rules from a supported
   addendum or return `file manifest type not supported`. Reject a missing or
   syntactically invalid `artifactType`.

After recovering the complete stored file, the consumer must:

1. apply the declared compression decoder;
2. count and hash decoded bytes while writing them;
3. stop if decoded output exceeds `io.imgoci.content.size`; and
4. require the final decoded size and SHA-256 digest to match the corresponding
   file-entry annotations.

When `compression=none`, the standard file-layer digest and size or the BigOCI
whole-file digest and size must equal the corresponding imgoci content digest
and size.

The file-entry title names the decoded output. A BigOCI title is informational
only and has no imgoci meaning.

A consumer must not treat a file as verified before it passes every required
check. A manifest-type mismatch, decoding failure, or integrity failure is not
a selection failure. It fails the complete resolved result. The consumer must
not select another transport alternative in response. This specification does
not define network retries.

## 9. Deterministic encoding

A producer must encode a standard imgoci file manifest with the JSON
Canonicalization Scheme in RFC 8785. Section 3.1 fixes the complete member
set, so the same stored file produces the same standard file manifest, byte
for byte, and the same digest. The layer-size limit in section 3.1 and the
descriptor-size limit in section 5.2 keep every number in these objects
exactly representable under RFC 8785.

BigOCI file manifests use the canonical encoding defined by BigOCI File Format
v1. imgoci must not add fields to them or re-encode them.

Before encoding a release index, a producer must validate it against rules 1
through 8 in section 6.

The producer must sort `manifests` by this tuple:

~~~text
(architecture, target, representation, role, compression)
~~~

Each tuple field is compared by ascending UTF-8 byte order.

The producer must then encode the full release index with the JSON
Canonicalization Scheme in RFC 8785. The producer sends the compact canonical
bytes to the registry.

A consumer must validate all ten rules in section 6 and reject an index whose
descriptor order or JSON encoding is not canonical.

The same release-index fields, descriptors, and annotations produce the same
index bytes and digest. Equal decoded content can still produce different OCI
graphs. The resulting digests also depend on the file-manifest format,
compressed bytes, descriptor metadata, and other annotations. BigOCI manifests
also depend on part size and BigOCI title.

## 10. References and tags

The caller supplies a tag or digest. imgoci v1 does not derive a tag from
`org.opencontainers.image.version`.

A digest reference used by imgoci v1 must use SHA-256.

A tag is a lookup name, not the identity of a release.

Version comparison, tag escaping, tag listing, and multi-release catalogs
are outside this specification.

## 11. External OCI artifacts

Release indexes and file manifests are content-addressed OCI objects. Another
OCI artifact may name either digest as its subject.

imgoci does not define that artifact's format, discovery, verification, copy
behavior, or trust policy. External artifacts do not change the meaning of an
imgoci release.

## 12. Conformance

A conforming producer must emit objects that satisfy this document. A
conforming consumer must reject objects that do not satisfy it.

Non-normative conformance artifacts may include a JSON Schema, positive
fixtures, and negative fixtures. A JSON Schema can check structure and field
syntax. Fixtures can cover cross-entry rules, canonical bytes, selection,
file-manifest validation, and decoded-content verification.

## 13. Non-normative examples

The examples are pretty-printed for reading. Their digests are placeholders
with valid syntax. A producer sends the compact RFC 8785 form of the release
index and of the standard file manifest.

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
        "io.imgoci.file.manifest-type": "application/vnd.imgoci.file.v1",
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

The file entry above points to a standard file manifest such as:

~~~json
{
  "artifactType": "application/vnd.imgoci.file.v1",
  "config": {
    "digest": "sha256:44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a",
    "mediaType": "application/vnd.oci.empty.v1+json",
    "size": 2
  },
  "layers": [
    {
      "digest": "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
      "mediaType": "application/octet-stream",
      "size": 123456789
    }
  ],
  "mediaType": "application/vnd.oci.image.manifest.v1+json",
  "schemaVersion": 2
}
~~~

The sole layer holds the complete stored xz stream. For a stored file that
needs multipart storage, the same release-index descriptor shape may instead
point to a BigOCI manifest with at least two parts.

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
- [OCI Image Format, image manifest](https://github.com/opencontainers/image-spec/blob/v1.1.1/manifest.md)
- [OCI Image Format, descriptor](https://github.com/opencontainers/image-spec/blob/v1.1.1/descriptor.md)
- [OCI Distribution Specification v1.1.1](https://github.com/opencontainers/distribution-spec/blob/v1.1.1/spec.md)
- [RFC 6838: Media Type Specifications and Registration Procedures](https://www.rfc-editor.org/rfc/rfc6838.html)
- [BigOCI File Format v1](https://github.com/componere/bigoci/blob/v0.1.0/docs/docs/reference/format.md)
- [RFC 1952: GZIP file format](https://www.rfc-editor.org/rfc/rfc1952.html)
- [XZ file format](https://tukaani.org/xz/xz-file-format.txt)
- [RFC 8878: Zstandard compression](https://www.rfc-editor.org/rfc/rfc8878.html)
- [RFC 8785: JSON Canonicalization Scheme](https://www.rfc-editor.org/rfc/rfc8785.html)
- [QEMU v11.0.3 QCOW2 Image File Format](https://gitlab.com/qemu-project/qemu/-/blob/v11.0.3/docs/interop/qcow2.rst)
- [ECMA-119, 6th edition](https://ecma-international.org/wp-content/uploads/ECMA-119_6th_edition_december_2025.pdf)
- [Incus 7.0 Image Format](https://github.com/lxc/incus/blob/v7.0.0/doc/reference/image_format.md)
