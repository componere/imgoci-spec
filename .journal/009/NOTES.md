---
id: 009
title: Session 009
started: 2026-08-16
---

## 2026-08-16 19:57 — Kickoff
Goal for the session: not yet stated. The user asked only to start a new
session; the concrete task will be supplied next and recorded here.
Current state of the world:
- `master` is at `5b95710` ("chore: retarget repository to imgoci/spec (#16)")
  and is 1 behind `origin/master`.
- Journal branch `journal/jmgilman` is in sync with its remote; sessions 001-008
  are all closed with summaries.
- Spec state after session 008: `spec.md` normative, CUE canonical schema,
  generated JSON Schema projection, and explicit pass/fail conformance fixtures
  driven by `conformance/check.sh` via `scripts/check_cue.sh`.
- Known open threads: byte-level canonical encoding, selection, retrieval,
  file-manifest, and decoded-content conformance are deferred; the real Incus
  7.0 import and launch proof should be repeated before the first release; the
  first draft release (`v0.1.0-draft.1`) decision is still outstanding.
Plan: wait for the user's actual request, then scope the work, branch with `wt`
from the fetched default branch, and checkpoint progress here.

## 2026-08-16 20:05 — README orientation rewrite
Task: the README explained repository artifacts but not what imgoci is, what it
solves, or who should care. Goal is orientation for first-time visitors and
prospective contributors, not a long document.
Work: created worktree `.wt/docs-readme-orientation` on branch
`docs/readme-orientation` from `origin/master` (master had moved to include
PR #15, so the corpus is now 13 pass / 25 fail fixtures).
Rewrote `README.md`:
- lede states what a release is; `The problem` section covers the OS image
  matrix, HTTP-directory-plus-catalog status quo, and the fact that an OCI
  image index only carries `platform` (OS + architecture);
- `What a release looks like` reuses the section 3 object-model diagram and the
  section 13 single-entry example, then explains the four addressing
  annotations, transport alternatives sharing one content digest, and the
  standard-versus-BigOCI layout signal in descriptor `artifactType`;
- `What a consumer does` summarizes validate/list/resolve/retrieve including
  all-or-nothing resolution; `What imgoci does not define` restates the section
  1 non-goals;
- merged the overlapping `Authority` and `Repository contents` sections into
  one table while keeping the authority-order and schema-boundary paragraphs;
- `Contributing` now names the open work (implementation reports, spec review,
  fixtures, public-value proposals).
Verification: `moon run root:cue` passes; the README JSON example was extracted
and accepted by `cue vet -c -d '#ReleaseIndex'`; all relative links resolve.
CHANGELOG was intentionally not edited — Release Please generates the
`Documentation` section from the `docs:` commit subject.
Result: PR #18 open, `validate` check passing. Awaiting review/merge decision.

## 2026-08-16 20:20 — Usage selector was missing from the README
Mistake found by the user: the first README draft was written against `spec.md`
in the main worktree, which sits on local `master` and was one commit behind
`origin/master`. PR #17 (`feat(spec): add deliverable usage selector`) had
already added `usage` as a fourth deliverable-key field, so the draft described
a three-part key and a four-annotation addressing model.
Lesson: read source documents from the worktree that is based on the fetched
default branch, not from the stale main checkout.
Fixes pushed as a second commit on `docs/readme-orientation`:
- lede and `The problem` mention what a deliverable can do, using the live vs
  offline-installer ISO case;
- addressing prose replaced by a five-row annotation table plus a paragraph on
  `io.imgoci.usage` being optional, comma-separated in byte order, empty when
  absent, `install-offline` requiring `install`, and being a producer assertion
  that imgoci does not execute;
- consumer steps distinguish list-time usage containment from resolve-time set
  equality with a possibly empty set;
- non-goal bullet matches the revised section 1 wording about not implementing
  installation or boot behavior;
- fixture pointer mentions usage-set variants.
Verified again: `moon run root:cue` passes, README example still accepted by
`cue vet -d '#ReleaseIndex'`, all relative links resolve, PR #18 `validate`
check passes.
Open gap for later: `GOVERNANCE.md` `Public-value registry` still lists only
targets, representations, roles, and compression values, so a proposed `usage`
value has no acceptance criteria. Left out of PR #18 because governance changes
are non-trivial under that document's rules.

## 2026-08-16 20:27 — PR #18 merged
Squash-merged as `1cbf200` on `master`. Local `master` fast-forwarded, the
`docs/readme-orientation` worktree and its local and remote branches are gone,
and `git ls-files .journal` on `master` prints nothing.
Post-merge workflows: Validate on `master` success, Release Please success.
Release Please refreshed its PR #3, now proposing `0.1.0-draft.1` with the
README change under Documentation. That release decision is still open.
Remaining follow-up from this session: add `usage` to the `GOVERNANCE.md`
public-value registry categories and define its acceptance criteria.

## 2026-08-16 20:36 — Governance usage registry PR
Branch `docs/governance-usage-registry` from `origin/master`, worktree
`.wt/docs-governance-usage-registry`. PR #19, `validate` passing.
Change: `GOVERNANCE.md` public-value registry now governs usage values. Added a
usage `Definition` criterion (capability asserted about a complete deliverable,
specific enough for a producer to decide applicability since imgoci never
proves the behavior, and it must state required or excluded relationships such
as `install-offline` requiring `install`) plus a paragraph requiring a usage
proposal to state how existing publishers adopt the value, because producers
must declare every applicable standard usage value and the usage set is part of
the deliverable key. Deliberately posed that as a per-proposal question instead
of writing a republication rule into policy.
Also updated `.github/ISSUE_TEMPLATE/value-proposal.yml` (usage in the dropdown,
extended definition guidance, new `Adoption by existing publishers` field) and
the usage mention in `CONTRIBUTING.md` and `README.md`.
Found but not fixed: `spec.md` section 6 says descriptors sharing a
file-manifest digest may differ in architecture, target, representation, role,
and filename. Usage is missing from that enumeration and invalidity rule 8 does
not require agreement on it, so this looks like an omission from PR #17. It is
normative text and needs its own change.

## 2026-08-16 20:48 — PR #19 merged, PR #20 opened
PR #19 squash-merged as `6700066`. Local `master` fast-forwarded and the
`docs-governance-usage-registry` worktree and branches removed.
PR #20 (`fix/spec-shared-digest-usage`) fixes the normative omission found
earlier, `validate` passing:
- section 6 now lists usage among the fields that descriptors sharing a
  file-manifest digest may differ in;
- section 5.3's reuse sentence generalized from "more than one architecture or
  target" to "more than one deliverable, such as two architectures, two
  targets, or two usage sets";
- new fixture `conformance/v1/pass/shared-manifest-across-usage-sets.json`:
  two descriptors share digest `sha256:1111...`, agree on everything invalidity
  rule 8 requires, and differ in usage set (absent versus `live`) and filename.
Important finding: no schema change was needed. `release-index-v1.cue` line 105
already implements rule 8 with agreement required only on media type, descriptor
size, artifact type, compression, content digest, and content size, so differing
usage on a shared digest was always valid. The fixture was accepted before any
spec edit, which confirms this was stale prose, not a behavior change.
Corpus is now 14 passing and 25 failing.
Rejected wording along the way: qualifying filename differences with "when they
do not describe the same file". Rule 8 forces shared-digest descriptors to agree
on compression, so they can never be transport alternatives of the same file;
the qualifier would have been vacuous.
