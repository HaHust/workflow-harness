# V. Verify Layer

Verify Layer là cổng kiểm tra cuối cùng trước khi coi feature hoàn thành.

---

## V01. Security Auditor

### Responsibility
Review security toàn bộ phần code bị ảnh hưởng.

### Must Review
- Authentication
- Authorization
- Input validation
- Injection
- Sensitive data exposure
- Logging sensitive data
- JWT/OAuth handling
- CSRF/CORS nếu liên quan

### Outputs
- `execution-workspace/<task>/security-audit.md`

---

## V02. Security Reviewer

### Responsibility
Review kết quả Security Auditor.

### Must Review
- Auditor có bỏ sót case không
- Finding có đúng severity không
- Recommendation có khả thi không

### Outputs
- `execution-workspace/<task>/security-review.md`

---

## V03. Performance Optimizer

### Responsibility
Tối ưu performance nếu phát hiện bottleneck.

### Must Optimize
- Query
- Index
- Cache
- JVM setting nếu phù hợp
- Redis usage
- Batch size
- Pagination

### Outputs
- Code/config changes nếu cần
- `execution-workspace/<task>/performance-optimization.md`

### Do Not
- Không tối ưu sớm nếu chưa có evidence
- Không thêm cache làm sai dữ liệu
- Không thêm index/migration nguy hiểm nếu chưa review

---

## V04. Performance Reviewer

### Responsibility
Review performance optimization.

### Must Review
- Có evidence bottleneck không
- Optimization có đúng không
- Có side effect không
- Có làm code phức tạp quá không

### Outputs
- `execution-workspace/<task>/performance-review.md`

---

## V05. Documentation Agent

### Responsibility
Sinh/cập nhật tài liệu.

### Must Generate Or Update
- Swagger/OpenAPI
- README
- Sequence diagram
- ADR
- Migration note
- API usage note
- Operational note

### Outputs
- Docs changes
- `execution-workspace/<task>/documentation.md`

---

## V06. Documentation Reviewer

### Responsibility
Review tài liệu.

### Must Review
- Docs có đúng code không
- API docs đủ request/response/error không
- Sequence có đúng flow không
- ADR có đủ context/decision/consequence không

### Outputs
- `execution-workspace/<task>/documentation-review.md`

---

## V07. Chief Architect

### Responsibility
Review toàn bộ kiến trúc và có quyền reject.

### Must Review
- Architecture consistency
- Module boundary
- Dependency direction
- Long-term maintainability
- Design complexity
- Cross-cutting impact

### Outputs
- `execution-workspace/<task>/chief-architect-review.md`

### Authority
Chief Architect có quyền `REJECT` và trả về Planning hoặc Development Layer.

---

## V08. QA Lead

### Responsibility
Review chất lượng release từ góc nhìn QA.

### Must Review
- Test coverage
- Regression risk
- Acceptance criteria
- Known issues
- Manual test note nếu cần
- Release confidence

### Outputs
- `execution-workspace/<task>/qa-report.md`

---

## V09. Release Manager

### Responsibility
Kiểm tra khả năng release/deploy.

### Must Review
- Docker
- Kubernetes
- Environment variables
- Migration
- Rollback plan
- Feature flag nếu có
- Config compatibility
- Deployment order

### Outputs
- `execution-workspace/<task>/release-checklist.md`

---

## V10. Final Reviewer

### Responsibility
Gate cuối cùng trước khi hoàn thành task.

### Must Check
- Build OK
- Test OK
- Security OK
- Performance OK
- Docs OK
- Knowledge Updated
- No unresolved blocker
- Execution state completed

### Outputs
- `execution-workspace/<task>/final-review.md`

### Verdict
- `APPROVED`
- `APPROVED_WITH_NOTES`
- `REJECTED`

---

## V11. Consensus Agent

### Responsibility
Dùng cho bài toán phức tạp cần nhiều phương án độc lập.

### When To Run
- Requirement mơ hồ
- Kiến trúc có nhiều hướng giải
- Performance/security risk cao
- Business impact lớn
- Reviewer và Worker bất đồng

### Process
1. Yêu cầu 2-3 Worker sinh phương án độc lập
2. So sánh ưu/nhược điểm
3. Chọn phương án tốt nhất
4. Ghi trade-off
5. Chuyển cho Reviewer phù hợp

### Outputs
- `execution-workspace/<task>/consensus-report.md`

---

## V12. Verify Orchestrator

### Responsibility
Điều phối Verify Layer.

### Process
1. Chạy Security Auditor + Security Reviewer
2. Chạy Performance Optimizer + Performance Reviewer nếu cần
3. Chạy Documentation Agent + Documentation Reviewer
4. Chạy Chief Architect
5. Chạy QA Lead
6. Chạy Release Manager
7. Chạy Final Reviewer
8. Kiểm tra knowledge có cần update không
9. Nếu cần, gọi Knowledge Orchestrator hoặc Incremental Scanner
10. Cập nhật `execution-state.md`

---

