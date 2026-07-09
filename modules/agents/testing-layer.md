# IV. Testing Layer

Testing Layer sinh test, chạy test và phân tích lỗi.

---

## T01. API Test Planner

### Responsibility
Sinh test matrix cho API/feature.

### Must Produce
- Happy path cases
- Negative cases
- Boundary cases
- Permission cases
- Contract cases
- Integration cases
- Performance/security test suggestion nếu cần

### Outputs
- `execution-workspace/<task>/test-plan.md`

---

## T02. Positive Test Agent

### Responsibility
Viết test happy path.

### Must Test
- Valid request
- Expected response
- Expected DB state
- Expected event/cache/integration nếu có

### Outputs
- Test code
- `execution-workspace/<task>/positive-test.md`

---

## T03. Positive Reviewer

### Responsibility
Review happy path tests.

### Must Review
- Test có đúng acceptance criteria không
- Assertion đủ mạnh không
- Test data rõ ràng không
- Có phụ thuộc môi trường không

### Outputs
- `execution-workspace/<task>/positive-test-review.md`

---

## T04. Negative Test Agent

### Responsibility
Viết test cho case lỗi.

### Must Test
- Validation error
- Boundary condition
- Permission denied
- Invalid state
- Not found
- Duplicate request
- Null/blank input
- Amount/date range edge cases nếu có

### Outputs
- Test code
- `execution-workspace/<task>/negative-test.md`

---

## T05. Negative Reviewer

### Responsibility
Review negative tests.

### Must Review
- Case lỗi có đủ không
- Error code/message đúng convention không
- Boundary có đủ `=`, `<`, `>`, null, empty không
- Permission test có đúng không

### Outputs
- `execution-workspace/<task>/negative-test-review.md`

---

## T06. Integration Test Agent

### Responsibility
Viết integration test.

### Must Use If Available
- Spring Boot Test
- TestContainers
- Embedded DB
- Mock server
- Kafka/RabbitMQ test support

### Outputs
- Integration test code
- `execution-workspace/<task>/integration-test.md`

---

## T07. Integration Test Reviewer

### Responsibility
Review integration tests.

### Must Review
- Test có gần production flow không
- Setup/teardown đúng không
- Có flaky không
- Có phụ thuộc dữ liệu ngoài không

### Outputs
- `execution-workspace/<task>/integration-test-review.md`

---

## T08. Contract Test Agent

### Responsibility
Viết hoặc kiểm tra contract test.

### Must Check
- OpenAPI compatibility
- Pact nếu có
- Request/response backward compatibility
- Required/optional fields
- Error response contract

### Outputs
- Contract test/code/report
- `execution-workspace/<task>/contract-test.md`

---

## T09. Contract Reviewer

### Responsibility
Review contract test.

### Must Review
- Có phá client cũ không
- Schema có thay đổi nguy hiểm không
- Required field mới có backward compatible không
- Error format có đúng convention không

### Outputs
- `execution-workspace/<task>/contract-review.md`

---

## T10. Performance Test Agent

### Responsibility
Sinh hoặc đề xuất performance test.

### Must Analyze
- Query performance
- Pagination
- Cache impact
- N+1 query
- Batch processing
- Load test bằng k6/Gatling/JMeter nếu phù hợp

### Outputs
- Performance test script/report
- `execution-workspace/<task>/performance-test.md`

---

## T11. Performance Test Reviewer

### Responsibility
Review performance test.

### Must Review
- Scenario có thực tế không
- Threshold có hợp lý không
- Có đo đúng bottleneck không
- Result có actionable không

### Outputs
- `execution-workspace/<task>/performance-test-review.md`

---

## T12. Security Test Agent

### Responsibility
Sinh security test.

### Must Test
- OWASP risk
- Authn/authz
- JWT/OAuth rule
- Injection
- Sensitive data exposure
- Mass assignment
- Input validation

### Outputs
- Security test/report
- `execution-workspace/<task>/security-test.md`

---

## T13. Security Test Reviewer

### Responsibility
Review security test.

### Must Review
- Permission case đủ chưa
- Injection case đủ chưa
- Sensitive data có bị lộ không
- Auth rule có đúng không

### Outputs
- `execution-workspace/<task>/security-test-review.md`

---

## T14. Test Coverage Reviewer

### Responsibility
Review tổng thể test coverage.

### Must Review
- Coverage
- Assertion quality
- Mock usage
- Flaky test risk
- Missing business edge cases
- Missing regression tests

### Outputs
- `execution-workspace/<task>/test-coverage-review.md`

---

## T15. Test Runner

### Responsibility
Chạy toàn bộ test liên quan.

### Must Run
- Unit test
- Integration test
- Contract test nếu có
- Build command
- Static check nếu có

### Outputs
- `execution-workspace/<task>/test-result.md`

### Output Must Include
- Command executed
- Pass/fail summary
- Failed tests
- Logs summary

---

## T16. Failure Analyzer

### Responsibility
Đọc log test/build và tìm root cause.

### Must Analyze
- Build error
- Compile error
- Unit test fail
- Integration fail
- Contract fail
- Runtime exception
- Assertion mismatch

### Outputs
- `execution-workspace/<task>/failure-analysis.md`

### Handoff Rule
Nếu lỗi thuộc:

| Root Cause | Return To |
|---|---|
| Requirement sai/thiếu | Requirement Analyst |
| Design sai | Solution Architect |
| API/DB sai | Designer |
| Business logic sai | Business Logic Developer |
| Integration sai | Integration Developer |
| Test sai | Test Agent tương ứng |
| Refactor gây lỗi | Refactor Agent |

---

## T17. Testing Orchestrator

### Responsibility
Điều phối Testing Layer.

### Process
1. Chạy API Test Planner
2. Chạy Positive Test Agent + Reviewer
3. Chạy Negative Test Agent + Reviewer
4. Chạy Integration Test Agent + Reviewer nếu cần
5. Chạy Contract Test Agent + Reviewer nếu API contract bị ảnh hưởng
6. Chạy Performance/Security Test Agent nếu có rủi ro tương ứng
7. Chạy Test Coverage Reviewer
8. Chạy Test Runner
9. Nếu fail, chạy Failure Analyzer
10. Cập nhật `execution-state.md`
11. Nếu pass, bàn giao Verify Orchestrator
12. Nếu fail, trả về đúng Worker

---

