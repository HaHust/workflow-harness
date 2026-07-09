# VII. Global Rules For All Agents

Tất cả agents phải tuân thủ các rule sau.

## 1. Read Before Write

Trước khi sửa hoặc sinh code, agent phải đọc:

- Requirement
- Existing knowledge
- Similar code
- Convention
- Architecture

## 2. Smallest Safe Change

Chỉ thay đổi phần cần thiết để hoàn thành requirement.

## 3. No Hidden Side Effects

Không thay đổi behavior ngoài phạm vi requirement.

## 4. Explain Assumption

Nếu phải giả định, ghi vào `assumptions.md`.

## 5. Ask When Blocked

Nếu thiếu business rule quan trọng, ghi vào `questions.md` và đánh dấu `BLOCKED` trong `execution-state.md`.

## 6. Reviewer Gate

Không chuyển sang layer tiếp theo nếu reviewer tương ứng `REJECT`.

## 7. Test Before Verify

Không chạy Verify Layer nếu test chưa pass hoặc chưa có lý do rõ ràng vì sao test không chạy được.

## 8. Update Knowledge

Sau mỗi feature, kiểm tra có cần cập nhật knowledge không. Nếu có, chạy Incremental Scanner.

## 9. Traceability

Mọi quyết định quan trọng phải trace được tới:

- Requirement
- Code hiện có
- Convention
- Architecture
- Decision file
- Reviewer note

## 10. Backend Enterprise Safety

Đặc biệt chú ý:

- Transaction
- Permission
- Data consistency
- Database migration
- Backward compatibility
- Logging sensitive data
- Retry/idempotency
- Performance query
- Integration timeout

## 11. Agent Registry Required

Mọi agent sinh ra phải xuất hiện trong `agents/agent-registry.md` với caller, trigger, output, reviewer, handoff và stop condition.

## 12. Handoff Artifact Required

Không agent nào được coi là hoàn thành nếu chưa tạo output và handoff entry đúng format trong `handoff-log.md`.

## 13. Permission Least Privilege

Agent chỉ được đọc, ghi và chạy lệnh trong phạm vi đã khai báo. Nếu cần vượt quyền, phải dừng và báo Workflow Orchestrator.

## 14. Parallel Safety

Agent chỉ được chạy song song khi Harness Runtime xác nhận không conflict write scope, lock và dependency.

## 15. Debate Is Bounded

Debate phải có max round, evidence, decision file và stop condition. Mặc định tối đa 3 vòng.

## 16. Stop And Report

Khi vượt max iteration, thiếu business input, conflict quyền hoặc debate không kết luận, agent phải đánh dấu `BLOCKED`, tạo `blocked-report.md` và yêu cầu user quyết định.

---

