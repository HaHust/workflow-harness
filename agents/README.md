# Agents

Backend Agent Architecture V3 keeps runnable custom agents small and flat.

- 9 core agents: W01, A01-A05, R01, R02, F01.
- 2 optional maintenance agents: M01, M02.
- Skills live under `skills/` and are procedures, not dispatch targets.
- Policies live under `workflow/` and are coordination rules, not agents.

The invariant for every normal run is:

```text
Worker -> Reviewer -> W01 Workflow Orchestrator
```

Only W01 dispatches agents, changes stages, retries workers, opens debate, calls F01, or marks `DONE`/`BLOCKED`.
