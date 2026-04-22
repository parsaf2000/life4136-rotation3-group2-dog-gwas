# Dog GWAS Pipeline (LIFE4136 Rotation 3 – Group 2)

## Overview

This project implements a complete bioinformatics pipeline to perform a Genome-Wide Association Study (GWAS) on domestic dog sequencing data. The aim was to identify genetic variants associated with two phenotypic traits: **height** and **weight**.

The workflow processes raw paired-end sequencing reads through quality control, trimming, alignment, variant calling, filtering, genotype processing, population structure analysis, and finally GWAS using linear regression.

---

## Pipeline Summary

Raw FASTQ → quality control → trimming → reference indexing → alignment → BAM processing → variant calling → variant filtering → PLINK conversion → imputed genotype import → genotype QC → PCA → GWAS

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

```bash
conda env create -f environment.yml
conda activate R3G2


⸻

Data Description

Input Data
	•	Raw FASTQ files:
/share/BioinfMSc/Hannah_resources/doggies/fastqs/
	•	Sample names:
data/names.txt
	•	Phenotypes:
data/height_2.txt
data/weight_2.txt
	•	Reference genome:
ROS_Cfam.fa
	•	Imputed variants:
/share/BioinfMSc/Hannah_resources/doggies/doggies_snps_imputed.vcf.gz

⸻

Workflow

This pipeline processes raw paired-end sequencing data into GWAS results for height and weight. Each step is implemented as a SLURM batch script to allow scalable execution across multiple samples.

⸻

Step 1 — Quality control of raw sequencing reads (FastQC)

Purpose
The first stage of the workflow was to assess the quality of the raw paired-end sequencing reads before any downstream processing. This is important for identifying issues such as low-quality base calls, GC bias, duplicated reads, and possible adapter contamination.

Input
	•	Raw paired-end FASTQ files from:
/share/BioinfMSc/Hannah_resources/doggies/fastqs/

Expected output
	•	FastQC HTML reports
	•	FastQC ZIP report archives
	•	A MultiQC summary report combining all FastQC outputs

Why this step matters
Quality control provides an overview of the sequencing data and helps justify later trimming and filtering steps. Although the original fastqc.sh script was not accessible due to file permissions, the project directory shows that FastQC outputs and a MultiQC report were generated during the analysis.

⸻

Step 2 — Trimming of raw reads (fastp)

Purpose
Raw reads were cleaned using fastp to remove low-quality bases and improve read quality before alignment. Trimming helps reduce alignment errors and improves the reliability of downstream variant calling.

Script
	•	scripts/02_trim.sh

How the script works
	•	The script was designed as a SLURM array job
	•	Sample IDs are read from names.txt
	•	For each sample, paired-end FASTQ files are loaded
	•	fastp is used to generate cleaned paired-end reads

Input
	•	Sample list:
data/names.txt
	•	Raw reads:
${SAMPLE}_1.fastq.gz
${SAMPLE}_2.fastq.gz

Output
	•	Trimmed paired-end reads:
trimmed/${SAMPLE}_1.fq.gz
trimmed/${SAMPLE}_2.fq.gz

Run command

sbatch scripts/02_trim.sh

Command used in the script

fastp -i $FILE1 -I $FILE2 -o $OUT${SAMPLE}_1.fq.gz -O $OUT${SAMPLE}_2.fq.gz

Why this step matters
This stage improves the quality of the reads used for alignment and reduces the influence of technical artefacts from raw sequencing data.

⸻

Step 3 — Reference genome indexing (BWA)

Purpose
Before read alignment, the dog reference genome had to be indexed using bwa index. This creates the files required for efficient alignment with BWA.

Script
	•	scripts/03_index_reference.sh

Input
	•	Reference genome:
ROS_Cfam.fa

Output
	•	BWA index files (.amb, .ann, .bwt, .pac, .sa)

Run command

sbatch scripts/03_index_reference.sh

Command used

bwa index ROS_Cfam.fa

Why this step matters
BWA cannot align reads until the reference genome has been indexed. This is a one-time preparatory step.

⸻

Step 4 — Read alignment and BAM generation

Purpose
Trimmed reads were aligned to the dog reference genome using bwa mem. The alignments were then converted into BAM format, sorted, and indexed using samtools.

Script
	•	scripts/04_align_and_make_bam.sh

Tools used
	•	bwa mem
	•	samtools view
	•	samtools sort
	•	samtools index

Input
	•	Trimmed paired-end FASTQ files
	•	Indexed dog reference genome

Process
	1.	Align trimmed reads to the reference genome
	2.	Convert SAM output to BAM
	3.	Sort BAM files
	4.	Index BAM files

Run command

sbatch scripts/04_align_and_make_bam.sh

Commands used

bwa mem -t 8 $REF $FILE1 $FILE2 | samtools view -bh - > aligned.bam
samtools sort aligned.bam -o sorted.bam
samtools index sorted.bam

Output
	•	Sorted BAM files:
BAM/${SAMPLE}_sort.bam
	•	BAM index files:
BAM/${SAMPLE}_sort.bam.bai

Why this step matters
Alignment places sequencing reads onto the reference genome so that variants can later be identified. BAM sorting and indexing are required for efficient downstream variant calling.

⸻

Step 5 — BAM indexing fixes and supplementary BAM processing

Purpose
Additional scripts were included to correct or regenerate BAM indexes where needed.

Scripts
	•	scripts/03b_fix_bam_indexes.sh
	•	scripts/04c_bam_index.sh

Why these scripts exist
In practice, BAM workflows often need small correction steps if indexing fails for a subset of files or if indexes need to be regenerated separately. Including these scripts improves reproducibility and documents the exact working analysis environment.

⸻

Step 6 — Variant calling (bcftools)

Purpose
After alignment, genetic variants were identified across the aligned samples using bcftools mpileup and bcftools call.

Script
	•	scripts/05_call_variants.sh

Input
	•	Sorted BAM files from the alignment step
	•	Dog reference genome

Run command

sbatch scripts/05_call_variants.sh

Command used

bcftools mpileup -f REF BAM/*_sort.bam | bcftools call -mv -Ov -o result.vcf

Output
	•	Raw VCF file:
result.vcf

Why this step matters
This is the stage where sequence differences relative to the reference genome are converted into a variant file for further filtering and downstream genotype analysis.

⸻

Step 7 — Variant filtering

Purpose
The raw VCF contained many variants that were not suitable for GWAS. Filtering was applied to remove low-quality, low-information, and non-biallelic variants.

Script
	•	scripts/06_filter_variants.sh

Tools used
	•	vcftools
	•	bcftools

Filtering criteria
	•	Minor allele frequency (MAF) ≥ 0.05
	•	Missingness threshold
	•	Quality threshold
	•	Depth filtering
	•	Removal of indels
	•	Retention of biallelic SNPs only

Run command

sbatch scripts/06_filter_variants.sh

Output
	•	Filtered VCF files, including:
dog_80b.vcf.gz

Why this step matters
GWAS requires high-quality genotype data. Filtering removes variants that are likely to be unreliable or uninformative and standardises the dataset before PLINK-based analysis.

⸻

Step 8 — Conversion of filtered variants to PLINK format

Purpose
The filtered VCF data were converted into PLINK binary format to allow downstream genotype analysis and summary missingness checks.

Script
	•	scripts/07_convert_to_plink.sh

Run command

sbatch scripts/07_convert_to_plink.sh

Command used

plink --vcf input.vcf.gz --make-bed --out output

Output
	•	PLINK binary files:
.bed, .bim, .fam

Why this step matters
PLINK format is required for efficient genotype filtering, PCA, and GWAS analysis.

⸻

Step 9 — Import of externally imputed genotype data

Purpose
An externally imputed VCF was imported into PLINK format for downstream genotype QC and association testing.

Script
	•	scripts/08_import_imputed_plink.sh

Input
	•	Imputed VCF:
/share/BioinfMSc/Hannah_resources/doggies/doggies_snps_imputed.vcf.gz

Run command

sbatch scripts/08_import_imputed_plink.sh

Output
	•	PLINK files for the imputed dataset:
doggies_raw.*

Why this step matters
The imputed dataset provided the genotype matrix that was then cleaned and used for PCA and GWAS.

⸻

Step 10 — Genotype quality control (PLINK)

Purpose
Before association testing, genotype quality control was applied to remove low-quality SNPs and individuals based on missingness and allele frequency.

Script
	•	scripts/09_genotype_qc.sh

Filtering thresholds
	•	SNP missingness ≤ 30%
	•	Individual missingness ≤ 60%
	•	Minor allele frequency ≥ 0.1

Run command

sbatch scripts/09_genotype_qc.sh

Example command

plink --bfile input --geno 0.3 --mind 0.6 --maf 0.1 --make-bed --out output

Output
	•	QC-filtered PLINK dataset for downstream PCA and GWAS

Why this step matters
GWAS results are only as good as the quality of the underlying genotype data. This filtering step reduces false positives caused by poor-quality markers or samples.

⸻

Step 11 — Principal component analysis (PCA)

Purpose
PCA was used to examine population structure and potential stratification in the genotype data.

Input
	•	QC-filtered PLINK genotype dataset

Output
	•	Eigenvalues
	•	Eigenvectors

Why this step matters
Population structure can confound association results. PCA helps assess whether there is measurable structure in the dataset and supports interpretation of GWAS results.

⸻

Step 12 — Genome-wide association study (GWAS)

Purpose
The final aim of the pipeline was to identify SNPs associated with the two traits of interest: height and weight.

Script
	•	scripts/10_run_gwas.sh

Method
	•	Linear regression using PLINK

Input
	•	QC-filtered genotype data
	•	Phenotype files:
	•	data/height_2.txt
	•	data/weight_2.txt

Run command

sbatch scripts/10_run_gwas.sh

Commands used

plink --bfile input --pheno height.txt --linear --out gwas_height
plink --bfile input --pheno weight.txt --linear --out gwas_weight

Output
	•	gwas_height.assoc.linear
	•	gwas_weight.assoc.linear

How the GWAS results were generated
The GWAS results were generated by combining:
	1.	the imputed genotype data imported into PLINK,
	2.	genotype QC filtering,
	3.	phenotype files for height and weight,
	4.	linear regression in PLINK.

For each SNP, PLINK tested whether genotype variation was associated with phenotype variation across the dogs in the dataset. This produced .assoc.linear output files containing regression statistics and p-values for each tested SNP.

Why this step matters
This is the final analytical stage of the project and directly addresses the biological question of which genomic regions are associated with variation in dog height and weight.

⸻

How to Run the Pipeline
	1.	Clone the repository:

git clone https://github.com/parsaf2000/life4136-rotation3-group2-dog-gwas.git
cd life4136-rotation3-group2-dog-gwas

	2.	Activate environment:

conda env create -f environment.yml
conda activate R3G2

	3.	Submit jobs in order:

sbatch scripts/02_trim.sh
sbatch scripts/03_index_reference.sh
sbatch scripts/04_align_and_make_bam.sh
sbatch scripts/05_call_variants.sh
sbatch scripts/06_filter_variants.sh
sbatch scripts/07_convert_to_plink.sh
sbatch scripts/08_import_imputed_plink.sh
sbatch scripts/09_genotype_qc.sh
sbatch scripts/10_run_gwas.sh

Full reproduction requires access to the original HPC data locations listed in the Data Description section.

⸻

Key Findings (Summary)

GWAS identified strong association signals for both traits:
	•	Height: Strongest signals located on chromosome NC_049239.1 (~20.6 Mb), with p-values on the order of 10^-18.
	•	Weight: Strongest signals observed on chromosome NC_049246.1 (~44.9 Mb), with p-values around 10^-16.

These findings indicate genomic regions associated with morphological variation in dogs.

PCA results indicated measurable population structure, supporting the importance of controlling for stratification in GWAS.

⸻

Repository Structure

├── scripts/        # Pipeline scripts
├── data/           # Input metadata and phenotype files
├── results/        # Summary outputs
├── docs/           # Notes and documentation
├── environment.yml # Conda environment
├── README.md       # Project documentation


⸻

Reproducibility Notes
	•	Large files (FASTQ, BAM, full VCF, full GWAS outputs) are not included due to size constraints.
	•	The pipeline is reproducible on HPC systems with SLURM.
	•	Paths may require adjustment depending on system configuration.

⸻

Limitations
	•	FastQC script is currently unavailable due to permission restrictions.
	•	Plot files (Manhattan/PCA) are not included but can be added.
	•	Some scripts may require path adjustments outside the HPC environment.

⸻

Author

Mohammad Parsa Faraji
Hannah Byrne
Mengchan Liu
University of Nottingham
Bioinformatics Rotation 3


