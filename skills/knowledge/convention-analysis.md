# Convention Analysis

## Purpose
Document the conventions actually used by the codebase so later agents follow existing style.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Bootstrap, relevant convention drift, or refresh of affected modules.

## Preconditions
The version 2 bundle lists this file and representative source/test scopes.

## Inputs
- Repository/package map.
- Representative existing features and tests from each relevant layer.
- Existing `knowledge/convention.md`.

## Must Analyze
- Naming, package, comment, annotation, logging, exception, validation, and response-wrapper style.
- Controller, DTO, mapper, service/business, repository, transaction, and test conventions.

## Procedure
1. Confirm skill load and record this file.
2. Sample multiple representative implementations; do not generalize from one file when alternatives exist.
3. Separate dominant convention, accepted variants, and known anti-patterns.
4. Cite example paths and explain when each convention applies.

## Outputs
- `knowledge/convention.md` organized by layer with do/don't guidance, examples, exceptions, risks, and freshness metadata.

## Permission Requirement
Read source/tests/knowledge; write only knowledge/run artifacts; no network.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Each convention cites representative code.
- Conflicting conventions are reported rather than silently normalized.
- Guidance is scoped by module/layer where needed.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `CONFLICTING_RULE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`.
