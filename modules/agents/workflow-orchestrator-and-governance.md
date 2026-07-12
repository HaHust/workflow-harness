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
- Schema Revision: 2.1
- Workflow Home:
- Skill Registry:
- Task ID:
- Run ID:
- Stage:
- Host Agent ID:
- Host Agent Name:
- Iteration: 1
- Required Review Profile:

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
- Write Scope:
- Required Locks:
- Forbidden Paths:

## Reviewer Contract

## Skill Load Evidence
```

W01 must validate each skill against `skills/skill-registry.md`, write its concrete path into the bundle, and include the same bundle path in the child run request. The child must read all required skill files in load order and record `Skill Files Read`; a list of skill names alone is not a loaded bundle.

Before every new or re-dispatched child run, W01 must run `scripts/validate-skill-bundle.sh <bundle-path> <workflow-home>` and proceed only after detached `SKILL_BUNDLE_VALID` evidence. The validator is mandatory and fail-closed. It validates the immutable Bundle Version 2 / Schema Revision 2.1 bundle, canonical task root, host/registry mapping, concrete skills, required sections, reviewer/iteration/lock declarations, and write-scope roots. It never writes `Bundle Validation Status` into the bundle; W01 records a digest-bound `BUNDLE_VALIDATED` event in `runtime/runtime-log.jsonl`.

On resume, W01 first inventories already-dispatched runs and reconciles their persisted evidence. Legacy bundles are classified as `LEGACY_SCHEMA_FAILURE` or `INTERRUPTED_RUN` metadata and are never retroactively validated or mutated. Any continuation receives a new Run ID and a fresh canonical bundle that must pass the validator.

## Shared State Writer Rule

Only W01 writes:

- `execution-state.md`
- `handoff-log.md`
- `runtime-log.jsonl`
- `agent-dispatch-log.md`
- `parallel-groups.md`
- `permission-audit.md`

Every transition is idempotent and uses a stable `dispatch_key`. A successful child or blocked child receives one terminal child event, then `HANDOFF_RECONCILED` and `STATE_RECONCILED`. An external dispatch failure receives `DISPATCH_FAILED`, an explicit `handoff: NONE` projection, `HANDOFF_RECONCILED`, and `STATE_RECONCILED`; the next dispatch is forbidden until these records exist. Duplicate event IDs with identical payloads are no-ops; conflicting payloads block with `RUNTIME_EVENT_CONFLICT`.

Workers and reviewers write only their `runs/<run-id>/` artifacts.

## Codex Dispatch Discipline

For Codex output, W01 dispatches runnable agents by Codex custom-agent `name` from `.codex/agents/*.toml`. `agents/agent-registry.md` remains the routing and permission index, but W01 must not turn `agents/**/*.md` into runtime instructions or route through a generic agent with Markdown as the role source.

## Debate

Debate is policy-driven, not a standing custom agent. W01 may request A02 isolated proposals or R02 comparison, then W01 records the decision.

## Maintenance

M01 and M02 run only in `WORKFLOW_MAINTENANCE` profile or explicit user-requested optimization.
