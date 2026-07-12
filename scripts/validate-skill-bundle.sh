#!/usr/bin/env bash
set -euo pipefail

# Fail-closed v2.1 pre-dispatch validator. It never edits the bundle; PASS is
# emitted as detached evidence for W01's runtime log.
usage() { echo "Usage: $0 <bundle-path> <workflow-home>" >&2; exit 2; }
[[ $# -eq 2 ]] || usage

bundle=$1
workflow_home=$2
[[ -f "$bundle" ]] || { echo "SKILL_BUNDLE_INVALID:BUNDLE_NOT_FOUND" >&2; exit 1; }
[[ -d "$workflow_home" ]] || { echo "SKILL_BUNDLE_INVALID:WORKFLOW_HOME_NOT_FOUND" >&2; exit 1; }

bundle_abs=$(realpath -m "$bundle")
home_abs=$(realpath -m "$workflow_home")
registry="$home_abs/skills/skill-registry.md"
[[ -f "$registry" ]] || { echo "SKILL_BUNDLE_INVALID:SKILL_REGISTRY_NOT_FOUND" >&2; exit 1; }

value() { sed -n "s/^- $1:[[:space:]]*//p" "$bundle" | head -n1; }
require_value() {
  local key=$1 expected=${2-} actual
  actual=$(value "$key")
  [[ -n "$actual" ]] || { echo "SKILL_BUNDLE_INVALID:MISSING_$key" >&2; exit 1; }
  if [[ -n "$expected" && "$actual" != "$expected" ]]; then
    echo "SKILL_BUNDLE_INVALID:BAD_$key" >&2; exit 1
  fi
}

require_value "Bundle Version" "2"
require_value "Schema Revision" "2.1"
require_value "Workflow Home" "$home_abs"
require_value "Skill Registry" "$registry"
task_id=$(value "Task ID"); run_id=$(value "Run ID")
stage=$(value "Stage"); host_id=$(value "Host Agent ID"); host_name=$(value "Host Agent Name")
iteration=$(value "Iteration"); review_profile=$(value "Required Review Profile")
for pair in "Task ID:$task_id" "Run ID:$run_id" "Stage:$stage" "Host Agent ID:$host_id" "Host Agent Name:$host_name" "Iteration:$iteration" "Required Review Profile:$review_profile"; do
  key=${pair%%:*}; actual=${pair#*:}
  [[ -n "$actual" ]] || { echo "SKILL_BUNDLE_INVALID:MISSING_${key// /_}" >&2; exit 1; }
done
[[ "$task_id" =~ ^(feature|bugfix|hotfix|refactor|test|docs|knowledge|maintenance|analysis)-[0-9]{8}-[a-z0-9-]+$ ]] || { echo "SKILL_BUNDLE_INVALID:BAD_TASK_ID" >&2; exit 1; }
[[ "$run_id" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "SKILL_BUNDLE_INVALID:BAD_RUN_ID" >&2; exit 1; }
[[ "$iteration" =~ ^[1-9][0-9]*$ ]] || { echo "SKILL_BUNDLE_INVALID:BAD_ITERATION" >&2; exit 1; }

task_root="$home_abs/execution-workspace/$task_id"
expected_prefix="$task_root/runs/$run_id/skill-bundle.md"
[[ "$bundle_abs" == "$expected_prefix" ]] || { echo "SKILL_BUNDLE_INVALID:TASK_ROOT_NONCANONICAL" >&2; exit 1; }
[[ -d "$task_root" ]] || { echo "SKILL_BUNDLE_INVALID:TASK_WORKSPACE_NOT_FOUND" >&2; exit 1; }

grep -Fxq '## Required Skills' "$bundle" || { echo "SKILL_BUNDLE_INVALID:REQUIRED_SKILLS_SECTION" >&2; exit 1; }
grep -Fxq '## Forbidden Skills' "$bundle" || { echo "SKILL_BUNDLE_INVALID:FORBIDDEN_SKILLS_SECTION" >&2; exit 1; }
grep -Fxq '## Required Inputs' "$bundle" || { echo "SKILL_BUNDLE_INVALID:REQUIRED_INPUTS_SECTION" >&2; exit 1; }
grep -Fxq '## Expected Outputs' "$bundle" || { echo "SKILL_BUNDLE_INVALID:EXPECTED_OUTPUTS_SECTION" >&2; exit 1; }
grep -Fxq '## Write Scope And Locks' "$bundle" || { echo "SKILL_BUNDLE_INVALID:WRITE_SCOPE_SECTION" >&2; exit 1; }
grep -Fxq '## Reviewer Contract' "$bundle" || { echo "SKILL_BUNDLE_INVALID:REVIEWER_SECTION" >&2; exit 1; }
grep -Fxq '## Skill Load Evidence' "$bundle" || { echo "SKILL_BUNDLE_INVALID:LOAD_EVIDENCE_SECTION" >&2; exit 1; }
grep -Eq '^- Required Locks:' "$bundle" || { echo "SKILL_BUNDLE_INVALID:LOCK_DECLARATION" >&2; exit 1; }
grep -Eq '^- Forbidden Paths:' "$bundle" || { echo "SKILL_BUNDLE_INVALID:FORBIDDEN_PATH_DECLARATION" >&2; exit 1; }
grep -Eq '^- Bundle Validation Status:[[:space:]]*PENDING[[:space:]]*$' "$bundle" || { echo "SKILL_BUNDLE_INVALID:VALIDATION_STATUS_NOT_PENDING" >&2; exit 1; }

agent_toml=""
agent_dirs=("$home_abs/agents" "$home_abs/../../agents" "${CODEX_HOME:-$HOME/.codex}/agents")
while IFS= read -r candidate; do
  if grep -Eq "^[[:space:]]*name[[:space:]]*=[[:space:]]*\"$host_name\"" "$candidate"; then agent_toml=$candidate; break; fi
done < <(find "${agent_dirs[@]}" -maxdepth 1 -type f -name '*.toml' -print 2>/dev/null)
[[ -n "$agent_toml" ]] || { echo "SKILL_BUNDLE_INVALID:HOST_TOML_NOT_FOUND" >&2; exit 1; }
grep -Fq "| $host_id |" "$home_abs/agents/agent-registry.md" || { echo "SKILL_BUNDLE_INVALID:HOST_REGISTRY_ID_NOT_FOUND" >&2; exit 1; }
grep -Eq "\|[[:space:]]*\`?$host_name\`?[[:space:]]*\|" "$home_abs/agents/agent-registry.md" || { echo "SKILL_BUNDLE_INVALID:HOST_REGISTRY_NAME_NOT_FOUND" >&2; exit 1; }

# Every concrete skill path in required/optional tables must exist and be under Workflow Home.
skill_count=0
while IFS= read -r path; do
  skill_count=$((skill_count + 1))
  [[ "$path" == /* ]] || { echo "SKILL_BUNDLE_INVALID:SKILL_PATH_NOT_ABSOLUTE" >&2; exit 1; }
  path_abs=$(realpath -m "$path")
  [[ "$path_abs" == "$home_abs"/* ]] || { echo "SKILL_BUNDLE_INVALID:SKILL_PATH_OUTSIDE_WORKFLOW_HOME" >&2; exit 1; }
  [[ -f "$path_abs" ]] || { echo "SKILL_BUNDLE_INVALID:SKILL_FILE_NOT_FOUND" >&2; exit 1; }
  skill_name=$(basename "$path_abs" .md)
  grep -Eq "\|[[:space:]]*\`?$skill_name\`?[[:space:]]*\|" "$registry" || { echo "SKILL_BUNDLE_INVALID:SKILL_NOT_REGISTERED:$skill_name" >&2; exit 1; }
done < <(awk -F'|' '/^\|[[:space:]]*[0-9]+[[:space:]]*\|/ {gsub(/[[:space:]]/,"",$4); if ($4 ~ /^\//) print $4}' "$bundle")
[[ "$skill_count" -gt 0 ]] || { echo "SKILL_BUNDLE_INVALID:NO_CONCRETE_SKILLS" >&2; exit 1; }

digest=$(sha256sum "$bundle_abs" | awk '{print $1}')
echo "SKILL_BUNDLE_VALID bundle_sha256=$digest"
