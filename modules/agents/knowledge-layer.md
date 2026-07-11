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

`update.md` K01-K16 are capabilities, not additional custom agents:

- A01 loads and executes K01-K10 and K12-K14 from concrete skill files.
- A02 loads K11 `similar-code-search` for task planning.
- R01 loads K15 `knowledge-review`.
- W01 performs K16 orchestration through readiness, bundle construction, flat dispatch, review acceptance, and publication.

Every knowledge run uses a version 2 skill bundle. W01 resolves each selected skill through `skills/skill-registry.md`, writes the concrete file path and load order, and blocks when a required file is unavailable. A01/R01 must record `Skill Files Read`; names alone do not load a skill.

| K | Skill | Host | Primary Output |
| --- | --- | --- | --- |
| K01 | repository-scan | A01 | knowledge/repository.md |
| K02 | incremental-git-scan | A01 | knowledge/incremental-scan.md; dirty manifest map |
| K03 | convention-analysis | A01 | knowledge/convention.md |
| K04 | architecture-discovery | A01 | knowledge/architecture.md |
| K05 | pattern-discovery | A01 | knowledge/patterns.md |
| K06 | business-flow-discovery | A01 | knowledge/business-flow.md |
| K07 | api-discovery | A01 | knowledge/api-index.md |
| K08 | database-discovery | A01 | knowledge/database.md |
| K09 | technology-stack-discovery | A01 | knowledge/technology-stack.md; knowledge/skill-matrix.md |
| K10 | reusable-component-discovery | A01 | knowledge/component-index.md |
| K11 | similar-code-search | A02 | execution-workspace/<task>/similar-code.md or planning section |
| K12 | business-rule-discovery | A01 | knowledge/business-rule.md |
| K13 | decision-memory-update | A01 | knowledge/decision.md |
| K14 | knowledge-index-update | A01 | knowledge/knowledge-index.md; knowledge/knowledge-manifest.md |
| K15 | knowledge-review | R01 | runs/<run-id>/knowledge-review.md and verdict |
| K16 | knowledge orchestration policy | W01 | selected bundles, dispatch, review acceptance, publication state |
