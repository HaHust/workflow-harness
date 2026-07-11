# XI. Final Quality Requirements

The generated V3 system must prove:

- Only W01 can dispatch agents or move stages.
- Every worker returns to a reviewer before W01 accepts the stage output.
- Every reviewer returns only to W01.
- A01 is a bootstrap/sync/update worker, not a mandatory stage for every task.
- Knowledge context is loaded through `knowledge-context.md` to avoid reading all knowledge files by default.
- Knowledge is updated after stable implementation and tests, before final gate, when impact requires it.
- All custom agents have caller, trigger, allowed skills, handoff, reviewer/gate, permission, write scope, and stop condition.
- Skills are reusable procedures and are not dispatch targets.
- Policies are coordination rules and are not agents.
- Repair, failure, debate, restart, and maintenance loops have explicit budgets.
- Shared state has a single writer: W01.
- Codex `max_depth = 1` is respected.
- Codex runtime dispatch uses `.codex/agents/*.toml` via `Codex Name`; it does not reconstruct agent behavior from `agents/**/*.md`.
