# Knowledge Base

The Knowledge Base is long-lived codebase memory.

## Lifecycle

- Bootstrap: A01 full scan runs when no usable knowledge exists or the user requests a refresh.
- Consumption: normal workers read `knowledge-context.md` and only the listed knowledge files.
- Maintenance: after stable code and tests, A05 detects impact; W01 runs A01 incremental update only when required.

A01 does not run by default for every task.
