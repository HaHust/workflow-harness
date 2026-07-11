# Database Discovery

## Purpose
Map database objects, persistence code, migrations, relationships, and data risks.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Bootstrap, persistence/schema changes, or refresh of affected data areas.

## Preconditions
The version 2 bundle lists this file and persistence/migration scope.

## Inputs
- Entities/models, repositories/DAOs, queries, schema SQL, Liquibase/Flyway, and persistence tests.
- Existing `knowledge/database.md`.

## Must Analyze
- Tables, views, triggers, procedures, functions, entities, repositories, custom queries, indexes, foreign keys, relationships, transactions, and migration history.

## Procedure
1. Confirm skill load and record this file.
2. Inventory schema and persistence objects from declarations and migrations.
3. Map entities to tables, important columns, relationships, indexes, and queries.
4. Identify migration ordering, data consistency, transaction, and performance risks.

## Outputs
- `knowledge/database.md` with object inventory, entity-table mapping, columns, relationships, migrations, queries, indexes, risks, source references, and freshness metadata.

## Permission Requirement
Read source/schema/tests/knowledge; write knowledge/run artifacts only; no database mutation and no network.

## Write Impact
Knowledge: YES; Product/Test/Database Objects: NO.

## Validation
- Objects and relationships cite declarations or migrations.
- Migration history and current schema are distinguished.
- Query/performance risks have evidence.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `PERMISSION_DENIED`, `UNSAFE_CHANGE`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`; R02 `MIGRATION_GATE` when material migration knowledge changed.
