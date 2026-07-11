# Run New Task

1. W01 creates `execution-workspace/<task>/`.
2. W01 runs `knowledge-readiness-check`, computes the current codebase revision/fingerprint, and compares it with the knowledge manifest.
3. If needed, W01 dispatches A01 and R01 to bootstrap or sync knowledge.
4. W01 creates `knowledge-context.md` and a version 2 profile-specific `skill-bundle.md` with concrete required skill files.
5. Each child reads its bundle and required skill files, records `Skill Files Read`, then W01 runs the selected profile through flat Worker -> Reviewer -> W01 transitions.
6. A05 detects knowledge impact after stable implementation and tests.
7. W01 updates knowledge if required.
8. R02 final gate runs when required by profile.
9. W01 writes `final-report.md` or `blocked-report.md`.
