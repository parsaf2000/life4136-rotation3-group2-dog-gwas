#!/bin/bash
#SBATCH --partition=defq
#SBATCH --job-name=makebam_test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=16g
#SBATCH --time=1:00:00
#SBATCH --mail-user=mbxhb5@nottingham.ac.uk
#SBATCH --output=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logOut/slurm-%x-%j.out
#SBATCH --error=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logErr/slurm-%x-%j.err
#SBATCH --array=0-5
#SBATCH --mail-type=ALL

source $HOME/.bash_profile
conda activate R3G2

# Load software
module load samtools-uoneasy/1.18-GCC-12.3.0

mapfile -t ROOTS < /share/BioinfMSc/life4136_2526/rotation3/group2/index_names.txt

SAMPLE=${ROOTS[$SLURM_ARRAY_TASK_ID]}
cd /share/BioinfMSc/life4136_2526/rotation3/group2/BAM/sorted
samtools index ${SAMPLE}_sort.bam

conda deactivate
