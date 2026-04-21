#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=5g
#SBATCH --time=00:10:00
#SBATCH --job-name=bam_index
#SBATCH --output=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/%x-%j.out
#SBATCH --error=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/%x-%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=alyml51@nottingham.ac.uk

source ~/miniconda3/etc/profile.d/conda.sh
conda activate rotation3

samtools index /share/BioinfMSc/life4136_2526/rotation3/group2/BAM/SRR1105792_aligned.bam
samtools index /share/BioinfMSc/life4136_2526/rotation3/group2/BAM/SRR7107534_aligned.bam
samtools index /share/BioinfMSc/life4136_2526/rotation3/group2/BAM/SRR7107615_aligned.bam
