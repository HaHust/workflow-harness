# VIII. Output Requirements For V3 Generation

When this prompt is used to generate the workflow harness, output:

1. The V3 agent files under `agents/`.
2. `agents/agent-registry.md` containing only runnable custom agents.
3. `skills/skill-registry.md` and skill files using the standard skill contract.
4. `workflow/stage-policies/*.md`.
5. `workflow/runtime-policies/*.md`.
6. `.codex/config.toml` with `max_depth = 1` and V3 custom agent TOML files.
7. Task templates under `templates/` and `execution-workspace/_template/`.
8. README instructions for the flat Worker -> Reviewer -> W01 runtime.
9. Assembled prompt under `dist/` using the Codex manifest.

Do not output old sub-orchestrators as custom agents.
