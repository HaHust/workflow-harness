## 6A. V3 Invocation, Handoff, And Review Matrix

### Stage Matrix

| Stage | Worker | Primary Reviewer | Additional Reviewer | Return |
| --- | --- | --- | --- | --- |
| KNOWLEDGE_BOOTSTRAP_OR_UPDATE | A01 | R01 `KNOWLEDGE_QUALITY` | R02 `ARCHITECTURE_GATE` if architecture changed | W01 |
| PLANNING | A02 | R01 `PLANNING_QUALITY` | R02 for API/DB/security/performance/architecture risk | W01 |
| DEVELOPMENT | A03 | R01 `CODE_CORRECTNESS` | R02 for high-risk diff | W01 |
| TESTING | A04 | R01 `TEST_QUALITY` or `TEST_COVERAGE` | R02 for contract/security/performance risk | W01 |
| VERIFY | A05 | R02 `FINAL_GATE` or specific risk gate | R01 `DOCUMENTATION_QUALITY` for docs-only | W01 |
| FAILURE | F01 | W01 validates routing | R02 if root cause is high-risk | W01 |
| WORKFLOW_MAINTENANCE | M01 | M02 | R02 `WORKFLOW_EVOLUTION_GATE` if permissions/risk policy change | W01 |

### Repair Loop

```text
Worker -> Reviewer REJECT -> W01 increments iteration -> same Worker fixes -> Reviewer reviews again
```

`MAX_WORKER_REVIEW_ITERATIONS = 2`. After that W01 calls F01 or marks BLOCKED.

### Workflow Profiles

| Profile | Flow |
| --- | --- |
| FULL_FEATURE | readiness/context -> A02 -> A03 -> A04 -> A05 -> knowledge impact/update -> R02 |
| STANDARD_BUGFIX | readiness/context -> lightweight A02 -> A03 -> A04 -> A05 |
| HOTFIX | A02 triage -> A03 -> focused A04 -> R02 release gate |
| REFACTOR | A01 impact if needed -> A02 -> A03 -> A04 regression -> A05 |
| TEST_ONLY | A02 test scope -> A04 -> R01 |
| DOCS_ONLY | readiness/context -> A05 documentation -> R01 |
| KNOWLEDGE_REFRESH | A01 -> R01 |
| WORKFLOW_MAINTENANCE | M01 -> M02 -> W01 |

### Root Cause Routing

| Root Cause | W01 Route |
| --- | --- |
| Requirement missing/wrong | A02 |
| Solution design wrong | A02 |
| Product code wrong | A03 |
| Test code wrong | A04 |
| Knowledge stale | A01 |
| Verification/doc/release artifact wrong | A05 |
| Security/release policy unclear | BLOCKED or user |
| Infrastructure outside authority | BLOCKED |
