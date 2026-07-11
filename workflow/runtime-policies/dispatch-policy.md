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
- Before dispatch, run `scripts/validate-skill-bundle.sh <bundle-path> <workflow-home>` when the validator is present; dispatch only on `SKILL_BUNDLE_VALID`.
- Reject the run as `BLOCKED` with `SKILL_NOT_LOADED` when required skill evidence is missing.

No dispatched agent may dispatch another agent. With Codex `max_depth = 1`, every logical handoff returns to W01 for the next flat dispatch.

## Database Execution Freeze

- W01 must not include or authorize any migration execution command or any command whose direct or indirect database effect includes `ALTER`, `DROP`, `TRUNCATE`, `DELETE`, or `INSERT`.
- This prohibition covers raw SQL, database clients, scripts, framework/ORM migration CLIs, schema push/sync, seeders, application startup, tests, and wrapper commands.
- Agents may design and edit migration/SQL files, but must mark execution `NOT_EXECUTED_POLICY`.
- If required completion depends on a prohibited command, W01 returns `BLOCKED` with `DB_MUTATION_EXECUTION_FORBIDDEN`; it must not reroute the command to another agent.
