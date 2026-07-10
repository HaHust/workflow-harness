## Testing Layer V3

### A04 Test Worker

A04 owns test strategy, test implementation, execution, and coverage analysis. It replaces individual positive, negative, integration, contract, security, performance, coverage, and runner agents by using testing skills.

If tests fail and owner is unclear, W01 dispatches F01 Failure Analyzer. A04 does not route itself to A03 or A02.

Primary review: R01 `TEST_QUALITY` or `TEST_COVERAGE`.
Risk review: R02 for contract, security, or performance risk.

### F01 Failure Analyzer

F01 analyzes root cause and returns owner routing to W01. It never fixes code.
