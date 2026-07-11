# Pattern Discovery

## Purpose
Index reusable design and implementation patterns already present in the codebase.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Bootstrap, pattern-affecting changes, or refresh of relevant modules.

## Preconditions
The version 2 bundle lists this file and representative source scope.

## Inputs
- Repository and architecture knowledge.
- Relevant source, tests, and existing `knowledge/patterns.md`.

## Must Analyze
- Strategy, factory, builder, CQRS, saga, observer, chain, facade, template method, event-driven, specification, mapper, and adapter patterns when present.
- Codebase-specific implementation patterns that constrain future work.

## Procedure
1. Confirm skill load and record this file.
2. Search for structural and behavioral evidence, not class-name coincidence alone.
3. Record pattern purpose, location, collaborators, reuse conditions, and limitations.
4. Mark suspicious or inconsistent usages as risks rather than recommended patterns.

## Outputs
- `knowledge/patterns.md` with pattern name, source locations, purpose, reuse guidance, non-use guidance, examples, risks, and freshness metadata.

## Permission Requirement
Read source/tests/knowledge; write knowledge/run artifacts only; no network.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Every pattern has concrete source evidence.
- Pattern intent and limitations are documented.
- Anti-patterns are not presented as conventions.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`.
