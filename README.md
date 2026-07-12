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
- `.codex/agents/`: Codex custom-agent TOML files; these are the Codex runtime source of truth.
- `templates/` and `execution-workspace/_template/`: task workspace templates.
- `dist/`: assembled prompt output.

Runtime artifacts are stored under `/home/ha/.codex/codex-workflows/booking/execution-workspace/<task-id>/` (or the configured Workflow Home), never directly under `~/codex-workflows/booking/<task-id>/`. Every new or re-dispatched v2.1 skill bundle must pass the read-only `scripts/validate-skill-bundle.sh` gate; validation status is detached in `runtime/runtime-log.jsonl` and the bundle remains immutable.
## Promt
  Using workflow_orchestrator agent
  Act as workflow_orchestrator in the main/root session.
  Do not spawn workflow_orchestrator as a subagent.
  Agent:
  /home/ha/.codex/agents
  Workflow Home:
  /home/ha/.codex/codex-workflows/booking
  Runtime Workspace:
  /home/ha/.codex/codex-workflows/booking/execution-workspace/<task-id>/
  Project Root:
  current working directory
  Load registry, skills, and policies from Workflow Home. All output file is saved in Workflow Home
  Keep runtime artifacts under the canonical Workflow Home path:
  /home/ha/.codex/codex-workflows/booking/execution-workspace/<task-id>/
  Do not dirty the project with agent/workflow files.

Task: Hãy xây dựng và cập nhật knowledge base của codebase dự án.
Không thay đổi product code, test, migration hoặc planning artifacts.

## Assemble

```bash
./assemble.sh dist/backend-agent-generation-master-prompt-workflow-harness.md manifests/codex.txt
```

The default manifest is `manifests/codex.txt`.
