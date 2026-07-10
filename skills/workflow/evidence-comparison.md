# Evidence Comparison

## Purpose
Run the `evidence-comparison` procedure inside the permission and context of the calling agent.

## Allowed Agents
W01 Workflow Orchestrator; F01/M01 may use specific workflow skills when bundled by W01

## Trigger
W01 includes this skill in `execution-workspace/<task>/runs/<run-id>/skill-bundle.md`.

## Preconditions
- The host agent has an active W01-approved skill bundle.
- Required input artifacts exist or the host agent returns `BLOCKED`.
- The skill runs inside the host agent permission scope and cannot expand it.

## Inputs
- User requirement or reviewer request when relevant.
- `execution-workspace/<task>/knowledge-context.md` when knowledge is needed.
- Artifacts and source files named in the skill bundle.
- Existing knowledge files referenced by the skill bundle.

## Procedure
1. Confirm this skill is present in the skill bundle and not listed as forbidden.
2. Read only the inputs needed for this procedure.
3. Produce the required section or artifact with source evidence.
4. Record assumptions, questions, risks, and changed files for the host agent handoff.
5. Stop with a failure code instead of exceeding permission or scope.

## Outputs
- The section or artifact requested by W01 in the skill bundle.
- Evidence links or file references sufficient for reviewer validation.
- Failure code and blocker details when the procedure cannot complete.

## Permission Requirement
- Read: inherited from host agent.
- Write: inherited from host agent and limited to declared outputs.
- Execute: inherited from host agent; no independent execution authority.
- Network: NO unless W01 explicitly authorizes it.

## Write Impact
Shared state only when host is W01; otherwise proposal artifact only

## Validation
- Output matches the skill bundle.
- Evidence is specific enough for review.
- No forbidden skill, file, or permission was used.
- Handoff data is complete.

## Failure Codes
- `MISSING_INPUT`
- `INSUFFICIENT_EVIDENCE`
- `PERMISSION_DENIED`
- `CONFLICTING_RULE`
- `UNSAFE_CHANGE`
- `EXECUTION_FAILED`

## Review Mapping
W01 decision or M02 maintenance review
