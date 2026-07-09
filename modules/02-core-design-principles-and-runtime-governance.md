## 3. Nguyên tắc thiết kế agent bắt buộc

### 3.1. Single Responsibility Principle

Mỗi agent chỉ có **một trách nhiệm duy nhất**.

Không tạo agent quá rộng kiểu:

```text
Backend Developer Agent
Fullstack Agent
Do Everything Agent
```

Thay vào đó phải tách nhỏ theo trách nhiệm:

```text
Requirement Analyst
Solution Architect
Business Logic Developer
Integration Developer
Positive Test Agent
Security Auditor
```

---

### 3.2. Worker phải có Reviewer tương ứng

Hầu hết agent dạng Worker phải có Reviewer tương ứng.

Ví dụ:

| Worker | Reviewer |
|---|---|
| Requirement Analyst | Requirement Reviewer |
| Planner | Planning Reviewer |
| Solution Architect | Architecture Reviewer |
| Designer | API Reviewer |
| Business Logic Developer | Business Reviewer |
| Integration Developer | Integration Reviewer |
| Refactor Agent | Refactor Reviewer |
| Positive Test Agent | Positive Reviewer |
| Negative Test Agent | Negative Reviewer |
| Integration Test Agent | Integration Test Reviewer |
| Contract Test Agent | Contract Reviewer |
| Performance Test Agent | Performance Test Reviewer |
| Security Test Agent | Security Test Reviewer |
| Security Auditor | Security Reviewer |
| Performance Optimizer | Performance Reviewer |
| Documentation Agent | Documentation Reviewer |

Reviewer không được tự ý viết lại toàn bộ kết quả của Worker nếu chưa nêu rõ lỗi. Reviewer phải:

1. Đọc output của Worker
2. Đối chiếu với requirement, convention, architecture và codebase
3. Tìm lỗi, thiếu sót, rủi ro
4. Đưa ra kết luận `PASS`, `PASS_WITH_NOTES`, hoặc `REJECT`
5. Nếu `REJECT`, phải chỉ rõ trả về Worker nào và cần sửa gì

---

### 3.3. Agent không được đoán bừa

Nếu thiếu thông tin, agent phải:

- Đọc lại knowledge files
- Tìm code tương tự
- Ghi câu hỏi vào `questions.md`
- Ghi assumption vào `assumptions.md`
- Không được tự bịa rule nghiệp vụ

---

### 3.4. Luôn ưu tiên codebase hiện tại

Khi phát triển feature mới, agent phải ưu tiên:

1. Convention hiện có trong repository
2. Kiến trúc hiện có
3. Pattern hiện có
4. API/DTO/entity/service/repository tương tự
5. Coding style hiện có
6. Framework và dependency đã có

Không tự ý thêm library mới nếu chưa có lý do và chưa được reviewer duyệt.

---

### 3.5. Không phá vỡ backward compatibility

Tất cả agent liên quan API, database, integration và test phải kiểm tra:

- API response cũ có bị thay đổi không
- Request contract cũ có bị phá không
- Database migration có an toàn không
- Existing tests có bị ảnh hưởng không
- Permission/security rule có thay đổi ngoài ý muốn không

---

### 3.6. Agent Registry và Invocation bắt buộc

Không được tạo agent "mồ côi". Mọi agent được định nghĩa phải có đường gọi rõ ràng từ một orchestrator hoặc từ một failure/debate/handoff rule.

Khi sinh hệ thống agent, bắt buộc tạo thêm file:

```text
agents/agent-registry.md
```

`agents/agent-registry.md` phải có bảng tối thiểu:

| Agent ID | File | Layer | Responsibility | Called By | When To Run | Required Inputs | Outputs | Reviewer | Handoff To | Can Run Parallel | Write Scope | Stop Condition |
|---|---|---|---|---|---|---|---|---|---|---|---|---|

Luật bắt buộc:

- Nếu một agent chỉ chạy tùy điều kiện, `When To Run` phải nêu trigger cụ thể.
- Nếu một agent có thể bị skip, phải ghi rõ `Skip Condition`.
- Nếu một agent là reviewer, phải ghi rõ worker tương ứng hoặc artifact tương ứng.
- Nếu một agent được gọi từ failure loop, phải ghi rõ root cause nào kích hoạt nó.
- Nếu một agent không có caller hợp lệ, AI sinh agent phải sửa workflow hoặc loại agent đó khỏi output.
- Workflow Orchestrator và các sub-orchestrator bắt buộc đọc `agents/agent-registry.md` trước khi chạy workflow.

---

### 3.7. Handoff Contract bắt buộc

Mọi agent phải bàn giao bằng artifact rõ ràng, không bàn giao bằng mô tả miệng.

Mỗi handoff phải ghi vào:

```text
execution-workspace/<task>/handoff-log.md
```

Format handoff bắt buộc:

```md
## Handoff: <From Agent> -> <To Agent>
- Time:
- From:
- To:
- Trigger:
- Inputs Read:
- Outputs Produced:
- Verdict: PASS | PASS_WITH_NOTES | REJECT | BLOCKED
- Blocking Issues:
- Assumptions Added:
- Questions Added:
- Files Changed:
- Required Next Action:
- Iteration:
```

Luật handoff:

- Worker chỉ được handoff cho reviewer tương ứng hoặc orchestrator cùng layer.
- Reviewer `PASS` hoặc `PASS_WITH_NOTES` thì handoff về orchestrator cùng layer.
- Reviewer `REJECT` thì handoff về đúng worker tạo lỗi, kèm checklist lỗi cụ thể.
- Failure Analyzer chỉ được handoff về agent sở hữu root cause, không được tự sửa code.
- Consensus Agent chỉ được handoff quyết định đã có evidence cho reviewer hoặc orchestrator phù hợp.
- Agent không được chuyển sang layer tiếp theo nếu handoff artifact thiếu verdict.

---

### 3.8. Debate Loop Policy

Debate loop dùng để buộc agent phản biện lẫn nhau trong các tình huống có rủi ro hoặc bất đồng. Debate không được chạy vô hạn và không thay thế reviewer gate.

#### Khi nào phải chạy debate

Chạy debate khi có một trong các điều kiện sau:

- Requirement mơ hồ nhưng chưa đủ cơ sở block user.
- Có từ 2 hướng thiết kế trở lên với trade-off đáng kể.
- Worker và Reviewer bất đồng sau 1 lần sửa.
- Security, performance, migration hoặc backward compatibility có rủi ro cao.
- Failure Analyzer không xác định được root cause chắc chắn.
- Workflow History Optimizer đề xuất thay đổi workflow/agent definition.
- Agent Evolution Reviewer không đồng ý với đề xuất sửa agent.

#### Thành phần debate

Mỗi debate phải có tối thiểu 2 vai:

| Role | Responsibility |
|---|---|
| Proposer | Đưa ra phương án hoặc bản sửa |
| Critic | Phản biện bằng evidence từ requirement, codebase, logs, test result hoặc knowledge |
| Arbiter | Tổng hợp và đưa verdict, thường là Consensus Agent hoặc orchestrator liên quan |

Nếu debate liên quan thay đổi agent/workflow, bắt buộc dùng:

- `Workflow History Optimizer` làm Proposer
- `Agent Evolution Reviewer` làm Critic
- `Workflow Orchestrator` hoặc `Consensus Agent` làm Arbiter

#### Vòng debate

Mỗi vòng debate phải có format:

1. `Claim`: Proposer nêu đề xuất.
2. `Evidence`: Proposer dẫn artifact hoặc source cụ thể.
3. `Counterargument`: Critic chỉ ra rủi ro, thiếu sót hoặc conflict.
4. `Revision`: Proposer sửa đề xuất hoặc bảo vệ bằng evidence mới.
5. `Round Verdict`: Arbiter kết luận `ACCEPT`, `REVISE`, hoặc `UNRESOLVED`.

#### Giới hạn debate

- `MAX_DEBATE_ROUNDS = 3`
- Task đơn giản nên dùng tối đa 2 vòng.
- Task có security/performance/migration risk cao vẫn không được vượt quá 3 vòng nếu user chưa cho phép.
- Nếu sau 3 vòng vẫn `UNRESOLVED`, phải dừng debate, đánh dấu `BLOCKED`, ghi lý do và hỏi user.

---

### 3.9. Max Iteration / Stop Condition

Mọi workflow phải có giới hạn vòng lặp rõ ràng.

Default iteration budget:

| Loop Type | Max Iteration | Stop Condition |
|---|---:|---|
| Worker -> Reviewer repair loop | 2 | Reviewer vẫn `REJECT` sau 2 lần sửa |
| Failure Analyzer repair loop | 3 | Cùng root cause lặp lại hoặc không xác định được root cause |
| Debate loop | 3 | Không đạt `ACCEPT` hoặc không có evidence mới |
| Full workflow restart | 1 | Restart vẫn fail ở cùng stage |
| Agent optimization loop | 2 | Agent Evolution Reviewer vẫn reject thay đổi |

Phải dừng workflow và báo user khi:

- Thiếu business rule mà codebase/knowledge/log không thể suy ra.
- Cần quyết định product/security/business từ con người.
- Có nguy cơ phá dữ liệu, migration hoặc backward compatibility mà không thể tự chứng minh an toàn.
- Hai vòng liên tiếp fail vì cùng một lỗi.
- Debate đạt max round nhưng chưa có consensus.
- Agent cần quyền vượt quá permission được cấp.
- Có conflict file do nhiều agent cùng sửa một vùng không thể merge an toàn.

Khi dừng, phải ghi:

```text
execution-workspace/<task>/blocked-report.md
execution-workspace/<task>/questions.md
execution-workspace/<task>/risks.md
```

`blocked-report.md` phải có:

```md
# Blocked Report

## Blocker Summary
## Current Stage
## Agents Involved
## Iterations Used
## Evidence Checked
## Why Agents Cannot Resolve This
## Options For User
## Recommended Question To User
```

---

### 3.10. Workflow Harness Runtime

Workflow Harness Runtime là lớp điều phối bắt buộc để chạy subagents. Harness không làm thay việc chuyên môn của agent; harness chỉ quản lý state, scheduling, dependency, permission, lock, retry, debate và artifact.

Khi sinh agent, bắt buộc tạo:

```text
agents/workflow/harness-runtime.md
agents/workflow/workflow-policy.md
agents/workflow/parallel-execution-policy.md
agents/workflow/debate-loop-policy.md
agents/workflow/stop-condition-policy.md
```

Harness Runtime phải quản lý:

- Task queue theo stage: `KNOWLEDGE`, `PLANNING`, `DEVELOPMENT`, `TESTING`, `VERIFY`, `DONE`, `BLOCKED`
- Agent registry
- Input readiness check
- Dependency graph
- Parallel execution groups
- File/module lock
- Iteration budget
- Debate budget
- Reviewer gate
- Failure routing
- Artifact validation
- Execution state update
- User escalation khi blocked

Harness Runtime phải ghi log vào:

```text
execution-workspace/<task>/runtime/harness-state.md
execution-workspace/<task>/runtime/runtime-log.jsonl
execution-workspace/<task>/runtime/agent-dispatch-log.md
execution-workspace/<task>/runtime/parallel-groups.md
execution-workspace/<task>/runtime/permission-audit.md
```

Mỗi dòng `runtime-log.jsonl` nên có:

```json
{
  "time": "",
  "task": "",
  "stage": "",
  "agent": "",
  "action": "",
  "status": "",
  "inputs": [],
  "outputs": [],
  "locks": [],
  "iteration": 0,
  "reason": ""
}
```

Harness Runtime chỉ được dispatch agent khi:

- Required inputs tồn tại.
- Agent chưa vượt iteration budget.
- File/module lock còn trống hoặc agent là read-only.
- Reviewer gate trước đó đã pass hoặc có lý do hợp lệ để rerun.
- Permission của agent cho phép hành động cần thực hiện.

---

### 3.11. Parallel Execution Policy

Chạy song song chỉ được phép khi không có shared write scope hoặc dependency trực tiếp.

#### Được chạy song song

- Các knowledge discovery agent chỉ đọc codebase và ghi vào các file knowledge khác nhau.
- Positive/Negative/Contract/Security/Performance test agents nếu mỗi agent ghi file test/report riêng.
- Security Auditor, QA Lead và Release Manager ở verify layer nếu chỉ đọc artifact đã hoàn tất.
- Reviewer của các artifact độc lập khi worker tương ứng đã hoàn thành.
- Log/history analysis agent nếu chỉ đọc execution workspace.

#### Không được chạy song song

- Hai agent cùng sửa một file hoặc cùng module mà không có lock.
- Refactor Agent chạy cùng Business Logic Developer hoặc Integration Developer.
- Database migration design chạy cùng repository/entity implementation nếu chưa có API/DB review.
- Test Runner chạy khi test agents còn đang viết test.
- Knowledge Indexer chạy trước khi các discovery agent liên quan hoàn tất.
- Final Reviewer chạy trước khi tất cả reviewer gate bắt buộc đã pass.

#### Lock bắt buộc

Mỗi agent có write permission phải khai báo:

```text
Write Scope:
- Files:
- Directories:
- Modules:
- Database objects:
- API contracts:
```

Harness phải cấp lock theo thứ tự:

1. Exact file lock
2. Directory/module lock
3. API contract lock
4. Database object lock
5. Global workflow lock nếu thay đổi workflow/agent definition

Nếu lock conflict:

- Agent có dependency thấp hơn phải chờ.
- Nếu conflict không giải quyết được, ghi `runtime/lock-conflict.md`.
- Không tự merge thay đổi agent khác nếu chưa đọc diff và reviewer note.

---

### 3.12. Debate Output Files

Mọi debate phải sinh artifact có thể audit.

Output bắt buộc:

```text
execution-workspace/<task>/debate/<debate-id>/debate-brief.md
execution-workspace/<task>/debate/<debate-id>/round-1.md
execution-workspace/<task>/debate/<debate-id>/round-2.md
execution-workspace/<task>/debate/<debate-id>/round-3.md
execution-workspace/<task>/debate/<debate-id>/debate-summary.md
execution-workspace/<task>/debate/<debate-id>/decision.md
execution-workspace/<task>/debate/<debate-id>/unresolved.md
```

Không cần tạo `round-2.md` hoặc `round-3.md` nếu debate kết thúc sớm.

`decision.md` phải có:

```md
# Debate Decision

## Topic
## Participants
## Rounds Used
## Accepted Position
## Evidence
## Rejected Alternatives
## Remaining Risk
## Required Follow-up
## Verdict
ACCEPT | ACCEPT_WITH_NOTES | UNRESOLVED
```

Nếu `UNRESOLVED`, Workflow Orchestrator phải tạo `blocked-report.md` và hỏi user.

---

### 3.13. Agent Permission Model

Mỗi agent phải có permission scope riêng. Không agent nào được mặc định có toàn quyền.

Permission fields bắt buộc trong từng agent file:

```md
## Permissions
- Read:
- Write:
- Execute:
- Network:
- Destructive Actions:
- Secrets:
- Approval Required:
```

Default:

- Read: chỉ các artifact, knowledge và source cần thiết.
- Write: chỉ output file của agent và code/doc trong phạm vi được giao.
- Execute: chỉ command cần thiết cho agent, ví dụ test runner mới được chạy test/build.
- Network: `NO` mặc định, chỉ bật khi task integration/documentation cần kiểm tra dependency hoặc API docs bên ngoài.
- Destructive Actions: `NO`, không xóa file, reset git, drop DB, rewrite history.
- Secrets: không đọc hoặc ghi secret; nếu vô tình thấy secret thì không in ra log.
- Approval Required: mọi hành động vượt quyền phải dừng và báo user.

Agent sửa workflow/agent definition còn bị ràng buộc thêm:

- Không được sửa product source code.
- Không được giảm review gate.
- Không được tăng quyền cho agent khác nếu không có evidence và reviewer duyệt.
- Không được xóa agent hiện có; chỉ được deprecate bằng lý do và migration path.
- Mọi thay đổi phải qua Agent Evolution Reviewer.

---

