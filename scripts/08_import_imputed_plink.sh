#!/bin/bash
#SBATCH --partition=defq
#SBATCH --job-name=
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

VCF_IMP=/share/BioinfMSc/Hannah_resources/doggies/doggies_snps_imputed.vcf.gz
cd /share/BioinfMSc/life4136_2526/rotation3/group2/imputed

plink --vcf $VCF_IMP --double-id --allow-extra-chr --make-bed --out doggies_raw

plink --bfile doggies_raw --missing --allow-extra-chr --out doggies_missing

conda deactivate
