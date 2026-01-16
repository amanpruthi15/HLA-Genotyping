# HLA-Genotyping

This repository provides a **reproducible pipeline for HLA genotyping** using **HLA-T1K** on **public whole-exome sequencing (WXS) data** from the Coriell / 1000 Genomes Project.  
The workflow starts from **CRAM files**, converts them to **paired-end FASTQ**, performs **HLA typing**, and summarizes results into a **single allele call table**.

---

## Overview

**Input:** Public WXS CRAM files (GRCh38)  
**Output:** Per-sample HLA allele calls and a combined summary table  

Pipeline steps:
1. Download public CRAM files
2. Convert CRAM → FASTQ (GATK SamToFastq)
3. Run HLA genotyping (HLA-T1K)
4. Summarize all HLA results into one table

---

## Data Source

This pipeline is designed for **public Coriell / 1000 Genomes Project exome data**.

- Repository: 1000 Genomes Project (ENA/EBI)
- Sequencing strategy: **WXS** (Whole Exome Sequencing)
- Reference genome: **GRCh38 + decoy + HLA**

> Note: While whole exome sequencing is commonly referred to as **WES**, ENA/1000G denote it as **WXS**.

---

## Requirements

- Linux (HPC environment recommended)
- SLURM workload manager
- Docker
- GATK Docker image: `broadinstitute/gatk:4.4.0.0`
- HLA-T1K installed and available in `$PATH` (`run-t1k`)
- `datamash`
- GRCh38 reference FASTA (matching CRAM files)
- HLA-T1K reference database

---

## Directory Structure
working_dir/

├── cram/          # Downloaded CRAM files

├── download/      # Generated FASTQ files

├── hla_out/       # HLA-T1K output per sample

├── job_files/     # SLURM job scripts

├── job_output/    # SLURM stdout logs

├── job_error/     # SLURM stderr logs

└── sample_info.txt


---

## Pipeline Steps

### 1. CRAM to FASTQ

CRAM files are converted to paired-end FASTQ files using **GATK SamToFastq** inside a Docker container.  
This ensures reference consistency and reproducibility.

**Output:**
- `sample_R1.fastq.gz`
- `sample_R2.fastq.gz`

---

### 2. HLA Genotyping

HLA typing is performed using **HLA-T1K**, optimized for exome data.

**Key points:**
- Uses paired-end FASTQ files
- Targets classical and non-classical HLA genes
- Produces per-sample genotype TSV files

---

### 3. Result Summarization

All per-sample HLA genotype outputs are merged into a **single, wide-format table**:
- One row per sample
- Separate columns for each allele (e.g., `A_1`, `A_2`, `B_1`, `B_2`, etc.)

This final table is suitable for:
- Downstream association analysis
- QC and cohort-level inspection
- Clinical or research reporting

---

## Output Files

- Per-sample HLA-T1K results:
hla_out/<sample>_hla_out/*_genotype.tsv


- Final combined table:
YYYY-MM-DD_hla_allele-call_Table.tsv

---

## Notes & Assumptions

- CRAM files **must match the reference FASTA exactly**
- This pipeline is intended for **exome (WXS) data**
- SLURM is used for scalability across many samples
- Scripts are provided separately and can be adapted for other schedulers

---

## Use Cases

- Population-scale HLA typing
- Validation using public reference samples
- Method benchmarking
- Downstream immunogenomics analyses

---

## License

This project is provided for research and educational use.  
Users are responsible for complying with the licenses of external tools and datasets.

---

## Contact

For questions, issues, or improvements, please open a GitHub issue or contact the repository maintainer.




