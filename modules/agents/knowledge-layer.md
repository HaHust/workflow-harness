## Knowledge Layer V3

### A01 Knowledge Maintainer

A01 bootstraps and synchronizes the Knowledge Base. It is not run for every task.

Run A01 only when:

- `knowledge-readiness-check` returns `BOOTSTRAP_REQUIRED`.
- `knowledge-readiness-check` returns `SYNC_REQUIRED` for task-relevant knowledge.
- User requests full refresh.
- A05 returns `UPDATE_REQUIRED` after stable implementation and tests.

Normal workers consume knowledge through:

```text
execution-workspace/<task>/knowledge-context.md
```

A01 handoff target is R01 with profile `KNOWLEDGE_QUALITY`.
