## 6. Chuẩn `execution-state.md`

Mỗi feature/task mới bắt buộc có một file:

```text
execution-state.md
```

File này dùng để tracking trạng thái xử lý qua toàn bộ workflow.

Template:

```md
# Execution State

## Task Info
- Type: FEATURE | BUGFIX | REFACTOR | HOTFIX | DOCS | TEST
- Name:
- Created At:
- Owner:
- Branch:
- Related Ticket:

## Current Stage
- Stage: KNOWLEDGE | PLANNING | DEVELOPMENT | TESTING | VERIFY | DONE | BLOCKED
- Current Agent:
- Status: TODO | IN_PROGRESS | PASS | PASS_WITH_NOTES | REJECT | BLOCKED

## Runtime Control
- Harness Status: IDLE | DISPATCHING | WAITING | REVIEWING | DEBATING | BLOCKED | DONE
- Current Parallel Group:
- Active Locks:
- Current Iteration:
- Max Iteration:
- Debate Active: YES | NO
- Debate ID:
- Debate Round:
- Max Debate Round: 3
- Last Stop Check:

## Requirement Summary

## Assumptions

## Questions

## Agent Timeline
| Time | Agent | Action | Status | Output |
|---|---|---|---|---|

## Handoff Timeline
| Time | From | To | Verdict | Artifact | Iteration |
|---|---|---|---|---|---|

## Debate Timeline
| Debate ID | Topic | Participants | Rounds Used | Verdict | Decision File |
|---|---|---|---|---|---|

## Parallel Execution
| Group | Agents | Shared Inputs | Write Scopes | Locks | Status |
|---|---|---|---|---|---|

## Files Changed
| File | Change Type | Reason |
|---|---|---|

## Knowledge Impact
- Need update knowledge: YES | NO
- Files to update:

## Risks

## Blockers
| Blocker | Owner Agent | Evidence | User Question | Status |
|---|---|---|---|---|

## Final Result
- Build: PASS | FAIL | NOT_RUN
- Test: PASS | FAIL | NOT_RUN
- Security: PASS | FAIL | NOT_RUN
- Performance: PASS | FAIL | NOT_RUN
- Docs: PASS | FAIL | NOT_RUN
- Knowledge Updated: YES | NO
```

---

