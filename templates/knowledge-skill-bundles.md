# Knowledge Skill Bundle Profiles

Use these profiles to fill the version 2 run bundle with concrete paths rooted at `Workflow Home`.

## Full Bootstrap A01

| Load Order | Skill | Canonical Skill File | Required Output |
| ---: | --- | --- | --- |
| 1 | repository-scan | skills/knowledge/repository-scan.md | knowledge/repository.md |
| 2 | convention-analysis | skills/knowledge/convention-analysis.md | knowledge/convention.md |
| 3 | architecture-discovery | skills/knowledge/architecture-discovery.md | knowledge/architecture.md |
| 4 | pattern-discovery | skills/knowledge/pattern-discovery.md | knowledge/patterns.md |
| 5 | business-flow-discovery | skills/knowledge/business-flow-discovery.md | knowledge/business-flow.md |
| 6 | business-rule-discovery | skills/knowledge/business-rule-discovery.md | knowledge/business-rule.md |
| 7 | api-discovery | skills/knowledge/api-discovery.md | knowledge/api-index.md |
| 8 | database-discovery | skills/knowledge/database-discovery.md | knowledge/database.md |
| 9 | technology-stack-discovery | skills/knowledge/technology-stack-discovery.md | knowledge/technology-stack.md; knowledge/skill-matrix.md |
| 10 | reusable-component-discovery | skills/knowledge/reusable-component-discovery.md | knowledge/component-index.md |
| 11 | knowledge-index-update | skills/knowledge/knowledge-index-update.md | knowledge/knowledge-index.md; knowledge/knowledge-manifest.md |

`decision-memory-update` is selected only when accepted decisions already exist. It runs before `knowledge-index-update`.

## Incremental Sync A01

| Load Order | Skill | Canonical Skill File | Rule |
| ---: | --- | --- | --- |
| 1 | incremental-git-scan | skills/knowledge/incremental-git-scan.md | Always first |
| 2..N | affected discovery/update skills | Resolve through skills/skill-registry.md | Only skills mapped from dirty knowledge |
| Last | knowledge-index-update | skills/knowledge/knowledge-index-update.md | Always last |

Do not include `repository-scan` in an incremental bundle unless the incremental scan proves repository-wide remapping is required.

## Knowledge Review R01

| Load Order | Skill | Canonical Skill File | Required Output |
| ---: | --- | --- | --- |
| 1 | knowledge-review | skills/review/knowledge-review.md | runs/<run-id>/knowledge-review.md; handoff.md |

## Normal Planning A02

Add `similar-code-search` at `skills/knowledge/similar-code-search.md` only when the requirement may have an existing precedent.

## Load Gate

W01 replaces every canonical relative path with a concrete readable path, and the child records those paths under `Skill Files Read`. A missing path, wrong host agent, wrong order barrier, or missing load evidence returns `SKILL_NOT_LOADED` and blocks the run.
