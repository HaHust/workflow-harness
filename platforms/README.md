# Platform Adapters

Current adapter:

- `codex.md`: contains the Codex-specific request from the original master prompt.
- `claude.md`: contains Claude Code custom subagent rules and output requirements.

To target another platform, create a new adapter file such as `cursor.md` or `openai-agents.md`, then create/update a manifest that replaces only the `platforms/*.md` line. Keep the shared workflow, agent, policy, and template modules unchanged unless the workflow logic itself changes.
