# Planning Stage Policy

## Flow
```text
W01 -> A02 Planning Worker -> R01 Quality Reviewer -> W01
```

W01 may add R02 after R01 for high-risk API, DB, security, performance, transaction, migration, or architecture impact.

## Required Outputs
- `planning-package/requirement-analysis.md`
- `planning-package/acceptance-criteria.md`
- `planning-package/implementation-plan.md`
- `planning-package/solution-design.md`
- `planning-package/impact-analysis.md`
- `planning-package/risks.md`

## Exit
Planning passes only when required R01/R02 profiles pass and unresolved questions do not block implementation.
