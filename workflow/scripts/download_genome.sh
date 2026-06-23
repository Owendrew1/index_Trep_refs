#!/usr/bin/env bash
# Download a GenBank assembly with NCBI datasets and write expected .fna.gz path.
set -euo pipefail

ACCESSION="$1"
OUT_GZ="$2"
LOG="${3:-/dev/stderr}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

exec 2>>"$LOG"
mkdir -p "$(dirname "$OUT_GZ")"

echo "Downloading $ACCESSION -> $OUT_GZ" >&2
datasets download genome accession "$ACCESSION" \
  --filename "$WORKDIR/dl.zip" \
  --no-progressbar

unzip -q "$WORKDIR/dl.zip" -d "$WORKDIR/extract"
FNA="$(find "$WORKDIR/extract" -name '*.fna' | head -1)"
[[ -n "$FNA" ]] || { echo "No .fna found in datasets archive for $ACCESSION" >&2; exit 1; }

gzip -c "$FNA" > "$OUT_GZ"
echo "Wrote $OUT_GZ" >&2
