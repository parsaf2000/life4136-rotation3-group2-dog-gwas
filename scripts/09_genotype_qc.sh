#!/bin/bash
#SBATCH --partition=defq
#SBATCH --job-name=geno_qc
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

RAW=/share/BioinfMSc/life4136_2526/rotation3/group2/imputed/doggies_raw
OUT=/share/BioinfMSc/life4136_2526/rotation3/group2/imputed

plink --bfile $RAW --allow-extra-chr --geno 0.3 --mind 0.6 --maf 0.1 --make-bed --out $OUT/doggies_qc

conda deactivate
