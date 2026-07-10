# Backend Agent Generation Master Prompt Workflow Harness V3

This repository contains a modular prompt and generated harness for a simpler backend-agent architecture.

## V3 Summary

- 9 core custom agents instead of a large specialist mesh.
- 2 optional maintenance agents.
- Skills replace most former specialist agents.
- Policies replace sub-orchestrators and runtime agents.
- The only valid logical route is `Worker -> Reviewer -> W01`.
- Codex dispatch stays flat with `max_depth = 1`.

## Main Directories

- `modules/`: source modules for the assembled master prompt.
- `agents/`: runnable V3 custom-agent specs.
- `skills/`: reusable skill contracts.
- `workflow/`: stage and runtime policies applied by W01.
- `.codex/agents/`: Codex custom-agent TOML files.
- `templates/` and `execution-workspace/_template/`: task workspace templates.
- `dist/`: assembled prompt output.

## Assemble

```bash
./assemble.sh dist/backend-agent-generation-master-prompt-workflow-harness.md manifests/codex.txt
```

The default manifest is `manifests/codex.txt`.
