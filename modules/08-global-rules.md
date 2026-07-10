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
