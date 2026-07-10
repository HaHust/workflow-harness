# Review Policy

- W01 supplies every review profile explicitly.
- R01 handles quality profiles.
- R02 handles risk and final-gate profiles.
- Reviewer cannot switch profile without W01 approval.
- `PASS_WITH_NOTES` is allowed only when notes are non-blocking and downstream-safe.
- `REJECT` returns to W01, then W01 routes back to the same worker with required fixes.
