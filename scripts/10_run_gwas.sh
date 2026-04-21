#!/bin/bash
#SBATCH --partition=defq
#SBATCH --job-name=gwas
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

INPUT=/share/BioinfMSc/life4136_2526/rotation3/group2/imputed/doggies_qc
OUTDIR=/share/BioinfMSc/life4136_2526/rotation3/group2/gwas
SHARE=/share/BioinfMSc/life4136_2526/rotation3/group2

plink --bfile $INPUT --allow-extra-chr --allow-no-sex --pheno $SHARE/weight_2.txt --linear --out $OUTDIR/gwas_weight
plink --bfile $INPUT --allow-extra-chr --allow-no-sex --pheno $SHARE/height_2.txt --linear --out $OUTDIR/gwas_height

conda deactivate
