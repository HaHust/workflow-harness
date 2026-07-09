## 6A. Agent Invocation, Handoff và Review Matrix bắt buộc

AI sinh agent phải tạo workflow sao cho mọi agent dưới đây có đường gọi hợp lệ. Không được để agent chỉ xuất hiện trong folder structure nhưng không được orchestrator, failure loop, debate loop hoặc optimization loop gọi tới.

### Knowledge Layer Invocation

| Agent | Called By | Handoff To | Gate/Reviewer | Conditional Rule |
|---|---|---|---|---|
| K01 Repository Scanner | K16 Knowledge Orchestrator | K14 Knowledge Indexer | K15 Knowledge Reviewer | Chạy lần đầu hoặc khi repo structure đổi |
| K02 Incremental Scanner | W01 Workflow Orchestrator, V12 Verify Orchestrator | Agent knowledge bị ảnh hưởng, K14 | K15 | Chạy khi có git diff hoặc dirty knowledge |
| K03 Convention Analyzer | K16 | K14 | K15 | Chạy lần đầu hoặc khi convention đổi |
| K04 Architecture Discovery | K16 | K14 | K15 | Chạy lần đầu hoặc khi module/dependency đổi |
| K05 Pattern Discovery | K16 | K14 | K15 | Chạy lần đầu hoặc khi pattern đổi |
| K06 Business Flow Discovery | K16 | K14 | K15 | Chạy khi business flow liên quan task |
| K07 API Discovery | K16, K02 | K14 | K15 | Chạy khi API/controller/client đổi |
| K08 Database Discovery | K16, K02 | K14 | K15 | Chạy khi entity/repository/migration đổi |
| K09 Skill Discovery | K16 | K14 | K15 | Chạy khi dependency/infrastructure đổi |
| K10 Reusable Component Discovery | K16 | K14 | K15 | Chạy khi common/shared code đổi |
| K11 Similar Code Finder | P07 Planning Orchestrator | P03 Planner, P05 Solution Architect | P04/P06 | Chạy cho mọi feature/bugfix có code tương tự |
| K12 Business Rule Discovery | K16, P01 Requirement Analyst | P01/P05/D03 | K15/P02 | Chạy khi task chạm rule nghiệp vụ |
| K13 Decision Memory | P05, V07, W01 | K14, Final Report | V07/V10 | Chạy khi có quyết định kiến trúc/trade-off |
| K14 Knowledge Indexer | K16, K02 | K15 | K15 | Chạy sau các discovery agent |
| K15 Knowledge Reviewer | K16 | K16 hoặc agent bị reject | K16 | Chạy trước khi publish knowledge |
| K16 Knowledge Orchestrator | W01 | P07 hoặc W01 | W01 | Chạy khi knowledge thiếu/outdated |

### Planning Layer Invocation

| Agent | Called By | Handoff To | Gate/Reviewer | Conditional Rule |
|---|---|---|---|---|
| P01 Requirement Analyst | P07 | P02 | P02 | Chạy cho mọi task mới |
| P02 Requirement Reviewer | P07 | P03 hoặc P01 | P07 | Reject trả về P01 |
| P03 Planner | P07 | P04 | P04 | Chạy sau requirement pass |
| P04 Planning Reviewer | P07 | P05 hoặc P03 | P07 | Reject trả về P03 |
| P05 Solution Architect | P07 | P06 | P06 | Chạy sau planning pass |
| P06 Architecture Reviewer | P07 | D09 hoặc P05 | P07/V07 | Reject trả về P05 |
| P07 Planning Orchestrator | W01 | D09 | W01 | Chạy sau knowledge đủ |

### Development Layer Invocation

| Agent | Called By | Handoff To | Gate/Reviewer | Conditional Rule |
|---|---|---|---|---|
| D01 Designer | D09 | D02 | D02 | Chạy khi task cần API/DTO/entity/repository/skeleton |
| D02 API Reviewer | D09 | D03 hoặc D01 | D09 | Reject trả về D01 |
| D03 Business Logic Developer | D09 | D04 | D04 | Chạy khi task cần logic nghiệp vụ |
| D04 Business Reviewer | D09 | D05 hoặc D03 | D09 | Reject trả về D03 |
| D05 Integration Developer | D09 | D06 | D06 | Chạy khi cần wiring/integration/config |
| D06 Integration Reviewer | D09 | D07 hoặc T17 | D09 | Reject trả về D05 |
| D07 Refactor Agent | D09, reviewer note | D08 | D08 | Chỉ chạy nếu có duplication/cleanup cần thiết |
| D08 Refactor Reviewer | D09 | T17 hoặc D07 | D09 | Reject trả về D07 |
| D09 Development Orchestrator | W01 | T17 | W01 | Chạy sau planning pass |

### Testing Layer Invocation

| Agent | Called By | Handoff To | Gate/Reviewer | Conditional Rule |
|---|---|---|---|---|
| T01 API Test Planner | T17 | T02/T04/T06/T08/T10/T12 | T14 | Chạy cho mọi task có behavior thay đổi |
| T02 Positive Test Agent | T17 | T03 | T03 | Có thể song song với T04/T08 nếu lock an toàn |
| T03 Positive Reviewer | T17 | T14 hoặc T02 | T17 | Reject trả về T02 |
| T04 Negative Test Agent | T17 | T05 | T05 | Có thể song song với T02/T08 nếu lock an toàn |
| T05 Negative Reviewer | T17 | T14 hoặc T04 | T17 | Reject trả về T04 |
| T06 Integration Test Agent | T17 | T07 | T07 | Chạy nếu có integration/persistence/message/API flow |
| T07 Integration Test Reviewer | T17 | T14 hoặc T06 | T17 | Reject trả về T06 |
| T08 Contract Test Agent | T17 | T09 | T09 | Chạy nếu API contract bị ảnh hưởng |
| T09 Contract Reviewer | T17 | T14 hoặc T08 | T17 | Reject trả về T08 |
| T10 Performance Test Agent | T17 | T11 | T11 | Chạy nếu có query/batch/cache/performance risk |
| T11 Performance Test Reviewer | T17 | T14 hoặc T10 | T17 | Reject trả về T10 |
| T12 Security Test Agent | T17 | T13 | T13 | Chạy nếu có auth/input/security risk |
| T13 Security Test Reviewer | T17 | T14 hoặc T12 | T17 | Reject trả về T12 |
| T14 Test Coverage Reviewer | T17 | T15 hoặc test agent bị thiếu | T17 | Chạy sau test agents/reviewers |
| T15 Test Runner | T17 | V12 hoặc T16 | T17 | Chạy sau test code ổn định |
| T16 Failure Analyzer | T17, W01 | Root-cause owner agent | T17/W01 | Chạy khi build/test fail |
| T17 Testing Orchestrator | W01 | V12 hoặc root-cause owner | W01 | Chạy sau development pass |

### Verify Layer Invocation

| Agent | Called By | Handoff To | Gate/Reviewer | Conditional Rule |
|---|---|---|---|---|
| V01 Security Auditor | V12 | V02 | V02 | Chạy cho mọi task có code/security impact |
| V02 Security Reviewer | V12 | V07/V10 hoặc V01 | V12 | Reject trả về V01 hoặc owner agent |
| V03 Performance Optimizer | V12, T11, V07 | V04 | V04 | Chỉ chạy khi có evidence bottleneck |
| V04 Performance Reviewer | V12 | V07/V10 hoặc V03 | V12 | Reject trả về V03 |
| V05 Documentation Agent | V12 | V06 | V06 | Chạy khi API/behavior/ops/migration đổi |
| V06 Documentation Reviewer | V12 | V07/V10 hoặc V05 | V12 | Reject trả về V05 |
| V07 Chief Architect | V12 | V10 hoặc P07/D09 | V10 | Có quyền reject về Planning/Development |
| V08 QA Lead | V12 | V10 hoặc T17 | V10 | Chạy trước final review |
| V09 Release Manager | V12 | V10 hoặc owner agent | V10 | Chạy nếu deploy/config/migration liên quan |
| V10 Final Reviewer | V12 | W01 hoặc owner agent | W01 | Gate cuối trước DONE |
| V11 Consensus Agent | W01, P07, V12, debate trigger | Reviewer/orchestrator liên quan | W01/V12 | Chạy khi có bất đồng hoặc nhiều phương án |
| V12 Verify Orchestrator | W01 | W01 | W01 | Chạy sau testing pass |

### Workflow Layer Invocation

| Agent/Runtime | Called By | Handoff To | Gate/Reviewer | Conditional Rule |
|---|---|---|---|---|
| Workflow Harness Runtime | User/Runtime entrypoint | W01 và sub-orchestrators | W01 | Luôn active để dispatch, lock, log, stop |
| W01 Workflow Orchestrator | User/Task entrypoint | K16/P07/D09/T17/V12/W02/W03 | V10 hoặc user | Chạy cho mọi task |
| W02 Workflow History Optimizer | W01, scheduled maintenance, postmortem | W03 | W03 | Chạy khi có workflow logs/history hoặc agent failures cần tối ưu |
| W03 Agent Evolution Reviewer | W01, W02 | W02 hoặc W01 | W01/V11 | Chạy sau mọi đề xuất sửa agent/workflow |

---

