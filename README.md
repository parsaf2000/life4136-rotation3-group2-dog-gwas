# Dog GWAS Pipeline (LIFE4136 Rotation 3 – Group 2)

## Overview

This project implements a complete bioinformatics pipeline to perform a Genome-Wide Association Study (GWAS) on domestic dog sequencing data. The aim was to identify genetic variants associated with two phenotypic traits: **height** and **weight**.

The workflow processes raw paired-end sequencing reads through quality control, trimming, alignment, variant calling, filtering, genotype processing, population structure analysis, and finally GWAS using linear regression.

This repository is designed to be **reproducible**, **well-documented**, and aligned with best practices in computational genomics.

---

## Pipeline Summary

Raw FASTQ → QC → Trim → Align → BAM → Variant Calling → Filtering → PLINK → QC → PCA → GWAS

---

## Prerequisites

This workflow was developed and executed on a **High Performance Computing (HPC) cluster** using SLURM.

Required:
- Access to an HPC system with SLURM
- Linux/Unix environment
- Conda installed

---

## Installation and Dependencies

The following software tools were used:

| Tool | Version | Purpose | Source |
|------|---------|---------|--------|
| FastQC | N/A | Read quality control | Official FastQC website |
| fastp | ~0.23 | Read trimming | Official fastp GitHub |
| BWA | 0.7.17 | Sequence alignment | Official BWA website |
| SAMtools | 1.18 | BAM processing | Official HTSlib website |
| bcftools | 1.18 | Variant calling | Official HTSlib website |
| vcftools | 0.1.16 | Variant filtering | Official VCFtools website |
| PLINK | 1.9 | Genotype processing and GWAS | Official PLINK website |
| SLURM | HPC-managed | Job scheduling | Official SLURM website |

### Conda environment

Create environment using:

```
conda env create -f environment.yml
conda activate R3G2
```

---

## Data Description

### Input Data

- Raw FASTQ files:  
  `/share/BioinfMSc/Hannah_resources/doggies/fastqs/`

- Sample names:  
  `data/names.txt`

- Phenotypes:  
  `data/height_2.txt`  
  `data/weight_2.txt`

- Reference genome:  
  `ROS_Cfam.fa`

- Imputed variants:  
  `/share/BioinfMSc/Hannah_resources/doggies/doggies_snps_imputed.vcf.gz`


## Workflow

This pipeline processes raw paired-end sequencing data into GWAS results for height and weight. Each step is implemented as a SLURM batch script to allow scalable execution across multiple samples.

---

### Step 1 — Quality Control (FastQC)

**Purpose:**  
Assess the quality of raw sequencing reads before downstream processing.

**Input:**
- Raw FASTQ files:
  /share/BioinfMSc/Hannah_resources/doggies/fastqs/*.fastq.gz

**Output:**
- FastQC reports (.html and .zip)
- MultiQC summary report

**Command:**
(Not included due to permission restrictions — to be added later)

---

### Step 2 — Read Trimming (fastp)

```
sbatch scripts/02_trim.sh
```

Removes adapters and low-quality bases from paired-end reads.

---

### Step 3 — Reference Genome Indexing (BWA)

```
sbatch scripts/03_index_reference.sh
```

Indexes the reference genome for alignment.

---

### Step 4 — Alignment and BAM Generation

```
sbatch scripts/04_align_and_make_bam.sh
```

Aligns reads using BWA MEM and produces sorted, indexed BAM files.

---

### Step 5 — Variant Calling

```
sbatch scripts/05_call_variants.sh
```

Calls variants using bcftools mpileup and bcftools call.

---

### Step 6 — Variant Filtering

```
sbatch scripts/06_filter_variants.sh
```

Applies filtering based on:
- Minor allele frequency (≥ 0.05)
- Missingness
- Quality score
- Depth
- Biallelic SNP selection

---

### Step 7 — Convert to PLINK Format

```
sbatch scripts/07_convert_to_plink.sh
```

Converts filtered VCF files to PLINK binary format.

---

### Step 8 — Import Imputed Data

```
sbatch scripts/08_import_imputed_plink.sh
```

Imports externally imputed genotype data.

---

### Step 9 — Genotype Quality Control

```
sbatch scripts/09_genotype_qc.sh
```

Applies filtering:
- SNP missingness ≤ 30%
- Individual missingness ≤ 60%
- MAF ≥ 0.1

---

### Step 10 — PCA

Performs principal component analysis to assess population structure.

Outputs:
- Eigenvalues
- Eigenvectors

---

### Step 11 — GWAS

```
sbatch scripts/10_run_gwas.sh
```

Runs linear regression in PLINK for:
- Height
- Weight

Outputs:
- gwas_height.assoc.linear
- gwas_weight.assoc.linear

---

## How to Run the Pipeline

1. Clone the repository:

```
git clone https://github.com/parsaf2000/life4136-rotation3-group2-dog-gwas.git
cd life4136-rotation3-group2-dog-gwas
```

2. Activate environment:

```
conda env create -f environment.yml
conda activate R3G2
```

3. Submit jobs in order:

```
sbatch scripts/02_trim.sh
sbatch scripts/03_index_reference.sh
sbatch scripts/04_align_and_make_bam.sh
sbatch scripts/05_call_variants.sh
sbatch scripts/06_filter_variants.sh
sbatch scripts/07_convert_to_plink.sh
sbatch scripts/08_import_imputed_plink.sh
sbatch scripts/09_genotype_qc.sh
sbatch scripts/10_run_gwas.sh
```

---

## Key Findings (Summary)

GWAS identified strong association signals for both traits:

- **Height:** Strongest signals located on chromosome NC_049239.1 (~20.6 Mb), with p-values on the order of 10^-18.
- **Weight:** Strongest signals observed on NC_049246.1 (~44.9 Mb), with p-values around 10^-16.

These findings indicate genomic regions associated with morphological variation in dogs.

PCA results indicated measurable population structure, supporting the importance of controlling for stratification in GWAS.

---

## Repository Structure

```
├── scripts/        # Pipeline scripts
├── data/           # Input metadata and phenotype files
├── results/        # Summary outputs
├── docs/           # Notes and documentation
├── environment.yml # Conda environment
├── README.md       # Project documentation
```

---

## Reproducibility Notes

- Large files (FASTQ, BAM, full VCF, full GWAS outputs) are not included due to size constraints.
- The pipeline is reproducible on HPC systems with SLURM.
- Paths may require adjustment depending on system configuration.

---

## Limitations

- FastQC script is currently unavailable due to permission restrictions.
- Plot files (Manhattan/PCA) are not included but can be added.
- Some scripts may require path adjustments outside the HPC environment.

---

## Author

Mohammad Parsa Faraji  
Hannah Byrne  
Mengchan Liu  
University of Nottingham  
Bioinformatics Rotation 3

