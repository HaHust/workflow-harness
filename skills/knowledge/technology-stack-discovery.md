# Technology Stack Discovery

## Purpose
Inventory the technical stack and produce the skill matrix that constrains implementation and integration work.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Bootstrap, dependency/infrastructure changes, or explicit stack refresh.

## Preconditions
The version 2 bundle lists this file and build/config/infrastructure scope.

## Inputs
- Build descriptors, dependency locks, configuration, source imports, Docker/Kubernetes, CI/CD, and tests.
- Existing `knowledge/technology-stack.md` and `knowledge/skill-matrix.md`.

## Must Analyze
- Frameworks, runtime, build and test tooling.
- Redis, Kafka, relational/NoSQL databases, Elastic, RabbitMQ, Redisson, reporting, schedulers, mapping/codegen, security/auth, containers, orchestration, API documentation, Testcontainers, and load-test tools when present.

## Procedure
1. Confirm skill load and record this file.
2. Correlate declared dependencies with actual source/config usage.
3. Record version, location, purpose, operational notes, and confidence.
4. Mark declared-but-unused and used-but-undeclared technology as risks.

## Outputs
- `knowledge/technology-stack.md` with runtime/framework/build/infrastructure details.
- `knowledge/skill-matrix.md` table: Skill, Used, Location, Purpose, Version, Notes.

## Permission Requirement
Read build/source/config/tests/knowledge; write knowledge/run artifacts only; no network by default.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Usage claims cite both declarations and usage when available.
- Versions are evidence-backed, not guessed.
- Integration/infrastructure skills required by development are explicit.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`.
