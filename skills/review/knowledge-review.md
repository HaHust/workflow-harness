# Knowledge Review

## Purpose
Review a complete knowledge publication candidate before W01 accepts it for task use.

## Allowed Agents
R01 Quality Reviewer.

## Trigger
W01 dispatches R01 with `KNOWLEDGE_QUALITY` and a version 2 bundle containing this file.

## Preconditions
- A01 handoff is `READY_FOR_REVIEW`.
- Candidate index, manifest, changed knowledge files, source evidence, and A01 skill load evidence exist.

## Inputs
- A01 result and handoff.
- `knowledge/knowledge-index.md`, `knowledge-manifest.md`, and all changed knowledge files.
- Source revision/fingerprint and representative source evidence.
- A01 skill bundle and `Skill Files Read`.

## Must Review
- Completeness, correctness, duplication, conflicts, freshness, outdated claims, missing source references, index coverage, manifest consistency, and loaded-skill compliance.

## Procedure
1. Confirm this review skill is loaded and record it in `Skill Files Read`.
2. Validate A01 loaded every required skill file and produced each expected output.
3. Sample material claims against current source and revision/fingerprint.
4. Check all knowledge files are indexed, scoped, non-duplicative, and freshness-labelled.
5. Return actionable findings and one verdict.

## Outputs
- `execution-workspace/<task>/runs/<run-id>/knowledge-review.md`.
- Reviewer handoff with `PASS`, `PASS_WITH_NOTES`, `REJECT`, or `BLOCKED`.
- On PASS/PASS_WITH_NOTES, recommendation for W01 to publish manifest status `CLEAN`; reviewer does not edit knowledge files.

## Permission Requirement
Read source/knowledge/run artifacts; write only own review/handoff artifacts; no network.

## Write Impact
Review artifact only; Product/Test/Knowledge writes: NO.

## Validation
- Findings cite knowledge and source evidence.
- `PASS_WITH_NOTES` contains only non-blocking freshness/quality notes.
- Missing skill-load evidence or stale revision cannot pass.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `STALE_KNOWLEDGE`, `INSUFFICIENT_EVIDENCE`, `CONFLICTING_RULE`, `PERMISSION_DENIED`.

## Review Mapping
W01 consumes R01 verdict and publishes or blocks the knowledge candidate.
