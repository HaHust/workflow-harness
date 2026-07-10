# Parallel Policy

Allowed only when W01 proves non-overlapping inputs, outputs, and locks.

Safe examples:
- Independent A01 knowledge analysis slices.
- A02 isolated architecture proposals.
- R01/R02 reviewing independent artifacts.
- A04 test matrix work for distinct modules and test files.

Forbidden examples:
- Two A03 runs on the same module.
- A03 and A04 while source code is still unstable.
- A03 and A05 on the same diff.
- R02 final gate before upstream reviewers pass.
