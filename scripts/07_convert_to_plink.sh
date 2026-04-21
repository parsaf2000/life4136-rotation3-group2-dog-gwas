#!/bin/bash
#SBATCH --partition=defq
#SBATCH --job-name=plink_convert
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=16g
#SBATCH --time=1:00:00
#SBATCH --mail-user=mbxhb5@nottingham.ac.uk
#SBATCH --output=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logOut/slurm-%x-%j.out
#SBATCH --error=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logErr/slurm-%x-%j.err
#SBATCH --mail-type=ALL

#source bash profile to use conda
source $HOME/.bash_profile

#activate conda environment
conda activate R3G2

VCF8=/share/BioinfMSc/life4136_2526/rotation3/group2/vcf/dog_80b.vcf.gz
VCF7=/share/BioinfMSc/life4136_2526/rotation3/group2/vcf/dog_70b.vcf.gz
OUT=/share/BioinfMSc/life4136_2526/rotation3/group2/vcf
#Converto
plink --vcf $VCF8 --double-id --allow-extra-chr --make-bed --out $OUT/doggies_8_raw
plink --vcf $VCF7 --double-id --allow-extra-chr --make-bed --out $OUT/doggies_7_raw
#Run QC
plink --bfile $OUT/doggies_8_raw --missing --allow-extra-chr --out doggies_8_missing
plink --bfile $OUT/doggies_7_raw --missing --allow-extra-chr --out doggies_7_missing

conda deactivate
