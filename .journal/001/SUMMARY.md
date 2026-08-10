---
id: 001
title: Specification review and language revision
date: 2026-08-10
status: complete
repos_touched: [imgoci-spec]
related_sessions: []
---

## Goal
Review the current draft specification for obvious, provable contradictions and no broader class of issue. Then revise its prose for plain language, remove LLM-like or overly verbose wording, and correct grammar while retaining standard RFC-style language.

## Outcome
The goals were met. The contradiction review found no obvious, provable contradictions and therefore required no fixes. The linguistic review revised `spec.md` in three passes, preserved normative intent, passed local and hosted validation, and was squash-merged through PR #1 as `e01e41e`.

## Key Decisions
- Excluded ambiguity, omissions, and merely conceivable interpretations from the contradiction review because the requested lens required direct, provable conflicts.
- Kept precise specification terms and normative keywords while simplifying surrounding prose so readability changes would not weaken or broaden requirements.
- Reviewed the complete language diff for semantic drift after each pass, with independent checks for plain language, LLMisms, grammar, and run-on sentences.

## Changes
- `spec.md` - replaced indirect and repetitive wording, clarified actors and comparisons, shortened long constructions, and corrected grammar without intentionally changing schemas, selector values, media types, fixtures, or conformance requirements.

## Open Threads
- None.

## References
- [PR #1: docs(spec): clarify draft language](https://github.com/componere/imgoci-spec/pull/1)
- [Squash commit `e01e41e`](https://github.com/componere/imgoci-spec/commit/e01e41e43ab1950036ca28e7568a4b8ac9c0ce3e)
- [Post-merge validation run](https://github.com/componere/imgoci-spec/actions/runs/31424218650)

## Lessons
- Treat edits to normative prose as possible semantic changes until a full diff confirms that each actor, trigger, comparison, and requirement level is unchanged.
