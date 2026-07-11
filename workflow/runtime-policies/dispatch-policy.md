# Dispatch Policy

Only W01 dispatches custom agents. W01 must provide:

- Task ID and stage.
- Agent ID.
- Platform runtime target.
- Skill bundle path.
- Required inputs.
- Write scope and locks.
- Review profile for the next reviewer.
- Iteration number.

For Codex runtime:

- Resolve Agent ID through `agents/agent-registry.md` to `Codex Name` and `Codex TOML`.
- Spawn the Codex custom agent by `Codex Name`; the TOML `developer_instructions` is the runtime behavior source.
- Use the registry only for routing, permission, write scope, lock, reviewer, and handoff metadata.
- Do not use the spec Markdown path as the role source, dispatch target, or required input for normal execution.

No dispatched agent may dispatch another agent. With Codex `max_depth = 1`, every logical handoff returns to W01 for the next flat dispatch.
