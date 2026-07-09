## Platform Adapter: Claude Code Custom Subagents

Khi target platform là **Claude Code**, hãy sinh hệ thống agent ở dạng có thể dùng trực tiếp với Claude Code custom subagents.

Rule nền tảng lấy từ tài liệu chính thức Claude Code Subagents, Settings, Agent SDK và parallel agents. Prompt đầu ra phải tự chứa đủ rule tạo agent Claude Code bên dưới; không được chỉ nói "hãy đọc tài liệu Claude".

### Claude Code Subagent Behavior

- Claude Code custom subagents là **Markdown files có YAML frontmatter**.
- Subagent dùng context riêng và trả summary/result về main conversation.
- Dùng subagent khi task phụ tạo nhiều output nhiễu như search results, logs, file reads, test output hoặc analysis mà main conversation không cần giữ nguyên văn.
- Không dùng subagent cho task cần trao đổi qua lại liên tục, quick targeted change, hoặc nhiều phase cần share context dày đặc trong main thread.
- Claude Code có thể delegate theo `description`, theo natural language request, theo `@` mention, hoặc khi chạy session với `--agent`.
- Subagents có thể chạy foreground hoặc background. Background giúp parallel work nhưng permission prompt vẫn phải surface về main session.
- Không coi subagent là reviewer gate thay thế. Reviewer/gate trong workflow này vẫn phải tạo artifact, verdict và handoff đúng contract.

### Claude Code Custom Agent Output Required

Ngoài folder `agents/` và các artifact chung trong prompt này, khi target là Claude Code, bắt buộc sinh thêm cấu trúc cài đặt Claude:

```text
.claude/
  agents/
    <agent-name>.md
```

Luật:

- Mỗi custom subagent là **một file Markdown độc lập** trong `.claude/agents/` cho project-scoped agents.
- Chỉ dùng `~/.claude/agents/` nếu user yêu cầu personal/global agents.
- Không đặt TOML/YAML thuần vào `.claude/agents/`; file agent Claude phải là `.md` có YAML frontmatter.
- Claude Code scan `.claude/agents/` và `~/.claude/agents/` recursively. Subfolder không quyết định identity; identity lấy từ frontmatter `name`.
- `name` phải unique trong cùng scope. Nếu có trùng tên trong cùng scope, chỉ một definition được load.
- `agents/agent-registry.md` phải map được:
  - Agent ID trong workflow.
  - Claude subagent `name`.
  - File `.claude/agents/<agent-name>.md`.
  - Caller.
  - Reviewer/gate.
  - Handoff.
  - Permission/write scope.

### Claude Subagent File Schema

Mỗi `.claude/agents/*.md` bắt buộc có YAML frontmatter và Markdown body:

```md
---
name: <lowercase-hyphen-agent-name>
description: <when Claude should delegate to this subagent>
tools: Read, Grep, Glob
model: inherit
effort: medium
permissionMode: default
---

# <Agent Name>

<full system prompt for the subagent>
```

Required frontmatter:

| Field | Required | Rule |
|---|---:|---|
| `name` | Yes | Unique identifier, use lowercase letters and hyphens. Filename does not have to match but should match for maintainability. |
| `description` | Yes | Specific delegation trigger. Claude uses this to decide when to delegate. |

Supported optional frontmatter:

| Field | Use |
|---|---|
| `tools` | Tool allowlist. If omitted, subagent inherits all available tools, so prefer explicit least-privilege lists. |
| `disallowedTools` | Denylist removed from inherited/specified tools. Useful for blocking `Write`, `Edit`, or MCP tools. |
| `model` | `inherit`, `sonnet`, `opus`, `haiku`, `fable`, or a valid full model ID. Default is `inherit`. |
| `permissionMode` | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`, or `manual` alias. |
| `maxTurns` | Maximum agentic turns before subagent stops. Use for bounded review/debate/triage. |
| `skills` | Skills to preload into the subagent context. Use only when the agent needs that skill content at startup. |
| `mcpServers` | MCP servers scoped to this subagent, as existing server names or inline server definitions. |
| `hooks` | Lifecycle hooks scoped to this subagent. |
| `memory` | Persistent memory scope: `user`, `project`, or `local`. |
| `background` | Set `true` to always run in background. Use only when workflow can proceed while it runs. |
| `effort` | `low`, `medium`, `high`, `xhigh`, or `max`, depending on model support. |
| `isolation` | Set `worktree` to run Bash/PowerShell in a temporary git worktree. Use for parallel writers only with a merge strategy. |
| `color` | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`. |
| `initialPrompt` | Auto-submitted first user turn when the agent runs as main session via `--agent` or `agent` setting. |

The Markdown body becomes the subagent system prompt. It must contain the full behavior definition from the shared agent spec:

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

### Naming Rules

- Use lowercase hyphen names in Claude frontmatter, e.g. `requirement-analyst`, `security-reviewer`, `workflow-orchestrator`.
- Avoid spaces, uppercase and underscores in `name`.
- Filename should match `name`, e.g. `.claude/agents/requirement-analyst.md`.
- `agents/agent-registry.md` may keep existing Agent ID like `P01`, but must include Claude `name` and Claude file path.
- Do not rely on subfolder path for identity.

### Tool And Permission Rules

Claude subagents inherit available tools if `tools` is omitted, so every generated agent should declare explicit `tools` or `disallowedTools`.

Recommended mappings:

| Agent type | Claude fields |
|---|---|
| Read-only scanner/reviewer | `tools: Read, Grep, Glob, Bash`; add `disallowedTools: Write, Edit`; `permissionMode: plan` or `default` |
| Planner/architect | `tools: Read, Grep, Glob`; `permissionMode: plan` |
| Code/test writer | `tools: Read, Grep, Glob, Edit, Write, Bash`; `permissionMode: default` or `acceptEdits` only if user approves |
| Test runner | `tools: Read, Grep, Glob, Bash`; `permissionMode: default` |
| Workflow orchestrator | `tools: Read, Grep, Glob, Agent`; add `Agent(<allowed-agent-name>)` only when running as main session with `--agent` |
| MCP/browser/database specialist | Add scoped `mcpServers` and the minimum built-in tools needed |

Rules:

- Do not use `bypassPermissions` unless user explicitly requests it and reviewer approves.
- Do not use `dontAsk` for writer agents because it can auto-deny required prompts and create false failures.
- Use `plan` for read-only planning/exploration where possible.
- `acceptEdits` may auto-accept edits in allowed paths; use only for trusted writer agents with narrow write scope.
- If a subagent must spawn nested subagents, include `Agent` in `tools`; otherwise omit `Agent`.
- In a subagent definition, `Agent(worker, reviewer)` type lists are ignored for nested spawns. The allowlist syntax is only meaningful when the agent runs as main thread with `claude --agent`.
- To prevent a subagent from spawning others, omit `Agent` from `tools` or add `Agent` to `disallowedTools`.

### Model And Effort Rules

Claude `model` field:

- Prefer `model: inherit` unless the user explicitly wants a model policy.
- Use aliases only when needed: `sonnet`, `opus`, `haiku`, `fable`.
- Do not invent full model IDs. If not certain, use `inherit`.
- For cost-sensitive broad scans, `haiku` or `sonnet` may be appropriate if user allows.
- For architecture, security, failure analysis and release gates, prefer `inherit` or stronger model policy rather than forcing a weaker model.

Claude `effort` field:

```text
low | medium | high | xhigh | max
```

Map from shared prompt:

| Prompt chung | Claude frontmatter |
|---|---|
| LOW | `low` |
| MEDIUM | `medium` |
| HIGH | `high` |
| HIGHEST | `max` if supported, otherwise `xhigh` |

Rule bắt buộc khi sinh Claude agents:

- Planning agents, bug finding agents, failure analysis agents, test case generation agents và workflow/agent optimization agents phải dùng `effort: max` nếu model hỗ trợ, fallback `effort: xhigh`.
- Agent implementation, integration, refactor và agent có nhiều bước suy luận mặc định dùng `xhigh` hoặc `max` theo risk.
- Reviewer thông thường có thể dùng `effort: low`.
- Security Reviewer, Architecture Reviewer, Chief Architect, Release Manager và Final Reviewer không được hạ dưới `medium`; dùng `high`, `xhigh` hoặc `max` nếu risk cao.
- Không thêm frontmatter `thinking` hoặc `extendedThinking`; Claude Code subagents inherit extended thinking config từ main session, không có per-subagent thinking field riêng.

### Isolation, Parallelism And Worktrees

- Read-only subagents có thể chạy song song nếu output artifact khác nhau.
- Writer subagents chỉ chạy song song khi Harness Runtime xác nhận không conflict write scope, lock, module, API contract hoặc database object.
- Với parallel writer agents, cân nhắc `isolation: worktree` để giảm collision, nhưng chỉ dùng khi workflow có strategy rõ để merge hoặc port changes về main checkout.
- Nếu không có merge strategy, writer agents phải chạy tuần tự dù Claude hỗ trợ background/parallel.
- Barrier agents như Test Runner, Knowledge Indexer, Final Reviewer không chạy song song với upstream writer.
- Agent teams là experimental và disabled by default; không dùng agent teams trừ khi user yêu cầu rõ và bật `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`.

### Invocation Rules For Claude Code

Workflow Orchestrator phải mô tả cách invoke Claude subagents rõ ràng.

Natural language invocation:

```text
Use the <agent-name> subagent to <task>. Return only the required artifact summary and cite files read.
```

Guaranteed one-task invocation with @-mention:

```text
@agent-<agent-name> <task>. Produce <artifact> and handoff verdict.
```

Session-wide agent mode:

```bash
claude --agent <agent-name>
```

Parallel group instruction:

```text
Run these Claude Code subagents in parallel/background where safe, wait for all required results, then consolidate artifacts:
- @agent-<agent-name>: <task>, required output <artifact>
- @agent-<agent-name>: <task>, required output <artifact>
```

Sequential handoff instruction:

```text
Use the <worker-agent> subagent first. After it produces <artifact>, use the <reviewer-agent> subagent to review that artifact. Do not continue to the next layer unless the reviewer returns PASS or PASS_WITH_NOTES.
```

Rules:

- Reviewer only runs after the corresponding worker artifact exists.
- If `@agent-<name>` is not available in the current Claude Code UI, use natural language with exact subagent `name`.
- If newly created `.claude/agents/` directory is not detected, restart Claude Code before invoking.

### MCP, Skills, Hooks And Memory

- Use `mcpServers` only when the agent truly needs external tools. Prefer scoped inline MCP definitions to avoid loading tools into the main conversation.
- Use `skills` only when the agent needs skill content at startup. Do not preload unrelated skills.
- If `memory` is enabled:
  - Prefer `memory: project` for shareable codebase learning.
  - Remember that memory automatically enables Read, Write and Edit for memory management.
  - Ensure write scope includes only the memory directory unless the agent is also a writer.
- Hooks can enforce deterministic safety checks such as read-only database queries or lint after edits. Keep hook commands project-local and documented.
- Plugin subagents do not support `hooks`, `mcpServers` or `permissionMode`; if those are required, generate project/user subagents instead of plugin agents.

### Claude Subagent Template For Each Agent

Mỗi custom agent Claude Code phải sinh theo template:

```md
---
name: <lowercase-hyphen-agent-name>
description: <specific trigger and responsibility; include "use proactively" only when safe>
tools: <comma-separated least-privilege tool list>
model: inherit
effort: <low|medium|high|xhigh|max>
permissionMode: <default|plan|acceptEdits>
maxTurns: <bounded integer when useful>
---

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
```

### Optional Claude Settings Output

Chỉ sinh `.claude/settings.json` khi workflow thật sự cần project-level setting.

Các use case hợp lệ:

- Set default session agent:

```json
{
  "agent": "workflow-orchestrator"
}
```

- Deny a subagent:

```json
{
  "permissions": {
    "deny": ["Agent(unsafe-agent-name)"]
  }
}
```

Không tự động set `agent` mặc định nếu user không yêu cầu. Không bật experimental agent teams nếu user không yêu cầu.

### Claude Output Checklist

Trước khi kết thúc generation cho target Claude Code, kiểm tra:

- [ ] Có `.claude/agents/*.md` cho từng runnable custom subagent.
- [ ] Mỗi file có YAML frontmatter và Markdown body.
- [ ] Mỗi frontmatter có `name` và `description`.
- [ ] `name` dùng lowercase hyphen và unique trong scope.
- [ ] `description` nêu trigger rõ để Claude biết khi nào delegate.
- [ ] Tools dùng least privilege; read-only agents không có `Write`/`Edit`.
- [ ] Writer agents có tool/write scope rõ và không dùng parallel nếu conflict.
- [ ] `effort` dùng đúng giá trị Claude: `low`, `medium`, `high`, `xhigh`, `max`.
- [ ] Planning/bug/test/failure/optimization dùng `max` hoặc fallback `xhigh`.
- [ ] Reviewer thường có thể `low`, high-risk gate không dưới `medium`.
- [ ] Không dùng `bypassPermissions` nếu chưa có approval.
- [ ] Không thêm field không tồn tại như `model_reasoning_effort` hoặc `developer_instructions` vào Claude agent files.
- [ ] Registry map được Agent ID sang Claude `name` và file `.claude/agents/*.md`.
- [ ] Workflow Orchestrator có invocation text cho parallel group và sequential reviewer gate.
- [ ] Không phụ thuộc vào agent teams experimental nếu user không yêu cầu.
