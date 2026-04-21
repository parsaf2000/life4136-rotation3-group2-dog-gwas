# Data description

## Project
Dog GWAS for height and weight.

## Raw sequencing reads
Raw paired-end FASTQ files were used as the starting point for the analysis. The original reads were taken from:

`/share/BioinfMSc/Hannah_resources/doggies/fastqs/`

These files are not stored directly in this repository because of their size.

## Sample metadata
- `names.txt`: list of sample IDs used across the analysis pipeline

## Phenotype files
- `height_2.txt`: phenotype file used for the height GWAS
- `weight_2.txt`: phenotype file used for the weight GWAS

## Reference genome
Reads were aligned to the dog reference genome:

`ROS_Cfam.fa`

Reference files were stored in:

`/share/BioinfMSc/life4136_2526/rotation3/group2/ref_genome/`

## Imputed genotype data
An imputed VCF used for downstream PLINK processing and genotype QC was taken from:

`/share/BioinfMSc/Hannah_resources/doggies/doggies_snps_imputed.vcf.gz`

## Notes
Large raw and intermediate files such as FASTQ, BAM, full VCF, and full GWAS/PCA result files are described here but are not stored directly in the GitHub repository.
