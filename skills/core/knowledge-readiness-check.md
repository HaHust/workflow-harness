# Knowledge Readiness Check

## Purpose
Check whether the Knowledge Base can be safely used before a workflow enters planning.

## Allowed Agents
W01 Workflow Orchestrator only.

## Trigger
At the start of every workflow and before W01 creates `knowledge-context.md`.

## Preconditions
- W01 has the user requirement and task type.
- `knowledge/knowledge-manifest.md` and `knowledge/knowledge-index.md` may or may not exist.

## Inputs
- User requirement.
- Task type and impacted modules/files if known.
- `knowledge/knowledge-manifest.md`.
- `knowledge/knowledge-index.md`.
- Dirty knowledge items from previous workflow, if any.

## Procedure
1. Check whether the Knowledge Base exists.
2. Check manifest status: `CLEAN`, `DIRTY`, `BOOTSTRAP_REQUIRED`, `SYNC_REQUIRED`, or `BLOCKED`.
3. Decide whether dirty items are relevant to the current task.
4. Return one readiness verdict and evidence.

## Outputs
- Readiness verdict: `READY`, `READY_WITH_DIRTY_ITEMS`, `BOOTSTRAP_REQUIRED`, `SYNC_REQUIRED`, or `BLOCKED`.
- Evidence for the verdict.
- Required A01 skill bundle when bootstrap or sync is required.

## Permission Requirement
- Read: knowledge manifest/index and task artifacts.
- Write: W01 shared state only.
- Execute: read-only inspection commands if needed.
- Network: NO.

## Write Impact
Shared state only through W01.

## Validation
- Verdict is one of the allowed values.
- Dirty item relevance is explicit.
- W01 does not skip required bootstrap/sync without evidence.

## Failure Codes
- `MISSING_INPUT`
- `INSUFFICIENT_EVIDENCE`
- `PERMISSION_DENIED`
- `CONFLICTING_RULE`
- `UNSAFE_CHANGE`
- `EXECUTION_FAILED`

## Review Mapping
W01 records the decision; R02 may inspect it during `FINAL_GATE` if knowledge status affects release readiness.
