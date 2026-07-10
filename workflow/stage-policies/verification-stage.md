# Verification Stage Policy

## Flow
```text
W01 -> A05 Verification Worker -> R02 Risk Reviewer -> W01
```

## Knowledge Impact
A05 runs `knowledge-impact-detector` after stable implementation and tests. If update is required:

```text
W01 -> A01 Knowledge Maintainer -> R01 Knowledge Review -> W01 -> R02 Final Gate
```

## Rules
- A05 may update verification and approved documentation artifacts.
- A05 must not change product code.
- Final gate can pass only when knowledge status is `CLEAN` or knowledge update is not required.
