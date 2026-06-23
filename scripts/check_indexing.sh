#!/usr/bin/env bash
# Status check. Usage: bash scripts/check_indexing.sh
set -euo pipefail

source "$(dirname "$0")/config_paths.sh"

bar() { printf '%s\n' "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; }

indexed=0
while IFS= read -r line; do
  [[ "$line" =~ ,genome, ]] || continue
  src=$(echo "$line" | cut -d, -f2)
  file=$(echo "$line" | cut -d, -f4)
  asm="${file%.gz}"
  asm="${asm%.fna}"
  [[ -f "$SRC/$src/${asm}.fna.bwt" ]] && indexed=$((indexed + 1))
done < "$ROOT/resources/samples.csv"

bar
if [[ -f "$DONE" ]]; then
  echo "  STATUS      ✅ DONE"
else
  echo "  STATUS      🔄 not finished (no Trep_ref_indexing.done)"
fi
bar
echo "  Indexed     ${indexed}/${NGEN} genomes (BWA .bwt present)"
echo "  source_dir  $SRC"
bar
