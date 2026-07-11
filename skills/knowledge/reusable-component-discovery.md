# Reusable Component Discovery

## Purpose
Index components that future work should reuse instead of duplicating.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Bootstrap, shared-component changes, or refresh of relevant modules.

## Preconditions
The version 2 bundle lists this file and shared/component source scope.

## Inputs
- Utilities, base classes, shared modules, helpers, templates, abstract services, validators, exceptions, response wrappers, and usage sites.
- Existing `knowledge/component-index.md`.

## Must Analyze
- Component name/location, purpose, API or usage pattern, example callers, ownership, limitations, and compatibility risks.

## Procedure
1. Confirm skill load and record this file.
2. Find components with multiple or intended reuse sites.
3. Verify actual usage and avoid promoting accidental helpers as stable extension points.
4. Document how to use each component and when not to use it.

## Outputs
- `knowledge/component-index.md` with component, location, purpose, usage, examples, limitations, ownership, and freshness metadata.

## Permission Requirement
Read source/tests/knowledge; write knowledge/run artifacts only; no network.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Every component has concrete source and usage evidence.
- Limitations and ownership are explicit.
- Duplicated or unsafe components are marked as risks.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`.
