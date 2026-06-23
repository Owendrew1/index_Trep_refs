# Paths, config-derived constants, and helpers (aligned with Trep_pangenome / Trep_blast).

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


def accession(r):
    """GenBank assembly accession for datasets download (GCA_/GCF_)."""
    if r.get("accession"):
        return r["accession"]
    stem = asm(r)
    if stem.startswith("GCA_") or stem.startswith("GCF_"):
        return stem.split("_", 1)[0]
    return ""


SRC = Path(config["source_dir"])
LOG = f"{SRC}/Trep_ref_indexing_logs"
DONE = f"{SRC}/Trep_ref_indexing.done"
AUTO_DOWNLOAD = config.get("auto_download", True)
CONDA = "envs/ref.yaml"
DATASETS_CONDA = "envs/datasets.yaml"

ROWS = load_samples(config["samples_csv"])
GENOMES = [r for r in ROWS if r["file_type"] == "genome"]
GENOME_LOOKUP = {(r["source"], asm(r)): r for r in GENOMES}
SOURCES = [r["source"] for r in GENOMES]
ASSEMBLIES = [asm(r) for r in GENOMES]
SOURCE_SET = sorted(set(SOURCES))
ASSEMBLY_SET = sorted(set(ASSEMBLIES))

DOWNLOAD_SCRIPT = Path(workflow.basedir) / "scripts" / "download_genome.sh"


def genome_row(wc):
    return GENOME_LOOKUP[(wc.source, wc.assembly)]


def raw_path(r):
    return str(SRC / r["source"] / r["file"])


def genome_gz_input(wc):
    r = genome_row(wc)
    if AUTO_DOWNLOAD and accession(r):
        return rules.download_genome.output.gz
    return raw_path(r)


def indexing_done_inputs(wildcards):
    return [
        expand(rules.samtools_faidx.output, zip, source=SOURCES, assembly=ASSEMBLIES),
        expand(rules.gatk_sequence_dictionary.output, zip, source=SOURCES, assembly=ASSEMBLIES),
        expand(rules.bwa_index.output, zip, source=SOURCES, assembly=ASSEMBLIES),
    ]


wildcard_constraints:
    source="|".join(re.escape(s) for s in SOURCE_SET),
    assembly="|".join(re.escape(a) for a in ASSEMBLY_SET),
