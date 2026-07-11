# Similar Code Search

## Purpose
Find existing features, flows, validation, persistence, integrations, and tests that should constrain the current plan.

## Allowed Agents
A02 Planning Worker for normal tasks; A01 only when indexing reusable precedents during bootstrap.

## Trigger
Planning work where a comparable implementation may exist and the version 2 bundle selects this file.

## Preconditions
- Requirement and task scope are available.
- Knowledge context or targeted source scope is available.

## Inputs
- Current requirement and acceptance criteria draft.
- `knowledge/api-index.md`, `business-flow.md`, `business-rule.md`, `patterns.md`, and `component-index.md` when relevant.
- Relevant source and tests.

## Must Analyze
- Similar APIs, flows, validations, persistence logic, integrations, error handling, and tests.
- Similarity, meaningful differences, reusable components/patterns, and known defects in candidate examples.

## Procedure
1. Confirm skill load and record this file.
2. Search knowledge indexes before targeted source/tests.
3. Rank candidates by behavioral and architectural similarity.
4. Record reusable decisions and differences that prevent blind copying.
5. Do not implement product code.

## Outputs
- `execution-workspace/<task>/similar-code.md` or a planning-package section with candidate feature, reasons, files, reusable pattern, differences, and warnings.

## Permission Requirement
Read relevant source/tests/knowledge; write planning/run artifacts only; read-only commands; no network.

## Write Impact
Workspace: YES; Product/Test/Knowledge writes: NO in normal task flow.

## Validation
- Candidates cite concrete files.
- Similarity and differences are both documented.
- Targeted search is preferred over unnecessary full scans.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `PLANNING_QUALITY`.
