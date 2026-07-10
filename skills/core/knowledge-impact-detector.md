# Knowledge Impact Detector

## Purpose
Detect whether stable code/test/documentation changes require incremental Knowledge Base updates before final gate.

## Allowed Agents
A05 Verification Worker; W01 may run the decision step when A05 returns evidence.

## Trigger
After implementation review and testing review pass, before R02 final gate.

## Preconditions
- Stable code diff exists.
- `development-report.md` and `test-result.md` exist or W01 records why they are not required.

## Inputs
- Git diff or changed file list.
- `planning-package/*`.
- `development-report.md`.
- `test-result.md`.
- Existing `knowledge/knowledge-index.md` and `knowledge/knowledge-manifest.md`.

## Procedure
1. Map changed files to impacted knowledge files.
2. Decide `NO_UPDATE`, `UPDATE_REQUIRED`, or `FULL_SCAN_REQUIRED`.
3. List required A01 update skills when update is required.
4. Return evidence to W01.

## Outputs
- `execution-workspace/<task>/knowledge-impact.md`.
- Required A01 skill list when update is needed.

## Permission Requirement
- Read: task artifacts, git diff, relevant knowledge index/manifest.
- Write: verification workspace artifact only.
- Execute: read-only inspection commands.
- Network: NO.

## Write Impact
Workspace artifact only. No product code writes.

## Validation
- Every changed source/API/DB/business-rule file is mapped or explicitly marked no update.
- Final gate cannot pass when update is required but not completed.

## Failure Codes
- `MISSING_INPUT`
- `INSUFFICIENT_EVIDENCE`
- `PERMISSION_DENIED`
- `CONFLICTING_RULE`
- `UNSAFE_CHANGE`
- `EXECUTION_FAILED`

## Review Mapping
R02 `FINAL_GATE`; R01 `KNOWLEDGE_QUALITY` if A01 updates knowledge.
