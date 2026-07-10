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

## Gates
- R01 profile: `KNOWLEDGE_QUALITY`.
- R02 profile: `ARCHITECTURE_GATE` only for large architecture knowledge changes.

## Exit
- Knowledge status is `CLEAN`, or W01 records why dirty items are unrelated to the task.
