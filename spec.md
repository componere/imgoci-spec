# imgoci release format v1

Status: draft, 2026-08-16

License: Community Specification License 1.0
([`LICENSE-COMMUNITY-SPEC`](LICENSE-COMMUNITY-SPEC)).

This document defines the imgoci release format.

The words `must`, `must not`, `should`, and `may` state requirements,
prohibitions, recommendations, and permissions.

## 1. Scope

An imgoci release contains one or more OS image files. The release and its
files are stored in one OCI repository.

The format lets a consumer:

- find a deliverable by architecture, target, representation, and usage;
- find each file in that deliverable by role;
- choose among stored encodings of the same file;
- verify the size and SHA-256 digest of the decoded content; and
- store a file as one OCI blob by default and use BigOCI when multipart storage
  is needed.

This specification does not define:

- integration with an existing image reader or engine;
- a compatibility adapter for another catalog or schema;
- image conversion or the implementation of installation or boot behavior;
- decoded-content structure beyond the representation requirements in section
  5.4;
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
| Deliverable | All file entries with the same architecture, target, representation, and usage set. | `amd64`, `metal`, `iso`, and `install,install-offline`. |
| File entry | One descriptor in the release index. | A descriptor for the `disk` role using `zstd` compression. |
| File | All transport alternatives with the same deliverable key and role. | The `disk` role across its `none` and `zstd` alternatives. |
| Transport alternative | One stored encoding of a file. A consumer first filters by supported file-manifest type, then selects by compression. | The `zstd` encoding of a `disk` file. |
| Architecture | The CPU instruction set required by a deliverable. | `amd64` or `arm64`. |
| Target | The boot or import environment for which a deliverable was built. | `qemu` or `metal`. |
| Representation | The form a consumer requests, such as a disk format or a coordinated network-boot set. | `qcow2` or `linux-netboot`. |
| Usage | The producer-asserted ways in which a deliverable can be used. | `live` or `install,install-offline`. |
| Role | The purpose of one file in a deliverable. | `disk`, `kernel`, or `initramfs`. |
| File manifest | An OCI image manifest that describes one stored file. | A standard imgoci file manifest or a BigOCI file manifest. |
| Stored file | The bytes referenced by a standard file manifest or assembled from a BigOCI file manifest. These bytes may be compressed. | A zstd stream stored as one OCI blob. |
| Content | The bytes produced after decoding the stored file. | The qcow2 bytes produced by decoding a zstd stored file. |
| Reference | An OCI tag or digest supplied by the caller. | `registry.example.com/os/example:42.1` or a digest reference. |

The deliverable key is:

~~~text
(architecture, target, representation, usage)
~~~

The file key is:

~~~text
(architecture, target, representation, usage, role)
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
                    |
                    +-- another format supported by the consumer
~~~

A release index must contain only imgoci file entries. It must not mix file
entries with container images or compatibility descriptors.

imgoci v1 directly defines the standard imgoci file manifest and the BigOCI
File Format v1 manifest. A consumer must support the standard format. BigOCI
support is optional. An imgoci addendum or private extension may define another
file-manifest format. A producer may use it when its intended consumers support
that format.

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
The file-entry descriptor declares that format with its OCI `artifactType`
member. This is capability metadata, not a selector. It does not change file or
deliverable identity and does not permit two entries with the same selector
tuple. A producer must set it to the same media type as the referenced
manifest's top-level `artifactType`.

OCI Image Specification v1.1.1 gives two related rules. Its generic descriptor
text derives `artifactType` for an image manifest from the config media type.
Its image-manifest guidance treats the top-level `artifactType` as the artifact
type. OCI Distribution v1.1.1 also uses the top-level value first for referrer
descriptors. imgoci uses this top-level-first rule for file-entry descriptors.
For imgoci file entries, this rule controls where the OCI texts differ. Both
file-manifest formats defined by imgoci v1 require a top-level `artifactType`,
so the config fallback does not apply.

A producer must publish the release index and every manifest and blob reachable
from it in the same OCI repository. A consumer must use that repository for the
fetches required by sections 7 and 8. Ordinary resolution and retrieval do not
require the consumer to fetch unselected entries or traverse the complete
referenced object graph.

An imgoci consumer must not reject a supported OCI object or descriptor because
its `annotations` map contains an unknown key. Unknown annotation keys have no
imgoci-defined meaning.

An imgoci producer must not put an OCI `platform` object in a file-entry
descriptor.
`io.imgoci.architecture` is the only architecture value used by this format.
This leaves one source of architecture metadata. This specification does not
define how a general OCI image client handles the index.

### 3.1 Standard file manifest

A standard imgoci file manifest stores the complete stored file as one OCI
blob. It must conform to the OCI image manifest and contain these members. An
imgoci producer must not add other top-level members:

- `schemaVersion` with the number `2`;
- `mediaType` with `application/vnd.oci.image.manifest.v1+json`;
- `artifactType` with `application/vnd.imgoci.file.v1`;
- `config` with the OCI empty descriptor; and
- `layers` with exactly one file-layer descriptor.

The `config` member must identify the OCI empty descriptor with these members.
An imgoci producer must not add other members:

~~~json
{
  "digest": "sha256:44136fa355b3678a1146ad16f7e8649e94fb4fc21fe77e8310c060f61caaff8a",
  "mediaType": "application/vnd.oci.empty.v1+json",
  "size": 2
}
~~~

The referenced config blob contains the two bytes `{}`.

The file-layer descriptor must contain `mediaType`, `digest`, and `size`. An
imgoci producer must not add other members. Its `mediaType` must be
`application/octet-stream`. Its `digest` must be `sha256:` followed by 64
lowercase hexadecimal digits. Its `size` must be a JSON integer from 0 through
9007199254740991.

A consumer must accept additional members on the manifest, config descriptor,
or file-layer descriptor. It must apply this section's rules to the defined
members and ignore other members for imgoci behavior. An `annotations` member,
when present, must map string keys to string values. Unknown annotation keys
have no imgoci-defined meaning, but they affect the encoded bytes and manifest
digest. Additional members also affect those bytes and digest and must satisfy
the canonical encoding rule in section 9.

The producer member sets are fixed. A conforming producer's standard file
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
| File-entry descriptor | `artifactType` | Top-level `artifactType` of the referenced file manifest |
| Standard file manifest | `artifactType` | `application/vnd.imgoci.file.v1` |
| Standard file config | `mediaType` | `application/vnd.oci.empty.v1+json` |
| Standard file layer | `mediaType` | `application/octet-stream` |
| BigOCI file manifest | `artifactType` | `application/vnd.bigoci.file.v1` |
| BigOCI part | `mediaType` | `application/vnd.bigoci.file.part.v1` |

`application/vnd.imgoci.release.v1` and `application/vnd.imgoci.file.v1` are
the type identifiers defined by imgoci v1. The `.v1` suffix is the schema
version. A breaking change requires a new type identifier.

An imgoci producer must use the lowercase spellings defined in this document.
A consumer must compare media types without regard to ASCII letter case. RFC
6838 defines the type and subtype as case-insensitive. The media types accepted
by this document do not contain parameters. All media-type comparisons in this
document use this rule.

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

An imgoci producer must not add other top-level members. A consumer must accept
an otherwise valid release index with additional top-level members and ignore
them for imgoci behavior.

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

A file-entry descriptor must contain these members:

- `mediaType`;
- `digest`;
- `size`;
- `artifactType`; and
- `annotations`.

An imgoci producer must not add other members, including `data`, `platform`, or
`urls`. A consumer must accept an otherwise valid descriptor with additional
members and ignore them when interpreting the release. `artifactType` declares
the referenced manifest's top-level `artifactType` before the consumer fetches
it. A producer must set it to the same media type as that top-level member.

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
| `io.imgoci.filename` | Producer-chosen filename for the decoded content. |

`io.imgoci.usage` is an optional deliverable usage selector. Its absence
represents the empty usage set.

A missing or invalid required annotation makes the whole release index
invalid.

Other annotation keys are allowed on release indexes and file-entry
descriptors. The `io.imgoci.` namespace is reserved for this specification and
its addenda. A producer must not emit a key in that namespace unless this
specification or an addendum defines it. This is a producer rule. A consumer
must not reject an object because it contains an unknown annotation key,
including an unknown `io.imgoci.` key. Unknown annotations do not affect
selection, but all annotations affect the release-index digest. A producer that
needs a reproducible digest should not add annotations whose values can differ
across otherwise identical release indexes.

An annotation's imgoci syntax and meaning apply only at an object location
where this specification or an addendum defines that annotation. At another
annotation location, a consumer must treat the same key as an unknown
annotation. A producer must not emit a defined annotation at another location
unless this specification or an addendum also defines it there.

Consumer-ignored members and annotations remain part of the encoded release
index. They affect its digest and must satisfy the canonical encoding rule in
section 9.

### 5.3 Value syntax

A basic token contains 1 to 128 ASCII bytes and must match:

~~~text
^[a-z0-9]+([._-][a-z0-9]+)*$
~~~

`target`, `representation`, `role`, and `compression` values must be basic
tokens.

A present `io.imgoci.usage` value contains one or more unique basic tokens. If
it contains more than one token, exactly one ASCII comma with no whitespace
must separate each adjacent pair. The tokens must appear in strictly ascending
UTF-8 byte order, and the complete value must contain no more than 4096 ASCII
bytes. The annotation must be omitted for the empty usage set. A present empty
string is invalid.

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

A file-entry descriptor's `artifactType` must contain an RFC 6838 type and
subtype without parameters. imgoci v1 defines
`application/vnd.imgoci.file.v1` and `application/vnd.bigoci.file.v1`. A
imgoci addendum or private extension may define another syntactically valid
value. A consumer must preserve every other syntactically valid value during
discovery. During resolution, it treats a value as unsupported unless it
supports that file-manifest format.

Public target, representation, usage, role, and compression values are
append-only. Their meanings must not change. These imgoci-owned values are
defined only in this specification or a later imgoci addendum. Public
architecture spellings come from OCI as described above. When a public
selector value matches the producer's intended meaning, the producer must use
it. The producer must not define a private synonym for that value. Other
producer-defined selector values must use `x-<owner>-<name>`. This naming rule
does not apply to `io.imgoci.name` or the release version.

The imgoci-owned public-value registry applies to producer conformance, not to
consumer validation of selector values. A consumer must accept every
syntactically valid value and compare selector values exactly. During
discovery, it must preserve and return unknown values. An operation that must
interpret an unknown value may report the value as unsupported.

imgoci v1 has no wildcard values. A query matches every value for a field only
when it omits that field. A producer must not assign special wildcard meaning
to `any`, `*`, or another token.

To classify one file for more than one deliverable, such as two architectures,
two targets, or two usage sets, a producer emits one descriptor for each
deliverable. Those descriptors may share one file-manifest digest.

A filename must match:

~~~text
^[a-z0-9]([a-z0-9._+-]{0,253}[a-z0-9])?$
~~~

A filename is one path component. It must not be `.` or `..`. This syntax does
not guarantee that the value is valid on every filesystem. A consumer must
apply destination-specific rules before using it as a local filename and may
map it to another local name. A consumer must not parse a filename to discover
architecture, target, representation, usage, role, or compression.

### 5.4 Standard selector values

The tables in this section define the initial public values owned by imgoci for
targets, representations, usage, compression, and roles. Public architecture
spellings come from OCI as described in section 5.3. A later compatible
revision or addendum may add an imgoci-owned public value without changing the
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
| `linux-netboot` | `kernel` | One Linux network-boot set. `kernel` is a bootable Linux kernel. Separate initial RAM filesystem and root filesystem files use the optional `initramfs` and `rootfs` roles. |

An `incus-vm` deliverable must use `target=incus`. Its metadata tar archive and
contents must conform to the Incus Image Format. The archive must contain
`metadata.yaml` at its root and may contain a `templates/` directory. It must
not contain the root disk; the `disk` role carries that file.

The XZ stream is part of the decoded `metadata` content. An entry that stores
the XZ stream directly uses `compression=none`. If an entry applies an imgoci
compression, decoding it must produce the exact XZ stream.

`linux-netboot` identifies Linux boot files, not the mechanism that retrieves
them. PXE, UEFI HTTP Boot, and other network-boot mechanisms are outside this
specification. The boot loader, boot-server configuration, deployed file
locations, and kernel command line are also outside this specification.
The kernel may contain an embedded initramfs. An initramfs, whether embedded
or separate, may provide the complete root filesystem.

A producer must assign architecture, target, representation, and role values
that describe the decoded content and deliverable. It must declare usage values
as specified under Usage. When it uses a standard representation, the decoded
content must have the form listed in the table.
During imgoci validation and retrieval, a consumer verifies transport
structure, decoding, size, and digest as specified in section 8. It is not
required to parse decoded content to confirm the declared selectors, role, or
representation-internal structure. Format-specific validation performed when
importing, booting, or otherwise using decoded content is outside this
specification.

A deliverable using a standard representation must contain every required role
listed for that representation. It may contain other roles. Those roles do not
change the representation. Unless the representation definition says
otherwise, a consumer does not need them to consume the representation. Every
role in a `linux-netboot` deliverable is part of its coordinated boot set. An
addendum that defines another representation must define its decoded form and
required roles.

Representation and compression are separate. A compound source label such as
`qcow2.xz` does not become an imgoci representation value.

If a wrapper remains part of the selected deliverable form, it is part of the
representation, not the compression. If the stored file has no outer transform
beyond the representation, the entry uses `compression=none`. The entry may use
private representation and role values until an imgoci addendum defines public
values for that form.

#### Usage

Usage values are capabilities and may be combined.

| Value | Meaning |
|---|---|
| `live` | The deliverable can boot and run an OS session without first installing the release on persistent storage. |
| `install` | The deliverable can install the release on persistent storage separate from the source used to run the installer. |
| `install-offline` | The deliverable can complete the producer-defined baseline installation while network connectivity is unavailable. |

A producer must declare every standard usage value that applies to a
deliverable. `install-offline` requires `install`; both values must appear in
the serialized usage set. A consumer must reject a usage set that contains
`install-offline` without `install`.

The baseline includes every update, registration, or activation that the
producer requires to complete installation. It excludes optional instances of
those operations. Usage values apply independently of representation. A
preinstalled disk image is not `live` solely because it can boot without an
installation step.

Usage values are producer assertions. imgoci validation and retrieval do not
execute the deliverable or prove that it has the asserted behavior.

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

A `zstd` stored file must not require a dictionary for decoding.

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
one file, such as `qcow2`, or a coordinated file set, such as
`linux-netboot`.

Usage identifies the producer-asserted ways in which a deliverable can be used.
The complete usage set distinguishes deliverables that otherwise have the same
architecture, target, and representation.

Role identifies one file inside a deliverable. Two files in one deliverable
must use different roles.

Compression describes only the transform between the stored file and the
content. It must not select a different logical file.

## 6. Release validity

A consumer must validate the complete release index before it selects a
deliverable. Consumer validation applies the structural, value, and cross-entry
rules in this section. It does not apply requirements stated only for
producers.

Release-index validation checks file-entry descriptor `artifactType` syntax
and cross-entry consistency without fetching referenced manifests. It accepts
unknown annotations and syntactically valid unknown file-manifest types. The
consumer checks the declared type against each selected manifest during
retrieval as required by section 8.

The release index is invalid for a consumer if any of these conditions is true:

1. The root object violates a consumer-validation requirement in section 5.1.
2. A descriptor violates a consumer-validation requirement in section 5.2.
3. A required value does not satisfy the syntax in section 5.3.
4. A deliverable using a standard representation is missing a required role or
   uses a target forbidden by that representation in section 5.4, or a usage
   set violates a standard usage-value relationship in section 5.4.
5. Two entries have the same
   `(architecture, target, representation, usage, role, compression)` tuple.
6. Transport alternatives for one file have different content digests,
   content sizes, or filenames.
7. Two different roles in one deliverable have the same filename.
8. Two descriptors with the same file-manifest digest disagree on descriptor
   media type or artifact type under section 4, or disagree on descriptor size,
   compression, content digest, or content size.
9. The descriptor array is not in the canonical order defined in section 9.
10. The index bytes are not in the canonical form defined in section 9.

Producer-only requirements are not consumer-validation requirements. These
include fixed producer member sets, reserved annotation names, public selector
naming, and lowercase media-type spelling.

Descriptors that share a file-manifest digest may differ in architecture,
target, representation, usage, role, and filename. This allows one stored file
to be classified for more than one deliverable without copying it.

If an index is invalid, a consumer must reject the entire index. It must not
ignore an invalid entry and continue with the remaining entries.

## 7. Discovery and selection

Discovery and resolution are separate operations. A broad query returns
matches. It does not choose one.

A consumer's supported file-manifest types are a capability set. The set must
contain `application/vnd.imgoci.file.v1`. It contains
`application/vnd.bigoci.file.v1` only when the consumer supports BigOCI. A
consumer may add any other file-manifest format it supports. A consumer can
compare this set with a file-entry descriptor's `artifactType` without fetching
the referenced manifests. That comparison follows the media-type rule in
section 4.

### 7.1 Fetch the release

The caller supplies an OCI reference.

Before fetching the release, a consumer must validate the query. Every query
value must satisfy section 5.3. A usage list or role list must not contain
duplicates. A usage list in a list query, when present, must be non-empty. A
resolve query must contain a usage list, which may be empty. A role list, when
present, must be non-empty. For a resolve query, the accepted-compression list
must be non-empty and contain no duplicates. Every value in that list must name
a compression that the consumer can decode. List order runs from most preferred
to least preferred.

A consumer must fetch the release index with an OCI Distribution manifest
`GET` request. The request must contain:

~~~text
Accept: application/vnd.oci.image.index.v1+json
~~~

Every manifest and blob `GET` request in sections 7.1 and 8 must contain:

~~~text
Accept-Encoding: identity
~~~

If a response to one of these requests contains a `Content-Encoding` field, its
value must contain only `identity`. The `identity` value does not change the
response content. For every manifest fetch in sections 7.1 and 8, the manifest
bytes are the response content before parsing JSON. A consumer must use these
bytes without re-encoding them for every digest and byte-length calculation.

A consumer must:

1. require a `200 OK` response;
2. require the response `Content-Type`, after ignoring its parameters, to
   identify `application/vnd.oci.image.index.v1+json` under section 4;
3. compute the SHA-256 digest of the manifest bytes;
4. if the caller supplied a digest reference, require the computed digest to
   match the digest in that reference;
5. if the registry sends a `Docker-Content-Digest` header, either ignore it or
   verify it against the manifest bytes with the digest algorithm named in its
   value;
6. parse the manifest bytes and require its top-level `mediaType` to identify
   the same media type as the response `Content-Type` under section 4;
7. validate the complete release index;
8. if the caller supplied a tag, record the computed SHA-256 digest as the
   resolved release reference for this operation; and
9. use digest references for all later fetches.

The `Docker-Content-Digest` header may use an algorithm other than SHA-256. A
consumer that uses the header must verify its value with that algorithm. It
must not compare that value with the computed SHA-256 digest when the algorithms
differ.

Selection requires one release-index retrieval after registry authentication.
It can require more than one network round trip.

### 7.2 List deliverables

A list query may contain:

- architecture;
- target;
- representation;
- one or more usage values that each result must contain; and
- one or more roles.

Every supplied scalar value is an exact, case-sensitive filter. An omitted
scalar field matches every value. An omitted usage list matches every usage
set. A deliverable matches a usage filter only if its usage set contains every
requested value.

A deliverable matches a role filter only if it contains every requested role.

The result must include every matching deliverable, its exact usage set, its
roles, and the available transport alternatives for each role. Deliverables
must be sorted by their keys. Roles within a deliverable must be sorted by
role. Alternatives within a role must be sorted by compression. Each
comparison uses ascending UTF-8 byte order.

Listing must not remove alternatives because the consumer does not support
their file-manifest type. It exposes those types so the caller can filter or
report them without fetching the file manifests.

An empty list is a valid result.

For example, a query that supplies only `representation=qcow2` lists every
deliverable with that representation.

### 7.3 Resolve one deliverable

A resolve query must contain an exact architecture, target, representation,
and complete usage set. The usage set may be empty. The query may contain a
role list. It must contain the accepted-compression list defined in section
7.1.

A consumer must:

1. find the deliverable with the exact requested key, including exact usage-set
   equality;
2. fail without a result if it does not exist;
3. when the role list is present, select exactly the requested roles;
4. when the role list is omitted for `linux-netboot`, select every role;
5. when the role list is omitted for another representation, select the
   required roles defined by this specification or a supported addendum. If no
   such definition is known, select every role;
6. fail without a partial result when a selected role is absent;
7. inspect the transport alternatives for each selected role;
8. remove alternatives whose descriptor `artifactType` is not in the consumer's
   supported file-manifest types;
9. fail without a partial result when a selected role has no remaining
   alternative;
10. choose the first accepted compression that exists among the remaining
    alternatives for that role; and
11. fail without a partial result when a selected role has no accepted
    alternative.

For steps 7 through 11, the consumer must complete each step for every selected
role before starting the next step. Any failure returns no roles.

A present role list always limits the resolved result to those roles. For
example, requesting only `initramfs` from a `linux-netboot` deliverable selects
only `initramfs`, not the required `kernel` role.

An accepted-compression list with one item is an exact compression request. A
consumer may select different compressions for different roles.

For example, a standard-only consumer removes a BigOCI `zstd` alternative
before compression selection. If the next accepted compression uses the
standard manifest type, the consumer selects it. This is selection, not
post-retrieval fallback.

The producer does not mark one compression as preferred. Every transport
alternative for a file has the same content digest, size, and filename.

An operation that needs to interpret a representation, usage value, or role may
report the value as unsupported. A consumer may still list, mirror, or verify
stored-file and decoded-content integrity when it does not understand the
selector values.

## 8. Retrieval and verification

A consumer must fetch each selected file manifest by its descriptor digest with
an OCI Distribution manifest `GET` request. The request must contain an
`Accept` header whose value is the descriptor's `mediaType`.

The consumer must apply the manifest-byte definition in section 7.1 and:

1. require a `200 OK` response;
2. verify the SHA-256 digest and byte length of the manifest bytes against the
   file-entry descriptor;
3. if the registry sends a `Docker-Content-Digest` header, apply the rule in
   section 7.1; and
4. parse the manifest bytes and require the response `Content-Type`, after
   ignoring its parameters, and the manifest's top-level `mediaType` to identify
   the same media type as the descriptor's `mediaType` under section 4.

A failure in these checks fails the complete resolved result.

The consumer must require the manifest's top-level `artifactType` and the
descriptor's `artifactType` to identify the same media type under section 4. A
mismatch is invalid producer output and fails the complete resolved result.

The consumer must then inspect the manifest's `artifactType` and recover the
stored file as follows:

1. For `application/vnd.imgoci.file.v1`, validate the manifest against section
   3.1 and reject it if its bytes are not in the canonical form defined in
   section 9. Fetch its file layer and verify the layer digest and size. The
   layer bytes are the stored file.
2. For `application/vnd.bigoci.file.v1`, validate the manifest against BigOCI
   File Format v1 and require at least two parts. Fetch the parts in any order,
   verify each part's digest and size, assemble them in manifest order, and
   verify the SHA-256 digest and byte length of the assembled bytes against the
   manifest's `io.bigoci.file.digest` and `io.bigoci.file.size` annotations. The
   assembled bytes are the stored file.
3. For another syntactically valid value, use the rules for that format when the
   consumer supports it. Otherwise, fail the complete resolved result because
   the file-manifest type is unsupported. Reject a missing or syntactically
   invalid `artifactType`.

After recovering the complete stored file, the consumer must:

1. apply the declared compression decoder;
2. count and hash decoded bytes while writing them;
3. stop if decoded output exceeds `io.imgoci.content.size`; and
4. require the final decoded size and SHA-256 digest to match the corresponding
   file-entry annotations.

When `compression=none`, the standard file-layer digest and size or the BigOCI
whole-file digest and size must equal the corresponding imgoci content digest
and size.

The `io.imgoci.filename` annotation names the decoded output. A BigOCI title is
informational only and has no imgoci meaning.

A consumer must not treat a file as having passed imgoci retrieval verification
before it passes every required check. A manifest-type mismatch, decoding
failure, or integrity failure is not a selection failure. It fails the complete
resolved result. The consumer must not select another transport alternative in
response. This specification does not define network retries.

## 9. Deterministic encoding

A producer must encode a standard imgoci file manifest with the JSON
Canonicalization Scheme in RFC 8785. Section 3.1 fixes the producer member set,
so the same stored file produces the same standard file manifest, byte for
byte, and the same digest. The layer-size limit in section 3.1 and the
descriptor-size limit in section 5.2 keep every number in these objects exactly
representable under RFC 8785.

BigOCI file manifests use the canonical encoding defined by BigOCI File Format
v1. imgoci must not add fields to them or re-encode them.

Before encoding a release index, a producer must validate it against rules 1
through 8 in section 6.

The producer must sort `manifests` by this tuple:

~~~text
(architecture, target, representation, usage, role, compression)
~~~

Each tuple field is compared by ascending UTF-8 byte order. For `usage`, the
producer compares the canonical serialized value and uses the empty string when
the annotation is absent.

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

When a producer publishes a release index under a tag, the same release-index
bytes must be retrievable from the same repository by their SHA-256 digest.

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

A conforming producer must follow every producer requirement in this document.
A conforming consumer must follow every consumer requirement. A producer-only
requirement does not by itself make an otherwise valid object invalid for a
consumer.

Non-normative conformance artifacts may include a JSON Schema, positive
fixtures, and negative fixtures. A JSON Schema can check structure and field
syntax. Fixtures can cover cross-entry rules, canonical bytes, selection,
file-manifest validation, and decoded-content digest and size verification.

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
        "io.imgoci.filename": "exampleos-42.1.qcow2",
        "io.imgoci.representation": "qcow2",
        "io.imgoci.role": "disk",
        "io.imgoci.target": "qemu"
      },
      "artifactType": "application/vnd.imgoci.file.v1",
      "digest": "sha256:1111111111111111111111111111111111111111111111111111111111111111",
      "mediaType": "application/vnd.oci.image.manifest.v1+json",
      "size": 427
    }
  ],
  "mediaType": "application/vnd.oci.image.index.v1+json",
  "schemaVersion": 2
}
~~~

The file entry omits `io.imgoci.usage`, so it belongs to the empty usage set.

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

A Linux network-boot deliverable may use three entries with one deliverable key
and three roles:

| Architecture | Target | Representation | Usage | Role |
|---|---|---|---|---|
| `amd64` | `metal` | `linux-netboot` | empty set | `kernel` |
| `amd64` | `metal` | `linux-netboot` | empty set | `initramfs` |
| `amd64` | `metal` | `linux-netboot` | empty set | `rootfs` |

Each row is a separate file entry. The `kernel` role is required. The
`initramfs` and `rootfs` roles are optional. Each role may have one or more
compression alternatives. A resolve query that omits the role list selects
every role present.

## 14. Normative references

- [OCI Image Format, image index](https://github.com/opencontainers/image-spec/blob/v1.1.1/image-index.md)
- [OCI Image Format, image manifest](https://github.com/opencontainers/image-spec/blob/v1.1.1/manifest.md)
- [OCI Image Format, descriptor](https://github.com/opencontainers/image-spec/blob/v1.1.1/descriptor.md)
- [OCI Distribution Specification v1.1.1](https://github.com/opencontainers/distribution-spec/blob/v1.1.1/spec.md)
- [RFC 9110: HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110.html)
- [RFC 6838: Media Type Specifications and Registration Procedures](https://www.rfc-editor.org/rfc/rfc6838.html)
- [BigOCI File Format v1](https://github.com/imgoci/bigoci/blob/v0.1.0/docs/docs/reference/format.md)
- [RFC 1952: GZIP file format](https://www.rfc-editor.org/rfc/rfc1952.html)
- [The .xz File Format, version 1.2.1](https://tukaani.org/xz/xz-file-format-1.2.1.txt)
- [RFC 8878: Zstandard compression](https://www.rfc-editor.org/rfc/rfc8878.html)
- [RFC 8785: JSON Canonicalization Scheme](https://www.rfc-editor.org/rfc/rfc8785.html)
- [QEMU v11.0.3 QCOW2 Image File Format](https://gitlab.com/qemu-project/qemu/-/blob/v11.0.3/docs/interop/qcow2.rst)
- [ECMA-119, 6th edition](https://ecma-international.org/wp-content/uploads/ECMA-119_6th_edition_december_2025.pdf)
- [Incus 7.0 Image Format](https://github.com/lxc/incus/blob/v7.0.0/doc/reference/image_format.md)
