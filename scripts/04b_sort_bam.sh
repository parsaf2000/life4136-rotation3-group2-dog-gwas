#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=100g
#SBATCH --time=2:00:00
#SBATCH --job-name=sortBAM
#SBATCH --output=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logOut/slurm-%x-%j.out
#SBATCH --error=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logErr/slurm-%x-%j.err
#SBATCH --array=0-96 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mbxhb5@nottingham.ac.uk

source $HOME/.bash_profile
conda activate R3G2

# Load software
module load samtools-uoneasy/1.18-GCC-12.3.0

mapfile -t ROOTS < /share/BioinfMSc/life4136_2526/rotation3/group2/sort_names.txt

SAMPLE=${ROOTS[$SLURM_ARRAY_TASK_ID]}
OUTFILE=/share/BioinfMSc/life4136_2526/rotation3/group2/BAM/sorted
cd /share/BioinfMSc/life4136_2526/rotation3/group2/BAM


samtools sort /aligned/${SAMPLE}_aligned.bam -o $OUTFILE

samtools index /sorted/${SAMPLE}_sort.bam

conda deactivate
