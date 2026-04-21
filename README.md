# LIFE4136 Rotation 3 Group 2: Dog GWAS for Height and Weight

## Input data
See `data/README.md` for full details.

Main inputs:
- raw FASTQ files from `/share/BioinfMSc/Hannah_resources/doggies/fastqs/`
- sample names in `data/names.txt`
- phenotype files `data/height_2.txt` and `data/weight_2.txt`
- dog reference genome `ROS_Cfam.fa`
- imputed VCF `/share/BioinfMSc/Hannah_resources/doggies/doggies_snps_imputed.vcf.gz`

## Software and dependencies
This workflow used:
- FastQC
- fastp
- bwa
- samtools
- bcftools
- vcftools
- plink
- SLURM
- conda environments including `R3G2` and `vcf_env`

A minimal environment file is provided in `environment.yml`.

## Workflow summary
1. Run quality control on raw reads using FastQC.
2. Trim paired-end reads using `fastp`.
3. Index the dog reference genome using `bwa index`.
4. Align trimmed reads to the reference using `bwa mem`.
5. Convert, sort, and index BAM files using `samtools`.
6. Call variants using `bcftools mpileup` and `bcftools call`.
7. Filter variants using `vcftools` and `bcftools`.
8. Convert filtered variants to PLINK format.
9. Import imputed variants and perform genotype QC.
10. Assess population structure using PCA.
11. Run GWAS for height and weight using PLINK linear regression.

## Scripts
Included scripts:
- `scripts/02_trim.sh` – trims paired-end FASTQ files using fastp
- `scripts/03_index_reference.sh` – builds the BWA index for the dog reference genome
- `scripts/03b_fix_bam_indexes.sh` – indexes selected BAM files
- `scripts/04_align_and_make_bam.sh` – aligns trimmed reads to the reference and creates sorted/indexed BAM files
- `scripts/04b_sort_bam.sh` – alternative BAM sorting/indexing step used during workflow development
- `scripts/04c_bam_index.sh` – indexes BAM files for selected samples
- `scripts/05_call_variants.sh` – calls variants from BAM files using bcftools
- `scripts/06_filter_variants.sh` – filters variants by quality, depth, missingness, and allele structure
- `scripts/07_convert_to_plink.sh` – converts filtered VCF files into PLINK format
- `scripts/08_import_imputed_plink.sh` – imports imputed genotype data into PLINK format
- `scripts/09_genotype_qc.sh` – applies genotype/sample missingness and MAF filtering
- `scripts/10_run_gwas.sh` – runs GWAS for height and weight using PLINK linear regression

`01_fastqc.sh` will be added later once the original file is accessible.

## Suggested execution order
1. Run FastQC on the raw FASTQ files.
2. Run `scripts/02_trim.sh`
3. Run `scripts/03_index_reference.sh`
4. Run `scripts/04_align_and_make_bam.sh`
5. Run `scripts/05_call_variants.sh`
6. Run `scripts/06_filter_variants.sh`
7. Run `scripts/07_convert_to_plink.sh`
8. Run `scripts/08_import_imputed_plink.sh`
9. Run `scripts/09_genotype_qc.sh`
10. Perform PCA
11. Run `scripts/10_run_gwas.sh`

## Main findings

### Height GWAS
The strongest association signal for height was concentrated on chromosome/reference sequence `NC_049239.1`, around approximately 20.6 Mb. The top hits in this region had p-values on the order of `10^-18`, indicating a very strong association signal in this dataset.

Examples from the strongest height hits:
- `NC_049239.1 : 20668261`, p = `3.11e-18`
- `NC_049239.1 : 20606845`, p = `3.815e-18`
- `NC_049239.1 : 20668011`, p = `3.93e-18`

### Weight GWAS
The strongest association for weight was observed on `NC_049246.1` at approximately 44.93 Mb, with additional strong signals across multiple chromosomes.

Examples from the strongest weight hits:
- `NC_049246.1 : 44931263`, p = `9.568e-16`
- `NC_049228.1 : 27276918`, p = `4.989e-15`
- `NC_049230.1 : 44495105`, p = `1.365e-14`
- `NC_049223.1 : 68978900`, p = `1.695e-14`
- `NC_049232.1 : 13775938`, p = `1.968e-14`

### PCA
PCA was performed successfully and produced eigenvalue and eigenvector outputs. The first few eigenvalues were:
- `8.67264`
- `4.91413`
- `4.76942`
- `4.4155`
- `4.1151`

These results indicate measurable structure in the genotype data and support the inclusion of population-structure-aware interpretation in the GWAS workflow.

## Repository results

### GWAS summaries
The full GWAS outputs were generated on the shared system in:

`/share/BioinfMSc/life4136_2526/rotation3/group2/gwas/`

Key full files:
- `gwas_height.assoc.linear`
- `gwas_weight.assoc.linear`

Repository summaries:
- `results/gwas/gwas_height_head.txt`
- `results/gwas/gwas_weight_head.txt`
- `results/gwas/gwas_height_linecount.txt`
- `results/gwas/gwas_weight_linecount.txt`

### PCA summaries
The full PCA outputs were generated in:

`/share/BioinfMSc/life4136_2526/rotation3/group2/PCA/`

Repository summaries:
- `results/pca/pca20_eigenval_head.txt`
- `results/pca/pca20_eigenvec_head.txt`

### Variant filtering summaries
- `results/vcf/dog_70b.vcf.gz.SNPS.txt`
- `results/vcf/dog_80b.vcf.gz.SNPS.txt`

## Limitations and future additions
- The original FastQC script is not yet included because the source file was not readable at the time of repository preparation.
- Plot files were not present in the project directory at the time of repository preparation and can be added later.
- Some original scripts may need minor path cleanup before rerunning in a new environment.
- Large raw and intermediate files are intentionally excluded from GitHub to keep the repository clear, portable, and reproducible.
