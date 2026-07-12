# Skill Bundle

## Bundle Identity
- Bundle Version: 2
- Schema Revision: 2.1
- Workflow Home:
- Skill Registry: <workflow-home>/skills/skill-registry.md
- Task ID:
- Run ID:
- Stage:
- Host Agent ID:
- Host Agent Name:
- Iteration: 1
- Required Review Profile:

## Skill Load Protocol
1. Resolve every skill file against `Workflow Home`; W01 must write a concrete path, not only a skill name.
2. Before task work, read the skill registry and every file in `Required Skills` in `Load Order`.
3. Read a selected optional skill only when it appears in `Selected Optional Skills` with a concrete file.
4. Do not use a skill listed under `Forbidden Skills`.
5. If a required skill file is missing, unreadable, mismatched with the registry, or not loaded, return `BLOCKED` with `SKILL_NOT_LOADED`.
6. Record all loaded files under `Skill Files Read` in `result.md`, `handoff.md`, or `review.md`.

## Required Skills
| Load Order | Skill | Skill File | Expected Output |
| ---: | --- | --- | --- |

## Selected Optional Skills
| Load Order | Skill | Skill File | Trigger | Expected Output |
| ---: | --- | --- | --- | --- |

## Forbidden Skills
| Skill | Reason |
| --- | --- |

## Required Inputs
| Input | Path or Scope | Required |
| --- | --- | --- |

## Expected Outputs
| Output | Owner | Validation |
| --- | --- | --- |

## Write Scope And Locks
- Write Scope:
- Required Locks:
- Forbidden Paths:

## Reviewer Contract
- Reviewer:
- Review Profile:
- Review Skill File:

## Skill Load Evidence
- Skill Files Read: agent must fill this in its run artifact.
- Registry Validation: PASS | BLOCKED
- Bundle Validation Command: <workflow-home>/scripts/validate-skill-bundle.sh <bundle-path> <workflow-home>
- Bundle Validation Status: PENDING
- Detached Validation Evidence: runtime/runtime-log.jsonl event `BUNDLE_VALIDATED`; this bundle is immutable after validation.
