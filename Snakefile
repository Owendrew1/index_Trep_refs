#Default workflow: index genome FASTAs (gunzip + samtools + GATK + BWA). 
#Other workflows: Snakefile.prep_aux, Snakefile.mapping (in docs/WORKFLOWS.md) - split up for simplicity (340 ish rows - 90), activated through other commands noted 

configfile: "config/config.yaml"
include: "workflow/common.smk"


def genome_targets():
    return [ref_done_path(r) for r in GENOMES]


rule all:
    input:
        genome_targets()


rule decompress_genome:
    input:
        lambda wc: raw_path(genome_row(wc)),
    output:
        ref="results/{source}/{haplotype}/{assembly}.fna",
    wildcard_constraints:
        source=WC_SRC,
        haplotype=WC_HAP,
        assembly=WC_ASM,
    shell:
        "mkdir -p $(dirname {output.ref}) && gzip -dc {input} > {output.ref}"


rule samtools_faidx:
    input:
        ref=rules.decompress_genome.output.ref,
    output:
        "results/{source}/{haplotype}/{assembly}.fna.fai",
    wildcard_constraints:
        source=WC_SRC,
        haplotype=WC_HAP,
        assembly=WC_ASM,
    conda:
        "envs/ref.yaml",
    shell:
        "samtools faidx {input.ref}"


rule gatk_sequence_dictionary:
    input:
        ref=rules.decompress_genome.output.ref,
    output:
        "results/{source}/{haplotype}/{assembly}.dict",
    wildcard_constraints:
        source=WC_SRC,
        haplotype=WC_HAP,
        assembly=WC_ASM,
    conda:
        "envs/ref.yaml",
    shell:
        "gatk CreateSequenceDictionary -R {input.ref} -O {output}"


rule bwa_index:
    input:
        ref=rules.decompress_genome.output.ref,
    output:
        multiext(
            "results/{source}/{haplotype}/{assembly}.fna",
            ".amb",
            ".ann",
            ".bwt",
            ".pac",
        ),
    wildcard_constraints:
        source=WC_SRC,
        haplotype=WC_HAP,
        assembly=WC_ASM,
    conda:
        "envs/ref.yaml",
    shell:
        "bwa index {input.ref}"


rule genome_ref_done:
    input:
        rules.samtools_faidx.output,
        rules.gatk_sequence_dictionary.output,
        rules.bwa_index.output,
    output:
        "results/{source}/{haplotype}/{assembly}.ref.done",
    wildcard_constraints:
        source=WC_SRC,
        haplotype=WC_HAP,
        assembly=WC_ASM,
    shell:
        "touch {output}"
