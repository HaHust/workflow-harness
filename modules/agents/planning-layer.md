# II. Planning Layer

Planning Layer nhận requirement mới và biến requirement thành kế hoạch phát triển rõ ràng.

---

## P01. Requirement Analyst

### Responsibility
Phân tích requirement đầu vào.

### Must Analyze
- Functional requirement
- Non-functional requirement
- Business rule
- Input/output
- Actor
- Permission
- Boundary condition
- Data impact
- Integration impact
- Backward compatibility

### Inputs
- User requirement
- Ticket/spec nếu có
- Knowledge files

### Outputs
- `execution-workspace/<task>/requirement-analysis.md`
- `execution-workspace/<task>/questions.md`
- `execution-workspace/<task>/assumptions.md`

### Output Must Include
- Requirement summary
- Functional requirements
- Non-functional requirements
- Open questions
- Assumptions
- Acceptance criteria

---

## P02. Requirement Reviewer

### Responsibility
Review requirement analysis.

### Must Review
- Thiếu requirement không
- Mâu thuẫn không
- Có assumption nguy hiểm không
- Acceptance criteria có test được không
- Có ảnh hưởng security/performance không

### Outputs
- `execution-workspace/<task>/requirement-review.md`

### Verdict
- `PASS`
- `PASS_WITH_NOTES`
- `REJECT`

---

## P03. Planner

### Responsibility
Sinh task plan từ requirement đã được review.

### Must Produce
- Epic nếu cần
- Story nếu cần
- Task list
- Subtask list
- Milestone
- Dependency
- Execution order

### Outputs
- `execution-workspace/<task>/planning.md`

### Output Must Include
| Order | Task | Agent | Input | Output | Dependency |
|---|---|---|---|---|---|

---

## P04. Planning Reviewer

### Responsibility
Review kế hoạch thực hiện.

### Must Review
- Task có đủ không
- Thứ tự có đúng không
- Có thiếu test/verify không
- Có task nào quá lớn không
- Có dependency vòng không

### Outputs
- `execution-workspace/<task>/planning-review.md`

---

## P05. Solution Architect

### Responsibility
Thiết kế solution kỹ thuật cho feature.

### Must Design
- Module impact
- Package impact
- API design
- Database design
- Service design
- Sequence flow
- Dependency
- Transaction boundary
- Error handling
- Integration approach
- Security consideration
- Performance consideration

### Inputs
- Requirement analysis
- Planning
- Knowledge files
- Similar code

### Outputs
- `execution-workspace/<task>/solution-design.md`

### Output Must Include
- Proposed design
- Sequence diagram dạng Mermaid nếu phù hợp
- Files to create/change
- Data model impact
- API impact
- Risk and trade-off

---

## P06. Architecture Reviewer

### Responsibility
Review solution architecture.

### Must Review
- Có đúng architecture hiện tại không
- Có phá dependency rule không
- Có quá phức tạp không
- Có thêm dependency không cần thiết không
- Có backward compatible không
- Có đủ security/performance consideration không

### Outputs
- `execution-workspace/<task>/architecture-review.md`

---

## P07. Planning Orchestrator

### Responsibility
Điều phối Planning Layer.

### Process
1. Tạo execution workspace nếu chưa có
2. Tạo `execution-state.md`
3. Chạy Requirement Analyst
4. Chạy Requirement Reviewer
5. Nếu pass, chạy Similar Code Finder
6. Chạy Planner
7. Chạy Planning Reviewer
8. Chạy Solution Architect
9. Chạy Architecture Reviewer
10. Cập nhật execution state
11. Bàn giao cho Development Orchestrator

### Outputs
- Planning package hoàn chỉnh trong execution workspace

---

