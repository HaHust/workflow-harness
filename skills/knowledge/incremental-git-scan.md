# Incremental Git Scan

## Purpose
Identify which knowledge artifacts are affected by codebase changes without rescanning unrelated areas.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
`SYNC_REQUIRED`, post-change `UPDATE_REQUIRED`, or explicit incremental refresh.

## Preconditions
- The version 2 bundle lists this file, baseline revision/fingerprint, and current project scope.
- Existing knowledge index and manifest are available.

## Inputs
- Git diff/status and baseline revision when Git exists.
- Added, changed, deleted, and renamed file inventory.
- For non-Git projects, the previous and current deterministic source fingerprint/file inventory.
- Existing `knowledge/` and `knowledge-impact.md` when present.

## Must Analyze
- Changed files and impacted modules, APIs, database objects, tests, configuration, and integrations.
- Which knowledge files become dirty and which discovery skills must run.
- Migration and configuration changes even when source code is unchanged.

## Procedure
1. Confirm this file is loaded and record it in `Skill Files Read`.
2. Compare baseline and current source state.
3. Classify each changed path as API, business, persistence, migration, config, integration, test, docs, or infrastructure.
4. Map changes to knowledge files and required follow-up skill files.
5. Avoid a full scan unless evidence shows repository-wide impact.

## Outputs
- `knowledge/incremental-scan.md` with change classification and affected knowledge.
- Dirty entries and current revision/fingerprint in `knowledge/knowledge-manifest.md`.
- Required follow-up knowledge skill list for W01/A01.

## Permission Requirement
Read repository status/diff and knowledge; write only declared knowledge/run artifacts; no network.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Every changed source/API/DB/config path is mapped or explicitly marked no knowledge impact.
- Renames and deletions invalidate old references.
- Full scan escalation has evidence.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_BASELINE`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `PERMISSION_DENIED`, `EXECUTION_FAILED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`.
