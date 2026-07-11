# API Discovery

## Purpose
Build a complete index of application and integration endpoints.

## Allowed Agents
A01 Knowledge Maintainer.

## Trigger
Bootstrap, API/integration changes, or refresh of affected modules.

## Preconditions
The version 2 bundle lists this file and endpoint/integration search scope.

## Inputs
- REST, SOAP, gRPC, GraphQL, client, producer, and consumer source.
- DTOs, validators, auth/permission code, tests, and API specifications when present.
- Existing `knowledge/api-index.md`.

## Must Analyze
- Method/path or protocol identity, controller/client/consumer, request/response, validation, authentication/authorization, related service, versioning, and compatibility notes.

## Procedure
1. Confirm skill load and record this file.
2. Inventory inbound and outbound endpoints and message interfaces.
3. Trace DTOs, validation, permissions, handlers, and downstream services.
4. Record undocumented or inconsistent contracts as risks.

## Outputs
- `knowledge/api-index.md` with method/path or protocol, owner, request, response, validation, auth, service mapping, compatibility notes, source references, and freshness metadata.

## Permission Requirement
Read source/tests/specs/knowledge; write knowledge/run artifacts only; no network.

## Write Impact
Knowledge: YES; Product/Test Code: NO.

## Validation
- Every discovered endpoint has a concrete source location.
- Inbound, outbound, and messaging endpoints are distinguished.
- Auth and validation are explicit or marked absent/unknown.

## Failure Codes
`SKILL_NOT_LOADED`, `MISSING_INPUT`, `INSUFFICIENT_EVIDENCE`, `PERMISSION_DENIED`.

## Review Mapping
R01 `KNOWLEDGE_QUALITY`; R02 `API_COMPATIBILITY_GATE` when material contracts changed.
