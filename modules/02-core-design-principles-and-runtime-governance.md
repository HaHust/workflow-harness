## 3. V3 Core Design Principles And Runtime Governance

### 3.1. Agent, Skill, Policy

```text
Agent = runnable identity responsible for a stage result.
Skill = reusable procedure executed inside one agent context.
Policy = coordination rule applied only by W01.
```

Skills and policies are not dispatch targets, do not own handoff, and do not have independent permissions.

### 3.2. Flat Runtime Invariant

The only valid logical flow is:

```text
Worker -> Reviewer -> W01 Workflow Orchestrator
```

With Codex `max_depth = 1`, the physical runtime is flat:

1. W01 dispatches one worker with a skill bundle.
2. Worker returns handoff to W01.
3. W01 dispatches the reviewer profile.
4. Reviewer returns verdict to W01.
5. W01 retries, advances, calls F01, opens debate, marks DONE, or marks BLOCKED.

Worker must not call Worker. Reviewer must not call Worker. Reviewer must not advance stage.

### 3.3. Minimal Runnable Agent Set

Core agents:

- W01 Workflow Orchestrator
- A01 Knowledge Maintainer
- A02 Planning Worker
- A03 Implementation Worker
- A04 Test Worker
- A05 Verification Worker
- R01 Quality Reviewer
- R02 Risk Reviewer
- F01 Failure Analyzer

Optional maintenance agents:

- M01 Workflow Optimizer
- M02 Agent Evolution Reviewer

### 3.4. Knowledge Lifecycle

Knowledge is not a mandatory stage in every workflow.

```text
LOAD KNOWLEDGE CONTEXT
-> PLANNING
-> DEVELOPMENT
-> TESTING
-> VERIFY
-> UPDATE KNOWLEDGE IF DIRTY
-> FINAL GATE
```

A01 runs only for bootstrap, sync, user refresh, or post-change knowledge update.

### 3.5. Reviewer Profiles

R01 handles ordinary quality profiles. R02 handles risk and final profiles. W01 must pass the exact profile; reviewers cannot choose a different profile without W01 approval.

### 3.6. Iteration Budgets

| Loop Type | Max |
| --- | ---: |
| Worker-reviewer repair | 2 |
| Failure analyzer repair | 3 |
| Debate | 3 |
| Full workflow restart | 1 |
| Workflow maintenance optimization | 2 |

Budget exhaustion creates `blocked-report.md` unless W01 has enough evidence to route safely.
