# Đề xuất Backend Agent Architecture V3

## 1. Mục tiêu thiết kế

Mô hình mới giải quyết hai vấn đề:

1. Chuẩn hóa tuyệt đối luồng:

```text
Worker → Reviewer → Workflow Orchestrator
```

2. Giảm số lượng custom agent bằng cách:

```text
Agent = chủ thể chịu trách nhiệm cho kết quả của một stage
Skill = quy trình chuyên môn có thể tái sử dụng
Policy = luật điều phối, không phải agent
```

Prompt hiện tại yêu cầu registry, handoff artifact, permission, reviewer gate và dùng Codex với `max_depth = 1`. Vì vậy, mô hình dispatch phẳng với một orchestrator gốc phù hợp hơn mô hình nhiều sub-orchestrator gọi lẫn nhau.

---

# 2. Kiến trúc tổng thể

## 2.1. Số lượng custom agent

### Agent cốt lõi

| ID  | Custom Agent          | Loại         | Trách nhiệm duy nhất                                         |
| --- | --------------------- | ------------ | ------------------------------------------------------------ |
| W01 | Workflow Orchestrator | Orchestrator | Điều phối toàn bộ task và quyết định bước tiếp theo          |
| A01 | Knowledge Worker      | Worker       | Tạo hoặc cập nhật knowledge package                          |
| A02 | Planning Worker       | Worker       | Tạo planning và solution package                             |
| A03 | Implementation Worker | Worker       | Thực hiện code change đã được duyệt                          |
| A04 | Test Worker           | Worker       | Thiết kế, viết và chạy test                                  |
| A05 | Verification Worker   | Worker       | Tạo verification và release-readiness package                |
| R01 | Quality Reviewer      | Reviewer     | Review correctness và completeness của artifact thông thường |
| R02 | Risk Reviewer         | Reviewer     | Review các gate có rủi ro cao                                |
| F01 | Failure Analyzer      | Specialist   | Phân tích root cause, không sửa code                         |

Tổng cộng:

```text
9 custom agent cốt lõi
```

### Agent bảo trì tùy chọn

| ID  | Custom Agent             | Trách nhiệm                                          |
| --- | ------------------------ | ---------------------------------------------------- |
| M01 | Workflow Optimizer       | Phân tích lịch sử và đề xuất tối ưu workflow         |
| M02 | Agent Evolution Reviewer | Review độc lập đề xuất thay đổi agent/skill/workflow |

Hai agent này không tham gia feature workflow thông thường.

Tổng khi bật maintenance:

```text
9 core agents + 2 maintenance agents
```

---

# 3. Thành phần không còn là custom agent

Các thành phần sau được chuyển thành workflow policy:

```text
Knowledge Orchestrator
Planning Orchestrator
Development Orchestrator
Testing Orchestrator
Verify Orchestrator
Harness Runtime
```

Chúng trở thành:

```text
workflow/
  workflow-orchestrator.md
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
```

Chỉ `W01 Workflow Orchestrator` được phép áp dụng các policy này.

Các stage policy:

* Không có identity riêng.
* Không được spawn agent.
* Không có permission riêng.
* Không ghi artifact nghiệp vụ.
* Chỉ mô tả stage cần chạy worker nào, reviewer nào và gate nào.

---

# 4. Luồng Worker → Reviewer → Orchestrator

## 4.1. Luồng logic

```text
Workflow Orchestrator
        │
        ▼
      Worker
        │
        ▼
     Reviewer
        │
        ▼
Workflow Orchestrator
```

Reviewer không được gọi worker tiếp theo.

Worker không được tự chuyển task sang stage tiếp theo.

Chỉ Workflow Orchestrator được:

* Dispatch agent.
* Chuyển stage.
* Retry worker.
* Chọn reviewer.
* Mở debate.
* Gọi Failure Analyzer.
* Đánh dấu `DONE` hoặc `BLOCKED`.

## 4.2. Luồng runtime với `max_depth = 1`

Do runtime dùng dispatch phẳng, agent không trực tiếp spawn agent khác.

Luồng thực tế:

```text
1. W01 dispatch A02 Planning Worker.
2. A02 tạo planning package.
3. A02 khai báo Logical Handoff Target = R01.
4. A02 kết thúc.
5. W01 đọc handoff và dispatch R01.
6. R01 review artifact.
7. R01 trả verdict về W01.
8. W01 quyết định retry hoặc chuyển stage.
```

Như vậy vẫn giữ đúng logical flow:

```text
Worker → Reviewer → Orchestrator
```

nhưng không vi phạm giới hạn recursive subagent.

---

# 5. Handoff contract chuẩn hóa

## 5.1. Worker handoff

Worker luôn handoff tới reviewer, không handoff tới worker khác.

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
```

Ví dụ:

```text
From Agent: A03 Implementation Worker
Logical Handoff To: R01 Quality Reviewer
Required Review Profile: CODE_CORRECTNESS
Worker Status: READY_FOR_REVIEW
```

## 5.2. Reviewer handoff

Reviewer luôn trả kết quả về W01.

```md
# Reviewer Handoff

- Task ID:
- Stage:
- Reviewer:
- Worker Reviewed:
- Review Profile:
- Artifact Reviewed:
- Findings:
- Required Fixes:
- Downstream Artifacts Invalidated:
- Verdict: PASS | PASS_WITH_NOTES | REJECT | BLOCKED
- Return To: W01 Workflow Orchestrator
```

Reviewer không được ghi:

```text
Next Agent: A04 Test Worker
```

Reviewer chỉ được ghi:

```text
Recommended Next Stage: TESTING
```

W01 là thành phần quyết định có thực hiện recommendation đó hay không.

## 5.3. Repair loop

```text
Worker
   ↓
Reviewer REJECT
   ↓
W01 tăng iteration
   ↓
W01 gửi finding về đúng Worker
   ↓
Worker sửa
   ↓
Reviewer review lại
```

Giới hạn mặc định:

```text
MAX_WORKER_REVIEW_ITERATIONS = 2
```

Sau hai lần vẫn `REJECT`:

```text
W01 → F01 Failure Analyzer
```

Nếu lỗi do thiếu business decision hoặc permission:

```text
Task → BLOCKED
```

---

# 6. Mô hình Skill

## 6.1. Skill là gì trong kiến trúc mới

Một skill là procedure chuyên môn có thể được nhiều agent tái sử dụng.

Skill:

* Không có identity độc lập.
* Không tự nhận task.
* Không tự spawn agent.
* Không có reviewer riêng.
* Không có execution state riêng.
* Không tự handoff.
* Chỉ chạy bên trong context và permission của agent gọi nó.

Ví dụ:

```text
repository-scan
api-contract-analysis
database-impact-analysis
negative-test-design
security-audit
release-readiness-check
```

## 6.2. Khi nào dùng Skill, khi nào dùng Agent

### Dùng Skill khi

* Công việc là một checklist hoặc procedure.
* Có thể tái sử dụng ở nhiều stage.
* Không cần context độc lập.
* Không cần permission độc lập.
* Không cần tranh luận hoặc ownership riêng.
* Output chỉ là một phần của artifact lớn hơn.

Ví dụ:

```text
Phân tích API compatibility
Kiểm tra boundary condition
Tạo Mermaid sequence diagram
Kiểm tra migration safety
Tính test coverage gap
```

### Dùng Agent khi

* Thành phần chịu trách nhiệm cho kết quả cuối của một stage.
* Cần permission riêng.
* Cần context độc lập.
* Cần reviewer độc lập.
* Cần write scope hoặc lock riêng.
* Cần được orchestrator dispatch và theo dõi.

Ví dụ:

```text
Implementation Worker
Test Worker
Risk Reviewer
Failure Analyzer
```

---

# 7. Skill catalog đề xuất

## 7.1. Core skills

Các skill dùng cho nhiều agent:

```text
skills/core/
  artifact-validation.md
  evidence-collection.md
  assumption-management.md
  question-management.md
  backward-compatibility.md
  risk-classification.md
  change-impact-analysis.md
  handoff-builder.md
  blocked-report-builder.md
```

## 7.2. Knowledge skills

Được phép dùng bởi `A01 Knowledge Worker`.

```text
skills/knowledge/
  repository-scan.md
  incremental-git-scan.md
  convention-analysis.md
  architecture-discovery.md
  pattern-discovery.md
  business-flow-discovery.md
  business-rule-discovery.md
  api-discovery.md
  database-discovery.md
  technology-stack-discovery.md
  reusable-component-discovery.md
  similar-code-search.md
  decision-memory-update.md
  knowledge-index-update.md
```

Thay thế phần lớn:

```text
K01–K14
```

## 7.3. Planning skills

Được phép dùng bởi `A02 Planning Worker`.

```text
skills/planning/
  requirement-analysis.md
  acceptance-criteria-design.md
  ambiguity-detection.md
  task-decomposition.md
  dependency-planning.md
  solution-design.md
  api-impact-design.md
  database-impact-design.md
  transaction-design.md
  integration-design.md
  migration-design.md
  security-impact-analysis.md
  performance-impact-analysis.md
  architecture-decision-record.md
```

Thay thế:

```text
Requirement Analyst
Planner
Solution Architect
Similar Code Finder
Business Rule Discovery
Decision Memory
```

## 7.4. Development skills

Được phép dùng bởi `A03 Implementation Worker`.

```text
skills/development/
  api-contract-implementation.md
  dto-mapping-implementation.md
  persistence-implementation.md
  migration-implementation.md
  business-logic-implementation.md
  transaction-implementation.md
  integration-implementation.md
  cache-implementation.md
  messaging-implementation.md
  error-handling-implementation.md
  safe-refactoring.md
  documentation-update.md
```

Thay thế:

```text
Designer
Business Logic Developer
Integration Developer
Refactor Agent
Documentation Agent
```

Không phải task nào cũng sử dụng toàn bộ skill. W01 lựa chọn skill bundle dựa trên planning package.

## 7.5. Testing skills

Được phép dùng bởi `A04 Test Worker`.

```text
skills/testing/
  test-strategy.md
  positive-test-design.md
  negative-test-design.md
  boundary-test-design.md
  permission-test-design.md
  unit-test-implementation.md
  integration-test-implementation.md
  contract-test-implementation.md
  security-test-implementation.md
  performance-test-implementation.md
  regression-test-selection.md
  test-execution.md
  coverage-analysis.md
  flaky-test-analysis.md
```

Thay thế phần lớn:

```text
T01–T15
```

`F01 Failure Analyzer` vẫn là agent vì root-cause analysis cần context và ownership độc lập.

## 7.6. Verification skills

Được phép dùng bởi `A05 Verification Worker`.

```text
skills/verification/
  security-audit.md
  performance-audit.md
  architecture-conformance.md
  documentation-consistency.md
  acceptance-criteria-verification.md
  regression-risk-assessment.md
  release-readiness.md
  migration-readiness.md
  rollback-plan-check.md
  configuration-impact.md
  knowledge-impact-check.md
```

Thay thế phần lớn:

```text
Security Auditor
Performance Optimizer
QA Lead
Release Manager
Documentation Agent
```

Lưu ý:

`A05 Verification Worker` chỉ được sửa documentation và verification artifact.

Nếu phát hiện cần sửa product code:

```text
A05 → R02 → W01 → A03
```

A05 không tự sửa business code.

## 7.7. Review skills

### R01 Quality Reviewer

```text
skills/review/
  knowledge-review.md
  requirement-review.md
  planning-review.md
  code-correctness-review.md
  convention-review.md
  business-rule-review.md
  integration-review.md
  refactor-review.md
  test-quality-review.md
  coverage-review.md
  documentation-review.md
```

### R02 Risk Reviewer

```text
skills/risk-review/
  architecture-review.md
  api-compatibility-review.md
  database-migration-review.md
  security-review.md
  performance-review.md
  transaction-review.md
  release-review.md
  final-gate-review.md
```

R01 và R02 là hai agent khác nhau để tránh một reviewer quá rộng và giữ gate rủi ro cao độc lập.

---

# 8. Review profile

Reviewer được tái sử dụng thông qua profile thay vì tạo một custom agent cho mỗi checklist.

## 8.1. R01 Quality Reviewer profiles

```text
KNOWLEDGE_QUALITY
REQUIREMENT_QUALITY
PLANNING_QUALITY
CODE_CORRECTNESS
BUSINESS_CORRECTNESS
INTEGRATION_CORRECTNESS
REFACTOR_SAFETY
TEST_QUALITY
TEST_COVERAGE
DOCUMENTATION_QUALITY
```

## 8.2. R02 Risk Reviewer profiles

```text
ARCHITECTURE_GATE
API_COMPATIBILITY_GATE
MIGRATION_GATE
SECURITY_GATE
PERFORMANCE_GATE
RELEASE_GATE
FINAL_GATE
WORKFLOW_EVOLUTION_GATE
```

W01 phải truyền profile rõ ràng khi dispatch reviewer:

```text
Dispatch R02 Risk Reviewer
Profile: MIGRATION_GATE
Artifact: solution-design.md
Required skills:
- database-migration-review
- backward-compatibility
- rollback-plan-check
```

Reviewer không tự chọn một profile khác nếu W01 chưa phê duyệt.

---

# 9. Stage workflow mới

## 9.1. Knowledge Stage

```text
W01
  ↓
A01 Knowledge Worker
  Skills:
    - incremental-git-scan hoặc repository-scan
    - convention-analysis
    - architecture-discovery
    - api/database/business discovery theo impact
    - knowledge-index-update
  ↓
R01 Quality Reviewer
  Profile: KNOWLEDGE_QUALITY
  ↓
W01
```

Nếu architecture knowledge có thay đổi lớn:

```text
W01 → R02
Profile: ARCHITECTURE_GATE
```

## 9.2. Planning Stage

```text
W01
  ↓
A02 Planning Worker
  Skills:
    - requirement-analysis
    - similar-code-search
    - acceptance-criteria-design
    - task-decomposition
    - solution-design
    - impact-analysis
  ↓
R01 Quality Reviewer
  Profile: PLANNING_QUALITY
  ↓
R02 Risk Reviewer nếu có high-risk impact
  Profile: ARCHITECTURE_GATE hoặc MIGRATION_GATE
  ↓
W01
```

Không còn ba cặp agent riêng:

```text
Requirement Analyst → Requirement Reviewer
Planner → Planning Reviewer
Solution Architect → Architecture Reviewer
```

Thay bằng một planning package được review qua nhiều profile.

Planning package phải chia thành các section riêng để reviewer vẫn biết chính xác lỗi nằm ở đâu:

```text
planning-package/
  requirement-analysis.md
  acceptance-criteria.md
  implementation-plan.md
  solution-design.md
  impact-analysis.md
  risks.md
```

## 9.3. Development Stage

```text
W01
  ↓
A03 Implementation Worker
  Skills được chọn theo planning package
  ↓
R01 Quality Reviewer
  Profile: CODE_CORRECTNESS
  ↓
R02 nếu có API, migration, security hoặc architecture risk
  ↓
W01
```

Ví dụ task chỉ sửa service logic:

```text
Required skills:
- business-logic-implementation
- transaction-implementation
- error-handling-implementation
```

Không chạy các skill:

```text
migration-implementation
messaging-implementation
cache-implementation
```

## 9.4. Testing Stage

```text
W01
  ↓
A04 Test Worker
  1. Tạo test strategy.
  2. Viết các test cần thiết.
  3. Chạy test.
  4. Sinh test result và coverage analysis.
  ↓
R01 Quality Reviewer
  Profile: TEST_QUALITY
  ↓
R02 nếu có security/performance/contract risk
  ↓
W01
```

Nếu test fail:

```text
A04 Test Worker
  ↓
W01
  ↓
F01 Failure Analyzer
  ↓
W01 route về owner
```

Root-cause routing:

| Root cause                           | W01 route tới     |
| ------------------------------------ | ----------------- |
| Requirement sai hoặc thiếu           | A02               |
| Solution design sai                  | A02               |
| Product code sai                     | A03               |
| Test code sai                        | A04               |
| Knowledge stale                      | A01               |
| Security/release policy chưa rõ      | BLOCKED hoặc user |
| Infrastructure ngoài quyền kiểm soát | BLOCKED           |

## 9.5. Verification Stage

```text
W01
  ↓
A05 Verification Worker
  Skills:
    - security-audit
    - performance-audit
    - architecture-conformance
    - documentation-consistency
    - release-readiness
    - knowledge-impact-check
  ↓
R02 Risk Reviewer
  Profile: FINAL_GATE
  ↓
W01
```

Nếu A05 phát hiện cần sửa code:

```text
A05
  ↓
R02 xác nhận finding
  ↓
W01
  ↓
A03 Implementation Worker
  ↓
R01/R02
  ↓
A04 Test Worker
  ↓
Verification chạy lại
```

Không được để Performance Optimizer hoặc Security Auditor tự sửa code trong Verify Stage.

---

# 10. Stage matrix

| Stage                | Worker | Reviewer chính          | Reviewer bổ sung                      | Handoff cuối |
| -------------------- | ------ | ----------------------- | ------------------------------------- | ------------ |
| KNOWLEDGE            | A01    | R01                     | R02 nếu architecture impact lớn       | W01          |
| PLANNING             | A02    | R01                     | R02 nếu API/DB/security risk          | W01          |
| DEVELOPMENT          | A03    | R01                     | R02 nếu high-risk change              | W01          |
| TESTING              | A04    | R01                     | R02 với contract/security/performance | W01          |
| VERIFY               | A05    | R02                     | Không cần reviewer thứ ba             | W01          |
| FAILURE              | F01    | Không review như worker | W01 xác nhận routing                  | W01          |
| WORKFLOW MAINTENANCE | M01    | M02                     | R02 nếu permission thay đổi           | W01          |

---

# 11. Mapping agent cũ sang mô hình mới

## Knowledge Layer

| Agent cũ                         | Thành phần mới                       |
| -------------------------------- | ------------------------------------ |
| K01 Repository Scanner           | `repository-scan` skill              |
| K02 Incremental Scanner          | `incremental-git-scan` skill         |
| K03 Convention Analyzer          | `convention-analysis` skill          |
| K04 Architecture Discovery       | `architecture-discovery` skill       |
| K05 Pattern Discovery            | `pattern-discovery` skill            |
| K06 Business Flow Discovery      | `business-flow-discovery` skill      |
| K07 API Discovery                | `api-discovery` skill                |
| K08 Database Discovery           | `database-discovery` skill           |
| K09 Skill Discovery              | `technology-stack-discovery` skill   |
| K10 Reusable Component Discovery | `reusable-component-discovery` skill |
| K11 Similar Code Finder          | `similar-code-search` skill          |
| K12 Business Rule Discovery      | `business-rule-discovery` skill      |
| K13 Decision Memory              | `decision-memory-update` skill       |
| K14 Knowledge Indexer            | `knowledge-index-update` skill       |
| K15 Knowledge Reviewer           | R01 profile `KNOWLEDGE_QUALITY`      |
| K16 Knowledge Orchestrator       | Knowledge stage policy của W01       |

## Planning Layer

| Agent cũ                  | Thành phần mới                    |
| ------------------------- | --------------------------------- |
| P01 Requirement Analyst   | Planning skill                    |
| P02 Requirement Reviewer  | R01 profile `REQUIREMENT_QUALITY` |
| P03 Planner               | Planning skill                    |
| P04 Planning Reviewer     | R01 profile `PLANNING_QUALITY`    |
| P05 Solution Architect    | Planning skill                    |
| P06 Architecture Reviewer | R02 profile `ARCHITECTURE_GATE`   |
| P07 Planning Orchestrator | Planning stage policy của W01     |

## Development Layer

| Agent cũ                     | Thành phần mới                        |
| ---------------------------- | ------------------------------------- |
| D01 Designer                 | Development skill bundle              |
| D02 API Reviewer             | R01/R02 review profile                |
| D03 Business Logic Developer | `business-logic-implementation` skill |
| D04 Business Reviewer        | R01 profile `BUSINESS_CORRECTNESS`    |
| D05 Integration Developer    | `integration-implementation` skill    |
| D06 Integration Reviewer     | R01 profile `INTEGRATION_CORRECTNESS` |
| D07 Refactor Agent           | `safe-refactoring` skill              |
| D08 Refactor Reviewer        | R01 profile `REFACTOR_SAFETY`         |
| D09 Development Orchestrator | Development stage policy của W01      |

## Testing Layer

| Agent cũ                 | Thành phần mới                 |
| ------------------------ | ------------------------------ |
| T01–T14                  | Testing và review skills       |
| T15 Test Runner          | `test-execution` skill của A04 |
| T16 Failure Analyzer     | Giữ lại F01 custom agent       |
| T17 Testing Orchestrator | Testing stage policy của W01   |

## Verify Layer

| Agent cũ                   | Thành phần mới                          |
| -------------------------- | --------------------------------------- |
| V01 Security Auditor       | Verification skill                      |
| V02 Security Reviewer      | R02 `SECURITY_GATE`                     |
| V03 Performance Optimizer  | Route về A03 khi cần sửa code           |
| V04 Performance Reviewer   | R02 `PERFORMANCE_GATE`                  |
| V05 Documentation Agent    | Development/Verification skill          |
| V06 Documentation Reviewer | R01 `DOCUMENTATION_QUALITY`             |
| V07 Chief Architect        | R02 `ARCHITECTURE_GATE`                 |
| V08 QA Lead                | Verification skill                      |
| V09 Release Manager        | Verification skill + R02 `RELEASE_GATE` |
| V10 Final Reviewer         | R02 `FINAL_GATE`                        |
| V11 Consensus Agent        | Debate/decision skill của W01           |
| V12 Verify Orchestrator    | Verification stage policy của W01       |

---

# 12. Consensus và debate không cần custom agent riêng

Consensus Agent được thay bằng:

```text
skills/workflow/
  option-generation.md
  evidence-comparison.md
  tradeoff-analysis.md
  debate-facilitation.md
  decision-recording.md
```

Khi có nhiều phương án:

```text
1. W01 dispatch A02 nhiều lần với isolated context.
2. Mỗi run tạo một proposal độc lập.
3. W01 dispatch R02 với profile ARCHITECTURE_GATE.
4. R02 phản biện và xếp hạng proposal.
5. W01 làm arbiter và ghi decision.
```

Luồng:

```text
A02 Proposal A ─┐
A02 Proposal B ─┼→ R02 Risk Reviewer → W01 quyết định
A02 Proposal C ─┘
```

Không cần một `Consensus Agent` thường trực.

---

# 13. Skill contract chuẩn

Mỗi skill nên có format:

```md
# <Skill Name>

## Purpose
Một mục tiêu chuyên môn duy nhất.

## Allowed Agents
Agent nào được gọi skill này.

## Trigger
Điều kiện kích hoạt.

## Preconditions
Input và artifact phải tồn tại.

## Inputs
Các file và context cần đọc.

## Procedure
Các bước xử lý.

## Outputs
Section hoặc artifact phải tạo.

## Permission Requirement
- Read:
- Write:
- Execute:
- Network:

## Write Impact
- Product Code: YES | NO
- Test Code: YES | NO
- Documentation: YES | NO
- Knowledge: YES | NO

## Validation
Điều kiện để coi skill chạy thành công.

## Failure Codes
- MISSING_INPUT
- INSUFFICIENT_EVIDENCE
- PERMISSION_DENIED
- CONFLICTING_RULE
- UNSAFE_CHANGE
- EXECUTION_FAILED

## Review Mapping
Reviewer profile nào kiểm tra output của skill.
```

Ví dụ `contract-test-implementation`:

```md
# Contract Test Implementation

## Allowed Agents
- A04 Test Worker

## Trigger
API request, response hoặc error contract bị ảnh hưởng.

## Outputs
- Contract test code
- Contract compatibility section trong test-result.md

## Review Mapping
- R01: TEST_QUALITY
- R02: API_COMPATIBILITY_GATE
```

---

# 14. Skill bundle

W01 không dispatch worker bằng yêu cầu chung chung.

W01 phải tạo `skill-bundle.md` cho mỗi run:

```md
# Skill Bundle

## Worker
A03 Implementation Worker

## Required Skills
1. api-contract-implementation
2. business-logic-implementation
3. error-handling-implementation

## Optional Skills
1. dto-mapping-implementation

## Forbidden Skills
1. migration-implementation
2. cache-implementation
3. messaging-implementation

## Expected Outputs
- Code diff
- development-report.md
- worker-handoff.md

## Reviewer
R01

## Review Profile
CODE_CORRECTNESS
```

Điều này tránh một agent rộng tự ý làm thêm việc ngoài scope.

---

# 15. Registry mới

`agents/agent-registry.md` chỉ đăng ký runnable custom agents.

| ID  | Kind          | Stage       | Allowed Skills          | Called By | Logical Handoff | Permission                 | Parallel    |
| --- | ------------- | ----------- | ----------------------- | --------- | --------------- | -------------------------- | ----------- |
| W01 | ORCHESTRATOR  | ALL         | Workflow skills         | User/root | User/final      | Runtime control            | NO          |
| A01 | WORKER        | KNOWLEDGE   | Knowledge skills        | W01       | R01             | Read mostly                | CONDITIONAL |
| A02 | WORKER        | PLANNING    | Planning skills         | W01       | R01/R02         | Read + workspace artifact  | CONDITIONAL |
| A03 | WORKER        | DEVELOPMENT | Development skills      | W01       | R01/R02         | Workspace write            | CONDITIONAL |
| A04 | WORKER        | TESTING     | Testing skills          | W01       | R01/R02         | Test write + execute       | CONDITIONAL |
| A05 | WORKER        | VERIFY      | Verification skills     | W01       | R02             | Read + docs/artifact write | CONDITIONAL |
| R01 | REVIEWER      | MULTI       | Quality review skills   | W01       | W01             | Read-only                  | YES         |
| R02 | RISK_REVIEWER | MULTI       | Risk review skills      | W01       | W01             | Read-only                  | YES         |
| F01 | SPECIALIST    | FAILURE     | Failure-analysis skills | W01       | W01             | Read + execute diagnostics | NO          |

Skill registry được đặt riêng:

```text
skills/skill-registry.md
```

Các cột:

| Skill | Category | Allowed Agents | Trigger | Inputs | Outputs | Write Impact | Review Profile |
| ----- | -------- | -------------- | ------- | ------ | ------- | ------------ | -------------- |

---

# 16. Folder structure mới

```text
agents/
  agent-registry.md

  workflow/
    workflow-orchestrator.md

  workers/
    knowledge-worker.md
    planning-worker.md
    implementation-worker.md
    test-worker.md
    verification-worker.md

  reviewers/
    quality-reviewer.md
    risk-reviewer.md

  specialists/
    failure-analyzer.md

  maintenance/
    workflow-optimizer.md
    agent-evolution-reviewer.md

skills/
  skill-registry.md

  core/
    artifact-validation.md
    evidence-collection.md
    backward-compatibility.md
    risk-classification.md
    handoff-builder.md

  knowledge/
    repository-scan.md
    incremental-git-scan.md
    convention-analysis.md
    architecture-discovery.md
    api-discovery.md
    database-discovery.md
    business-rule-discovery.md
    knowledge-index-update.md

  planning/
    requirement-analysis.md
    acceptance-criteria-design.md
    task-decomposition.md
    solution-design.md
    architecture-decision-record.md

  development/
    api-contract-implementation.md
    persistence-implementation.md
    business-logic-implementation.md
    integration-implementation.md
    safe-refactoring.md

  testing/
    test-strategy.md
    positive-test-design.md
    negative-test-design.md
    integration-test-implementation.md
    contract-test-implementation.md
    test-execution.md
    coverage-analysis.md

  verification/
    security-audit.md
    performance-audit.md
    architecture-conformance.md
    release-readiness.md
    knowledge-impact-check.md

  review/
    knowledge-review.md
    planning-review.md
    code-review.md
    test-review.md
    documentation-review.md

  risk-review/
    architecture-review.md
    security-review.md
    migration-review.md
    performance-review.md
    release-review.md
    final-gate-review.md

  workflow/
    debate-facilitation.md
    failure-routing.md
    stop-evaluation.md
    workflow-profile-selection.md

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

.codex/
  config.toml
  agents/
    workflow-orchestrator.toml
    knowledge-worker.toml
    planning-worker.toml
    implementation-worker.toml
    test-worker.toml
    verification-worker.toml
    quality-reviewer.toml
    risk-reviewer.toml
    failure-analyzer.toml
```

Skill không cần một TOML custom agent riêng.

---

# 17. Quyền ghi shared state

Chỉ W01 được cập nhật trực tiếp:

```text
execution-state.md
handoff-log.md
runtime-log.jsonl
agent-dispatch-log.md
parallel-groups.md
permission-audit.md
```

Worker và Reviewer chỉ ghi kết quả riêng:

```text
execution-workspace/<task>/
  runs/
    <run-id>/
      request.md
      skill-bundle.md
      result.md
      handoff.md
      review.md
```

Sau khi agent kết thúc, W01 tổng hợp kết quả vào state chung.

Điều này loại bỏ race condition khi nhiều agent chạy song song.

---

# 18. Parallel execution

Với mô hình mới, không chạy song song nhiều agent cùng stage nếu chúng cùng sửa source code.

Có thể song song trong các trường hợp:

```text
A01 knowledge analysis cho các module độc lập
A02 sinh nhiều architecture proposal độc lập
R01 review nhiều artifact độc lập
R02 thực hiện security và release assessment độc lập
A04 phân tích test matrix cho các module không dùng chung test file
```

Không chạy song song:

```text
A03 Implementation Worker trên cùng module
A03 và A04 khi test phụ thuộc source code chưa ổn định
A03 và A05 khi Verify đang đọc một diff chưa hoàn tất
R02 Final Gate khi upstream reviewer chưa pass
```

W01 phải chờ toàn bộ agent trong parallel group hoàn tất rồi mới chuyển stage.

---

# 19. Workflow profile

Mô hình mới nên có nhiều profile để tránh task nhỏ chạy toàn bộ workflow.

| Profile              | Luồng                                               |
| -------------------- | --------------------------------------------------- |
| FULL_FEATURE         | A01 → A02 → A03 → A04 → A05                         |
| STANDARD_BUGFIX      | A01 incremental → A02 lightweight → A03 → A04 → A05 |
| HOTFIX               | A02 triage → A03 → A04 focused → R02 release gate   |
| REFACTOR             | A01 impact → A02 plan → A03 → A04 regression → A05  |
| TEST_ONLY            | A02 test scope → A04 → R01                          |
| DOCS_ONLY            | A01 impact → A05 documentation → R01                |
| KNOWLEDGE_REFRESH    | A01 → R01                                           |
| WORKFLOW_MAINTENANCE | M01 → M02 → W01                                     |

Mỗi worker vẫn phải đi qua reviewer trước khi quay về W01.

---

# 20. Mô hình hoàn chỉnh đề xuất

```text
                       ┌──────────────────────────┐
                       │ W01 Workflow Orchestrator│
                       └─────────────┬────────────┘
                                     │
              ┌──────────────────────┼──────────────────────┐
              │                      │                      │
              ▼                      ▼                      ▼
      A01 Knowledge Worker   A02 Planning Worker    A03 Implementation Worker
              │                      │                      │
              ▼                      ▼                      ▼
       R01 Quality Reviewer   R01/R02 Reviewer       R01/R02 Reviewer
              │                      │                      │
              └──────────────────────┴──────────────────────┘
                                     │
                                     ▼
                       W01 Workflow Orchestrator
                                     │
                                     ▼
                            A04 Test Worker
                                     │
                                     ▼
                            R01/R02 Reviewer
                                     │
                                     ▼
                       W01 Workflow Orchestrator
                                     │
                                     ▼
                       A05 Verification Worker
                                     │
                                     ▼
                           R02 Risk Reviewer
                                     │
                                     ▼
                       W01 Workflow Orchestrator
                                     │
                              DONE hoặc BLOCKED
```

Nguyên tắc bất biến:

```text
Worker không gọi Worker.
Reviewer không gọi Worker.
Reviewer không chuyển stage.
Skill không có quyền handoff.
Policy không phải Agent.
Chỉ W01 được dispatch và chuyển stage.
Mọi Worker phải qua Reviewer trước khi W01 chấp nhận output.
```

---

# 21. Kết quả sau khi chuyển đổi

| Thành phần            |           Mô hình cũ |             Mô hình mới |
| --------------------- | -------------------: | ----------------------: |
| Custom agent core     |            Khoảng 65 |                       9 |
| Sub-orchestrator      |                    5 |                       0 |
| Reviewer custom agent |               Hơn 20 |                       2 |
| Worker chuyên biệt    |               Hơn 30 |                       5 |
| Failure specialist    |                    1 |                       1 |
| Reusable skill        |         Chưa tách rõ |               Khoảng 50 |
| Dispatch authority    |             Phân tán |                 Chỉ W01 |
| Handoff route         |  Có nhiều route chéo | Worker → Reviewer → W01 |
| Codex depth           | Có nguy cơ recursive |           Flat dispatch |
| Shared-state writer   |          Nhiều agent |                 Chỉ W01 |

Mô hình này giảm mạnh số custom agent nhưng không loại bỏ các chức năng cũ. Chức năng được chuyển từ “identity agent” sang “skill procedure”, còn review độc lập vẫn được bảo toàn bằng R01 và R02.
Knowledge không nên được xem là một stage bắt buộc chạy lại trong mỗi workflow. Nó nên là bộ nhớ lâu dài của codebase, được tạo một lần, được đọc trong mọi workflow, và chỉ cập nhật khi code thay đổi làm knowledge bị lỗi thời.

Mô hình nên chỉnh thành:

Knowledge Bootstrap — chạy lần đầu
Knowledge Consumption — xảy ra trong mọi workflow
Knowledge Maintenance — chỉ chạy sau thay đổi code có ảnh hưởng
1. Vai trò mới của Knowledge Layer

Knowledge Layer có ba nhiệm vụ tách biệt:

Chức năng	Thời điểm	Cách thực hiện
Khởi tạo knowledge	Lần đầu làm việc với repository	Full scan codebase
Cung cấp context	Mỗi workflow	Worker đọc knowledge liên quan
Đồng bộ knowledge	Sau khi code thay đổi	Incremental scan và cập nhật phần bị ảnh hưởng

Do đó pipeline chính không còn là:

KNOWLEDGE
→ PLANNING
→ DEVELOPMENT
→ TESTING
→ VERIFY

Mà nên là:

LOAD KNOWLEDGE CONTEXT
↓
PLANNING
↓
DEVELOPMENT
↓
TESTING
↓
VERIFY
↓
UPDATE KNOWLEDGE IF DIRTY

LOAD KNOWLEDGE CONTEXT không phải một stage chạy agent. Nó chỉ là một bước đọc dữ liệu trước khi agent thực hiện nhiệm vụ.

2. Vòng đời Knowledge đề xuất
   2.1. Giai đoạn 1: Knowledge Bootstrap

Chỉ chạy trong các trường hợp:

Repository chưa có thư mục knowledge/.
knowledge-manifest.md chưa tồn tại.
User yêu cầu scan lại toàn bộ codebase.
Codebase có thay đổi kiến trúc rất lớn và incremental update không còn đáng tin cậy.

Luồng:

W01 Workflow Orchestrator
↓
A01 Knowledge Maintainer
↓
R01 Quality Reviewer
↓
W01 publish Knowledge Base

A01 sử dụng các skill:

repository-scan
convention-analysis
architecture-discovery
pattern-discovery
business-flow-discovery
business-rule-discovery
api-discovery
database-discovery
technology-stack-discovery
reusable-component-discovery
knowledge-index-update

Kết quả:

knowledge/
repository.md
convention.md
architecture.md
patterns.md
business-flow.md
business-rule.md
api-index.md
database.md
technology-stack.md
component-index.md
decision.md
knowledge-index.md
knowledge-manifest.md

Sau khi R01 review PASS, knowledge được đánh dấu:

Status: CLEAN
2.2. Giai đoạn 2: Knowledge Consumption

Đây là hoạt động diễn ra trong mọi workflow.

Không cần gọi A01.

Mỗi Worker phải đọc knowledge liên quan trước khi làm việc.

Ví dụ:

Planning Worker đọc
knowledge/knowledge-index.md
knowledge/repository.md
knowledge/convention.md
knowledge/architecture.md
knowledge/business-flow.md
knowledge/business-rule.md
knowledge/api-index.md
knowledge/database.md
knowledge/decision.md
Implementation Worker đọc
knowledge/convention.md
knowledge/architecture.md
knowledge/patterns.md
knowledge/business-rule.md
knowledge/component-index.md
knowledge/api-index.md
knowledge/database.md
execution-workspace/<task>/solution-design.md
Test Worker đọc
knowledge/business-rule.md
knowledge/api-index.md
knowledge/business-flow.md
knowledge/convention.md
execution-workspace/<task>/acceptance-criteria.md
execution-workspace/<task>/development-report.md
Verification Worker đọc
knowledge/architecture.md
knowledge/convention.md
knowledge/api-index.md
knowledge/database.md
knowledge/decision.md
execution-workspace/<task>/planning-package/
execution-workspace/<task>/test-result.md

Điểm quan trọng:

Worker đọc Knowledge Base trực tiếp.
Không cần Knowledge Worker đứng giữa để truyền thông tin.
3. Không nên bắt Worker đọc toàn bộ knowledge

Nếu knowledge lớn, mỗi agent đọc tất cả file sẽ gây:

Tốn context.
Tăng token.
Dễ context pollution.
Agent khó xác định phần nào thật sự liên quan.

Nên có skill:

knowledge-context-loader

Skill này không scan codebase và không cập nhật knowledge. Nó chỉ chọn các knowledge file phù hợp với task.

Input
Task type
Requirement
Impacted modules
Impacted files nếu đã biết
Current workflow stage
knowledge/knowledge-index.md
Output
execution-workspace/<task>/knowledge-context.md

Ví dụ:

# Knowledge Context

## Task
Add claim amount range filter

## Relevant Knowledge

### Required
- knowledge/convention.md
    - BigDecimal comparison convention
    - Null handling convention
- knowledge/business-rule.md
    - Claim amount boundary rules
- knowledge/api-index.md
    - Claim search API
- knowledge/component-index.md
    - Existing amount parser utility

### Optional
- knowledge/database.md
    - Claim amount column precision

### Not Required
- knowledge/messaging.md
- knowledge/cache.md
- knowledge/deployment.md

Mỗi Worker đọc:

knowledge-context.md

sau đó chỉ mở các file được liệt kê.

4. Knowledge readiness check ở đầu workflow

Ở đầu mỗi workflow, W01 chỉ cần chạy một skill nhẹ:

knowledge-readiness-check

Skill này kiểm tra:

Knowledge Base có tồn tại không.
Knowledge đang CLEAN hay DIRTY.
Commit hoặc revision knowledge đang tham chiếu.
Module liên quan đến task có knowledge không.
Có dirty item chưa xử lý từ workflow trước không.

Kết quả:

READY
READY_WITH_DIRTY_ITEMS
BOOTSTRAP_REQUIRED
SYNC_REQUIRED
BLOCKED
Quy tắc xử lý
Kết quả	Hành động
READY	Tiếp tục Planning
READY_WITH_DIRTY_ITEMS	Tiếp tục nếu dirty item không liên quan task
SYNC_REQUIRED	Gọi A01 cập nhật phần liên quan
BOOTSTRAP_REQUIRED	Gọi A01 full scan
BLOCKED	Dừng và báo lỗi knowledge

Luồng đầu workflow:

W01
↓
knowledge-readiness-check skill
├── READY → tạo knowledge-context.md
├── SYNC_REQUIRED → A01 incremental update
└── BOOTSTRAP_REQUIRED → A01 full scan

Như vậy A01 không chạy mặc định.

5. Cập nhật knowledge sau khi workflow sửa code

Sau Development và Testing, codebase đã thay đổi. Khi đó cần xác định knowledge nào bị ảnh hưởng.

Không nên chạy lại toàn bộ Knowledge Layer.

Nên dùng:

knowledge-impact-detector

Skill này đọc:

git diff
files changed
development-report.md
solution-design.md
test-result.md

Và sinh:

execution-workspace/<task>/knowledge-impact.md

Ví dụ:

# Knowledge Impact

## Verdict
UPDATE_REQUIRED

## Changed Areas

| Changed File | Impacted Knowledge | Reason |
|---|---|---|
| ClaimController.java | api-index.md | API filter parameter changed |
| ClaimService.java | business-rule.md | Inclusive amount boundary added |
| ClaimRepository.java | database.md | Query condition changed |
| ClaimServiceTest.java | No update | Test-only artifact |

## Required Update Skills
- api-discovery
- business-rule-discovery
- database-discovery
- knowledge-index-update

## Full Scan Required
NO
6. Knowledge update phải chạy lúc nào?

Knowledge update nên chạy sau khi implementation và test đã ổn định, nhưng trước Final Gate.

Không nên cập nhật knowledge ngay sau Development vì code vẫn có thể bị Reviewer hoặc Test Worker yêu cầu sửa.

Luồng chuẩn:

Planning
↓
Implementation
↓
Review
↓
Testing
↓
Test Review
↓
Verification
↓
Knowledge Impact Detection
↓
Incremental Knowledge Update nếu cần
↓
Knowledge Review
↓
Final Gate

Chi tiết:

A05 Verification Worker
↓
knowledge-impact-detector skill
↓
W01
├── NO_UPDATE → R02 Final Gate
│
└── UPDATE_REQUIRED
↓
A01 Knowledge Maintainer
↓
R01 Knowledge Review
↓
W01
↓
R02 Final Gate

Final Reviewer chỉ được PASS khi:

Knowledge Status = CLEAN

hoặc:

Knowledge Update Required = NO
7. Đổi tên A01

Tên Knowledge Worker dễ tạo cảm giác đây là một worker phải chạy trong mọi workflow.

Nên đổi thành:

A01 Knowledge Maintainer
Responsibility mới
Khởi tạo và đồng bộ Knowledge Base của codebase.
Không tham gia trực tiếp vào việc lập kế hoạch hoặc triển khai feature.
When To Run

Chỉ chạy khi:

1. Knowledge Base chưa tồn tại.
2. W01 nhận kết quả BOOTSTRAP_REQUIRED.
3. Knowledge readiness check trả SYNC_REQUIRED.
4. Knowledge impact detector trả UPDATE_REQUIRED.
5. User yêu cầu refresh knowledge.
6. Codebase có structural change vượt ngưỡng incremental update.
   Không chạy khi
1. Workflow chỉ cần đọc knowledge hiện có.
2. Git diff không ảnh hưởng knowledge.
3. Task chỉ sửa test nhưng không đổi behavior.
4. Task chỉ sửa format/comment.
5. Dirty knowledge không liên quan task hiện tại.
8. Hai loại update
   Incremental Update

Dùng mặc định.

Ví dụ code thay đổi ở Controller:

api-discovery
business-rule-discovery nếu behavior đổi
knowledge-index-update

Code thay đổi ở Entity hoặc migration:

database-discovery
architecture-discovery nếu dependency đổi
business-rule-discovery
knowledge-index-update

Code thay đổi ở convention chung:

convention-analysis
reusable-component-discovery
knowledge-index-update
Full Rebuild

Chỉ chạy khi:

Thay đổi module structure lớn.
Chuyển kiến trúc.
Monolith tách thành nhiều service.
Build system thay đổi.
Knowledge bị stale quá lâu.
Incremental update không xác định được dependency impact.
Knowledge Reviewer phát hiện conflict trên nhiều phần.
9. Trạng thái Knowledge Base

Nên có file:

knowledge/knowledge-manifest.md

Template:

# Knowledge Manifest

## Repository State

- Repository:
- Default Branch:
- Last Full Scan Commit:
- Last Incremental Scan Commit:
- Last Updated At:
- Knowledge Version:

## Status

- Overall Status: CLEAN | PARTIALLY_DIRTY | DIRTY | REBUILD_REQUIRED
- Last Review Verdict:
- Last Reviewer:

## Knowledge Files

| Knowledge File | Status | Source Revision | Updated By | Related Modules |
|---|---|---|---|---|
| repository.md | CLEAN | abc123 | A01 | all |
| convention.md | CLEAN | abc123 | A01 | all |
| architecture.md | CLEAN | abc123 | A01 | core, claim |
| api-index.md | DIRTY | abc123 | A01 | claim |
| database.md | CLEAN | abc123 | A01 | persistence |

## Dirty Items

| Item | Trigger | Related Task | Required Skill | Status |
|---|---|---|---|---|
| api-index.md | ClaimController changed | FEATURE-123 | api-discovery | TODO |

## Full Rebuild Required

- Required: YES | NO
- Reason:

knowledge-index.md giúp agent tìm thông tin.

knowledge-manifest.md giúp W01 quản lý trạng thái và độ mới.

10. Kiến trúc workflow sau khi chỉnh
    ┌───────────────────────────────────────┐
    │        Persistent Knowledge Base      │
    │ repository, architecture, API, DB...  │
    └──────────────────┬────────────────────┘
    │ read
    ▼
    W01 Workflow Orchestrator
    │
    knowledge readiness check
    │
    ▼
    knowledge-context.md
    │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
    A02 Planning  A03 Implement  A04 Testing
    │           │           │
    └───────────┼───────────┘
    ▼
    A05 Verification
    │
    knowledge impact detection
    │
    ┌────────┴─────────┐
    │                  │
    NO UPDATE        UPDATE REQUIRED
    │                  │
    │             A01 Maintainer
    │                  │
    │              R01 Review
    └────────┬─────────┘
    ▼
    R02 Final Risk Gate
    │
    DONE/BLOCKED
11. Agent và Skill sau khi sửa
    Custom agents
    ID	Agent	Khi chạy
    W01	Workflow Orchestrator	Mọi workflow
    A01	Knowledge Maintainer	Bootstrap hoặc knowledge dirty
    A02	Planning Worker	Task cần planning
    A03	Implementation Worker	Task cần sửa code
    A04	Test Worker	Task cần test
    A05	Verification Worker	Task cần verify
    R01	Quality Reviewer	Review output thông thường
    R02	Risk Reviewer	Gate có rủi ro cao và final gate
    F01	Failure Analyzer	Build/test/workflow failure
    Knowledge skills
    knowledge-readiness-check
    knowledge-context-loader
    knowledge-impact-detector
    repository-scan
    incremental-git-scan
    convention-analysis
    architecture-discovery
    pattern-discovery
    api-discovery
    database-discovery
    business-flow-discovery
    business-rule-discovery
    technology-stack-discovery
    reusable-component-discovery
    decision-memory-update
    knowledge-index-update
    knowledge-manifest-update

Skill ownership:

Skill	Agent được phép dùng
knowledge-readiness-check	W01
knowledge-context-loader	W01, A02, A03, A04, A05
knowledge-impact-detector	W01, A05
Discovery/update skills	Chỉ A01
Knowledge review skill	R01
12. Quy tắc bất biến cho Knowledge

Nên thêm các rule sau vào prompt:

1. Knowledge Base là persistent codebase memory, không phải artifact riêng của từng task.

2. Không chạy full Knowledge Bootstrap trong mỗi workflow.

3. Mỗi workflow phải thực hiện Knowledge Readiness Check.

4. Mỗi Worker phải đọc knowledge-context.md trước khi xử lý.

5. Worker chỉ đọc các knowledge file liên quan đến task.

6. Product-code Worker không được tự cập nhật knowledge files.

7. Chỉ Knowledge Maintainer được sửa knowledge/.

8. Sau khi code thay đổi và test pass, phải chạy Knowledge Impact Detection.

9. Nếu Knowledge Impact = UPDATE_REQUIRED, phải cập nhật và review knowledge trước Final Gate.

10. Nếu code tiếp tục thay đổi sau khi knowledge đã cập nhật, knowledge phải được đánh dấu DIRTY lại.

11. Final Gate không được PASS khi knowledge liên quan đang DIRTY.

12. Full scan chỉ được chạy khi bootstrap, user yêu cầu, hoặc incremental update không còn đáng tin cậy.
    Mô hình rút gọn cuối cùng

Tóm lại, Knowledge Layer nên hoạt động như sau:

Lần đầu repository:
A01 Full Scan → R01 Review → Publish Knowledge

Mỗi workflow:
W01 Readiness Check → Load Relevant Knowledge → Workers đọc để thực hiện

Sau khi sửa code:
Detect Knowledge Impact → A01 Incremental Update nếu cần → R01 Review

Kết thúc:
R02 Final Gate chỉ pass khi knowledge sạch

Như vậy, A01 là agent bảo trì knowledge theo điều kiện, còn việc đọc knowledge trong mỗi workflow chỉ là một skill/context-loading step, không phải chạy lại Knowledge Layer.
Knowledge không nên được xem là một stage bắt buộc chạy lại trong mỗi workflow. Nó nên là bộ nhớ lâu dài của codebase, được tạo một lần, được đọc trong mọi workflow, và chỉ cập nhật khi code thay đổi làm knowledge bị lỗi thời.

Mô hình nên chỉnh thành:

Knowledge Bootstrap — chạy lần đầu
Knowledge Consumption — xảy ra trong mọi workflow
Knowledge Maintenance — chỉ chạy sau thay đổi code có ảnh hưởng
1. Vai trò mới của Knowledge Layer

Knowledge Layer có ba nhiệm vụ tách biệt:

Chức năng	Thời điểm	Cách thực hiện
Khởi tạo knowledge	Lần đầu làm việc với repository	Full scan codebase
Cung cấp context	Mỗi workflow	Worker đọc knowledge liên quan
Đồng bộ knowledge	Sau khi code thay đổi	Incremental scan và cập nhật phần bị ảnh hưởng

Do đó pipeline chính không còn là:

KNOWLEDGE
→ PLANNING
→ DEVELOPMENT
→ TESTING
→ VERIFY

Mà nên là:

LOAD KNOWLEDGE CONTEXT
↓
PLANNING
↓
DEVELOPMENT
↓
TESTING
↓
VERIFY
↓
UPDATE KNOWLEDGE IF DIRTY

LOAD KNOWLEDGE CONTEXT không phải một stage chạy agent. Nó chỉ là một bước đọc dữ liệu trước khi agent thực hiện nhiệm vụ.

2. Vòng đời Knowledge đề xuất
   2.1. Giai đoạn 1: Knowledge Bootstrap

Chỉ chạy trong các trường hợp:

Repository chưa có thư mục knowledge/.
knowledge-manifest.md chưa tồn tại.
User yêu cầu scan lại toàn bộ codebase.
Codebase có thay đổi kiến trúc rất lớn và incremental update không còn đáng tin cậy.

Luồng:

W01 Workflow Orchestrator
↓
A01 Knowledge Maintainer
↓
R01 Quality Reviewer
↓
W01 publish Knowledge Base

A01 sử dụng các skill:

repository-scan
convention-analysis
architecture-discovery
pattern-discovery
business-flow-discovery
business-rule-discovery
api-discovery
database-discovery
technology-stack-discovery
reusable-component-discovery
knowledge-index-update

Kết quả:

knowledge/
repository.md
convention.md
architecture.md
patterns.md
business-flow.md
business-rule.md
api-index.md
database.md
technology-stack.md
component-index.md
decision.md
knowledge-index.md
knowledge-manifest.md

Sau khi R01 review PASS, knowledge được đánh dấu:

Status: CLEAN
2.2. Giai đoạn 2: Knowledge Consumption

Đây là hoạt động diễn ra trong mọi workflow.

Không cần gọi A01.

Mỗi Worker phải đọc knowledge liên quan trước khi làm việc.

Ví dụ:

Planning Worker đọc
knowledge/knowledge-index.md
knowledge/repository.md
knowledge/convention.md
knowledge/architecture.md
knowledge/business-flow.md
knowledge/business-rule.md
knowledge/api-index.md
knowledge/database.md
knowledge/decision.md
Implementation Worker đọc
knowledge/convention.md
knowledge/architecture.md
knowledge/patterns.md
knowledge/business-rule.md
knowledge/component-index.md
knowledge/api-index.md
knowledge/database.md
execution-workspace/<task>/solution-design.md
Test Worker đọc
knowledge/business-rule.md
knowledge/api-index.md
knowledge/business-flow.md
knowledge/convention.md
execution-workspace/<task>/acceptance-criteria.md
execution-workspace/<task>/development-report.md
Verification Worker đọc
knowledge/architecture.md
knowledge/convention.md
knowledge/api-index.md
knowledge/database.md
knowledge/decision.md
execution-workspace/<task>/planning-package/
execution-workspace/<task>/test-result.md

Điểm quan trọng:

Worker đọc Knowledge Base trực tiếp.
Không cần Knowledge Worker đứng giữa để truyền thông tin.
3. Không nên bắt Worker đọc toàn bộ knowledge

Nếu knowledge lớn, mỗi agent đọc tất cả file sẽ gây:

Tốn context.
Tăng token.
Dễ context pollution.
Agent khó xác định phần nào thật sự liên quan.

Nên có skill:

knowledge-context-loader

Skill này không scan codebase và không cập nhật knowledge. Nó chỉ chọn các knowledge file phù hợp với task.

Input
Task type
Requirement
Impacted modules
Impacted files nếu đã biết
Current workflow stage
knowledge/knowledge-index.md
Output
execution-workspace/<task>/knowledge-context.md

Ví dụ:

# Knowledge Context

## Task
Add claim amount range filter

## Relevant Knowledge

### Required
- knowledge/convention.md
    - BigDecimal comparison convention
    - Null handling convention
- knowledge/business-rule.md
    - Claim amount boundary rules
- knowledge/api-index.md
    - Claim search API
- knowledge/component-index.md
    - Existing amount parser utility

### Optional
- knowledge/database.md
    - Claim amount column precision

### Not Required
- knowledge/messaging.md
- knowledge/cache.md
- knowledge/deployment.md

Mỗi Worker đọc:

knowledge-context.md

sau đó chỉ mở các file được liệt kê.

4. Knowledge readiness check ở đầu workflow

Ở đầu mỗi workflow, W01 chỉ cần chạy một skill nhẹ:

knowledge-readiness-check

Skill này kiểm tra:

Knowledge Base có tồn tại không.
Knowledge đang CLEAN hay DIRTY.
Commit hoặc revision knowledge đang tham chiếu.
Module liên quan đến task có knowledge không.
Có dirty item chưa xử lý từ workflow trước không.

Kết quả:

READY
READY_WITH_DIRTY_ITEMS
BOOTSTRAP_REQUIRED
SYNC_REQUIRED
BLOCKED
Quy tắc xử lý
Kết quả	Hành động
READY	Tiếp tục Planning
READY_WITH_DIRTY_ITEMS	Tiếp tục nếu dirty item không liên quan task
SYNC_REQUIRED	Gọi A01 cập nhật phần liên quan
BOOTSTRAP_REQUIRED	Gọi A01 full scan
BLOCKED	Dừng và báo lỗi knowledge

Luồng đầu workflow:

W01
↓
knowledge-readiness-check skill
├── READY → tạo knowledge-context.md
├── SYNC_REQUIRED → A01 incremental update
└── BOOTSTRAP_REQUIRED → A01 full scan

Như vậy A01 không chạy mặc định.

5. Cập nhật knowledge sau khi workflow sửa code

Sau Development và Testing, codebase đã thay đổi. Khi đó cần xác định knowledge nào bị ảnh hưởng.

Không nên chạy lại toàn bộ Knowledge Layer.

Nên dùng:

knowledge-impact-detector

Skill này đọc:

git diff
files changed
development-report.md
solution-design.md
test-result.md

Và sinh:

execution-workspace/<task>/knowledge-impact.md

Ví dụ:

# Knowledge Impact

## Verdict
UPDATE_REQUIRED

## Changed Areas

| Changed File | Impacted Knowledge | Reason |
|---|---|---|
| ClaimController.java | api-index.md | API filter parameter changed |
| ClaimService.java | business-rule.md | Inclusive amount boundary added |
| ClaimRepository.java | database.md | Query condition changed |
| ClaimServiceTest.java | No update | Test-only artifact |

## Required Update Skills
- api-discovery
- business-rule-discovery
- database-discovery
- knowledge-index-update

## Full Scan Required
NO
6. Knowledge update phải chạy lúc nào?

Knowledge update nên chạy sau khi implementation và test đã ổn định, nhưng trước Final Gate.

Không nên cập nhật knowledge ngay sau Development vì code vẫn có thể bị Reviewer hoặc Test Worker yêu cầu sửa.

Luồng chuẩn:

Planning
↓
Implementation
↓
Review
↓
Testing
↓
Test Review
↓
Verification
↓
Knowledge Impact Detection
↓
Incremental Knowledge Update nếu cần
↓
Knowledge Review
↓
Final Gate

Chi tiết:

A05 Verification Worker
↓
knowledge-impact-detector skill
↓
W01
├── NO_UPDATE → R02 Final Gate
│
└── UPDATE_REQUIRED
↓
A01 Knowledge Maintainer
↓
R01 Knowledge Review
↓
W01
↓
R02 Final Gate

Final Reviewer chỉ được PASS khi:

Knowledge Status = CLEAN

hoặc:

Knowledge Update Required = NO
7. Đổi tên A01

Tên Knowledge Worker dễ tạo cảm giác đây là một worker phải chạy trong mọi workflow.

Nên đổi thành:

A01 Knowledge Maintainer
Responsibility mới
Khởi tạo và đồng bộ Knowledge Base của codebase.
Không tham gia trực tiếp vào việc lập kế hoạch hoặc triển khai feature.
When To Run

Chỉ chạy khi:

1. Knowledge Base chưa tồn tại.
2. W01 nhận kết quả BOOTSTRAP_REQUIRED.
3. Knowledge readiness check trả SYNC_REQUIRED.
4. Knowledge impact detector trả UPDATE_REQUIRED.
5. User yêu cầu refresh knowledge.
6. Codebase có structural change vượt ngưỡng incremental update.
   Không chạy khi
1. Workflow chỉ cần đọc knowledge hiện có.
2. Git diff không ảnh hưởng knowledge.
3. Task chỉ sửa test nhưng không đổi behavior.
4. Task chỉ sửa format/comment.
5. Dirty knowledge không liên quan task hiện tại.
8. Hai loại update
   Incremental Update

Dùng mặc định.

Ví dụ code thay đổi ở Controller:

api-discovery
business-rule-discovery nếu behavior đổi
knowledge-index-update

Code thay đổi ở Entity hoặc migration:

database-discovery
architecture-discovery nếu dependency đổi
business-rule-discovery
knowledge-index-update

Code thay đổi ở convention chung:

convention-analysis
reusable-component-discovery
knowledge-index-update
Full Rebuild

Chỉ chạy khi:

Thay đổi module structure lớn.
Chuyển kiến trúc.
Monolith tách thành nhiều service.
Build system thay đổi.
Knowledge bị stale quá lâu.
Incremental update không xác định được dependency impact.
Knowledge Reviewer phát hiện conflict trên nhiều phần.
9. Trạng thái Knowledge Base

Nên có file:

knowledge/knowledge-manifest.md

Template:

# Knowledge Manifest

## Repository State

- Repository:
- Default Branch:
- Last Full Scan Commit:
- Last Incremental Scan Commit:
- Last Updated At:
- Knowledge Version:

## Status

- Overall Status: CLEAN | PARTIALLY_DIRTY | DIRTY | REBUILD_REQUIRED
- Last Review Verdict:
- Last Reviewer:

## Knowledge Files

| Knowledge File | Status | Source Revision | Updated By | Related Modules |
|---|---|---|---|---|
| repository.md | CLEAN | abc123 | A01 | all |
| convention.md | CLEAN | abc123 | A01 | all |
| architecture.md | CLEAN | abc123 | A01 | core, claim |
| api-index.md | DIRTY | abc123 | A01 | claim |
| database.md | CLEAN | abc123 | A01 | persistence |

## Dirty Items

| Item | Trigger | Related Task | Required Skill | Status |
|---|---|---|---|---|
| api-index.md | ClaimController changed | FEATURE-123 | api-discovery | TODO |

## Full Rebuild Required

- Required: YES | NO
- Reason:

knowledge-index.md giúp agent tìm thông tin.

knowledge-manifest.md giúp W01 quản lý trạng thái và độ mới.

10. Kiến trúc workflow sau khi chỉnh
    ┌───────────────────────────────────────┐
    │        Persistent Knowledge Base      │
    │ repository, architecture, API, DB...  │
    └──────────────────┬────────────────────┘
    │ read
    ▼
    W01 Workflow Orchestrator
    │
    knowledge readiness check
    │
    ▼
    knowledge-context.md
    │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
    A02 Planning  A03 Implement  A04 Testing
    │           │           │
    └───────────┼───────────┘
    ▼
    A05 Verification
    │
    knowledge impact detection
    │
    ┌────────┴─────────┐
    │                  │
    NO UPDATE        UPDATE REQUIRED
    │                  │
    │             A01 Maintainer
    │                  │
    │              R01 Review
    └────────┬─────────┘
    ▼
    R02 Final Risk Gate
    │
    DONE/BLOCKED
11. Agent và Skill sau khi sửa
    Custom agents
    ID	Agent	Khi chạy
    W01	Workflow Orchestrator	Mọi workflow
    A01	Knowledge Maintainer	Bootstrap hoặc knowledge dirty
    A02	Planning Worker	Task cần planning
    A03	Implementation Worker	Task cần sửa code
    A04	Test Worker	Task cần test
    A05	Verification Worker	Task cần verify
    R01	Quality Reviewer	Review output thông thường
    R02	Risk Reviewer	Gate có rủi ro cao và final gate
    F01	Failure Analyzer	Build/test/workflow failure
    Knowledge skills
    knowledge-readiness-check
    knowledge-context-loader
    knowledge-impact-detector
    repository-scan
    incremental-git-scan
    convention-analysis
    architecture-discovery
    pattern-discovery
    api-discovery
    database-discovery
    business-flow-discovery
    business-rule-discovery
    technology-stack-discovery
    reusable-component-discovery
    decision-memory-update
    knowledge-index-update
    knowledge-manifest-update

Skill ownership:

Skill	Agent được phép dùng
knowledge-readiness-check	W01
knowledge-context-loader	W01, A02, A03, A04, A05
knowledge-impact-detector	W01, A05
Discovery/update skills	Chỉ A01
Knowledge review skill	R01
12. Quy tắc bất biến cho Knowledge

Nên thêm các rule sau vào prompt:

1. Knowledge Base là persistent codebase memory, không phải artifact riêng của từng task.

2. Không chạy full Knowledge Bootstrap trong mỗi workflow.

3. Mỗi workflow phải thực hiện Knowledge Readiness Check.

4. Mỗi Worker phải đọc knowledge-context.md trước khi xử lý.

5. Worker chỉ đọc các knowledge file liên quan đến task.

6. Product-code Worker không được tự cập nhật knowledge files.

7. Chỉ Knowledge Maintainer được sửa knowledge/.

8. Sau khi code thay đổi và test pass, phải chạy Knowledge Impact Detection.

9. Nếu Knowledge Impact = UPDATE_REQUIRED, phải cập nhật và review knowledge trước Final Gate.

10. Nếu code tiếp tục thay đổi sau khi knowledge đã cập nhật, knowledge phải được đánh dấu DIRTY lại.

11. Final Gate không được PASS khi knowledge liên quan đang DIRTY.

12. Full scan chỉ được chạy khi bootstrap, user yêu cầu, hoặc incremental update không còn đáng tin cậy.
    Mô hình rút gọn cuối cùng

Tóm lại, Knowledge Layer nên hoạt động như sau:

Lần đầu repository:
A01 Full Scan → R01 Review → Publish Knowledge

Mỗi workflow:
W01 Readiness Check → Load Relevant Knowledge → Workers đọc để thực hiện

Sau khi sửa code:
Detect Knowledge Impact → A01 Incremental Update nếu cần → R01 Review

Kết thúc:
R02 Final Gate chỉ pass khi knowledge sạch

Như vậy, A01 là agent bảo trì knowledge theo điều kiện, còn việc đọc knowledge trong mỗi workflow chỉ là một skill/context-loading step, không phải chạy lại Knowledge Layer.