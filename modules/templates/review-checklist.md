# IX. Review Checklist Chung

Mỗi Reviewer nên dùng checklist chung này trước khi đưa verdict.

```md
# Review Checklist

## Scope
- [ ] Output đúng phạm vi agent
- [ ] Không làm thay trách nhiệm agent khác

## Correctness
- [ ] Đúng requirement
- [ ] Đúng business rule
- [ ] Không mâu thuẫn với knowledge

## Convention
- [ ] Đúng naming convention
- [ ] Đúng package convention
- [ ] Đúng exception/logging/validation style

## Architecture
- [ ] Đúng layer
- [ ] Không phá dependency direction
- [ ] Không tạo coupling không cần thiết

## Safety
- [ ] Không phá backward compatibility
- [ ] Không lộ sensitive data
- [ ] Không gây side effect ngoài ý muốn
- [ ] Permission scope đủ chặt
- [ ] Không có destructive action ngoài quyền

## Testability
- [ ] Có test hoặc test plan phù hợp
- [ ] Acceptance criteria có thể verify

## Handoff
- [ ] Output artifact tồn tại
- [ ] Handoff đúng next agent
- [ ] Return path khi reject rõ ràng
- [ ] Reviewer/gate tương ứng đã được xác định

## Runtime
- [ ] Agent có caller trong registry
- [ ] Agent không mồ côi
- [ ] Parallel safety rõ ràng
- [ ] Required lock rõ ràng nếu có write scope
- [ ] Stop condition rõ ràng
- [ ] Debate policy rõ ràng nếu có bất đồng

## Verdict
- Result: PASS | PASS_WITH_NOTES | REJECT
- Notes:
- Return to:
```

---

