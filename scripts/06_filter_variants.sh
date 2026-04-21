#!/bin/bash
#SBATCH --partition=defq
#SBATCH --job-name=vcf_filter
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=16g
#SBATCH --time=1:00:00
#SBATCH --mail-user=mbxhb5@nottingham.ac.uk
#SBATCH --output=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logOut/slurm-%x-%j.out
#SBATCH --error=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logErr/slurm-%x-%j.err
#SBATCH --mail-type=ALL

module load bcftools-uoneasy/1.18-GCC-13.2.0
module load vcftools-uoneasy/0.1.16-GCC-12.3.0

VCF_IN=/share/BioinfMSc/life4136_2526/rotation3/group2/vcf/doggies_snps.vcf.gz
VCF_OUT=/share/BioinfMSc/life4136_2526/rotation3/group2/vcf/dog_80.vcf.gz

# set filters
# Minor allele frequency
MAF=0.05
# Missing data - is inverted, means that genotype call present 70 individuals
MISS=0.80
# Quality filter
QUAL=30
# Only retain positions that are enither to deeply sequenced or at low depth - both may be due to errors 
MIN_DEPTH=1
MAX_DEPTH=50

# Use vcftools to filter data
vcftools --gzvcf $VCF_IN \
--remove-indels --maf $MAF --max-missing $MISS --minQ $QUAL \
--min-meanDP $MIN_DEPTH --max-meanDP $MAX_DEPTH \
--minDP $MIN_DEPTH --maxDP $MAX_DEPTH --recode --stdout | bgzip -c > \
$VCF_OUT

# Use bcftools to only retain biallelic sites.
VCF_OUT=/share/BioinfMSc/life4136_2526/rotation3/group2/vcf/dog_80.vcf.gz
VCFB=/share/BioinfMSc/life4136_2526/rotation3/group2/vcf/dog_80b.vcf.gz

# Keep bi-allelic SNPs, get rid of indels, write file to compressed vcf
bcftools view -M2 -m2 -v snps -Oz -o $VCFB $VCF_OUT
# Count number of SNPs in filtered VCF
bcftools view -H $VCFB | wc -l > $VCFB.SNPS.txt

bcftools index $VCF_OUT
