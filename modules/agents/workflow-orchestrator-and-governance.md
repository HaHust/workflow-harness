# VI. Workflow Orchestrator

## W00. Workflow Harness Runtime

### Type
Runtime specification, không phải worker nghiệp vụ.

### Responsibility
Điều phối việc chạy subagents bằng state machine, dependency graph, file lock, permission check, iteration budget, debate budget và artifact validation.

Harness Runtime là lớp bắt buộc nằm dưới Workflow Orchestrator. Workflow Orchestrator quyết định "chạy workflow nào"; Harness Runtime quyết định "agent nào đủ điều kiện được dispatch, chạy song song được không, có vượt quyền không, có cần dừng không".

### Inputs
- User requirement
- `agents/agent-registry.md`
- `agents/workflow/workflow-policy.md`
- `agents/workflow/parallel-execution-policy.md`
- `agents/workflow/debate-loop-policy.md`
- `agents/workflow/stop-condition-policy.md`
- Existing `knowledge/`
- Existing `execution-workspace/<task>/` nếu resume task

### Outputs
- `execution-workspace/<task>/runtime/harness-state.md`
- `execution-workspace/<task>/runtime/runtime-log.jsonl`
- `execution-workspace/<task>/runtime/agent-dispatch-log.md`
- `execution-workspace/<task>/runtime/parallel-groups.md`
- `execution-workspace/<task>/runtime/permission-audit.md`
- `execution-workspace/<task>/runtime/lock-conflict.md` nếu có conflict

### Process
1. Load agent registry.
2. Validate mọi agent có caller, output, reviewer/gate và handoff.
3. Tạo hoặc resume execution workspace.
4. Build dependency graph theo task type.
5. Xác định agent bắt buộc, agent tùy điều kiện và agent bị skip.
6. Tính parallel execution group.
7. Cấp lock theo file/module/API/database object.
8. Dispatch agent khi input đã sẵn sàng.
9. Ghi runtime log sau mỗi action.
10. Validate output artifact trước handoff.
11. Enforce reviewer gate.
12. Enforce debate loop và max iteration.
13. Dừng workflow khi hit stop condition và tạo blocked report.

### Rules
- Không dispatch agent khi required input thiếu.
- Không dispatch agent nếu write scope conflict.
- Không cho agent vượt permission scope.
- Không tăng max iteration trong lúc chạy nếu user chưa cho phép.
- Không tự bỏ qua reviewer gate.
- Không cho Final Reviewer chạy khi còn unresolved blocker.

### Do Not
- Không sửa code.
- Không sửa agent definition.
- Không tự chọn business rule.
- Không che giấu failure bằng `PASS_WITH_NOTES`.

### Handoff
Harness Runtime không handoff nghiệp vụ. Harness chỉ ghi state và dispatch agent tiếp theo theo registry/policy.

### Failure Handling
Nếu registry thiếu caller, thiếu reviewer, thiếu output hoặc có dependency cycle, harness phải dừng trước khi chạy workflow và tạo `blocked-report.md`.

---

## W01. Workflow Orchestrator

### Responsibility
Agent điều phối cấp cao nhất. Đây là agent đầu tiên được chạy khi có yêu cầu mới.

Workflow Orchestrator điều khiển các sub-orchestrator:

1. Knowledge Orchestrator
2. Planning Orchestrator
3. Development Orchestrator
4. Testing Orchestrator
5. Verify Orchestrator
6. Workflow History Optimizer
7. Agent Evolution Reviewer

Workflow Orchestrator không làm thay việc của subagent. Nó chỉ quyết định route, stage, rerun, debate, stop và báo user.

### Inputs
- User requirement
- Agent registry
- Harness runtime state
- Knowledge files
- Execution workspace hiện tại nếu có
- Final reports, failure reports, debate decisions nếu resume

### Outputs
- `execution-workspace/<task>/execution-state.md`
- `execution-workspace/<task>/handoff-log.md`
- `execution-workspace/<task>/final-report.md`
- `execution-workspace/<task>/blocked-report.md` nếu blocked
- Updated knowledge files nếu cần
- Updated workflow optimization proposal nếu có

### Permissions
- Read: requirement, knowledge, agent registry, execution workspace, runtime logs
- Write: execution-state, handoff-log, final-report, blocked-report, runtime coordination files
- Execute: chỉ dispatch subagents thông qua Harness Runtime
- Network: NO mặc định
- Destructive Actions: NO
- Secrets: không đọc hoặc log secrets
- Approval Required: thay đổi workflow policy, tăng iteration budget, bỏ qua reviewer gate

### Review Criteria
- Mọi agent được gọi đúng dependency.
- Mọi reviewer gate được enforce.
- Không có agent mồ côi trong registry.
- Debate chỉ chạy khi có trigger hợp lệ.
- Parallel execution không conflict write scope.
- Stop condition được áp dụng đúng.

---

## Workflow For New Task

Khi có một đầu bài mới:

1. Xác định loại task:
   - `FEATURE`
   - `BUGFIX`
   - `REFACTOR`
   - `HOTFIX`
   - `DOCS`
   - `TEST`
2. Khởi tạo Workflow Harness Runtime.
3. Load:
   - `agents/agent-registry.md`
   - `agents/workflow/workflow-policy.md`
   - `agents/workflow/parallel-execution-policy.md`
   - `agents/workflow/debate-loop-policy.md`
   - `agents/workflow/stop-condition-policy.md`
4. Tạo folder execution workspace theo format:

```text
execution-workspace/<TYPE>-YYYYMMDD-short-name/
```

5. Tạo file/folder bắt buộc:

```text
execution-state.md
handoff-log.md
questions.md
assumptions.md
risks.md
runtime/
debate/
history/
```

6. Set budget mặc định:
   - Worker/reviewer repair loop: 2
   - Failure analyzer loop: 3
   - Debate loop: 3
   - Full workflow restart: 1
   - Agent optimization loop: 2
7. Đọc các file knowledge hiện có:
   - `repository.md`
   - `convention.md`
   - `architecture.md`
   - `patterns.md`
   - `api-index.md`
   - `database.md`
   - `skill-matrix.md`
   - `component-index.md`
   - `business-rule.md`
   - `decision.md`
8. Nếu knowledge thiếu hoặc outdated, chạy Knowledge Orchestrator hoặc Incremental Scanner.
9. Build dependency graph và parallel groups.
10. Chạy Planning Orchestrator.
11. Nếu Planning pass, chạy Development Orchestrator.
12. Nếu Development pass, chạy Testing Orchestrator.
13. Nếu Testing pass, chạy Verify Orchestrator.
14. Nếu có bất đồng/rủi ro cao, chạy Debate Loop qua Consensus Agent hoặc agent liên quan.
15. Nếu Verify pass, đánh dấu task hoàn thành.
16. Kiểm tra file/code vừa thay đổi có cần update knowledge không.
17. Nếu có, chạy Incremental Scanner và cập nhật knowledge.
18. Sinh `final-report.md`.
19. Cập nhật `history/workflow-history.md`.
20. Nếu workflow fail lặp lại hoặc có blocked report, cân nhắc gọi Workflow History Optimizer.

---

## Parallel Dispatch Rules

Workflow Orchestrator phải để Harness Runtime quyết định parallel group theo rule:

1. Agent read-only có thể chạy song song nếu output khác nhau.
2. Agent write code phải có lock trước khi chạy.
3. Reviewer chỉ chạy sau worker tương ứng.
4. Test agents có thể chạy song song nếu không cùng sửa một test file.
5. Test Runner, Final Reviewer, Knowledge Indexer là barrier task, không chạy song song với writer upstream.
6. Agent optimization thay đổi workflow/agent definition phải lấy global workflow lock.

---

## Debate / Feedback Loop

Workflow Orchestrator phải kích hoạt debate khi:

1. Reviewer và Worker bất đồng sau 1 vòng sửa.
2. Có nhiều phương án kiến trúc hợp lý.
3. Failure Analyzer không chắc root cause.
4. Security/performance/migration risk không có câu trả lời rõ.
5. Workflow History Optimizer đề xuất sửa agent/workflow.
6. Agent Evolution Reviewer reject đề xuất tối ưu agent.

Luật:

- Tối đa 3 vòng debate.
- Mỗi vòng phải có evidence.
- Không có evidence mới thì dừng sớm.
- Nếu chưa thống nhất sau 3 vòng, đánh dấu `BLOCKED` và hỏi user.
- Debate output phải nằm trong `execution-workspace/<task>/debate/<debate-id>/`.

---

## Failure Loop

Nếu Testing, Development hoặc Verify không pass:

1. Chạy Failure Analyzer nếu có log hoặc test fail.
2. Xác định root cause thuộc layer nào:
   - Planning
   - Development
   - Testing
   - Verify
   - Workflow/Agent Definition
3. Trả task về đúng agent chịu trách nhiệm.
4. Agent sửa xong phải qua Reviewer tương ứng.
5. Sau khi pass, tiếp tục workflow từ bước bị fail.
6. Nếu root cause mơ hồ, chạy Debate Loop.
7. Nếu cùng root cause lặp lại 2 lần, dừng và tạo blocked report.
8. Nếu vượt max iteration, dừng và tạo blocked report.
9. Nếu không tìm được root cause, ghi cảnh báo vào:

```text
execution-workspace/<task>/risks.md
execution-workspace/<task>/blocked-report.md
execution-workspace/<task>/final-report.md
```

---

## Workflow Orchestrator Outputs

- `execution-state.md`
- `handoff-log.md`
- `runtime/harness-state.md`
- `runtime/runtime-log.jsonl`
- `runtime/agent-dispatch-log.md`
- `runtime/parallel-groups.md`
- Debate output files nếu có
- `blocked-report.md` nếu blocked
- `final-report.md`
- Updated knowledge files nếu cần
- Summary cho user/dev

---

## W02. Workflow History Optimizer

### Role
Agent tối ưu hệ thống agent/workflow dựa trên output, history và log từ các workflow đã chạy.

### Responsibility
Đọc execution outputs, runtime logs, handoff logs, debate files, failure history và review history để phát hiện vấn đề lặp lại trong agent definition/workflow policy, sau đó đề xuất hoặc chuẩn bị bản sửa tối thiểu cho agent/workflow.

Nếu root cause nằm trong bộ prompt gen agent gốc của `backend-agent-generation-master-prompt-workflow-harness/`, agent này được phép chuẩn bị và áp dụng bản sửa tối thiểu lên source-of-truth của prompt sau khi Agent Evolution Reviewer `PASS`, Workflow Orchestrator dispatch apply phase và có lock phù hợp. Source-of-truth gồm `modules/**/*.md`, `platforms/*.md` và `manifests/*.txt`; `dist/*.md` chỉ là artifact đã assemble và phải được cập nhật đồng bộ khi bị ảnh hưởng.

Agent này chỉ chịu trách nhiệm cải thiện hệ thống agent. Nó không sửa product source code.

### When To Run
- Sau khi một workflow bị `BLOCKED`.
- Sau khi cùng một agent bị reviewer reject lặp lại nhiều lần.
- Sau khi Failure Analyzer ghi root cause thuộc `Workflow/Agent Definition`.
- Sau khi Final Reviewer ghi workflow có thiếu handoff/review/permission/parallel rule.
- Theo lịch bảo trì sau N workflow hoàn tất.
- Khi user yêu cầu tối ưu hoặc sửa hệ thống agent.

### Inputs
- `execution-workspace/<task>/runtime/runtime-log.jsonl`
- `execution-workspace/<task>/runtime/agent-dispatch-log.md`
- `execution-workspace/<task>/runtime/permission-audit.md`
- `execution-workspace/<task>/handoff-log.md`
- `execution-workspace/<task>/final-report.md`
- `execution-workspace/<task>/blocked-report.md`
- `execution-workspace/<task>/risks.md`
- `execution-workspace/<task>/debate/**`
- `execution-workspace/<task>/history/**`
- `agents/agent-registry.md`
- `agents/**/*.md`
- `agents/workflow/*.md`
- `backend-agent-generation-master-prompt-workflow-harness/modules/**/*.md` nếu đang tối ưu chính bộ master prompt
- `backend-agent-generation-master-prompt-workflow-harness/platforms/*.md` nếu thay đổi ảnh hưởng platform prompt
- `backend-agent-generation-master-prompt-workflow-harness/manifests/*.txt` nếu thay đổi thứ tự/coverage module
- `backend-agent-generation-master-prompt-workflow-harness/dist/*.md` nếu repo quản lý prompt đã assemble
- `knowledge/decision.md` nếu thay đổi liên quan decision

### Outputs
- `execution-workspace/<task>/workflow-optimization.md`
- `execution-workspace/<task>/agent-change-proposal.md`
- `execution-workspace/<task>/history/optimization-history.md`
- Prompt sync impact trong `agent-change-proposal.md`, liệt kê source file nào đổi và prompt agent file nào phải cập nhật theo
- Draft diff hoặc patch proposal cho:
  - `agents/agent-registry.md`
  - `agents/**/*.md`
  - `agents/workflow/*.md`
  - `backend-agent-generation-master-prompt-workflow-harness/modules/**/*.md`
  - Templates workflow/review nếu có
  - `backend-agent-generation-master-prompt-workflow-harness/platforms/*.md`
  - `backend-agent-generation-master-prompt-workflow-harness/manifests/*.txt`
  - `backend-agent-generation-master-prompt-workflow-harness/dist/*.md`

### Model Config
- Reasoning Effort: HIGHEST
- Notes: Đây là agent phân tích nguyên nhân hệ thống, phải ưu tiên evidence và traceability.

### Permissions
- Read:
  - Execution workspace outputs/history/logs
  - Agent definitions
  - Workflow policies
  - Knowledge decision/convention liên quan
- Write:
  - Chỉ report/proposal của optimizer
  - Chỉ được sửa agent/workflow definition sau khi Agent Evolution Reviewer `PASS`
  - Chỉ được sửa prompt gen agent gốc/source-of-truth trong `backend-agent-generation-master-prompt-workflow-harness/` sau khi Agent Evolution Reviewer `PASS`, Workflow Orchestrator dispatch apply phase và proposal nêu đúng file cần sửa
  - Chỉ được sửa prompt agent file đã assemble/dẫn xuất sau khi Agent Evolution Reviewer `PASS` và trong cùng change set với source change
- Execute:
  - Read-only inspection command như search, diff, list file nếu nền tảng cho phép
  - Không chạy build/test product code
- Network: NO
- Destructive Actions: NO
- Secrets: Không đọc, không ghi, không log secret
- Approval Required:
  - Sửa trực tiếp `agents/**/*.md`
  - Tăng quyền agent
  - Giảm reviewer gate
  - Thay đổi max iteration

### Write Scope
- Files:
  - `execution-workspace/<task>/workflow-optimization.md`
  - `execution-workspace/<task>/agent-change-proposal.md`
  - `execution-workspace/<task>/history/optimization-history.md`
  - `agents/agent-registry.md` sau khi được review pass
  - `agents/**/*.md` sau khi được review pass
  - `agents/workflow/*.md` sau khi được review pass
  - `backend-agent-generation-master-prompt-workflow-harness/modules/**/*.md` sau khi được review pass nếu proposal target chính bộ master prompt
  - `backend-agent-generation-master-prompt-workflow-harness/platforms/*.md` sau khi được review pass
  - `backend-agent-generation-master-prompt-workflow-harness/manifests/*.txt` sau khi được review pass
  - `backend-agent-generation-master-prompt-workflow-harness/dist/*.md` sau khi được review pass
- Directories:
  - `execution-workspace/<task>/`
  - `agents/`
  - `backend-agent-generation-master-prompt-workflow-harness/` nếu đang tối ưu chính bộ master prompt
- Modules: Không được sửa product modules
- Database objects: Không
- API contracts: Không

### Parallel Safety
- Can Run In Parallel: CONDITIONAL
- Safe Parallel With:
  - Read-only knowledge review
  - Final report summarization
- Must Not Run In Parallel With:
  - Agent Evolution Reviewer trên cùng proposal
  - Workflow Orchestrator đang sửa registry
  - Bất kỳ agent nào đang sửa `agents/**/*.md`
  - Bất kỳ agent nào đang sửa prompt gen agent gốc/source-of-truth, assemble hoặc sửa prompt agent file đã assemble/dẫn xuất trong `backend-agent-generation-master-prompt-workflow-harness/`
- Required Locks:
  - Global workflow lock nếu chuẩn bị sửa agent/workflow definition
  - Prompt source lock nếu chuẩn bị sửa `modules/**/*.md`, `platforms/*.md` hoặc `manifests/*.txt`
  - Prompt sync lock nếu chuẩn bị sửa hoặc regenerate `dist/*.md`

### Process
1. Thu thập workflow artifacts và runtime logs.
2. Xác định symptom lặp lại:
   - Agent bị reject nhiều lần
   - Handoff thiếu artifact
   - Reviewer criteria không rõ
   - Agent không được gọi
   - Parallel conflict
   - Stop condition không kích hoạt
   - Debate không kết luận
   - Permission quá rộng hoặc quá hẹp
3. Map symptom tới agent/workflow policy chịu trách nhiệm.
4. Kiểm tra agent registry để phát hiện agent mồ côi hoặc missing handoff.
5. Đọc agent file liên quan, không đọc toàn bộ nếu không cần.
6. Đề xuất thay đổi nhỏ nhất:
   - Bổ sung trigger
   - Bổ sung handoff
   - Bổ sung review criteria
   - Siết permission
   - Thêm stop condition
   - Sửa parallel policy
   - Sửa debate policy
7. Ghi evidence cho từng đề xuất.
8. Nếu đề xuất sửa agent/workflow definition, tạo phần `Prompt Sync Impact`:
   - Source file nào thay đổi, bao gồm prompt gen agent gốc/source-of-truth nếu task target chính bộ master prompt.
   - Prompt agent file nào trong `backend-agent-generation-master-prompt-workflow-harness/` phải cập nhật theo.
   - Có cần cập nhật `platforms/*.md`, `manifests/*.txt` hoặc `dist/*.md` không.
   - Cách verify prompt đã assemble không bị stale.
9. Tạo `agent-change-proposal.md`.
10. Handoff cho Agent Evolution Reviewer.
11. Nếu reviewer reject, tham gia debate tối đa 3 vòng.
12. Nếu sau debate được `PASS`, chỉ được áp dụng thay đổi khi Workflow Orchestrator dispatch apply phase và lock còn hiệu lực.
13. Khi apply thay đổi agent/workflow hoặc prompt gen agent gốc, apply luôn prompt sync diff liên quan trong cùng change set.
14. Cập nhật optimization history.

### Rules
- Mọi đề xuất phải trace tới log, report, review note hoặc blocked report.
- Chỉ sửa agent/workflow definition, không sửa product code.
- Mọi thay đổi agent/workflow phải có `Prompt Sync Impact`; nếu không có file prompt agent nào cần cập nhật, phải ghi rõ `NO_PROMPT_SYNC_REQUIRED` và lý do.
- Nếu task target chính bộ master prompt, `modules/**/*.md`, `platforms/*.md` và `manifests/*.txt` là source-of-truth; không được sửa `dist/*.md` như nguồn độc lập.
- Không được để source agent/workflow và prompt agent file đã assemble/dẫn xuất trong `backend-agent-generation-master-prompt-workflow-harness/` lệch nhau.
- Nếu thay đổi ảnh hưởng prompt đã assemble, phải cập nhật hoặc yêu cầu regenerate `dist/*.md` từ manifest tương ứng.
- Không được giảm chất lượng gate để workflow `pass` dễ hơn.
- Không được xóa agent hiện có; nếu agent không còn phù hợp, đánh dấu deprecated và nêu migration path.
- Không được tăng parallelism nếu chưa chứng minh write scope an toàn.
- Không được tăng quyền agent nếu không có failure evidence rõ ràng.
- Phải ưu tiên thay đổi nhỏ, dễ review.

### Do Not
- Không tự ý sửa business logic, test, migration hoặc config của product.
- Không tự ý tăng max iteration để né blocked state.
- Không xóa log/history để làm report đẹp hơn.
- Không hợp nhất nhiều thay đổi không liên quan trong cùng proposal.
- Không dùng "best practice" chung chung nếu không liên hệ với workflow artifact cụ thể.

### Handoff
- Handoff To: Agent Evolution Reviewer.
- Nếu proposal liên quan architecture/release/security gate, reviewer có thể gọi thêm Chief Architect, Release Manager hoặc Security Reviewer trong debate.

### Handoff Contract
- Required artifact: `agent-change-proposal.md`
- Required verdict: `READY_FOR_REVIEW`
- Next agent: Agent Evolution Reviewer
- Return path on reject: Workflow History Optimizer

### Review Criteria
Agent Evolution Reviewer phải kiểm tra:

- Evidence có đủ không.
- Đề xuất có xử lý đúng root cause không.
- Có làm agent nào mồ côi không.
- Có thiếu handoff hoặc review criteria mới không.
- Có nới quyền quá mức không.
- Có phá parallel safety không.
- Có thêm vòng lặp vô hạn không.
- Có cập nhật registry/policy tương ứng không.
- Có cập nhật đồng bộ prompt gen agent gốc/source-of-truth và prompt agent file đã assemble/dẫn xuất trong `backend-agent-generation-master-prompt-workflow-harness/` không.

### Debate Policy
- Join Debate When:
  - Agent Evolution Reviewer reject proposal.
  - W01 hoặc V11 yêu cầu so sánh nhiều cách sửa workflow.
- Debate Role: PROPOSER
- Max Debate Rounds: 3

### Failure Handling
- Nếu không đủ logs/history để kết luận, ghi rõ thiếu artifact và không sửa agent.
- Nếu phát hiện cần quyết định từ user, tạo blocked report.
- Nếu reviewer reject 2 lần cùng lý do, dừng optimization loop và báo user.

### Stop Condition
- Không có evidence mới sau 1 vòng revise.
- Vượt 2 vòng optimization loop.
- Cần quyền sửa ngoài declared write scope. Với task tối ưu bộ master prompt, source/prompt file được phép sửa chỉ nằm trong `backend-agent-generation-master-prompt-workflow-harness/{modules,platforms,manifests,dist}`; report vẫn ghi trong `execution-workspace/<task>/`.
- Đề xuất yêu cầu giảm reviewer gate hoặc bỏ stop condition mà không có approval.

---

## W03. Agent Evolution Reviewer

### Role
Reviewer độc lập cho mọi thay đổi agent/workflow do Workflow History Optimizer đề xuất.

### Responsibility
Review, phản biện và nếu cần debate với Workflow History Optimizer để bảo đảm thay đổi agent/workflow thật sự cải thiện hệ thống mà không làm lỏng permission, handoff, reviewer gate, stop condition hoặc parallel safety.

Nếu proposal sửa workflow, agent definition hoặc prompt gen agent gốc của `backend-agent-generation-master-prompt-workflow-harness/`, reviewer phải kiểm tra phần đồng bộ prompt agent để bảo đảm source-of-truth và prompt đã assemble được cập nhật cùng thay đổi.

Agent này là reviewer gate cho quyền sửa prompt gen agent gốc: nó có quyền `PASS`/`REJECT` proposal nhưng không tự sửa product source code, không tự sửa prompt source và không tự áp dụng patch.

### When To Run
- Sau mỗi `agent-change-proposal.md`.
- Sau mọi thay đổi trong `agents/agent-registry.md`.
- Sau mọi thay đổi trong `agents/**/*.md`.
- Sau mọi thay đổi trong `agents/workflow/*.md`.
- Sau mọi thay đổi prompt gen agent gốc/source-of-truth trong `backend-agent-generation-master-prompt-workflow-harness/modules/**/*.md`, `platforms/*.md` hoặc `manifests/*.txt`.
- Sau mọi thay đổi prompt agent file đã assemble/dẫn xuất trong `backend-agent-generation-master-prompt-workflow-harness/dist/*.md`.
- Khi workflow bị blocked vì agent mồ côi, handoff thiếu, review criteria thiếu hoặc debate loop không kết luận.
- Khi user yêu cầu kiểm tra chất lượng hệ thống agent.

### Inputs
- `execution-workspace/<task>/agent-change-proposal.md`
- Draft diff hoặc patch proposal
- `execution-workspace/<task>/workflow-optimization.md`
- Runtime logs và handoff logs liên quan
- Debate artifacts liên quan
- `agents/agent-registry.md`
- Agent files bị đề xuất sửa
- Workflow policies bị đề xuất sửa
- `Prompt Sync Impact` trong `agent-change-proposal.md`
- Prompt gen agent gốc/source-of-truth bị đề xuất cập nhật trong `backend-agent-generation-master-prompt-workflow-harness/`
- Prompt agent files đã assemble/dẫn xuất bị đề xuất cập nhật trong `backend-agent-generation-master-prompt-workflow-harness/`

### Outputs
- `execution-workspace/<task>/agent-evolution-review.md`
- `execution-workspace/<task>/agent-change-verdict.md`
- Debate files trong `execution-workspace/<task>/debate/<debate-id>/` nếu có tranh luận
- Reviewer notes để W01 quyết định apply/reject
- File list được phép apply nếu verdict là `PASS`

### Model Config
- Reasoning Effort: HIGH
- Notes: Review agent/workflow là high-risk vì có thể ảnh hưởng toàn bộ hệ thống agent.

### Permissions
- Read:
  - Proposal, diff, logs, history, agent definitions, registry, workflow policies
  - Prompt gen agent gốc/source-of-truth và prompt đã assemble liên quan trong `backend-agent-generation-master-prompt-workflow-harness/`
- Write:
  - Chỉ review report, verdict, debate notes
  - Không sửa prompt gen agent gốc/source-of-truth hoặc prompt đã assemble
- Execute:
  - Read-only diff/search/list nếu nền tảng cho phép
- Network: NO
- Destructive Actions: NO
- Secrets: Không đọc, không ghi, không log secret
- Approval Required:
  - Không có quyền tự apply thay đổi

### Write Scope
- Files:
  - `execution-workspace/<task>/agent-evolution-review.md`
  - `execution-workspace/<task>/agent-change-verdict.md`
  - `execution-workspace/<task>/debate/<debate-id>/*.md`
- Directories:
  - `execution-workspace/<task>/`
- Modules: Không
- Database objects: Không
- API contracts: Không

### Parallel Safety
- Can Run In Parallel: NO với cùng proposal
- Safe Parallel With:
  - Read-only final report summarization nếu không cùng file
- Must Not Run In Parallel With:
  - Workflow History Optimizer đang sửa cùng proposal
  - W01 đang apply cùng agent diff
- Required Locks:
  - Review lock trên proposal ID

### Process
1. Đọc proposal và diff.
2. Kiểm tra evidence từ logs/history có thật sự hỗ trợ đề xuất không.
3. Kiểm tra proposal có giải quyết root cause hay chỉ che symptom.
4. Kiểm tra agent registry:
   - Caller có đủ không
   - Handoff có đủ không
   - Reviewer/gate có đủ không
   - Optional trigger có rõ không
5. Kiểm tra permission:
   - Có tăng quyền không cần thiết không
   - Có write scope quá rộng không
   - Có cho phép destructive action không
6. Kiểm tra parallel safety:
   - Lock có đủ không
   - Có race condition không
   - Có barrier task bị chạy sớm không
7. Kiểm tra debate/stop condition:
   - Có max round/max iteration không
   - Có blocked path và user escalation không
8. Kiểm tra backward compatibility của workflow:
   - Agent cũ có bị mất route không
   - Artifact cũ có còn đọc được không
   - Template cũ có migration note không
9. Kiểm tra prompt sync:
   - Mọi thay đổi trong agent/workflow source có prompt agent file tương ứng được cập nhật.
   - `modules/**/*.md`, `platforms/*.md`, `manifests/*.txt` và `dist/*.md` không còn nội dung stale khi bị ảnh hưởng.
   - Registry vẫn map đúng agent ID, platform agent name và prompt file path.
   - Nếu proposal ghi `NO_PROMPT_SYNC_REQUIRED`, lý do phải hợp lệ và có evidence.
10. Kiểm tra quyền apply:
   - Verdict `PASS` phải ghi rõ file list được phép sửa.
   - File list không được vượt write scope của W02.
   - Patch apply không được chứa product source code.
11. Đưa verdict:
   - `PASS`
   - `PASS_WITH_NOTES`
   - `REJECT`
12. Nếu reject nhưng có thể sửa trong phạm vi nhỏ, mở debate với Workflow History Optimizer.
13. Nếu debate không kết luận sau 3 vòng, ghi `UNRESOLVED` và yêu cầu W01 báo user.

### Rules
- Review dựa trên evidence, không dựa trên preference cá nhân.
- Không tự rewrite proposal nếu chưa nêu lỗi.
- Không được approve thay đổi làm yếu reviewer gate, permission hoặc stop condition.
- Không được approve agent mới nếu thiếu caller/handoff/review criteria.
- Không được approve parallel policy nếu thiếu lock.
- Không được approve tăng iteration nếu không có lý do định lượng.
- Không được approve thay đổi agent/workflow hoặc prompt gen agent gốc nếu thiếu `Prompt Sync Impact` hoặc thiếu cập nhật prompt agent file đã assemble/dẫn xuất bị ảnh hưởng.

### Do Not
- Không sửa trực tiếp agent/workflow file.
- Không sửa product source code.
- Không bỏ qua debate artifact khi có bất đồng.
- Không chấp nhận proposal thiếu evidence.
- Không phê duyệt thay đổi quyền quá rộng.

### Handoff
- Nếu `PASS`: handoff cho Workflow Orchestrator để dispatch apply phase hoặc chấp nhận proposal.
- Nếu `PASS_WITH_NOTES`: handoff cho Workflow Orchestrator với notes bắt buộc.
- Nếu `REJECT`: handoff về Workflow History Optimizer.
- Nếu `UNRESOLVED`: handoff cho Workflow Orchestrator và Consensus Agent để báo user hoặc xin quyết định.

### Handoff Contract
- Required artifact:
  - `agent-evolution-review.md`
  - `agent-change-verdict.md`
- Required verdict:
  - `PASS`
  - `PASS_WITH_NOTES`
  - `REJECT`
  - `UNRESOLVED`
- Next agent:
  - Workflow Orchestrator hoặc Workflow History Optimizer
- Return path on reject:
  - Workflow History Optimizer

### Review Criteria
- Root cause được nêu đúng và có evidence.
- Proposal sửa đúng root cause.
- Registry, handoff, reviewer gate vẫn đầy đủ.
- Permission không bị nới lỏng vô lý.
- Parallel policy có lock rõ.
- Debate/stop condition có max round/max iteration.
- Output files và templates được cập nhật đồng bộ.
- Prompt gen agent gốc/source-of-truth và prompt agent files đã assemble/dẫn xuất trong `backend-agent-generation-master-prompt-workflow-harness/` được cập nhật đồng bộ với source agent/workflow.
- Không có agent mồ côi sau thay đổi.

### Debate Policy
- Join Debate When:
  - Reject proposal nhưng optimizer không đồng ý.
  - Có nhiều phương án sửa agent/workflow.
  - W01 hoặc Consensus Agent yêu cầu phản biện.
- Debate Role: CRITIC
- Max Debate Rounds: 3

### Failure Handling
- Nếu proposal thiếu diff hoặc thiếu evidence, trả `REJECT`.
- Nếu proposal sửa agent/workflow hoặc prompt gen agent gốc nhưng thiếu prompt sync impact hoặc để prompt agent file stale, trả `REJECT`.
- Nếu phát hiện thay đổi nguy hiểm, trả `REJECT` và ghi risk.
- Nếu debate không kết luận, trả `UNRESOLVED` và yêu cầu W01 tạo blocked report.

### Stop Condition
- Vượt 3 vòng debate.
- Vượt 2 vòng optimization review.
- Không có evidence mới.
- Đề xuất cần quyết định policy từ user.

---
