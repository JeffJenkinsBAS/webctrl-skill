#!/usr/bin/env bash
# Rebuild the per-skill upload packages in dist/.
# Run from the repo root after any skill change: bash scripts/build-zips.sh
set -euo pipefail
cd "$(dirname "$0")/.."
rm -f dist/*.zip
for dir in .claude/skills/*/; do
  name=$(basename "$dir")
  (cd .claude/skills && zip -qr "../../dist/${name}.zip" "$name" -x '*.DS_Store')
  echo "built dist/${name}.zip"
done
