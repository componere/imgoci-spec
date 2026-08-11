@experiment(explicitopen)

package releaseindex

import (
	"list"
	"strconv"
	"strings"
)

// #ReleaseIndex is the canonical machine-readable schema for the value-level
// rules of an imgoci v1 release index. It validates the complete release index
// before a consumer selects a deliverable. Rules that require the original JSON
// bytes, referenced file manifests, or repository state remain conformance
// checks.
#ReleaseIndex: #ReleaseIndexShape & {
	// schemaVersion identifies the OCI image-index schema version and must be 2.
	schemaVersion!: 2 | error("schemaVersion must be 2")

	// mediaType identifies the object as an OCI image index.
	mediaType: #ReleaseIndexMediaType

	// artifactType identifies the object as an imgoci v1 release index.
	artifactType: #ReleaseArtifactType

	// manifests contains one file-entry descriptor for each transport
	// alternative. It must contain at least one file-entry descriptor.
	manifests!: [...#FileEntryDescriptor]
	if len(manifests) == 0 {
		manifests: error("manifests must contain at least one file-entry descriptor")
	}

	// annotations labels the release index with its stable product identifier and
	// producer-assigned release version. It may contain other OCI annotations.
	annotations!: #IndexAnnotations

	// Every standard representation must contain its required roles in each
	// deliverable that uses the representation.
	for entry in manifests {
		let architecture = entry.annotations["io.imgoci.architecture"]
		let target = entry.annotations["io.imgoci.target"]
		let representation = entry.annotations["io.imgoci.representation"]

		if representation == "raw" || representation == "raw-4kn" || representation == "qcow2" || representation == "iso" {
			if len([for candidate in manifests if candidate.annotations["io.imgoci.architecture"] == architecture && candidate.annotations["io.imgoci.target"] == target && candidate.annotations["io.imgoci.representation"] == representation && candidate.annotations["io.imgoci.role"] == "disk" {candidate}]) == 0 {
				manifests: error("deliverable \(architecture), \(target), \(representation) must contain the disk role")
			}
		}

		// incus-vm is the only standard representation with a required target.
		if representation == "incus-vm" {
			if target != "incus" {
				manifests: error("incus-vm deliverable \(architecture), \(target) must use target incus")
			}
			for requiredRole in ["disk", "metadata"] {
				if len([for candidate in manifests if candidate.annotations["io.imgoci.architecture"] == architecture && candidate.annotations["io.imgoci.target"] == target && candidate.annotations["io.imgoci.representation"] == representation && candidate.annotations["io.imgoci.role"] == requiredRole {candidate}]) == 0 {
					manifests: error("deliverable \(architecture), \(target), incus-vm must contain the \(requiredRole) role")
				}
			}
		}

		if representation == "linux-netboot" {
			if len([for candidate in manifests if candidate.annotations["io.imgoci.architecture"] == architecture && candidate.annotations["io.imgoci.target"] == target && candidate.annotations["io.imgoci.representation"] == representation && candidate.annotations["io.imgoci.role"] == "kernel" {candidate}]) == 0 {
				manifests: error("deliverable \(architecture), \(target), linux-netboot must contain the kernel role")
			}
		}
	}

	// Compare each pair of file entries once to enforce release-wide identity and
	// consistency rules.
	for leftIndex, left in manifests {
		for rightIndex, right in manifests {
			if leftIndex < rightIndex {
				let leftArchitecture = left.annotations["io.imgoci.architecture"]
				let leftTarget = left.annotations["io.imgoci.target"]
				let leftRepresentation = left.annotations["io.imgoci.representation"]
				let leftRole = left.annotations["io.imgoci.role"]
				let leftCompression = left.annotations["io.imgoci.compression"]
				let rightArchitecture = right.annotations["io.imgoci.architecture"]
				let rightTarget = right.annotations["io.imgoci.target"]
				let rightRepresentation = right.annotations["io.imgoci.representation"]
				let rightRole = right.annotations["io.imgoci.role"]
				let rightCompression = right.annotations["io.imgoci.compression"]
				let sameDeliverable = leftArchitecture == rightArchitecture && leftTarget == rightTarget && leftRepresentation == rightRepresentation
				let sameFile = sameDeliverable && leftRole == rightRole
				let sameTransportAlternative = sameFile && leftCompression == rightCompression

				if sameTransportAlternative {
					manifests: error("transport alternative \(rightArchitecture), \(rightTarget), \(rightRepresentation), \(rightRole), \(rightCompression) is duplicated")
				}

				if sameFile && (left.annotations["io.imgoci.content.digest"] != right.annotations["io.imgoci.content.digest"] || left.annotations["io.imgoci.content.size"] != right.annotations["io.imgoci.content.size"] || left.annotations["io.imgoci.filename"] != right.annotations["io.imgoci.filename"]) {
					manifests: error("transport alternatives for file \(rightArchitecture), \(rightTarget), \(rightRepresentation), \(rightRole) must have the same content digest, content size, and filename")
				}

				if sameDeliverable && leftRole != rightRole && left.annotations["io.imgoci.filename"] == right.annotations["io.imgoci.filename"] {
					manifests: error("different roles in deliverable \(rightArchitecture), \(rightTarget), \(rightRepresentation) must have different filenames")
				}

				if left.digest == right.digest && (strings.ToLower(left.mediaType) != strings.ToLower(right.mediaType) || left.size != right.size || strings.ToLower(left.artifactType) != strings.ToLower(right.artifactType) || leftCompression != rightCompression || left.annotations["io.imgoci.content.digest"] != right.annotations["io.imgoci.content.digest"] || left.annotations["io.imgoci.content.size"] != right.annotations["io.imgoci.content.size"]) {
					manifests: error("descriptors for file manifest \(right.digest) must agree on media type, descriptor size, artifact type, compression, content digest, and content size")
				}

				let leftOrderKey = "\(leftArchitecture)\u0000\(leftTarget)\u0000\(leftRepresentation)\u0000\(leftRole)\u0000\(leftCompression)"
				let rightOrderKey = "\(rightArchitecture)\u0000\(rightTarget)\u0000\(rightRepresentation)\u0000\(rightRole)\u0000\(rightCompression)"
				if leftOrderKey > rightOrderKey {
					manifests: error("manifests must be ordered by architecture, target, representation, role, and compression in ascending UTF-8 byte order")
				}
			}
		}
	}
}

// #ReleaseIndexJSONSchema is the best-effort JSON Schema compatibility
// projection. It preserves the required object shapes and local field constraints
// that CUE can translate without weakening #ReleaseIndex.
#ReleaseIndexJSONSchema: #ReleaseIndexShape

// #ReleaseIndexShape defines the release-index object and local field
// constraints used by the JSON Schema projection.
#ReleaseIndexShape: {
	...

	// schemaVersion identifies the OCI image-index schema version and must be 2.
	schemaVersion!: 2

	// mediaType identifies the object as an OCI image index.
	mediaType!: #ReleaseIndexMediaTypeConstraint

	// artifactType identifies the object as an imgoci v1 release index.
	artifactType!: #ReleaseArtifactTypeConstraint

	// manifests contains one file-entry descriptor for each transport
	// alternative. It must contain at least one file-entry descriptor.
	manifests!: [...#FileEntryDescriptorShape] & list.MinItems(1)

	// annotations labels the release index with its stable product identifier and
	// producer-assigned release version. It may contain other OCI annotations.
	annotations!: #IndexAnnotationsShape
}

// #FileEntryDescriptor is one descriptor in the release index. It points to a
// file manifest and adds CUE validation errors for invalid local values.
#FileEntryDescriptor: #FileEntryDescriptorShape & {
	// mediaType identifies the referenced object as an OCI image manifest.
	mediaType: #ImageManifestMediaType

	// digest is the SHA-256 digest of the referenced file manifest.
	digest: #SHA256Digest

	// size is the byte length of the referenced file manifest, not the file content.
	size: #ManifestSize

	// artifactType identifies the referenced file manifest's artifact type.
	artifactType: #MediaType

	// annotations describes the file entry and its decoded content.
	annotations: #FileEntryAnnotations

	let architectureParts = strings.Split(annotations["io.imgoci.architecture"] & #ArchitectureConstraint, "/")
	for architecturePart in architectureParts {
		if len(architecturePart) > 128 {
			annotations: {
				// _architectureValueError reports the per-token byte limit for the architecture selector.
				_architectureValueError: error("io.imgoci.architecture must contain no more than 128 ASCII bytes in each token")
			}
		}
	}

	if strconv.Atoi(annotations["io.imgoci.content.size"] & #ContentSizeConstraint) > 9223372036854775807 {
		annotations: {
			// _contentSizeValueError reports the decoded-content size limit for the file entry.
			_contentSizeValueError: error("io.imgoci.content.size must not exceed 9223372036854775807")
		}
	}
}

// #FileEntryDescriptorShape defines the file-entry descriptor and local
// field constraints used by the JSON Schema projection.
#FileEntryDescriptorShape: {
	...

	// mediaType identifies the referenced object as an OCI image manifest.
	mediaType!: #ImageManifestMediaTypeConstraint

	// digest is the SHA-256 digest of the referenced file manifest.
	digest!: #SHA256DigestConstraint

	// size is the byte length of the referenced file manifest, not the file content.
	size!: #ManifestSizeConstraint

	// artifactType identifies the referenced file manifest's artifact type.
	artifactType!: #MediaTypeConstraint

	// annotations describes the file entry and its decoded content.
	annotations!: #FileEntryAnnotationsShape
}

// #IndexAnnotations is the release-index annotation map. Only annotations
// defined for this object location receive imgoci value constraints.
#IndexAnnotations: {
	// io.imgoci.name is the stable product identifier shared by all releases of
	// that product.
	"io.imgoci.name"!: #BasicToken

	// org.opencontainers.image.version is the producer-assigned release version.
	// It is metadata; imgoci defines neither a tag mapping nor version order.
	"org.opencontainers.image.version"!: #ReleaseVersion

	// Consumer validation accepts every other annotation as an opaque string.
	[(string & !~"^(io\\.imgoci\\.name|org\\.opencontainers\\.image\\.version)$")]: string
}

// #IndexAnnotationsShape defines release-index annotation constraints used by
// the JSON Schema projection. The generator may omit constraints it cannot
// represent.
#IndexAnnotationsShape: {
	// io.imgoci.name is the stable product identifier shared by all releases of
	// that product.
	"io.imgoci.name"!: #BasicTokenConstraint

	// org.opencontainers.image.version is the producer-assigned release version.
	// It is metadata; imgoci defines neither a tag mapping nor version order.
	"org.opencontainers.image.version"!: #ReleaseVersionConstraint

	// Consumer validation accepts every other annotation as an opaque string.
	[(string & !~"^(io\\.imgoci\\.name|org\\.opencontainers\\.image\\.version)$")]: string
}

// #FileEntryAnnotations is the file-entry annotation map. Only annotations
// defined for this object location receive imgoci value constraints.
#FileEntryAnnotations: {
	// io.imgoci.architecture is the architecture selector.
	"io.imgoci.architecture"!: #Architecture

	// io.imgoci.target is the target selector.
	"io.imgoci.target"!: #BasicToken

	// io.imgoci.representation is the deliverable representation selector.
	"io.imgoci.representation"!: #BasicToken

	// io.imgoci.role is the file role.
	"io.imgoci.role"!: #BasicToken

	// io.imgoci.compression is the decoder applied to the stored file.
	"io.imgoci.compression"!: #BasicToken

	// io.imgoci.content.digest is the SHA-256 digest of the decoded content.
	"io.imgoci.content.digest"!: #SHA256Digest

	// io.imgoci.content.size is the byte length of the decoded content, encoded as
	// a string matching ^(0|[1-9][0-9]*)$.
	"io.imgoci.content.size"!: #ContentSize

	// io.imgoci.filename is the producer-chosen filename for the decoded content.
	"io.imgoci.filename"!: #Filename

	// Consumer validation accepts every other annotation as an opaque string.
	[(string & !~"^io\\.imgoci\\.(architecture|target|representation|role|compression|content\\.digest|content\\.size|filename)$")]: string
}

// #FileEntryAnnotationsShape defines file-entry annotation constraints used by
// the JSON Schema projection. The generator may omit constraints it cannot
// represent.
#FileEntryAnnotationsShape: {
	// io.imgoci.architecture is the architecture selector.
	"io.imgoci.architecture"!: #ArchitectureConstraint

	// io.imgoci.target is the target selector.
	"io.imgoci.target"!: #BasicTokenConstraint

	// io.imgoci.representation is the deliverable representation selector.
	"io.imgoci.representation"!: #BasicTokenConstraint

	// io.imgoci.role is the file role.
	"io.imgoci.role"!: #BasicTokenConstraint

	// io.imgoci.compression is the decoder applied to the stored file.
	"io.imgoci.compression"!: #BasicTokenConstraint

	// io.imgoci.content.digest is the SHA-256 digest of the decoded content.
	"io.imgoci.content.digest"!: #SHA256DigestConstraint

	// io.imgoci.content.size is the byte length of the decoded content, encoded as
	// a string matching ^(0|[1-9][0-9]*)$.
	"io.imgoci.content.size"!: #ContentSizeConstraint

	// io.imgoci.filename is the producer-chosen filename for the decoded content.
	"io.imgoci.filename"!: #FilenameConstraint

	// Consumer validation accepts every other annotation as an opaque string.
	[(string & !~"^io\\.imgoci\\.(architecture|target|representation|role|compression|content\\.digest|content\\.size|filename)$")]: string
}

// #BasicToken is a basic token with a custom error for invalid values.
#BasicToken: #BasicTokenConstraint |
	error("must be a basic token containing 1 to 128 ASCII bytes and matching ^[a-z0-9]+([._-][a-z0-9]+)*$")

// #BasicTokenConstraint is a basic token: 1 to 128 ASCII bytes that match
// ^[a-z0-9]+([._-][a-z0-9]+)*$.
#BasicTokenConstraint: string & strings.MinRunes(1) & strings.MaxRunes(128) &
	=~"^[a-z0-9]+([._-][a-z0-9]+)*$"

// #Architecture is an architecture selector with a custom error for invalid
// values. It contains one basic token or two basic tokens separated by a slash.
#Architecture: #ArchitectureConstraint |
	error("architecture must contain one or two basic tokens separated by /, with no more than 128 ASCII bytes in each token")

// #ArchitectureConstraint is one basic token or two basic tokens separated by a
// slash. #ReleaseIndex additionally limits each token to 128 ASCII bytes.
#ArchitectureConstraint: string & strings.MinRunes(1) & strings.MaxRunes(257) &
	=~"^[a-z0-9]+([._-][a-z0-9]+)*(/[a-z0-9]+([._-][a-z0-9]+)*)?$"

// #SHA256Digest is a SHA-256 digest with a custom error for invalid values.
#SHA256Digest: #SHA256DigestConstraint |
	error("digest must use sha256: followed by 64 lowercase hexadecimal digits")

// #SHA256DigestConstraint is sha256: followed by 64 lowercase hexadecimal
// digits.
#SHA256DigestConstraint: string & =~"^sha256:[0-9a-f]{64}$"

// #ContentSize is the byte length of decoded content encoded as a string
// matching ^(0|[1-9][0-9]*)$. #ReleaseIndex adds the exact numeric cap.
#ContentSize: #ContentSizeConstraint |
	error("content size must be a string matching ^(0|[1-9][0-9]*)$")

// #ContentSizeConstraint is a string matching ^(0|[1-9][0-9]*)$.
// #ReleaseIndex additionally caps its numeric value at 9223372036854775807.
#ContentSizeConstraint: string & strings.MinRunes(1) & strings.MaxRunes(19) &
	=~"^(0|[1-9][0-9]*)$"

// #MediaType is an RFC 6838 media type with a custom error for invalid values.
#MediaType: #MediaTypeConstraint |
	error("media type must use RFC 6838 type/subtype restricted-name syntax with no more than 127 characters in each component")

// #MediaTypeConstraint is an RFC 6838 type and subtype using restricted names
// of no more than 127 ASCII characters each.
#MediaTypeConstraint: string & =~"^[A-Za-z0-9][A-Za-z0-9!#$&^_.+-]{0,126}/[A-Za-z0-9][A-Za-z0-9!#$&^_.+-]{0,126}$"

// #ReleaseIndexMediaTypeConstraint identifies an OCI image index without regard
// to ASCII letter case using a pattern that is portable to JSON Schema.
#ReleaseIndexMediaTypeConstraint: string & =~"^[aA][pP][pP][lL][iI][cC][aA][tT][iI][oO][nN]/[vV][nN][dD]\\.[oO][cC][iI]\\.[iI][mM][aA][gG][eE]\\.[iI][nN][dD][eE][xX]\\.[vV]1\\+[jJ][sS][oO][nN]$"

// #ReleaseIndexMediaType adds a custom error to the portable constraint.
#ReleaseIndexMediaType: #ReleaseIndexMediaTypeConstraint |
	error("mediaType must identify application/vnd.oci.image.index.v1+json")

// #ReleaseArtifactTypeConstraint identifies an imgoci v1 release without regard
// to ASCII letter case using a pattern that is portable to JSON Schema.
#ReleaseArtifactTypeConstraint: string & =~"^[aA][pP][pP][lL][iI][cC][aA][tT][iI][oO][nN]/[vV][nN][dD]\\.[iI][mM][gG][oO][cC][iI]\\.[rR][eE][lL][eE][aA][sS][eE]\\.[vV]1$"

// #ReleaseArtifactType adds a custom error to the portable constraint.
#ReleaseArtifactType: #ReleaseArtifactTypeConstraint |
	error("artifactType must identify application/vnd.imgoci.release.v1")

// #ImageManifestMediaTypeConstraint identifies an OCI image manifest without
// regard to ASCII letter case using a pattern that is portable to JSON Schema.
#ImageManifestMediaTypeConstraint: string & =~"^[aA][pP][pP][lL][iI][cC][aA][tT][iI][oO][nN]/[vV][nN][dD]\\.[oO][cC][iI]\\.[iI][mM][aA][gG][eE]\\.[mM][aA][nN][iI][fF][eE][sS][tT]\\.[vV]1\\+[jJ][sS][oO][nN]$"

// #ImageManifestMediaType adds a custom error to the portable constraint.
#ImageManifestMediaType: #ImageManifestMediaTypeConstraint |
	error("file-entry descriptor mediaType must identify application/vnd.oci.image.manifest.v1+json")

// #Filename is the producer-chosen filename for decoded content with a custom
// error for invalid values.
#Filename: #FilenameConstraint |
	error("filename must be one path component matching ^[a-z0-9]([a-z0-9._+-]{0,253}[a-z0-9])?$")

// #FilenameConstraint is one path component containing 1 to 255 ASCII bytes
// that match ^[a-z0-9]([a-z0-9._+-]{0,253}[a-z0-9])?$.
#FilenameConstraint: string & strings.MinRunes(1) & strings.MaxRunes(255) &
	=~"^[a-z0-9]([a-z0-9._+-]{0,253}[a-z0-9])?$"

// #ReleaseVersion is a producer-assigned release version with a custom error for
// invalid values.
#ReleaseVersion: #ReleaseVersionConstraint |
	error("release version must contain 1 to 128 printable ASCII characters without whitespace")

// #ReleaseVersionConstraint contains 1 to 128 printable ASCII characters and no
// whitespace or control characters.
#ReleaseVersionConstraint: string & strings.MinRunes(1) & strings.MaxRunes(128) &
	=~"^[!-~]+$"

// #ManifestSize is the byte length of a referenced file manifest with a custom
// error for invalid values.
#ManifestSize: #ManifestSizeConstraint |
	error("descriptor size must be a JSON integer from 1 through 9007199254740991")

// #ManifestSizeConstraint is a JSON integer from 1 through 9007199254740991.
#ManifestSizeConstraint: int & >=1 & <=9007199254740991
