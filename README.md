# index_Trep_refs

Index *Trifolium repens* genome FASTAs for downstream **Trep_pangenome**, **Trep_blast**, and **Giraffe_vg**.

Genomes must already be on scratch under `source_dir` — this pipeline **does not download** them.

## Layout

```text
index_Trep_refs/
├── environment.yaml
├── config/config.yaml
├── resources/samples.csv
├── workflow/
│   ├── Snakefile
│   ├── envs/ref.yaml
│   └── rules/common.smk
└── scripts/run_indexing.sh
```

## Run

```bash
conda activate snakemake
cd ~/github-repos/index_Trep_refs
./scripts/run_indexing.sh 4
```

## Outputs

Under `{source_dir}/`: decompressed `.fna`, samtools `.fai`, GATK `.dict`, BWA index, and `Trep_ref_indexing.done`.
