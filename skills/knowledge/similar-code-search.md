# Similar Code Search

## Purpose
Find existing code and tests that should constrain planning and implementation choices.

## Allowed Agents
A02 Planning Worker when W01 includes it in the planning skill bundle. A01 may index reusable components during knowledge bootstrap, but normal task search is owned by A02.

## Trigger
Planning tasks where existing patterns, APIs, tests, or business rules may provide a reusable precedent.

## Preconditions
- User requirement is available.
- `knowledge-context.md` or source search scope is available.

## Inputs
- Requirement and acceptance criteria draft.
- `knowledge/component-index.md`, `knowledge/patterns.md`, `knowledge/api-index.md`, and relevant source files when listed.
- Existing tests for similar behavior.

## Procedure
1. Search only likely modules and patterns first.
2. Record similar files, reusable decisions, and differences.
3. Feed evidence into planning package; do not implement code.

## Outputs
- Similar-code section in planning package or `execution-workspace/<task>/similar-code.md`.

## Permission Requirement
- Read: relevant source, tests, and knowledge files.
- Write: planning workspace artifact only.
- Execute: read-only search commands.
- Network: NO.

## Write Impact
Workspace artifact only. No product/test/knowledge writes in normal task workflow.

## Validation
- Findings cite concrete files.
- Similarity and differences are both documented.
- No broad source scan is done when targeted search is enough.

## Failure Codes
- `MISSING_INPUT`
- `INSUFFICIENT_EVIDENCE`
- `PERMISSION_DENIED`
- `CONFLICTING_RULE`
- `UNSAFE_CHANGE`
- `EXECUTION_FAILED`

## Review Mapping
R01 `PLANNING_QUALITY`.
