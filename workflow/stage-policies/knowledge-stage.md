# Knowledge Stage Policy

A01 is a maintenance worker, not a mandatory feature stage.

## Entry Conditions
- `BOOTSTRAP_REQUIRED`: no usable Knowledge Base exists.
- `SYNC_REQUIRED`: relevant knowledge is dirty before planning.
- `UPDATE_REQUIRED`: A05 knowledge-impact-detector found stale knowledge before final gate.
- Explicit user request for refresh.

## Flow
```text
W01 -> A01 Knowledge Maintainer -> R01 Quality Reviewer -> W01
```

K01-K16 from `update.md` map to the flat V3 runtime as follows:
- A01 executes K01-K10 and K12-K14 as loaded skill files.
- A02 executes K11 `similar-code-search` for normal task planning.
- R01 executes K15 `knowledge-review`.
- W01 owns K16 orchestration: bundle selection, dispatch, review acceptance, and publication status.

## Bundle Profiles

Canonical profile rows are maintained in `templates/knowledge-skill-bundles.md`.

### Full Bootstrap
1. `repository-scan` must load and run first.
2. Selected discovery skills may analyze independent read scopes after repository mapping exists.
3. `knowledge-index-update` must load and run last.
4. R01 receives a separate review bundle containing `knowledge-review`.

### Incremental Sync
1. `incremental-git-scan` must load and run first.
2. W01/A01 select only discovery/update skills mapped to dirty knowledge.
3. `decision-memory-update` is selected only for an accepted durable decision.
4. `knowledge-index-update` must load and run last.

Every selected skill must include a concrete readable file path in the version 2 bundle. Skill names without files are invalid.

## Gates
- R01 profile: `KNOWLEDGE_QUALITY`.
- R02 profile: `ARCHITECTURE_GATE` only for large architecture knowledge changes.

## Exit
- R01 `KNOWLEDGE_QUALITY` is PASS or downstream-safe PASS_WITH_NOTES.
- W01 publishes knowledge status as `CLEAN`, or records why dirty items are unrelated to the task.
- Source revision/fingerprint and `Skill Files Read` evidence are complete.
