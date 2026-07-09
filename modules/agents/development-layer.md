# III. Development Layer

Development Layer tạo hoặc sửa code theo solution đã được duyệt.

---

## D01. Designer

### Responsibility
Thiết kế và sinh skeleton cho API/database layer.

### Must Generate Or Update
- Entity
- Repository
- DTO
- Request/response model
- Controller
- Validation annotation
- Swagger/OpenAPI annotation
- Mapper interface nếu codebase dùng

### Inputs
- Solution design
- Convention
- Architecture
- Similar code

### Outputs
- Code changes
- `execution-workspace/<task>/design-implementation.md`

### Do Not
- Không viết business logic phức tạp trong controller
- Không bypass service layer
- Không tạo database migration nguy hiểm nếu chưa có review

---

## D02. API Reviewer

### Responsibility
Review API và DB design/code do Designer tạo.

### Must Review
- API naming
- DTO structure
- Validation
- Swagger
- Entity mapping
- Repository query
- Migration safety
- Backward compatibility

### Outputs
- `execution-workspace/<task>/api-review.md`

---

## D03. Business Logic Developer

### Responsibility
Viết business/domain logic.

### Must Implement
- Service method
- Business rule
- Transaction boundary
- Domain logic
- Event publishing nếu cần
- Exception handling
- Status transition
- Idempotency nếu cần

### Inputs
- Requirement analysis
- Solution design
- Business rules
- Convention
- Similar code

### Outputs
- Code changes
- `execution-workspace/<task>/business-implementation.md`

### Do Not
- Không viết query phức tạp nếu Repository đã có trách nhiệm đó
- Không swallow exception
- Không hardcode magic value nếu codebase có constant/enum

---

## D04. Business Reviewer

### Responsibility
Review business logic.

### Must Review
- Rule đúng requirement không
- Exception đúng convention không
- Transaction đúng không
- Boundary condition đủ không
- Có side effect ngoài ý muốn không
- Có duplicate logic không

### Outputs
- `execution-workspace/<task>/business-review.md`

---

## D05. Integration Developer

### Responsibility
Ghép các phần API, DB, message, cache và external service.

### Must Integrate
- Controller -> Service
- Service -> Repository
- Service -> Kafka/RabbitMQ nếu có
- Service -> Redis/Cache nếu có
- Service -> Feign/external API nếu có
- Config binding nếu cần

### Outputs
- Code changes
- `execution-workspace/<task>/integration-implementation.md`

### Do Not
- Không tạo integration mới nếu không có trong solution design
- Không hardcode endpoint/credential
- Không bỏ qua timeout/retry/error handling

---

## D06. Integration Reviewer

### Responsibility
Review integration code.

### Must Review
- Wiring đúng chưa
- Bean/config đúng chưa
- Error handling đủ chưa
- Timeout/retry/cache rule đúng chưa
- Có ảnh hưởng transaction không
- Có ảnh hưởng performance không

### Outputs
- `execution-workspace/<task>/integration-review.md`

---

## D07. Refactor Agent

### Responsibility
Refactor code sau khi feature chạy được nhưng chưa sạch.

### Must Refactor
- Duplicate code
- Naming
- Method length
- Class responsibility
- Common utility usage
- Mapper cleanup
- Test readability

### Inputs
- Code changes
- Review notes
- Convention

### Outputs
- Code changes
- `execution-workspace/<task>/refactor-log.md`

### Do Not
- Không refactor ngoài phạm vi task nếu không cần
- Không thay đổi behavior khi refactor
- Không xóa test để pass build

---

## D08. Refactor Reviewer

### Responsibility
Review refactor.

### Must Review
- Behavior có giữ nguyên không
- Code có dễ đọc hơn không
- Có vi phạm convention không
- Có tạo bug mới không

### Outputs
- `execution-workspace/<task>/refactor-review.md`

---

## D09. Development Orchestrator

### Responsibility
Điều phối Development Layer.

### Process
1. Đọc planning package
2. Chạy Designer
3. Chạy API Reviewer
4. Chạy Business Logic Developer
5. Chạy Business Reviewer
6. Chạy Integration Developer
7. Chạy Integration Reviewer
8. Chạy Refactor Agent nếu cần
9. Chạy Refactor Reviewer nếu có refactor
10. Cập nhật `execution-state.md`
11. Bàn giao cho Testing Orchestrator

### Outputs
- Code changes hoàn chỉnh
- Development reports

---

