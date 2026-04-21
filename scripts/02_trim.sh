#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=100g
#SBATCH --time=2:00:00
#SBATCH --job-name=fastp
#SBATCH --output=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logOut/slurm-%x-%j.out
#SBATCH --error=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logErr/slurm-%x-%j.err
#SBATCH --array=0-114 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mbxhb5@nottingham.ac.uk

#source bash profile to use conda
source $HOME/.bash_profile

#activate conda environment
conda activate R3G2

# Load sample names into an array
mapfile -t ROOTS < /share/BioinfMSc/life4136_2526/rotation3/group2/names.txt

# Get the current sample name based on SLURM_ARRAY_TASK_ID
SAMPLE=${ROOTS[$SLURM_ARRAY_TASK_ID]}

# Set file paths
FILE1=/share/BioinfMSc/Hannah_resources/doggies/fastqs/${SAMPLE}_1.fastq.gz
FILE2=/share/BioinfMSc/Hannah_resources/doggies/fastqs/${SAMPLE}_2.fastq.gz
OUTPUT=/share/BioinfMSc/life4136_2526/rotation3/group2/trimmed/

fastp -i $FILE1 -I $FILE2 -o $OUT${SAMPLE}_1.fq.gz -O $OUT${SAMPLE}_2.fq.gz

conda deactivate
