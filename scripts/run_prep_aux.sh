#!/usr/bin/env bash
# Decompress GFF/GTF/CDS/RNA/protein and copy chr_mapping files.
set -euo pipefail
cd "$(dirname "$0")/.."
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate trifolium_ref
snakemake -s Snakefile.prep_aux --cores "${1:-4}" -p "${@:2}"
