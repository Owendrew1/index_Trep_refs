# index_Trep_refs

Index *Trifolium repens* genome FASTAs for downstream **Trep_pangenome**, **Trep_blast**, and **Giraffe_vg**.

## Layout

```text
index_Trep_refs/
├── environment.yaml          # Snakemake only
├── config/config.yaml
├── resources/samples.csv     # assemblies + GenBank accessions
├── workflow/
│   ├── Snakefile             # rules only
│   ├── envs/ref.yaml         # samtools, bwa, gatk
│   ├── envs/datasets.yaml    # NCBI datasets CLI
│   ├── scripts/download_genome.sh
│   └── rules/common.smk
└── scripts/run_indexing.sh
```

## Setup

```bash
conda env create -f environment.yaml
conda activate snakemake
```

Edit `config/config.yaml` — `source_dir` (scratch path), `auto_download` (default `true`).

## Run

```bash
cd ~/github-repos/index_Trep_refs
./scripts/run_indexing.sh 4
```

## NCBI auto-download

When `auto_download: true`, genomes with a `GCA_`/`GCF_` accession in `samples.csv` are fetched with the NCBI `datasets` CLI if the `.fna.gz` is not already present. Rows without an accession (e.g. Wang2023) must have the `.fna.gz` placed manually under `{source_dir}/{source}/`.

Existing indexed outputs on scratch are skipped by Snakemake — no rerun needed unless you delete outputs.

## Outputs

Under `{source_dir}/`:

| Path | Description |
|------|-------------|
| `{source}/{assembly}.fna` | Decompressed genome |
| `{source}/{assembly}.fna.fai` | samtools index |
| `{source}/{assembly}.dict` | GATK dictionary |
| `{source}/{assembly}.fna.bwt` (+ `.amb`, `.ann`, `.pac`) | BWA index |
| `Trep_ref_indexing.done` | Workflow complete |

`assembly` = stem of the `.fna.gz` filename (e.g. `GCA_030408175.1_UTM_Trep_v1.0_genomic`).
