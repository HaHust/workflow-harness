# Dispatch Policy

Only W01 dispatches custom agents. W01 must provide:

- Task ID and stage.
- Agent ID.
- Platform runtime target.
- Skill bundle path.
- Workflow Home and skill registry path.
- Concrete file path for every required and selected optional skill.
- Required inputs.
- Write scope and locks.
- Review profile for the next reviewer.
- Iteration number.

For Codex runtime:

- Resolve Agent ID through `agents/agent-registry.md` to `Codex Name` and `Codex TOML`.
- Spawn the Codex custom agent by `Codex Name`; the TOML `developer_instructions` is the runtime behavior source.
- Use the registry only for routing, permission, write scope, lock, reviewer, and handoff metadata.
- Do not use the spec Markdown path as the role source, dispatch target, or required input for normal execution.
- In the run request, require the child to read the skill bundle and every concrete required skill file before task work.
- A skill name without a resolved readable file is not loaded and must not be used.
- Require `Skill Files Read` and `Skill Load Status` in the child result, handoff, or review artifact.
- Before every new or re-dispatched run, run `scripts/validate-skill-bundle.sh <bundle-path> <workflow-home>`; absence, failure, or malformed output blocks dispatch with the exact validator code. Dispatch only after detached `SKILL_BUNDLE_VALID` evidence bound to the immutable bundle digest.
- A prior dispatched legacy bundle is reconciled first on resume. It is never mutated, reused, or retroactively required to pass the new schema. Continuation uses a new canonical bundle and Run ID.
- Reject the run as `BLOCKED` with `SKILL_NOT_LOADED` when required skill evidence is missing.

No dispatched agent may dispatch another agent. With Codex `max_depth = 1`, every logical handoff returns to W01 for the next flat dispatch.

## Runtime Event Contract

- `runtime/runtime-log.jsonl` is UTF-8 JSONL; each line is `booking.runtime.event/v1` with unique `event_id`, `dispatch_key`, monotonic `sequence`, timestamp, task/run/attempt, event type, status, and optional measurement fields.
- Pre-dispatch order is `BUNDLE_VALIDATED`, permission/lock/parallel records, `DISPATCH_COMMITTED`.
- Child completion order is one of `CHILD_RETURNED`, `CHILD_BLOCKED`, `CHILD_INTERRUPTED`; external failure is `DISPATCH_FAILED` with `handoff: NONE`; every terminal path then emits `HANDOFF_RECONCILED` and `STATE_RECONCILED` before another `BUNDLE_VALIDATED`.
- Reconciliation is idempotent by event ID and payload. Duplicate same-payload events are no-ops; conflicting duplicates block with `RUNTIME_EVENT_CONFLICT`.

## Database Execution Freeze

- W01 must not include or authorize any migration execution command or any command whose direct or indirect database effect includes `ALTER`, `DROP`, `TRUNCATE`, `DELETE`, or `INSERT`.
- This prohibition covers raw SQL, database clients, scripts, framework/ORM migration CLIs, schema push/sync, seeders, application startup, tests, and wrapper commands.
- Agents may design and edit migration/SQL files, but must mark execution `NOT_EXECUTED_POLICY`.
- If required completion depends on a prohibited command, W01 returns `BLOCKED` with `DB_MUTATION_EXECUTION_FORBIDDEN`; it must not reroute the command to another agent.
