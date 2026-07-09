#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${1:-$ROOT/dist/backend-agent-generation-master-prompt-workflow-harness.md}"
MANIFEST="${2:-$ROOT/manifest.txt}"

if [[ "$OUT" != /* ]]; then
  OUT="$ROOT/$OUT"
fi

if [[ "$MANIFEST" != /* ]]; then
  MANIFEST="$ROOT/$MANIFEST"
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest not found: $MANIFEST" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"
: > "$OUT"

while IFS= read -r rel || [[ -n "$rel" ]]; do
  [[ -z "${rel//[[:space:]]/}" ]] && continue
  [[ "$rel" =~ ^[[:space:]]*# ]] && continue

  src="$ROOT/$rel"
  if [[ ! -f "$src" ]]; then
    echo "Missing manifest entry: $rel" >&2
    exit 1
  fi

  cat "$src" >> "$OUT"
done < "$MANIFEST"

echo "Assembled: $OUT"
