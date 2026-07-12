# VIII. Output Requirements For V3 Generation

When this prompt is used to generate the workflow harness, output:

1. The V3 agent files under `agents/`.
2. `agents/agent-registry.md` containing only runnable custom agents.
3. `skills/skill-registry.md` and skill files using the standard skill contract, plus version 2 bundles that resolve and load concrete skill files.
4. `workflow/stage-policies/*.md`.
5. `workflow/runtime-policies/*.md`.
6. `.codex/config.toml` with `max_depth = 1` and V3 custom agent TOML files.
7. Task templates under `templates/` and `execution-workspace/_template/`.
8. Mandatory fail-closed `scripts/validate-skill-bundle.sh` dispatch gate with canonical v2.1 and detached validation evidence.
9. README instructions for the flat Worker -> Reviewer -> W01 runtime.
10. Assembled prompt under `dist/` using the Codex manifest.

Do not output old sub-orchestrators as custom agents.
