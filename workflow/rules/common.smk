# Shared helpers for workflow/Snakefile (and optional prep_aux / mapping).

import csv
import re
from pathlib import Path


def load_samples(path):
    with open(path, newline="") as f:
        rows = list(csv.DictReader(f))
    for i, r in enumerate(rows, 1):
        for k in list(r.keys()):
            r[k] = (r[k] or "").strip()
        r["row_id"] = f"{i:04d}"
    return rows


def asm(r):
    return Path(r["file"].replace(".gz", "")).stem


def init_indexing(config):
    """Wire paths and genome tables from config."""
    global SRC, LOG, DONE, ROWS, GENOMES, GENOME_LOOKUP, SOURCES, ASSEMBLIES, SOURCE_SET, ASSEMBLY_SET
    SRC = Path(config["source_dir"])
    LOG = f"{SRC}/Trep_ref_indexing_logs"
    DONE = f"{SRC}/Trep_ref_indexing.done"
    ROWS = load_samples(config["samples_csv"])
    GENOMES = [r for r in ROWS if r["file_type"] == "genome"]
    GENOME_LOOKUP = {(r["source"], asm(r)): r for r in GENOMES}
    SOURCES = [r["source"] for r in GENOMES]
    ASSEMBLIES = [asm(r) for r in GENOMES]
    SOURCE_SET = sorted(set(SOURCES))
    ASSEMBLY_SET = sorted(set(ASSEMBLIES))


def genome_row(wc):
    return GENOME_LOOKUP[(wc.source, wc.assembly)]


def raw_path(r):
    return str(SRC / r["source"] / r["file"])
