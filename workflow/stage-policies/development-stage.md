# Development Stage Policy

## Flow
```text
W01 -> A03 Implementation Worker -> R01 Quality Reviewer -> W01
```

W01 dispatches R02 after R01 when the diff touches high-risk API, migration, security, performance, transaction, release, or architecture areas.

## Rules
- A03 may only use skills and write scopes in `skill-bundle.md`.
- A03 must not update tests unless W01 explicitly assigns that scope.
- A03 must not modify shared runtime state.

## Exit
Development passes when correctness and required risk gates pass.
