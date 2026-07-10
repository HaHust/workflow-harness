## 5. V3 Agent And Skill File Standards

### Agent File Format

Every runnable custom agent file must include:

```md
# <ID> <Agent Name>

## Role
## Responsibility
## When To Run
## Inputs
## Outputs
## Allowed Skills
## Model Config
## Permissions
## Write Scope
## Parallel Safety
## Process
## Rules
## Do Not
## Handoff
## Handoff Contract
## Review Criteria
## Debate Policy
## Failure Handling
## Stop Condition
```

### Worker Handoff Contract

```md
# Worker Handoff

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
- Worker Status: READY_FOR_REVIEW | BLOCKED
- Required Review Profile:
- Return To: W01 Workflow Orchestrator
```

### Reviewer Handoff Contract

```md
# Reviewer Handoff

- Task ID:
- Stage:
- Reviewer:
- Worker/Artifact Reviewed:
- Review Profile:
- Artifact Reviewed:
- Findings:
- Required Fixes:
- Downstream Artifacts Invalidated:
- Verdict: PASS | PASS_WITH_NOTES | REJECT | BLOCKED
- Return To: W01 Workflow Orchestrator
- Recommended Next Stage:
```

### Specialist Routing Handoff Contract

```md
# Specialist Routing Handoff

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
- Routing Status: ROUTE_FOUND | NEEDS_USER_DECISION | BLOCKED
- Return To: W01 Workflow Orchestrator
```

### Skill File Format

Every skill file must include purpose, allowed agents, trigger, preconditions, inputs, procedure, outputs, permission requirement, write impact, validation, failure codes, and review mapping.
