# Agent Registry

This registry contains only runnable custom agents in Backend Agent Architecture V3. Skills and policies are not agents and must not appear as dispatch targets.

## Runtime Invariants

- `max_depth = 1`: W01 uses flat dispatch. No agent directly spawns another agent.
- Logical flow is always `Worker -> Reviewer -> W01`.
- Reviewer agents return findings to W01 only; they may recommend a next stage but cannot dispatch it.
- W01 is the only shared-state writer for execution state, handoff log, runtime log, dispatch log, permission audit, and parallel groups.
- W01 resolves every selected skill to a concrete file in a version 2 bundle; agents must load required files and return skill-load evidence.
- A01 Knowledge Maintainer is not a default pipeline stage. It runs only for bootstrap, sync, user refresh, or post-change knowledge update.
- For Codex runtime, `Codex Name` plus `Codex TOML` is the executable target. `Spec Markdown File` is a spec/sync reference, not the runtime instruction source.
- Database execution is frozen for all database-related routes: agents may design/edit/review migration and SQL files but must not execute migrations or commands causing `ALTER`, `DROP`, `TRUNCATE`, `DELETE`, or `INSERT`, directly or indirectly.

## Runnable Agents

| ID | Kind | Stage | Spec Markdown File | Codex Name | Codex TOML | Called By | Allowed Skill Families | Logical Handoff | Permission Summary | Parallel |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| W01 | ORCHESTRATOR | ALL | `agents/workflow/workflow-orchestrator.md` | `workflow_orchestrator` | `.codex/agents/workflow-orchestrator.toml` | User/root entrypoint | knowledge-readiness-check, knowledge-context-loader, workflow-profile-selection, artifact-validation... | Dispatches A01, A02, A03, A04, A05, R01, R02, F01, M01, or M02 through a flat max_depth=1 runtime. Final return is to user. | Runtime coordination files only; no product code writes. | NO |
| A01 | WORKER | KNOWLEDGE | `agents/workers/knowledge-maintainer.md` | `knowledge_maintainer` | `.codex/agents/knowledge-maintainer.toml` | W01 | repository-scan, incremental-git-scan, convention-analysis, architecture-discovery, pattern/business/API/database/stack/component discovery, decision-memory-update, knowledge-index-update | Logical Handoff To: R01 Quality Reviewer with profile KNOWLEDGE_QUALITY. | Read source, loaded skill files, and knowledge; write knowledge files and its run artifacts only. | CONDITIONAL |
| A02 | WORKER | PLANNING | `agents/workers/planning-worker.md` | `planning_worker` | `.codex/agents/planning-worker.toml` | W01 | requirement-analysis, acceptance-criteria-design, ambiguity-detection, task-decomposition... | Logical Handoff To: R01 Quality Reviewer, or R02 Risk Reviewer when W01 explicitly requests a high-risk planning gate. | Read requirement, knowledge, source for planning evidence; write planning artifacts only. | CONDITIONAL |
| A03 | WORKER | DEVELOPMENT | `agents/workers/implementation-worker.md` | `implementation_worker` | `.codex/agents/implementation-worker.toml` | W01 | api-contract-implementation, dto-mapping-implementation, persistence-implementation, migration-implementation... | Logical Handoff To: R01 Quality Reviewer for CODE_CORRECTNESS, plus R02 when W01 requested risk gate. | Read project files; write only assigned product code, documentation, and execution run artifacts after lock validation. | CONDITIONAL |
| A04 | WORKER | TESTING | `agents/workers/test-worker.md` | `test_worker` | `.codex/agents/test-worker.toml` | W01 | test-strategy, positive-test-design, negative-test-design, boundary-test-design... | Logical Handoff To: R01 Quality Reviewer for TEST_QUALITY or TEST_COVERAGE, plus R02 for security/performance/contract risk. | Read source and test files; write assigned test files and test artifacts; execute approved test commands. | CONDITIONAL |
| A05 | WORKER | VERIFY | `agents/workers/verification-worker.md` | `verification_worker` | `.codex/agents/verification-worker.toml` | W01 | security-audit, performance-audit, architecture-conformance, documentation-consistency... | Logical Handoff To: R02 Risk Reviewer with FINAL_GATE or a specific risk profile chosen by W01. | Read all task artifacts and relevant code; write verification/docs artifacts only. No product code writes. | CONDITIONAL |
| R01 | REVIEWER | MULTI | `agents/reviewers/quality-reviewer.md` | `quality_reviewer` | `.codex/agents/quality-reviewer.toml` | W01 | knowledge-review, requirement-review, planning-review, code-correctness-review... | Return To: W01 Workflow Orchestrator only. May recommend a next stage but cannot dispatch it. | Read-only review artifacts. No direct writes except review artifact in own run folder. | YES |
| R02 | RISK_REVIEWER | MULTI | `agents/reviewers/risk-reviewer.md` | `risk_reviewer` | `.codex/agents/risk-reviewer.toml` | W01 | architecture-review, api-compatibility-review, database-migration-review, security-review... | Return To: W01 Workflow Orchestrator only. May recommend routing to a stage but cannot dispatch it. | Read-only risk review artifacts. No direct writes except review artifact in own run folder. | YES |
| F01 | SPECIALIST | FAILURE | `agents/specialists/failure-analyzer.md` | `failure_analyzer` | `.codex/agents/failure-analyzer.toml` | W01 | failure-routing, evidence-collection, risk-classification, artifact-validation | Return To: W01 Workflow Orchestrator with root-cause owner A01, A02, A03, A04, A05, BLOCKED, or user decision required. | Read artifacts and execute diagnostic/read-only commands. No code writes. | NO |
| M01 | MAINTENANCE | WORKFLOW_MAINTENANCE | `agents/maintenance/workflow-optimizer.md` | `workflow_optimizer` | `.codex/agents/workflow-optimizer.toml` | W01, scheduled maintenance, or explicit user request | evidence-comparison, tradeoff-analysis, decision-recording, workflow-profile-selection | Logical Handoff To: M02 Agent Evolution Reviewer. | Read workflow artifacts; write proposal artifacts only unless user explicitly asks to apply approved changes. | NO |
| M02 | MAINTENANCE_REVIEWER | WORKFLOW_MAINTENANCE | `agents/maintenance/agent-evolution-reviewer.md` | `agent_evolution_reviewer` | `.codex/agents/agent-evolution-reviewer.toml` | W01 or M01 | artifact-validation, risk-classification, backward-compatibility, final-gate-review | Return To: W01 Workflow Orchestrator with PASS, PASS_WITH_NOTES, REJECT, or BLOCKED. | Read-only review; write review artifacts only. | NO |

## Review Profiles

### R01 Quality Reviewer

- `KNOWLEDGE_QUALITY`
- `REQUIREMENT_QUALITY`
- `PLANNING_QUALITY`
- `CODE_CORRECTNESS`
- `BUSINESS_CORRECTNESS`
- `INTEGRATION_CORRECTNESS`
- `REFACTOR_SAFETY`
- `TEST_QUALITY`
- `TEST_COVERAGE`
- `DOCUMENTATION_QUALITY`

### R02 Risk Reviewer

- `ARCHITECTURE_GATE`
- `API_COMPATIBILITY_GATE`
- `MIGRATION_GATE`
- `SECURITY_GATE`
- `PERFORMANCE_GATE`
- `RELEASE_GATE`
- `FINAL_GATE`
- `WORKFLOW_EVOLUTION_GATE`

## Registry Rules

- A worker handoff target must be `R01` or `R02`; it cannot target another worker.
- A reviewer handoff target must be `W01`; it cannot target a worker or stage.
- W01 must spawn Codex custom agents by `Codex Name`; it must not use the `Spec Markdown File` column as the runtime role source or dispatch target.
- `F01` returns root-cause routing to W01 and never fixes code.
- `M01` and `M02` are optional maintenance agents and are not part of normal feature profiles.
- A conditional or skipped agent must have the skip reason recorded in `execution-workspace/<task>/execution-state.md`.
- A dispatched run cannot advance without `Skill Files Read` and `Skill Load Status: PASS` evidence matching its bundle.
- If caller, profile, required input, handoff, permission, write scope, or stop condition is missing, W01 must stop and create `blocked-report.md`.
