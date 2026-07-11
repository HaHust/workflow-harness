# Knowledge Context Loader

## Purpose
Select the minimal relevant knowledge files and sections for the current task so workers do not read the whole Knowledge Base.

## Allowed Agents
W01 Workflow Orchestrator only.

## Trigger
After knowledge readiness is `READY` or after required A01 bootstrap/sync passes review.

## Preconditions
- Knowledge readiness is not `BLOCKED`.
- `knowledge/knowledge-index.md` exists unless W01 is running a knowledge refresh profile.

## Inputs
- User requirement.
- Task type and workflow profile.
- Impacted modules/files if known.
- `knowledge/knowledge-index.md`.
- Relevant knowledge manifest status.
- Current and manifest revision/fingerprint evidence from knowledge readiness.

## Procedure
1. Confirm readiness and revision/fingerprint evidence are usable.
2. Identify required, optional, and not-required knowledge files.
3. Reference specific sections and freshness evidence when possible.
4. Create `execution-workspace/<task>/knowledge-context.md` using the readiness-aware table format.
5. Instruct each worker to open only listed files unless new evidence requires W01 approval.

## Outputs
- `execution-workspace/<task>/knowledge-context.md`.

## Permission Requirement
- Read: knowledge index and manifest.
- Write: task `knowledge-context.md` through W01.
- Execute: no.
- Network: NO.

## Write Impact
Workspace artifact only through W01.

## Validation
- Required knowledge entries are relevant to the task.
- Unrelated large knowledge files are explicitly excluded.
- Workers can trace why each file is required.
- Context records current and manifest revision/fingerprint and cannot claim READY across a relevant mismatch.

## Failure Codes
- `MISSING_INPUT`
- `INSUFFICIENT_EVIDENCE`
- `PERMISSION_DENIED`
- `CONFLICTING_RULE`
- `UNSAFE_CHANGE`
- `EXECUTION_FAILED`

## Review Mapping
R01/R02 review downstream worker output that used this context; R02 may inspect context during final gate.
