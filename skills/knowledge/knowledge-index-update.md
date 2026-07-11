# Knowledge Index Update

## Purpose
Publish a navigable index and manifest for all knowledge artifacts after discovery/update skills finish.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Final required skill of every knowledge bootstrap or incremental update bundle.

## Preconditions
- The version 2 bundle lists this file last.
- All preceding required knowledge skills completed or returned explicit blockers.

## Inputs
- All affected files under `knowledge/`.
- Skill load evidence, source revision/fingerprint, changed file list, and prior manifest/index.

## Must Analyze
- Knowledge file ownership, purpose, summary, related modules, freshness, dirty/clean state, source references, and dependencies between knowledge files.

## Procedure
1. Confirm this skill was loaded last and record it in `Skill Files Read`.
2. Inventory every published knowledge artifact and validate required sections.
3. Update `knowledge-index.md` with read order and task/module routing.
4. Update `knowledge-manifest.md` with source revision/fingerprint, timestamps, owners, changed files, dirty flags, and `READY_FOR_REVIEW` status.
5. Never mark `CLEAN` before R01 `KNOWLEDGE_QUALITY` accepts the update.

## Outputs
- `knowledge/knowledge-index.md`.
- `knowledge/knowledge-manifest.md`.

## Permission Requirement
Read knowledge/run evidence; write index, manifest, and run artifacts only; no network.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Every knowledge file is indexed exactly once.
- Revision/fingerprint and freshness fields are populated.
- Dirty items and missing evidence are explicit.
- Status before review is `READY_FOR_REVIEW`.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INCOMPLETE_KNOWLEDGE`, `INSUFFICIENT_EVIDENCE`, `CONFLICTING_RULE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`.
