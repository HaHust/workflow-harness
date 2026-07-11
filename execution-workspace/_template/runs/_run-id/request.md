# Run Request

## Identity
- Task ID:
- Run ID:
- Stage:
- Agent ID:
- Codex Name:
- Workflow Home:

## Runtime Contract
- Skill Bundle:
- Skill Registry: <workflow-home>/skills/skill-registry.md
- Required Inputs:
- Expected Artifacts:
- Write Scope:
- Locks:
- Iteration:

## Mandatory Skill Loading
Before doing task work, read the skill bundle, resolve every required skill to its concrete file, read those files in bundle order, and record `Skill Files Read` in the result/handoff/review artifact. Return `BLOCKED` with `SKILL_NOT_LOADED` if any required skill cannot be loaded.

## Review Contract
- Reviewer:
- Review Profile:
- Return To: W01 Workflow Orchestrator
