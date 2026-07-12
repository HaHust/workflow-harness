## 4. V3 Output Folder Structure

```text
agents/
  agent-registry.md
  workflow/workflow-orchestrator.md
  workers/knowledge-maintainer.md
  workers/planning-worker.md
  workers/implementation-worker.md
  workers/test-worker.md
  workers/verification-worker.md
  reviewers/quality-reviewer.md
  reviewers/risk-reviewer.md
  specialists/failure-analyzer.md
  maintenance/workflow-optimizer.md
  maintenance/agent-evolution-reviewer.md

skills/
  skill-registry.md
  core/
  knowledge/
  planning/
  development/
  testing/
  verification/
  review/
  risk-review/
  workflow/

workflow/
  stage-policies/
    knowledge-stage.md
    planning-stage.md
    development-stage.md
    testing-stage.md
    verification-stage.md
  runtime-policies/
    dispatch-policy.md
    handoff-policy.md
    review-policy.md
    parallel-policy.md
    lock-policy.md
    retry-policy.md
    stop-policy.md
    debate-policy.md

scripts/
  validate-skill-bundle.sh

.codex/
  config.toml
  agents/
    workflow-orchestrator.toml
    knowledge-maintainer.toml
    planning-worker.toml
    implementation-worker.toml
    test-worker.toml
    verification-worker.toml
    quality-reviewer.toml
    risk-reviewer.toml
    failure-analyzer.toml
    workflow-optimizer.toml
    agent-evolution-reviewer.toml
```

Normal task workspace:

```text
execution-workspace/<TYPE>-YYYYMMDD-short-name/
  execution-state.md
  knowledge-context.md
  handoff-log.md
  questions.md
  assumptions.md
  risks.md
  blocked-report.md
  final-report.md
  planning-package/
  development-report.md
  test-plan.md
  test-result.md
  coverage-analysis.md
  verification-report.md
  knowledge-impact.md
  runs/<run-id>/
    request.md
    skill-bundle.md
    result.md
    handoff.md
    review.md
  runtime/
    runtime-log.jsonl
    agent-dispatch-log.md
    parallel-groups.md
    permission-audit.md
    lock-conflict.md
    workflow-selection.md
  debate/<debate-id>/
  history/
```

### Task ID Naming Rule

W01 must assign `task-id` before creating runtime artifacts.

Format:

```text
<type>-YYYYMMDD-<short-kebab-summary>
```

Rules:

- `<type>` must be one of `feature`, `bugfix`, `hotfix`, `refactor`, `test`, `docs`, `knowledge`, `maintenance`, or `analysis`.
- Date uses the current local date at task start.
- `<short-kebab-summary>` must be lowercase ASCII, digits, and hyphens only; derive it from the user's requirement in 2-6 words.
- Keep `task-id` stable for the whole workflow. Do not rename it after artifacts exist.
- If resuming an existing runtime workspace, reuse the existing `task-id`.
- Runtime artifacts must be written under the configured runtime workspace path for that `task-id`; do not create workflow artifacts in the project root.
