## K01. Repository Scanner

### Responsibility
Scan toàn bộ repository và tạo bản đồ tổng quan codebase.

### Must Analyze
- Repository structure
- Module structure
- Package structure
- Dependency
- Framework
- Build tool
- Monorepo hay multi-repo
- Entry points
- Config files
- Environment files
- CI/CD files nếu có

### Inputs
- Source code repository
- `pom.xml`, `build.gradle`, `settings.gradle`, `package.json` nếu có
- Dockerfile
- Kubernetes manifest
- CI/CD config

### Outputs
- `knowledge/repository.md`

### Output Must Include
- Project summary
- Module list
- Package map
- Dependency map
- Framework list
- Build/run command nếu phát hiện được
- Risk hoặc điểm chưa rõ

### Do Not
- Không sửa code
- Không thêm dependency
- Không suy đoán business rule

---

## K02. Incremental Scanner

### Responsibility
Đọc git diff và xác định phần knowledge nào bị ảnh hưởng.

### Must Analyze
- Changed files
- Added files
- Deleted files
- Renamed files
- Impacted modules
- Impacted APIs
- Impacted database objects
- Impacted tests

### Inputs
- Git diff
- Git status
- Existing `knowledge/`

### Outputs
- `knowledge/incremental-scan.md`
- Cập nhật trạng thái dirty knowledge trong `knowledge/index.md` nếu cần

### Process
1. Đọc danh sách file thay đổi
2. Phân loại theo type: API, service, repository, entity, config, test, migration
3. Xác định knowledge files cần update
4. Trigger agent phù hợp

### Do Not
- Không scan lại toàn repo nếu chỉ cần incremental
- Không bỏ qua migration hoặc config change

---

## K03. Convention Analyzer

### Responsibility
Học convention hiện có của codebase.

### Must Analyze
- Naming convention
- Logging style
- Exception handling
- Validation style
- DTO style
- Mapper style
- Controller style
- Service/business style
- Repository style
- Package structure
- Comment style
- Annotation style
- Transaction style
- Response wrapper style

### Inputs
- Source code
- Existing features tương tự

### Outputs
- `knowledge/convention.md`

### Output Must Include
- Convention theo từng layer
- Ví dụ code tham chiếu
- Điều nên làm
- Điều không nên làm

---

## K04. Architecture Discovery

### Responsibility
Khám phá kiến trúc backend hiện tại.

### Must Analyze
- Layered architecture
- Module boundary
- Dependency direction
- Clean Architecture nếu có
- Hexagonal Architecture nếu có
- Onion Architecture nếu có
- DDD pattern nếu có
- Shared kernel/common module
- Cross-cutting concern

### Inputs
- Repository map
- Package structure
- Dependency graph

### Outputs
- `knowledge/architecture.md`

### Output Must Include
- Architecture summary
- Layer diagram dạng text
- Dependency rule
- Module ownership
- Anti-pattern đang tồn tại nếu có

---

## K05. Pattern Discovery

### Responsibility
Tìm design pattern và implementation pattern đang được dùng trong codebase.

### Must Analyze
- Strategy
- Factory
- Builder
- CQRS
- Saga
- Observer
- Chain of Responsibility
- Facade
- Template Method
- Event-driven pattern
- Specification pattern
- Mapper pattern
- Adapter pattern

### Outputs
- `knowledge/patterns.md`

### Output Must Include
- Pattern name
- Location trong code
- Mục đích sử dụng
- Khi nào nên tái sử dụng
- Khi nào không nên dùng

---

## K06. Business Flow Discovery

### Responsibility
Đọc code nghiệp vụ và sinh business flow.

### Must Analyze
- Main use cases
- Business process
- State transition
- Approval flow
- Payment/accounting flow nếu có
- Event flow
- Error/rollback flow

### Outputs
- `knowledge/business-flow.md`

### Output Example

```text
Create Loan
↓
Approve
↓
Disbursement
↓
Accounting
```

### Output Must Include
- Flow name
- Trigger
- Actors/systems involved
- Steps
- State changes
- APIs/services/entities involved
- Failure cases

---

## K07. API Discovery

### Responsibility
Tạo index toàn bộ API và integration endpoint.

### Must Analyze
- REST controllers
- SOAP clients/services
- gRPC
- GraphQL
- Feign clients
- Message consumers/producers nếu đóng vai trò endpoint

### Outputs
- `knowledge/api-index.md`

### Output Must Include
- Method
- Path
- Controller/client
- Request DTO
- Response DTO
- Validation
- Auth/permission nếu có
- Related service

---

## K08. Database Discovery

### Responsibility
Tạo bản đồ database object và persistence layer.

### Must Analyze
- Entity
- Table
- View
- Trigger
- Procedure
- Function
- Repository
- Query
- Liquibase
- Flyway
- Index
- Foreign key

### Outputs
- `knowledge/database.md`

### Output Must Include
- Entity-table mapping
- Important columns
- Relationship
- Migration history
- Query risk
- Performance note

---

## K09. Skill Discovery

### Responsibility
Tổng hợp toàn bộ stack kỹ thuật mà codebase đang sử dụng.

### Must Analyze
- Redis
- Kafka
- Oracle
- Mongo
- Elastic
- RabbitMQ
- Redisson
- Jasper
- Quartz
- MapStruct
- Lombok
- Spring Security
- OAuth
- JWT
- Docker
- Kubernetes
- OpenAPI/Swagger
- TestContainers
- k6/Gatling/JMeter nếu có

### Outputs
- `knowledge/skill-matrix.md`

### Output Must Include
| Skill | Used? | Location | Purpose | Notes |
|---|---|---|---|---|

### Why Important
Agent development phải đọc file này trước khi thêm code liên quan đến integration hoặc infrastructure.

---

## K10. Reusable Component Discovery

### Responsibility
Tìm các component có thể tái sử dụng.

### Must Analyze
- Utils
- Base class
- Shared component
- Common module
- Helper
- Template
- Abstract service
- Common validator
- Common exception
- Common response wrapper

### Outputs
- `knowledge/component-index.md`

### Output Must Include
- Component name
- Location
- Purpose
- How to use
- Example usage
- Limitation

---

## K11. Similar Code Finder

### Responsibility
Tìm feature/code tương tự với yêu cầu hiện tại.

### Must Analyze
- Similar API
- Similar business flow
- Similar validation
- Similar persistence logic
- Similar integration
- Similar tests

### Inputs
- Current requirement
- `knowledge/api-index.md`
- `knowledge/business-flow.md`
- Source code

### Outputs
- `execution-workspace/<task>/similar-code.md`

### Output Must Include
- Candidate feature
- Similarity reason
- Files to reference
- Reusable pattern
- Warning nếu code mẫu có vấn đề

---

## K12. Business Rule Discovery

### Responsibility
Trích xuất business rules từ code.

### Must Analyze
- Validator
- Exception
- Rule class
- Business logic
- Status check
- Permission check
- Boundary condition
- Amount/date/range rules

### Outputs
- `knowledge/business-rule.md`

### Output Must Include
- Rule name
- Description
- Source location
- Trigger condition
- Error handling
- Related tests nếu có

---

## K13. Decision Memory

### Responsibility
Lưu lại quyết định kiến trúc và lý do chọn giải pháp.

### Must Track
- ADR
- Architecture decision
- Convention decision
- Trade-off
- Reason for choosing solution
- Rejected alternatives

### Outputs
- `knowledge/decision.md`

### Do Not
- Không ghi quyết định không có căn cứ
- Không ghi preference cá nhân nếu không liên quan codebase

---

## K14. Knowledge Indexer

### Responsibility
Tổng hợp toàn bộ knowledge thành index dễ đọc.

### Inputs
- Toàn bộ file trong `knowledge/`

### Outputs
- `knowledge/knowledge-index.md`

### Output Must Include
- List knowledge files
- Last updated
- Owner agent
- Summary
- Dirty/clean status
- Related modules

---

## K15. Knowledge Reviewer

### Responsibility
Review chất lượng knowledge output.

### Must Review
- Đủ chưa
- Sai không
- Trùng không
- Có conflict không
- Có outdated không
- Có thiếu source reference không

### Outputs
- `knowledge/knowledge-review.md`

### Verdict
- `PASS`
- `PASS_WITH_NOTES`
- `REJECT`

---

## K16. Knowledge Orchestrator

### Responsibility
Điều phối toàn bộ Knowledge Layer.

### When To Run
- Lần đầu AI làm việc với codebase
- Sau khi có thay đổi lớn
- Khi `Incremental Scanner` đánh dấu dirty knowledge

### Process
1. Chạy Repository Scanner
2. Chạy Convention Analyzer
3. Chạy Architecture Discovery
4. Chạy Pattern Discovery
5. Chạy API/Database/Business discovery
6. Chạy Skill và Component discovery
7. Chạy Knowledge Indexer
8. Chạy Knowledge Reviewer
9. Publish knowledge

### Outputs
- Updated `knowledge/`
- `knowledge/knowledge-review.md`

---