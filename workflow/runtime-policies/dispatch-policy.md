# Dispatch Policy

Only W01 dispatches custom agents. W01 must provide:

- Task ID and stage.
- Agent ID.
- Skill bundle path.
- Required inputs.
- Write scope and locks.
- Review profile for the next reviewer.
- Iteration number.

No dispatched agent may dispatch another agent. With Codex `max_depth = 1`, every logical handoff returns to W01 for the next flat dispatch.
