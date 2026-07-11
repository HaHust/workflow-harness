# Repository Scan

## Purpose
Create an evidence-backed map of the current codebase for `knowledge/repository.md`.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Knowledge bootstrap, explicit full refresh, or a bundle that requires repository remapping.

## Preconditions
- The version 2 skill bundle lists this concrete file and repository scope.
- Project root and permitted read scope are explicit.

## Inputs
- Source repository and file inventory.
- Build descriptors such as `pom.xml`, Gradle files, `package.json`, or equivalents.
- Docker, Kubernetes, environment, configuration, and CI/CD files when present.
- Existing `knowledge/repository.md` for refresh comparison.

## Must Analyze
- Repository, module, package, and dependency structure.
- Frameworks, build tools, monorepo or multi-repo shape, and entry points.
- Configuration, environment, container, deployment, and CI/CD surfaces.
- Build, test, and run commands only when supported by repository evidence.

## Procedure
1. Confirm this file is loaded from the bundle and record it in `Skill Files Read`.
2. Inventory the repository with read-only tools and identify build roots and entry points.
3. Map modules, packages, dependencies, configuration, and operational files.
4. Cite concrete source paths for every material claim.
5. Record unknowns and risks without inventing business rules.

## Outputs
- `knowledge/repository.md` with project summary, module list, package map, dependency map, frameworks, commands, risks, source references, and freshness metadata.

## Permission Requirement
Read repository; write only declared knowledge/run artifacts; read-only commands; no network by default.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Repository scope and source revision/fingerprint are recorded.
- Every module and entry point is traceable to source evidence.
- Missing or unsupported details are marked unknown, not inferred.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `PERMISSION_DENIED`, `EXECUTION_FAILED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`.
