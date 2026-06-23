#!/usr/bin/env bash
# Run reference indexing workflow. Usage: ./scripts/run_indexing.sh [cores]
set -euo pipefail
cd "$(dirname "$0")/.."

exec snakemake -s workflow/Snakefile --directory workflow --cores "${1:-4}" -p --use-conda
