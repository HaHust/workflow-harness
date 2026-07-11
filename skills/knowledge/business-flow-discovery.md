# Business Flow Discovery

## Purpose
Derive evidence-backed business flows and state transitions from current code and tests.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Bootstrap, business-flow changes, or refresh of affected features.

## Preconditions
The version 2 bundle lists this file and relevant feature scope.

## Inputs
- Controllers/endpoints, services/use cases, entities, events, integrations, tests, and user-approved requirements.
- Existing `knowledge/business-flow.md`.

## Must Analyze
- Main use cases, actors/systems, process steps, state transitions, approvals, accounting/payment where present, events, failures, rollback, and side effects.

## Procedure
1. Confirm skill load and record this file.
2. Trace each flow from trigger through service/persistence/integration outcomes.
3. Identify state changes, validations, emitted events, external calls, and failure/rollback paths.
4. Separate observed behavior from unresolved business questions.

## Outputs
- `knowledge/business-flow.md` with flow name, trigger, actors, ordered steps, state changes, APIs/services/entities, failure cases, source references, and freshness metadata.

## Permission Requirement
Read source/tests/requirements/knowledge; write knowledge/run artifacts only; no network.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Each step traces to code, tests, or an explicit user requirement.
- Side effects and failure paths are included.
- No business rule is invented.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `CONFLICTING_RULE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`.
