# Testing Stage Policy

## Flow
```text
W01 -> A04 Test Worker -> R01 Quality Reviewer -> W01
```

W01 may add R02 for contract, security, or performance testing risk.

## Test Failure
If tests fail and owner is unclear:

```text
W01 -> F01 Failure Analyzer -> W01 routes to A02/A03/A04/A01/BLOCKED
```

## Exit
Testing passes when test evidence, coverage decision, and required risk gates pass.
