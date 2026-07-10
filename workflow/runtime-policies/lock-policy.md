# Lock Policy

W01 owns lock allocation and writes lock state to runtime artifacts.

Lock types:
- Source file lock.
- Test file lock.
- Documentation lock.
- Knowledge file lock.
- API contract lock.
- Database object or migration lock.
- Workflow policy/registry lock.

If a lock cannot be acquired, W01 must serialize the work or block with evidence.
