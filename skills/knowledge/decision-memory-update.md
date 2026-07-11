# Decision Memory Update

## Purpose
Preserve evidence-backed architecture and implementation decisions, trade-offs, and rejected alternatives.

## Allowed Agents
A01 Knowledge Maintainer when W01 includes this skill after an accepted decision.

## Trigger
Accepted architecture, convention, workflow, integration, migration, or implementation decision that future tasks must retain.

## Preconditions
- The version 2 bundle lists this file.
- Decision evidence and approving artifact/verdict exist.

## Inputs
- ADRs, planning/solution artifacts, debate decisions, reviewer verdicts, final reports, and relevant code evidence.
- Existing `knowledge/decision.md`.

## Must Track
- Decision, context, rationale, trade-offs, accepted option, rejected alternatives, consequences, reversibility, owner, date, and source evidence.

## Procedure
1. Confirm skill load and record this file.
2. Verify the decision is accepted and material to future work.
3. Append or supersede a decision without erasing historical rationale.
4. Link replaced decisions and explain current applicability.

## Outputs
- `knowledge/decision.md` with durable decision records and freshness metadata.

## Permission Requirement
Read approved artifacts/source/knowledge; write knowledge/run artifacts only; no network.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Every decision has approval and evidence.
- Personal preference is excluded unless it reflects codebase constraints.
- Superseded decisions remain traceable.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_APPROVAL`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `CONFLICTING_RULE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`; R02 gate when the decision is high risk.
