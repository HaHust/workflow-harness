# Business Rule Discovery

## Purpose
Extract business rules, constraints, permissions, and boundary conditions from code and tests.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Bootstrap, business-logic changes, or refresh of affected features.

## Preconditions
The version 2 bundle lists this file and relevant business source/test scope.

## Inputs
- Validators, exceptions, rule classes, services, status and permission checks, entities, and tests.
- Explicit user-approved requirements and existing `knowledge/business-rule.md`.

## Must Analyze
- Trigger conditions, validation, status, permission, amount/date/range boundaries, error behavior, side effects, and related tests.

## Procedure
1. Confirm skill load and record this file.
2. Trace each rule from trigger to enforcement and error/result behavior.
3. Cite source and tests; distinguish implemented rule from requirement-only rule.
4. Record conflicting, missing, or ambiguous rules as questions/risks.

## Outputs
- `knowledge/business-rule.md` with rule name, description, source, trigger, enforcement, error handling, related tests, confidence, and freshness metadata.

## Permission Requirement
Read source/tests/requirements/knowledge; write knowledge/run artifacts only; no network.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- No rule exists without evidence.
- Boundaries and permissions are explicit.
- Contradictory implementations are reported.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `CONFLICTING_RULE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`.
