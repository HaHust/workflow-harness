# Architecture Discovery

## Purpose
Discover current backend architecture, boundaries, and dependency rules.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Bootstrap, architecture-impacting changes, module changes, or explicit refresh.

## Preconditions
The version 2 bundle lists this file and repository/package/dependency evidence.

## Inputs
- `knowledge/repository.md` or equivalent repository map.
- Package/module structure and dependency graph.
- Entry points, shared modules, and cross-cutting components.

## Must Analyze
- Layered, clean, hexagonal, onion, DDD, or mixed architecture only when evidence supports it.
- Module boundaries, ownership, dependency direction, shared kernel/common modules, and cross-cutting concerns.
- Existing boundary violations and architecture risks.

## Procedure
1. Confirm skill load and record this file.
2. Trace dependency direction from build and source imports/calls.
3. Identify layers/modules, their responsibilities, and allowed/forbidden dependencies.
4. Produce a text diagram and cite evidence for architecture classification.

## Outputs
- `knowledge/architecture.md` with summary, text diagram, dependency rules, module ownership, integrations, anti-patterns, risks, and freshness metadata.

## Permission Requirement
Read source/build/knowledge; write only knowledge/run artifacts; no network.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Architecture labels are evidence-backed.
- Boundary and dependency claims cite concrete modules/files.
- Unknown ownership or conflicting directions are explicit.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `CONFLICTING_RULE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`; R02 `ARCHITECTURE_GATE` when material architecture knowledge changes.
