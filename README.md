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

| Tool       | Purpose                          |
|------------|---------------------------------|
| FastQC     | Read quality control            |
| fastp      | Read trimming                   |
| BWA        | Sequence alignment              |
| SAMtools   | BAM processing                  |
| bcftools   | Variant calling                 |
| vcftools   | Variant filtering               |
| PLINK      | Genotype processing and GWAS    |
| SLURM      | Job scheduling                  |

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

---

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

**Notes:**
- FastQC evaluates per-base quality, GC content, duplication levels, and adapter contamination.
- MultiQC aggregates all reports into a single summary.

---

### Step 2 — Read Trimming (fastp)

**Purpose:**  
Remove low-quality bases and adapter sequences from raw reads.

**Script:**
```
scripts/02_trim.sh
```

**Key details:**
- Runs as a SLURM array job across all samples
- Uses paired-end reads

**Input:**
- ${SAMPLE}_1.fastq.gz  
- ${SAMPLE}_2.fastq.gz  

**Output:**
- Trimmed reads:
  ```
  trimmed/${SAMPLE}_1.fq.gz
  trimmed/${SAMPLE}_2.fq.gz
  ```

**Command used:**
```
fastp -i $FILE1 -I $FILE2 -o $OUT${SAMPLE}_1.fq.gz -O $OUT${SAMPLE}_2.fq.gz
```

---

### Step 3 — Reference Genome Indexing (BWA)

**Purpose:**  
Prepare the reference genome for alignment.

**Script:**
```
scripts/03_index_reference.sh
```

**Input:**
- ROS_Cfam.fa

**Output:**
- BWA index files (.bwt, .pac, .ann, etc.)

**Command:**
```
bwa index ROS_Cfam.fa
```

**Notes:**
- This step only needs to be run once.

---

### Step 4 — Read Alignment and BAM Generation

**Purpose:**  
Align trimmed reads to the reference genome and generate BAM files.

**Script:**
```
scripts/04_align_and_make_bam.sh
```

**Tools used:**
- BWA MEM
- SAMtools

**Input:**
- Trimmed FASTQ files
- Reference genome

**Process:**
1. Align reads using BWA MEM
2. Convert SAM to BAM
3. Sort BAM files
4. Index BAM files

**Command:**
```
bwa mem -t 8 $REF $FILE1 $FILE2 | samtools view -bh - > aligned.bam
samtools sort aligned.bam -o sorted.bam
samtools index sorted.bam
```

**Output:**
- Sorted and indexed BAM files:
  ```
  BAM/${SAMPLE}_sort.bam
  ```

---

### Step 5 — Variant Calling (bcftools)

**Purpose:**  
Identify genetic variants across all samples.

**Script:**
```
scripts/05_call_variants.sh
```

**Input:**
- Sorted BAM files
- Reference genome

**Command:**
```
bcftools mpileup -f REF BAM/*_sort.bam | bcftools call -mv -Ov -o result.vcf
```

**Output:**
- Raw variant file:
  ```
  result.vcf
  ```

---

### Step 6 — Variant Filtering

**Purpose:**  
Remove low-quality and non-informative variants.

**Script:**
```
scripts/06_filter_variants.sh
```

**Filtering criteria:**
- Minor allele frequency (MAF ≥ 0.05)
- Missingness (≤ 20% missing data)
- Quality score ≥ 30
- Depth filtering (1 ≤ DP ≤ 50)
- Removal of indels
- Retain only biallelic SNPs

**Tools:**
- vcftools
- bcftools

**Output:**
- Filtered VCF files:
  ```
  dog_80b.vcf.gz
  ```

---

### Step 7 — Conversion to PLINK Format

**Purpose:**  
Convert filtered VCF data into PLINK binary format for downstream analysis.

**Script:**
```
scripts/07_convert_to_plink.sh
```

**Command:**
```
plink --vcf input.vcf.gz --make-bed --out output
```

---

### Step 8 — Import Imputed Data

**Purpose:**  
Load externally imputed genotype data into PLINK format.

**Script:**
```
scripts/08_import_imputed_plink.sh
```

---

### Step 9 — Genotype Quality Control

**Purpose:**  
Filter individuals and SNPs based on missingness and allele frequency.

**Script:**
```
scripts/09_genotype_qc.sh
```

---

### Step 10 — Population Structure Analysis (PCA)

**Purpose:**  
Assess genetic structure and potential population stratification.

---

### Step 11 — Genome-Wide Association Study (GWAS)

**Purpose:**  
Identify SNPs associated with height and weight.

**Script:**
```
scripts/10_run_gwas.sh
```

---

## How to Run the Pipeline

```
git clone https://github.com/parsaf2000/life4136-rotation3-group2-dog-gwas.git
cd life4136-rotation3-group2-dog-gwas

conda env create -f environment.yml
conda activate R3G2

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

- Height GWAS showed strongest associations on chromosome NC_049239.1 (~20.6 Mb) with p-values ~10^-18  
- Weight GWAS showed strongest associations on chromosome NC_049246.1 (~44.9 Mb) with p-values ~10^-16  
- PCA indicated clear population structure within the dataset  

---

## Repository Structure

```
├── scripts/
├── data/
├── results/
├── docs/
├── environment.yml
├── README.md
```

---

## Reproducibility Notes

- Large files are excluded due to size
- Pipeline is reproducible on HPC systems
- Paths may need modification outside original environment

---

## Limitations

- FastQC script not included due to permissions
- Plots not included but can be added
- Some scripts may need path updates

---

## Author

Mohammad Parsa Faraji  
Hannah Byrne  
Mengchan Liu  
University of Nottingham  
Bioinformatics Rotation 3
