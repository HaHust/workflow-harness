# Agent Dispatch Log

Schema: `booking.runtime.markdown/v1`

Records: NONE

Each dispatch record has one stable `dispatch_key` and records `BUNDLE_VALIDATED`, `DISPATCH_COMMITTED`, then exactly one terminal disposition (`CHILD_RETURNED`, `CHILD_BLOCKED`, `CHILD_INTERRUPTED`, or `DISPATCH_FAILED`) followed by `HANDOFF_RECONCILED` and `STATE_RECONCILED`.
