## 5. Chuẩn format cho mỗi file agent

Mỗi file agent phải theo format sau:
Còn tùy vào agent của các nền tảng có các tham số cần thêm.
```md
# <Agent Name>

## Role
Mô tả vai trò ngắn gọn của agent.

## Responsibility
Agent này chỉ chịu trách nhiệm về một việc duy nhất.

## When To Run
Khi nào agent được chạy.

## Inputs
Danh sách file, dữ liệu, context agent cần đọc.

## Outputs
Danh sách file hoặc artifact agent phải tạo/cập nhật.

## Model Config
- Reasoning Effort: LOW | MEDIUM | HIGH | HIGHEST
- Temperature: theo nền tảng nếu có
- Notes:

Planning, bug finding, test case generation, failure analysis và agent optimization nên dùng reasoning effort cao nhất. Review đơn giản có thể dùng low, nhưng security/architecture/release gate nên dùng ít nhất medium.

## Permissions
- Read:
- Write:
- Execute:
- Network:
- Destructive Actions:
- Secrets:
- Approval Required:

## Write Scope
- Files:
- Directories:
- Modules:
- Database objects:
- API contracts:

## Parallel Safety
- Can Run In Parallel: YES | NO | CONDITIONAL
- Safe Parallel With:
- Must Not Run In Parallel With:
- Required Locks:

## Process
Các bước xử lý chi tiết.

## Rules
Các luật bắt buộc phải tuân thủ.

## Do Not
Các việc agent tuyệt đối không được làm.

## Handoff
Agent này bàn giao kết quả cho agent nào.

## Handoff Contract
- Required artifact:
- Required verdict:
- Next agent:
- Return path on reject:

## Review Criteria
Checklist để reviewer kiểm tra.

## Debate Policy
- Join Debate When:
- Debate Role: PROPOSER | CRITIC | ARBITER | NONE
- Max Debate Rounds:

## Failure Handling
Nếu không đủ dữ liệu hoặc bị lỗi thì xử lý thế nào.

## Stop Condition
Khi nào agent phải dừng, ghi blocked report và báo user hoặc orchestrator.
```

---

