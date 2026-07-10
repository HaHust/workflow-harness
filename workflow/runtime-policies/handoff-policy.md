# Handoff Policy

## Worker Handoff
- Task ID:
- Stage:
- From Agent:
- Logical Handoff To:
- Iteration:
- Skills Used:
- Inputs Read:
- Outputs Produced:
- Files Changed:
- Assumptions Added:
- Questions Added:
- Risks Found:
- Locks Used:
- Worker Status: `READY_FOR_REVIEW` | `BLOCKED`
- Required Review Profile:
- Return To: `W01 Workflow Orchestrator`

## Reviewer Handoff
- Task ID:
- Stage:
- Reviewer:
- Worker/Artifact Reviewed:
- Review Profile:
- Artifact Reviewed:
- Findings:
- Required Fixes:
- Downstream Artifacts Invalidated:
- Verdict: `PASS` | `PASS_WITH_NOTES` | `REJECT` | `BLOCKED`
- Return To: `W01 Workflow Orchestrator`
- Recommended Next Stage:

Reviewer handoffs never name a next worker as dispatch target.

## Specialist Routing Handoff
- Task ID:
- Stage:
- From Agent:
- Iteration:
- Skills Used:
- Inputs Read:
- Failure Evidence Reviewed:
- Root Cause Owner:
- Confidence:
- Routing Recommendation:
- Required Fixes:
- Assumptions Added:
- Questions Added:
- Risks Found:
- Locks Used:
- Routing Status: `ROUTE_FOUND` | `NEEDS_USER_DECISION` | `BLOCKED`
- Return To: `W01 Workflow Orchestrator`

Specialist routing handoffs never apply fixes directly.
