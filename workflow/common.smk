# Shared by Snakefile, Snakefile.prep_aux, and Snakefile.mapping (via include).
import csv
import re
from pathlib import Path

SRC = Path(config["source_dir"])
OUT = Path(config.get("results_dir", "results"))
MAP = Path(config.get("mapping_dir", "mapping"))


def load_samples(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f))
    for i, r in enumerate(rows, 1):
        for k in list(r.keys()):
            r[k] = (r[k] or "").strip()
        r["row_id"] = f"{i:04d}"
    return rows


ROWS = load_samples(config["samples_csv"])
ROW_BY_ID = {r["row_id"]: r for r in ROWS}
GENOMES = [r for r in ROWS if r["file_type"] == "genome"]
GENOME_LOOKUP = {(r["source"], r["haplotype"]): r for r in GENOMES}
AUX_ROWS = [r for r in ROWS if r["file_type"] != "genome"]

ASM = lambda r: Path(r["file"].replace(".gz", "")).stem
WC_SRC = "|".join(sorted({r["source"] for r in GENOMES})) or "X"
WC_HAP = "|".join(sorted({r["haplotype"] for r in GENOMES})) or "X"
WC_ASM = "|".join(re.escape(ASM(r)) for r in GENOMES) or "X"
WC_AUX = "|".join(r["row_id"] for r in AUX_ROWS) if AUX_ROWS else "NEVER"


def genome_row(wc):
    r = GENOME_LOOKUP[(wc.source, wc.haplotype)]
    if wc.assembly != ASM(r):
        raise ValueError("assembly wildcard mismatch")
    return r


def aux_row(wc):
    return ROW_BY_ID[wc.row_id]


def raw_path(r):
    return str(SRC / r["source"] / r["file"])


def genome_fasta_path(r):
    return str(OUT / r["source"] / r["haplotype"] / r["file"].replace(".gz", ""))


def ref_done_path(r):
    return f"results/{r['source']}/{r['haplotype']}/{ASM(r)}.ref.done"


def load_reads(path):
    with open(path, newline="") as f:
        rows = [dict((k, (v or "").strip()) for k, v in row.items()) for row in csv.DictReader(f)]
    return [r for r in rows if r.get("sample_id")]
