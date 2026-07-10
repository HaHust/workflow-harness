## Verification Layer V3

### A05 Verification Worker

A05 produces verification and release-readiness evidence. It may update verification artifacts and approved documentation, but it must not change product code.

A05 also runs `knowledge-impact-detector` after implementation and tests are stable. If knowledge update is required, W01 dispatches A01 and R01 before final gate.

Primary review: R02 `FINAL_GATE` or a specific risk profile.
Docs-only review: R01 `DOCUMENTATION_QUALITY` when W01 chooses DOCS_ONLY profile.
