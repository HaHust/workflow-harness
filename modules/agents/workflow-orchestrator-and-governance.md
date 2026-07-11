# VI. Workflow Orchestrator And Governance V3

## W01 Workflow Orchestrator

W01 is the only dispatch authority, stage-transition authority, retry authority, debate authority, and final status authority.

## End-To-End Normal Flow

```text
W01 readiness/context
  -> A02 Planning Worker -> R01/R02 -> W01
  -> A03 Implementation Worker -> R01/R02 -> W01
  -> A04 Test Worker -> R01/R02 -> W01
  -> A05 Verification Worker -> R02 -> W01
  -> A01/R01 knowledge update if dirty
  -> R02 Final Gate if required
  -> DONE or BLOCKED
```

## Skill Bundle Requirement

W01 must create `runs/<run-id>/skill-bundle.md` for every agent run:

```md
# Skill Bundle

## Bundle Identity
- Bundle Version: 2
- Workflow Home:
- Skill Registry:
- Task ID:
- Run ID:
- Stage:
- Host Agent ID:

## Skill Load Protocol
- Resolve each selected skill to a concrete file.
- Required skill files are read before task work.
- Missing load evidence returns BLOCKED.

## Required Skills
| Load Order | Skill | Skill File | Expected Output |

## Selected Optional Skills
| Load Order | Skill | Skill File | Trigger | Expected Output |

## Forbidden Skills
| Skill | Reason |

## Required Inputs

## Expected Outputs

## Write Scope And Locks

## Reviewer Contract

## Skill Load Evidence
```

W01 must validate each skill against `skills/skill-registry.md`, write its concrete path into the bundle, and include the same bundle path in the child run request. The child must read all required skill files in load order and record `Skill Files Read`; a list of skill names alone is not a loaded bundle.

When `scripts/validate-skill-bundle.sh` is available, W01 runs it before dispatch and proceeds only after `SKILL_BUNDLE_VALID`. Missing files, non-canonical paths, forbidden/selected overlap, or invalid registry mappings block dispatch.

## Shared State Writer Rule

Only W01 writes:

- `execution-state.md`
- `handoff-log.md`
- `runtime-log.jsonl`
- `agent-dispatch-log.md`
- `parallel-groups.md`
- `permission-audit.md`

Workers and reviewers write only their `runs/<run-id>/` artifacts.

## Codex Dispatch Discipline

For Codex output, W01 dispatches runnable agents by Codex custom-agent `name` from `.codex/agents/*.toml`. `agents/agent-registry.md` remains the routing and permission index, but W01 must not turn `agents/**/*.md` into runtime instructions or route through a generic agent with Markdown as the role source.

## Debate

Debate is policy-driven, not a standing custom agent. W01 may request A02 isolated proposals or R02 comparison, then W01 records the decision.

## Maintenance

M01 and M02 run only in `WORKFLOW_MAINTENANCE` profile or explicit user-requested optimization.
