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

- Planning agents, bug finding agents, failure analysis agents, test case generation agents và workflow/agent optimization agents phải dùng `model_reasoning_effort = "xhigh"`.
- Agent implementation, integration, refactor và agent có nhiều bước suy luận mặc định dùng `xhigh`, trừ khi có lý do rõ để hạ xuống.
- Reviewer thông thường có thể dùng `low`.
- Reviewer/gate rủi ro cao như R02 Risk Reviewer profiles such as `SECURITY_GATE`, `ARCHITECTURE_GATE`, `RELEASE_GATE`, and `FINAL_GATE` must not be lowered below the shared agent spec; use `medium`, `high`, or `xhigh` when risk is material.
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
...

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
- [ ] Agent reasoning mapping tuân thủ rule planning/bug/test/failure/optimization dùng `xhigh`.
- [ ] Reviewer thường dùng `low` nhưng high-risk gate không bị hạ thấp trái shared spec.
- [ ] Reviewer/scanner không ghi file dùng `sandbox_mode = "read-only"`; reviewer/scanner ghi artifact dùng `workspace-write` với write scope hẹp.
- [ ] Writer dùng `sandbox_mode = "workspace-write"` và có write scope rõ.
- [ ] Không có agent mồ côi trong `agents/agent-registry.md`.
- [ ] Registry map được Agent ID sang Codex `name` và TOML file.
- [ ] Workflow Orchestrator có prompt invocation yêu cầu spawn song song khi an toàn.
- [ ] Không dùng recursive subagents nếu `max_depth = 1`.
- [ ] Không phụ thuộc vào file ngoài `rule-agent-codex.md` để hiểu Codex schema.
