## 4. Cấu trúc folder output bắt buộc

Khi sinh agent, hãy tạo cấu trúc gợi ý như sau:

```text
agents/
  agent-registry.md

  knowledge/
    repository-scanner.md
    incremental-scanner.md
    convention-analyzer.md
    architecture-discovery.md
    pattern-discovery.md
    business-flow-discovery.md
    api-discovery.md
    database-discovery.md
    skill-discovery.md
    reusable-component-discovery.md
    similar-code-finder.md
    business-rule-discovery.md
    decision-memory.md
    knowledge-indexer.md
    knowledge-reviewer.md
    knowledge-orchestrator.md

  planning/
    requirement-analyst.md
    requirement-reviewer.md
    planner.md
    planning-reviewer.md
    solution-architect.md
    architecture-reviewer.md
    planning-orchestrator.md

  development/
    designer.md
    api-reviewer.md
    business-logic-developer.md
    business-reviewer.md
    integration-developer.md
    integration-reviewer.md
    refactor-agent.md
    refactor-reviewer.md
    development-orchestrator.md

  testing/
    api-test-planner.md
    positive-test-agent.md
    positive-reviewer.md
    negative-test-agent.md
    negative-reviewer.md
    integration-test-agent.md
    integration-test-reviewer.md
    contract-test-agent.md
    contract-reviewer.md
    performance-test-agent.md
    performance-test-reviewer.md
    security-test-agent.md
    security-test-reviewer.md
    test-coverage-reviewer.md
    test-runner.md
    failure-analyzer.md
    testing-orchestrator.md

  verify/
    security-auditor.md
    security-reviewer.md
    performance-optimizer.md
    performance-reviewer.md
    documentation-agent.md
    documentation-reviewer.md
    chief-architect.md
    qa-lead.md
    release-manager.md
    final-reviewer.md
    consensus-agent.md
    verify-orchestrator.md

  workflow/
    workflow-orchestrator.md
    harness-runtime.md
    workflow-policy.md
    parallel-execution-policy.md
    debate-loop-policy.md
    stop-condition-policy.md
    workflow-history-optimizer.md
    agent-evolution-reviewer.md
```

Knowledge output nên đặt riêng:

```text
knowledge/
  repository.md
  convention.md
  architecture.md
  patterns.md
  business-flow.md
  api-index.md
  database.md
  skill-matrix.md
  component-index.md
  business-rule.md
  decision.md
  knowledge-index.md
```

Mỗi lần xử lý một feature/task mới, phải tạo execution workspace riêng:

```text
execution-workspace/
  <TYPE>-YYYYMMDD-short-name/
    execution-state.md
    handoff-log.md
    requirement-analysis.md
    planning.md
    solution-design.md
    development-log.md
    test-plan.md
    test-result.md
    verification-report.md
    final-report.md
    questions.md
    assumptions.md
    risks.md
    blocked-report.md
    runtime/
      harness-state.md
      runtime-log.jsonl
      agent-dispatch-log.md
      parallel-groups.md
      permission-audit.md
      lock-conflict.md
    debate/
      <debate-id>/
        debate-brief.md
        round-1.md
        round-2.md
        round-3.md
        debate-summary.md
        decision.md
        unresolved.md
    history/
      workflow-history.md
      agent-output-history.md
      reviewer-history.md
      failure-history.md
      optimization-history.md
```

Ví dụ:

```text
execution-workspace/
  FEATURE-20260708-claim-amount-filter/
    execution-state.md
    handoff-log.md
    requirement-analysis.md
    planning.md
    solution-design.md
    development-log.md
    test-plan.md
    test-result.md
    verification-report.md
    final-report.md
    runtime/
    debate/
    history/
```

---

