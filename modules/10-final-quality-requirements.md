# XI. Yêu cầu chất lượng cuối cùng

Kết quả sinh ra phải đủ chi tiết để một backend engineer có thể:

- Copy từng file agent vào project
- Dùng Workflow Orchestrator cho task mới
- Duy trì knowledge codebase lâu dài
- Bảo đảm mỗi feature có execution workspace riêng
- Review được từng bước phát triển
- Trace được quyết định từ requirement đến code, test và release
- Chứng minh mọi agent đều có caller, handoff, reviewer/gate và stop condition
- Điều phối subagents qua Workflow Harness Runtime
- Chạy song song an toàn bằng lock và write scope
- Chạy debate/feedback loop có giới hạn vòng
- Dừng và báo user khi không thể tự giải quyết
- Tối ưu hệ thống agent dựa trên workflow logs/history mà không nới lỏng quyền

Không được trả lời chung chung. Không được chỉ liệt kê tên agent. Phải sinh mô tả có thể dùng trực tiếp.
