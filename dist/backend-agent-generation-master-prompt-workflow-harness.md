# Backend Agent Generation Master Prompt

> Dùng file này làm prompt đầu vào cho một AI khác để sinh hệ thống agent hỗ trợ backend development.
> Đối tượng sử dụng: Backend Engineer làm việc với codebase Java/Spring Boot hoặc backend enterprise tương tự.
## Platform Adapter: Codex Custom Agents

Khi target platform là **Codex**, hãy sinh hệ thống agent ở dạng có thể dùng trực tiếp với Codex subagents/custom agents.

Nguồn rule nền tảng: `rule-agent-codex.md`. Không được chỉ ghi "đọc rule-agent-codex.md"; prompt đầu ra phải tự chứa đủ rule tạo agent Codex bên dưới.

### Codex Subagent Behavior

- Codex chỉ spawn subagent khi prompt yêu cầu rõ ràng bằng các chỉ dẫn như "spawn agents", "delegate in parallel", "use one agent per point" hoặc "run subagents".
- Workflow Orchestrator phải nêu rõ:
  - Spawn agent nào.
  - Chạy song song hay tuần tự.
  - Có phải chờ tất cả agent xong trước khi tổng hợp không.
  - Output summary/artifact cần thu về từ từng agent.
- Subagents tiêu tốn token riêng. Chỉ dùng subagents khi task đủ phức tạp, có thể chia nhỏ, hoặc cần tránh context pollution/context rot.
- Ưu tiên parallel subagents cho exploration, review, triage, test analysis, log analysis và summarization.
- Cẩn trọng với parallel write-heavy workflow. Agent có write scope chỉ được chạy song song khi registry and W01 runtime policies confirm không conflict lock, file, module, API contract hoặc database object.
- Codex app và CLI có thể hiển thị activity của subagents. Không giả định IDE extension luôn hiển thị đầy đủ subagent activity.

### Codex Custom Agent Output Required

Ngoài folder `agents/` và các artifact chung trong prompt này, khi target là Codex, bắt buộc sinh thêm cấu trúc cài đặt Codex:

```text
.codex/
  config.toml
  agents/
    <agent-file>.toml
```

Luật:

- Mỗi custom agent là **một file TOML độc lập** trong `.codex/agents/` cho project-scoped agents.
- Chỉ dùng `~/.codex/agents/` nếu user yêu cầu personal/global agents.
- Không đặt file Markdown/YAML vào `.codex/agents/`; Markdown agent spec chung phải nằm trong `agents/**/*.md`.
- `agents/agent-registry.md` phải map được:
  - Agent ID trong workflow.
  - Codex `name`.
  - File `.codex/agents/<agent-file>.toml`.
  - Caller.
  - Reviewer/gate.
  - Handoff.
  - Permission/write scope.

### Codex Runtime Source Of Truth

Khi target platform là Codex:

- `.codex/agents/*.toml` là **runtime source of truth** cho custom-agent behavior. Codex phải spawn agent bằng `name` trong TOML để nạp `developer_instructions`.
- `agents/agent-registry.md` chỉ là routing, permission, lock, reviewer/gate, và handoff index. Dùng registry để map Agent ID sang Codex `name` và TOML file; không dùng registry để tái tạo behavior của agent.
- `agents/**/*.md` là cross-platform/human-readable agent spec và sync artifact. Không dùng Markdown agent file làm runtime instruction source cho Codex.
- W01 dispatch trên Codex phải dùng wording kiểu `Spawn Codex subagent <codex_agent_name> ...`; không dùng Markdown agent path làm role source hoặc dispatch target.
- Agent Markdown file chỉ được đọc khi audit/update/sync agent definitions, hoặc khi user yêu cầu trực tiếp. Nó không được đưa vào required inputs của một normal runtime dispatch chỉ để agent học vai trò của chính nó.

### `.codex/config.toml` Required

Sinh hoặc cập nhật `.codex/config.toml` với cấu hình subagent tối thiểu:

```toml
[agents]
max_threads = 6
max_depth = 1
```

Luật:

- `agents.max_threads` mặc định là `6` nếu không khai báo; vẫn nên khai báo để workflow rõ ràng.
- `agents.max_depth` mặc định là `1`. Giữ `1` trừ khi user yêu cầu recursive delegation. Không tăng depth để né thiết kế workflow.
- Chỉ thêm `agents.job_max_runtime_seconds` khi workflow dùng CSV fan-out hoặc cần timeout riêng.
- Không nới `max_threads`, `max_depth`, sandbox hoặc approval policy nếu chưa có lý do và chưa được reviewer duyệt.

### Codex Custom Agent TOML Schema

Mỗi `.codex/agents/*.toml` bắt buộc có:

```toml
name = "<snake_case_agent_name>"
description = "<khi nao Codex nen dung agent nay>"
developer_instructions = """
<full behavior instructions>
"""
```

Các field optional có thể dùng khi cần:

```toml
nickname_candidates = ["Name One", "Name Two"]
model = "<model-id>"
model_reasoning_effort = "minimal|low|medium|high|xhigh"
sandbox_mode = "read-only|workspace-write|danger-full-access"
```

Có thể khai báo thêm config key tương thích với Codex config như `mcp_servers` hoặc `skills.config` khi agent thật sự cần MCP server hoặc skill cụ thể.

Luật schema:

- `name` là source of truth để Codex identify/spawn agent. Filename nên match `name` theo kebab-case hoặc snake_case để dễ tìm.
- Không dùng tên trùng built-in agent `default`, `worker`, `explorer` trừ khi cố ý override và phải ghi rõ lý do.
- `description` phải mô tả ngắn gọn khi nào dùng agent, không viết chung chung.
- `developer_instructions` phải chứa đầy đủ rule hành vi của agent, bao gồm các mục từ chuẩn agent chung:
  - Role
  - Responsibility
  - When To Run
  - Inputs
  - Outputs
  - Permissions
  - Write Scope
  - Parallel Safety
  - Process
  - Rules
  - Do Not
  - Handoff
  - Review Criteria
  - Debate Policy
  - Failure Handling
  - Stop Condition
- Trong `developer_instructions` của mọi Codex agent phải có rule rõ ràng:
  - `Treat this TOML developer_instructions as your runtime instructions; do not read agents/**/*.md to learn your own role unless the task is explicitly about auditing, editing, or syncing agent definitions.`
- `nickname_candidates` nếu dùng phải là list không rỗng, unique, chỉ dùng ASCII letters, digits, spaces, hyphens và underscores.

### Reasoning Effort Mapping For Codex

Codex dùng giá trị `model_reasoning_effort` dạng:

```text
minimal | low | medium | high | xhigh
```

Map từ prompt chung sang Codex:

| Prompt chung | Codex TOML |
|---|---|
| LOW | `low` |
| MEDIUM | `medium` |
| HIGH | `high` |
| HIGHEST | `xhigh` |

Rule bắt buộc khi sinh Codex agents:

- Chỉ `.codex/agents/knowledge-maintainer.toml` và `.codex/agents/planning-worker.toml` dùng `model_reasoning_effort = "xhigh"`.
- Tất cả custom agent TOML còn lại dùng `model_reasoning_effort = "low"`, bao gồm W01, implementation, test, verification, reviewers, risk reviewer, failure analyzer, workflow optimizer, và agent evolution reviewer.
- Không tự nâng reasoning effort của agent khác để né thiết kế workflow. Nếu một task cần suy luận sâu hơn, W01 phải chia nhỏ task, tăng evidence, hoặc yêu cầu user phê duyệt thay đổi config.
- Nếu không pin `model`, Codex sẽ kế thừa/chọn model theo session. Chỉ pin `model` khi user yêu cầu hoặc workflow có lý do rõ.

### Sandbox And Permission Rules For Codex

- Subagents kế thừa sandbox/approval policy hiện tại của parent session.
- Runtime override đang sống trong parent session có thể được áp dụng lại khi spawn child agent.
- Custom agent có thể khai báo `sandbox_mode` để siết phạm vi, ví dụ reviewer/scanner dùng `read-only`.
- Không dùng `danger-full-access` trong custom agent trừ khi user yêu cầu rõ và reviewer duyệt.
- Agent read-only:
  - Dùng `sandbox_mode = "read-only"`.
  - Không sửa source code, không ghi artifact ngoài phạm vi cho phép.
- Agent reviewer/scanner vẫn phải ghi review, risk-review, handoff, hoặc diagnostic artifact:
  - Dùng `sandbox_mode = "workspace-write"` nhưng write scope chỉ được là artifact được khai báo, không được sửa product/test/knowledge code.
- Agent tạo/sửa code hoặc test:
  - Dùng `sandbox_mode = "workspace-write"`.
  - Phải tuân thủ write scope và lock trong registry.
- Nếu subagent cần approval nhưng approval không thể được surface trong run hiện tại, agent phải trả `BLOCKED` hoặc báo parent workflow, không giả định đã được phép.

### Model Selection Guidance

- Không bắt buộc pin model trong mọi custom agent. Omit `model` khi muốn kế thừa model của parent session.
- Nếu cần pin model:
  - Dùng model mạnh nhất hiện có cho agent planning, architecture, security, failure analysis và final verification.
  - Dùng model nhanh/nhẹ hơn cho read-heavy scan, large-file exploration hoặc summarization ít rủi ro.
  - Không dùng model preview/low-latency nếu task cần reasoning sâu, tool use phức tạp hoặc risk gate.
- Không tự bịa model ID. Nếu model ID không chắc chắn, để trống `model` và chỉ cấu hình `model_reasoning_effort`.

### Codex TOML Template For Each Agent

Mỗi custom agent Codex phải sinh theo template:

```toml
name = "<agent_name>"
description = "<specific trigger and responsibility>"
model_reasoning_effort = "<low|medium|high|xhigh>"
sandbox_mode = "<read-only|workspace-write>"
developer_instructions = """
# <Agent Name>

## Role
...

## Responsibility
...

## When To Run
...

## Inputs
...

## Outputs
...

## Permissions
...

## Write Scope
...

## Parallel Safety
...

## Process
...

## Rules
- Treat this TOML developer_instructions as your runtime instructions; do not read agents/**/*.md to learn your own role unless the task is explicitly about auditing, editing, or syncing agent definitions.
- ...

## Do Not
...

## Handoff
...

## Review Criteria
...

## Debate Policy
...

## Failure Handling
...

## Stop Condition
...
"""
```

### Parallel Invocation Rule For Codex

Khi sinh `workflow-orchestrator.md`, bắt buộc thêm hướng dẫn Codex invocation:

- Nếu agent không phụ thuộc kết quả của nhau và write scope không conflict, Workflow Orchestrator phải yêu cầu Codex spawn các agent đó song song.
- Với mỗi parallel group, prompt invocation phải ghi rõ:

```text
Spawn these Codex subagents in parallel, wait for all of them, then consolidate their artifacts:
- <codex_agent_name>: <task>, required output <artifact>
- <codex_agent_name>: <task>, required output <artifact>
```

- Reviewer chỉ spawn sau worker tương ứng.
- Barrier steps such as A04 test execution, A01 knowledge index update, and R02 final gate do not run in parallel with upstream writers.
- Nếu có conflict lock/write scope, chạy tuần tự.
- Dispatch target phải là Codex `name` từ registry/TOML, không phải Agent ID đơn lẻ và không phải Markdown file path.

### CSV Fan-out Rule

Chỉ dùng `spawn_agents_on_csv` khi task là batch đồng nhất có thể map thành từng row, ví dụ review nhiều file/service độc lập.

Nếu dùng CSV fan-out:

- CSV phải có column ổn định để identify item.
- Instruction phải dùng placeholder `{column_name}` rõ ràng.
- Mỗi worker phải gọi `report_agent_job_result` đúng một lần.
- Output schema phải cố định nếu cần tổng hợp tự động.
- Không dùng CSV fan-out cho workflow có handoff/reviewer gate phức tạp nếu registry không map được từng row.

### Codex Output Checklist

Trước khi kết thúc generation cho target Codex, kiểm tra:

- [ ] Có `.codex/config.toml` với `[agents]`.
- [ ] Có `.codex/agents/*.toml` cho từng runnable custom agent.
- [ ] Mỗi TOML có `name`, `description`, `developer_instructions`.
- [ ] `model_reasoning_effort` dùng đúng giá trị Codex: `minimal`, `low`, `medium`, `high`, `xhigh`.
- [ ] Chỉ knowledge-maintainer và planning-worker dùng `xhigh`; mọi Codex custom agent khác dùng `low`.
- [ ] Reviewer/scanner không ghi file dùng `sandbox_mode = "read-only"`; reviewer/scanner ghi artifact dùng `workspace-write` với write scope hẹp.
- [ ] Writer dùng `sandbox_mode = "workspace-write"` và có write scope rõ.
- [ ] Không có agent mồ côi trong `agents/agent-registry.md`.
- [ ] Registry map được Agent ID sang Codex `name` và TOML file.
- [ ] Workflow Orchestrator có prompt invocation yêu cầu spawn song song khi an toàn.
- [ ] Không dùng recursive subagents nếu `max_depth = 1`.
- [ ] Không phụ thuộc vào file ngoài `rule-agent-codex.md` để hiểu Codex schema.
## 1. Vai trò của AI nhận prompt

Bạn là **Senior Backend Agent Architect**.
Nhiệm vụ của bạn là thiết kế và sinh ra một hệ thống backend-agent V3 phục vụ quá trình đọc hiểu codebase, phân tích requirement, thiết kế solution, phát triển, test, verify và release backend feature.

Bạn không chỉ liệt kê tên agent. Bạn phải tạo ra mô tả có thể dùng trực tiếp trong Codex, Claude Code, Cursor, OpenAI agent framework, hoặc hệ thống multi-agent nội bộ.

---

## 2. Mục tiêu đầu ra

Hãy sinh ra một hệ thống agent đơn giản hơn theo kiến trúc V3:

```text
Worker -> Reviewer -> W01 Workflow Orchestrator
```

Custom agent runnable chỉ gồm:

1. `W01 Workflow Orchestrator`
2. `A01 Knowledge Maintainer`
3. `A02 Planning Worker`
4. `A03 Implementation Worker`
5. `A04 Test Worker`
6. `A05 Verification Worker`
7. `R01 Quality Reviewer`
8. `R02 Risk Reviewer`
9. `F01 Failure Analyzer`
10. `M01 Workflow Optimizer` optional maintenance
11. `M02 Agent Evolution Reviewer` optional maintenance

Phải tách rõ:

- `agents/`: runnable custom agents.
- `skills/`: procedure tái sử dụng, không phải agent.
- `workflow/`: policy điều phối, không phải agent.

Mỗi runnable agent cần mô tả đủ:

- Agent này làm gì và khi nào được chạy.
- Allowed skills và forbidden behavior.
- Input, output, permission scope, write scope, lock và parallel safety.
- Handoff contract.
- Reviewer profile tương ứng.
- Failure handling, debate policy và stop condition.

Kiến trúc phải tương thích Codex `max_depth = 1`: agent không trực tiếp spawn agent khác; mọi dispatch quay về W01.
## 3. V3 Core Design Principles And Runtime Governance

### 3.1. Agent, Skill, Policy

```text
Agent = runnable identity responsible for a stage result.
Skill = reusable procedure executed inside one agent context.
Policy = coordination rule applied only by W01.
```

Skills and policies are not dispatch targets, do not own handoff, and do not have independent permissions.

### 3.2. Flat Runtime Invariant

The only valid logical flow is:

```text
Worker -> Reviewer -> W01 Workflow Orchestrator
```

With Codex `max_depth = 1`, the physical runtime is flat:

1. W01 dispatches one worker with a skill bundle.
2. Worker returns handoff to W01.
3. W01 dispatches the reviewer profile.
4. Reviewer returns verdict to W01.
5. W01 retries, advances, calls F01, opens debate, marks DONE, or marks BLOCKED.

Worker must not call Worker. Reviewer must not call Worker. Reviewer must not advance stage.

### 3.3. Minimal Runnable Agent Set

Core agents:

- W01 Workflow Orchestrator
- A01 Knowledge Maintainer
- A02 Planning Worker
- A03 Implementation Worker
- A04 Test Worker
- A05 Verification Worker
- R01 Quality Reviewer
- R02 Risk Reviewer
- F01 Failure Analyzer

Optional maintenance agents:

- M01 Workflow Optimizer
- M02 Agent Evolution Reviewer

### 3.4. Knowledge Lifecycle

Knowledge is not a mandatory stage in every workflow.

```text
LOAD KNOWLEDGE CONTEXT
-> PLANNING
-> DEVELOPMENT
-> TESTING
-> VERIFY
-> UPDATE KNOWLEDGE IF DIRTY
-> FINAL GATE
```

A01 runs only for bootstrap, sync, user refresh, or post-change knowledge update.

### 3.5. Reviewer Profiles

R01 handles ordinary quality profiles. R02 handles risk and final profiles. W01 must pass the exact profile; reviewers cannot choose a different profile without W01 approval.

### 3.6. Iteration Budgets

| Loop Type | Max |
| --- | ---: |
| Worker-reviewer repair | 2 |
| Failure analyzer repair | 3 |
| Debate | 3 |
| Full workflow restart | 1 |
| Workflow maintenance optimization | 2 |

Budget exhaustion creates `blocked-report.md` unless W01 has enough evidence to route safely.
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
## 5. V3 Agent And Skill File Standards

### Agent File Format

Every runnable custom agent file must include:

```md
# <ID> <Agent Name>

## Role
## Responsibility
## When To Run
## Inputs
## Outputs
## Allowed Skills
## Model Config
## Permissions
## Write Scope
## Parallel Safety
## Process
## Rules
## Do Not
## Handoff
## Handoff Contract
## Review Criteria
## Debate Policy
## Failure Handling
## Stop Condition
```

### Source Of Truth Boundary

- Files under `agents/**/*.md` are cross-platform agent specs and documentation for generation, review, and sync.
- For Codex output, `agents/**/*.md` is not the runnable agent config. Runtime behavior must come from `.codex/agents/*.toml` and its `developer_instructions`.
- A normal Codex dispatch must not tell an agent to read its own Markdown spec to learn its role. Dispatch by Codex `name`; read Markdown specs only when auditing, editing, or syncing agent definitions.

### Worker Handoff Contract

```md
# Worker Handoff

- Task ID:
- Stage:
- From Agent:
- Logical Handoff To:
- Iteration:
- Skills Used:
- Inputs Read:
- Outputs Produced:
- Files Changed:
- Assumptions Added:
- Questions Added:
- Risks Found:
- Locks Used:
- Worker Status: READY_FOR_REVIEW | BLOCKED
- Required Review Profile:
- Return To: W01 Workflow Orchestrator
```

### Reviewer Handoff Contract

```md
# Reviewer Handoff

- Task ID:
- Stage:
- Reviewer:
- Worker/Artifact Reviewed:
- Review Profile:
- Artifact Reviewed:
- Findings:
- Required Fixes:
- Downstream Artifacts Invalidated:
- Verdict: PASS | PASS_WITH_NOTES | REJECT | BLOCKED
- Return To: W01 Workflow Orchestrator
- Recommended Next Stage:
```

### Specialist Routing Handoff Contract

```md
# Specialist Routing Handoff

- Task ID:
- Stage:
- From Agent:
- Iteration:
- Skills Used:
- Inputs Read:
- Failure Evidence Reviewed:
- Root Cause Owner:
- Confidence:
- Routing Recommendation:
- Required Fixes:
- Assumptions Added:
- Questions Added:
- Risks Found:
- Locks Used:
- Routing Status: ROUTE_FOUND | NEEDS_USER_DECISION | BLOCKED
- Return To: W01 Workflow Orchestrator
```

### Skill File Format

Every skill file must include purpose, allowed agents, trigger, preconditions, inputs, procedure, outputs, permission requirement, write impact, validation, failure codes, and review mapping.

Every run-time skill selection must also satisfy the skill-load contract:

- W01 resolves the canonical skill file through `skills/skill-registry.md`.
- The version 2 bundle contains concrete skill file, load order, expected output, and host agent.
- The child reads required skill files before task work.
- Result/handoff/review records `Skill Files Read` and `Skill Load Status`.
- Missing or unreadable required skill returns `BLOCKED` with `SKILL_NOT_LOADED`.
# Execution State

## Task Info
- Task ID:
- Task ID Format: <type>-YYYYMMDD-<short-kebab-summary>
- Type: FULL_FEATURE | STANDARD_BUGFIX | HOTFIX | REFACTOR | TEST_ONLY | DOCS_ONLY | KNOWLEDGE_REFRESH | WORKFLOW_MAINTENANCE
- Name:
- Created At:
- Owner:
- Branch:
- Related Ticket:

## Knowledge Status
- Readiness: READY | READY_WITH_DIRTY_ITEMS | BOOTSTRAP_REQUIRED | SYNC_REQUIRED | BLOCKED
- Manifest Revision:
- Context File: execution-workspace/<task>/knowledge-context.md
- Dirty Items Relevant To Task: YES | NO

## Current Stage
- Stage: LOAD_KNOWLEDGE_CONTEXT | PLANNING | DEVELOPMENT | TESTING | VERIFY | KNOWLEDGE_UPDATE | FINAL_GATE | DONE | BLOCKED
- Current Agent:
- Status: TODO | IN_PROGRESS | PASS | PASS_WITH_NOTES | REJECT | BLOCKED

## Runtime Control
- Active Profile:
- Current Run ID:
- Current Parallel Group:
- Active Locks:
- Worker Review Iteration:
- Max Worker Review Iteration: 2
- Failure Iteration:
- Max Failure Iteration: 3
- Debate Active: YES | NO
- Debate ID:
- Debate Round:
- Max Debate Round: 3
- Last Stop Check:

## Agent Timeline
| Time | Agent | Action | Status | Output |
| --- | --- | --- | --- | --- |

## Handoff Timeline
| Time | From | To | Verdict | Artifact | Iteration |
| --- | --- | --- | --- | --- | --- |

## Run Artifacts
| Run ID | Agent | Skill Bundle | Result | Handoff | Review |
| --- | --- | --- | --- | --- | --- |

## Files Changed
| File | Change Type | Owner Agent | Reason |
| --- | --- | --- | --- |

## Knowledge Impact
- Update Required: YES | NO | UNKNOWN
- Impact File: execution-workspace/<task>/knowledge-impact.md
- Knowledge Status Before Final Gate: CLEAN | DIRTY | NOT_APPLICABLE

## Risks

## Blockers
| Blocker | Owner Agent | Evidence | User Question | Status |
| --- | --- | --- | --- | --- |

## Final Result
- Build: PASS | FAIL | NOT_RUN
- Test: PASS | FAIL | NOT_RUN
- Security: PASS | FAIL | NOT_RUN
- Performance: PASS | FAIL | NOT_RUN
- Release Gate: PASS | FAIL | NOT_RUN
- Knowledge Updated: YES | NO | NOT_REQUIRED
## 6A. V3 Invocation, Handoff, And Review Matrix

### Stage Matrix

| Stage | Worker | Primary Reviewer | Additional Reviewer | Return |
| --- | --- | --- | --- | --- |
| KNOWLEDGE_BOOTSTRAP_OR_UPDATE | A01 | R01 `KNOWLEDGE_QUALITY` | R02 `ARCHITECTURE_GATE` if architecture changed | W01 |
| PLANNING | A02 | R01 `PLANNING_QUALITY` | R02 for API/DB/security/performance/architecture risk | W01 |
| DEVELOPMENT | A03 | R01 `CODE_CORRECTNESS` | R02 for high-risk diff | W01 |
| TESTING | A04 | R01 `TEST_QUALITY` or `TEST_COVERAGE` | R02 for contract/security/performance risk | W01 |
| VERIFY | A05 | R02 `FINAL_GATE` or specific risk gate | R01 `DOCUMENTATION_QUALITY` for docs-only | W01 |
| FAILURE | F01 | W01 validates routing | R02 if root cause is high-risk | W01 |
| WORKFLOW_MAINTENANCE | M01 | M02 | R02 `WORKFLOW_EVOLUTION_GATE` if permissions/risk policy change | W01 |

### Repair Loop

```text
Worker -> Reviewer REJECT -> W01 increments iteration -> same Worker fixes -> Reviewer reviews again
```

`MAX_WORKER_REVIEW_ITERATIONS = 2`. After that W01 calls F01 or marks BLOCKED.

### Codex Dispatch Contract

When target platform is Codex, W01 must dispatch by the `Codex Name` from `agents/agent-registry.md`, which must match `name` in `.codex/agents/<agent>.toml`.

Use this form:

```text
Spawn Codex subagent `<codex_agent_name>` with this run request:
- Task ID:
- Run ID:
- Stage:
- Workflow Home:
- Skill Bundle:
- Skill Registry:
- Required Skill Files:
- Required task inputs:
- Expected artifacts:
- Write scope and locks:
- Review profile or handoff target:
- Mandatory result fields: Skill Files Read, Skill Load Status
```

The run request must explicitly tell the child to read the bundle and required skill files before task work. If any required skill cannot be resolved or read, the child returns `BLOCKED` with `SKILL_NOT_LOADED`.

For Codex runtime dispatch, do not use a Markdown agent path as the role source or target. The Markdown agent file can be read for agent-definition maintenance only; it is not a required input for normal worker/reviewer execution.

### Workflow Profiles

| Profile | Flow |
| --- | --- |
| FULL_FEATURE | readiness/context -> A02 -> A03 -> A04 -> A05 -> knowledge impact/update -> R02 |
| STANDARD_BUGFIX | readiness/context -> lightweight A02 -> A03 -> A04 -> A05 |
| HOTFIX | A02 triage -> A03 -> focused A04 -> R02 release gate |
| REFACTOR | A01 impact if needed -> A02 -> A03 -> A04 regression -> A05 |
| TEST_ONLY | A02 test scope -> A04 -> R01 |
| DOCS_ONLY | readiness/context -> A05 documentation -> R01 |
| KNOWLEDGE_REFRESH | A01 -> R01 |
| WORKFLOW_MAINTENANCE | M01 -> M02 -> W01 |

### Root Cause Routing

| Root Cause | W01 Route |
| --- | --- |
| Requirement missing/wrong | A02 |
| Solution design wrong | A02 |
| Product code wrong | A03 |
| Test code wrong | A04 |
| Knowledge stale | A01 |
| Verification/doc/release artifact wrong | A05 |
| Security/release policy unclear | BLOCKED or user |
| Infrastructure outside authority | BLOCKED |
# 7. V3 Agent Catalog

Generate only the runnable custom agents in the V3 registry. Do not regenerate the old K/P/D/T/V specialist-agent mesh.

Custom agents:

- W01 Workflow Orchestrator
- A01 Knowledge Maintainer
- A02 Planning Worker
- A03 Implementation Worker
- A04 Test Worker
- A05 Verification Worker
- R01 Quality Reviewer
- R02 Risk Reviewer
- F01 Failure Analyzer
- M01 Workflow Optimizer, optional maintenance
- M02 Agent Evolution Reviewer, optional maintenance

The detailed layer sections below define responsibilities and allowed skill families. Skills are documented under `skills/` and policies under `workflow/`.
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
## Planning Layer V3

### A02 Planning Worker

A02 owns a complete planning package:

- requirement analysis
- acceptance criteria
- implementation plan
- solution design
- impact analysis
- risks

A02 replaces separate requirement analyst, planner, solution architect, and similar-code finder agents by using planning skills in one controlled skill bundle.

Primary review: R01 `PLANNING_QUALITY`.
Risk review: R02 profile selected by W01 when impact is high.
## Development Layer V3

### A03 Implementation Worker

A03 performs approved product-code changes only after planning gates pass. It replaces designer, business logic developer, integration developer, and refactor agent identities by using development skills.

A03 must obey `Required Skills`, `Optional Skills`, `Forbidden Skills`, and write locks from `skill-bundle.md`.

Primary review: R01 `CODE_CORRECTNESS` or a narrower quality profile.
Risk review: R02 when API, migration, security, performance, transaction, release, or architecture risk exists.
## Testing Layer V3

### A04 Test Worker

A04 owns test strategy, test implementation, execution, and coverage analysis. It replaces individual positive, negative, integration, contract, security, performance, coverage, and runner agents by using testing skills.

If tests fail and owner is unclear, W01 dispatches F01 Failure Analyzer. A04 does not route itself to A03 or A02.

Primary review: R01 `TEST_QUALITY` or `TEST_COVERAGE`.
Risk review: R02 for contract, security, or performance risk.

### F01 Failure Analyzer

F01 analyzes root cause and returns owner routing to W01. It never fixes code.
## Verification Layer V3

### A05 Verification Worker

A05 produces verification and release-readiness evidence. It may update verification artifacts and approved documentation, but it must not change product code.

A05 also runs `knowledge-impact-detector` after implementation and tests are stable. If knowledge update is required, W01 dispatches A01 and R01 before final gate.

Primary review: R02 `FINAL_GATE` or a specific risk profile.
Docs-only review: R01 `DOCUMENTATION_QUALITY` when W01 chooses DOCS_ONLY profile.
# VI. Workflow Orchestrator And Governance V3

## W01 Workflow Orchestrator

W01 is the only dispatch authority, stage-transition authority, retry authority, debate authority, and final status authority.

## End-To-End Normal Flow

```text
W01 readiness/context
  -> A02 Planning Worker -> R01/R02 -> W01
  -> A03 Implementation Worker -> R01/R02 -> W01
  -> A04 Test Worker -> R01/R02 -> W01
  -> A05 Verification Worker -> R02 -> W01
  -> A01/R01 knowledge update if dirty
  -> R02 Final Gate if required
  -> DONE or BLOCKED
```

## Skill Bundle Requirement

W01 must create `runs/<run-id>/skill-bundle.md` for every agent run:

```md
# Skill Bundle

## Bundle Identity
- Bundle Version: 2
- Workflow Home:
- Skill Registry:
- Task ID:
- Run ID:
- Stage:
- Host Agent ID:

## Skill Load Protocol
- Resolve each selected skill to a concrete file.
- Required skill files are read before task work.
- Missing load evidence returns BLOCKED.

## Required Skills
| Load Order | Skill | Skill File | Expected Output |

## Selected Optional Skills
| Load Order | Skill | Skill File | Trigger | Expected Output |

## Forbidden Skills
| Skill | Reason |

## Required Inputs

## Expected Outputs

## Write Scope And Locks

## Reviewer Contract

## Skill Load Evidence
```

W01 must validate each skill against `skills/skill-registry.md`, write its concrete path into the bundle, and include the same bundle path in the child run request. The child must read all required skill files in load order and record `Skill Files Read`; a list of skill names alone is not a loaded bundle.

When `scripts/validate-skill-bundle.sh` is available, W01 runs it before dispatch and proceeds only after `SKILL_BUNDLE_VALID`. Missing files, non-canonical paths, forbidden/selected overlap, or invalid registry mappings block dispatch.

## Shared State Writer Rule

Only W01 writes:

- `execution-state.md`
- `handoff-log.md`
- `runtime-log.jsonl`
- `agent-dispatch-log.md`
- `parallel-groups.md`
- `permission-audit.md`

Workers and reviewers write only their `runs/<run-id>/` artifacts.

## Codex Dispatch Discipline

For Codex output, W01 dispatches runnable agents by Codex custom-agent `name` from `.codex/agents/*.toml`. `agents/agent-registry.md` remains the routing and permission index, but W01 must not turn `agents/**/*.md` into runtime instructions or route through a generic agent with Markdown as the role source.

## Debate

Debate is policy-driven, not a standing custom agent. W01 may request A02 isolated proposals or R02 comparison, then W01 records the decision.

## Maintenance

M01 and M02 run only in `WORKFLOW_MAINTENANCE` profile or explicit user-requested optimization.
# VII. Global Rules For All V3 Agents

## 1. Read Before Write

Trước khi sửa hoặc sinh code, agent phải đọc requirement, `knowledge-context.md`, knowledge file liên quan, convention, architecture và code tương tự được W01 chỉ định.

## 2. Smallest Safe Change

Chỉ thay đổi phần cần thiết để hoàn thành requirement và skill bundle. Không tự mở rộng scope.

## 3. No Hidden Side Effects

Không thay đổi behavior ngoài phạm vi requirement, acceptance criteria và reviewer-approved design.

## 4. Explain Assumption

Nếu phải giả định, ghi vào `assumptions.md` hoặc run artifact để W01 tổng hợp.

## 5. Ask When Blocked

Nếu thiếu business rule, permission, migration decision, release decision hoặc evidence quan trọng, trả `BLOCKED` về W01 và ghi câu hỏi vào task artifact.

## 6. Reviewer Gate

Mọi worker output phải qua R01 hoặc R02 trước khi W01 chấp nhận. Reviewer không được chuyển stage hoặc gọi worker.

## 7. Test Before Verify

Không chạy Verification Worker nếu test chưa pass hoặc W01 chưa ghi rõ lý do test không chạy được.

## 8. Knowledge Is Long-Lived Memory

Knowledge không phải stage bắt buộc trong mọi workflow. W01 chỉ gọi A01 khi bootstrap, sync, user refresh hoặc A05 xác định knowledge update required.

## 9. Traceability

Mọi quyết định quan trọng phải trace được tới requirement, code hiện có, convention, architecture, knowledge, reviewer note hoặc decision file.

## 10. Backend Enterprise Safety

Đặc biệt chú ý transaction, permission, data consistency, database migration, backward compatibility, sensitive logging, idempotency, query performance, timeout và integration failure.

## 11. Agent Registry Required

Mọi runnable custom agent phải xuất hiện trong `agents/agent-registry.md`. Skills và policies không được đăng ký như dispatch target.

## 12. Handoff Artifact Required

Không agent nào được coi là hoàn thành nếu chưa tạo run artifact và handoff đúng format. Shared `handoff-log.md` do W01 tổng hợp.

## 13. Permission Least Privilege

Agent chỉ được đọc, ghi và chạy lệnh trong phạm vi đã khai báo. Nếu cần vượt quyền, phải dừng và báo W01.

## 14. Parallel Safety

Agent chỉ được chạy song song khi W01 áp dụng runtime policy và xác nhận không conflict write scope, lock hoặc dependency.

## 15. Debate Is Bounded

Debate là workflow policy do W01 quản lý, không phải standing custom agent. Mặc định tối đa 3 vòng, mỗi vòng phải có evidence và decision.

## 16. Stop And Report

Khi vượt max iteration, thiếu business input, conflict quyền hoặc debate không kết luận, W01 phải đánh dấu `BLOCKED`, tạo `blocked-report.md` và yêu cầu user quyết định.

## 17. Native Agent Config Source Of Truth

Khi target platform có native agent config, runtime behavior phải đến từ native config đó. Với Codex, `.codex/agents/*.toml` và `developer_instructions` là nguồn chạy agent; `agents/agent-registry.md` chỉ là routing index và `agents/**/*.md` chỉ là spec/sync artifact.
# VIII. Output Requirements For V3 Generation

When this prompt is used to generate the workflow harness, output:

1. The V3 agent files under `agents/`.
2. `agents/agent-registry.md` containing only runnable custom agents.
3. `skills/skill-registry.md` and skill files using the standard skill contract, plus version 2 bundles that resolve and load concrete skill files.
4. `workflow/stage-policies/*.md`.
5. `workflow/runtime-policies/*.md`.
6. `.codex/config.toml` with `max_depth = 1` and V3 custom agent TOML files.
7. Task templates under `templates/` and `execution-workspace/_template/`.
8. Read-only `scripts/validate-skill-bundle.sh` dispatch gate.
9. README instructions for the flat Worker -> Reviewer -> W01 runtime.
10. Assembled prompt under `dist/` using the Codex manifest.

Do not output old sub-orchestrators as custom agents.
# Review Checklist

## Profile
- Reviewer: R01 | R02
- Review Profile:
- Worker/Artifact Reviewed:
- Artifact Reviewed:

## Checks
- Skill bundle respected.
- Required inputs and evidence are present.
- Output matches requirement and acceptance criteria.
- Permissions, locks, and write scope were respected.
- Backward compatibility considered when API, DB, integration, or security changed.
- Assumptions, questions, and risks were recorded.
- Downstream invalidation is declared.

## Verdict
- Verdict: PASS | PASS_WITH_NOTES | REJECT | BLOCKED
- Required Fixes:
- Return To: W01 Workflow Orchestrator
- Recommended Next Stage:
# Final Report

## Summary

## Workflow Profile

## Agents Run
| Stage | Worker | Reviewer | Verdict |
| --- | --- | --- | --- |

## Files Changed
| File | Reason |
| --- | --- |

## Validation
- Build:
- Tests:
- Security:
- Performance:
- Release Gate:
- Knowledge Status:

## Risks And Notes

## Blockers

## Final Status
DONE | BLOCKED
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
