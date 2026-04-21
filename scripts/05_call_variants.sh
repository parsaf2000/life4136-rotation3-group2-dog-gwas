#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=5g
#SBATCH --time=1:00:00
#SBATCH --job-name=vcf
#SBATCH --output=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logOut/%x-%j.out
#SBATCH --error=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logErr/%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=alyml51@nottingham.ac.uk

source $HOME/.bash_profile
conda activate vcf_env

cd /share/BioinfMSc/life4136_2526/rotation3/group2

bcftools mpileup -f ~/ROS_Cfam.fa BAM/*_sort.bam | \
bcftools call -mv -Ov -o result.vcf 
