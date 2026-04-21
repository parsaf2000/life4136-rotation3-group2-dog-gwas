#!/bin/bash
#SBATCH --partition=defq
#SBATCH --job-name=makebam
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=16g
#SBATCH --output=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logOut/slurm-%x-%j.out
#SBATCH --error=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logErr/slurm-%x-%j.err
#SBATCH --time=24:00:00
#SBATCH --mail-user=mbxhb5@nottingham.ac.uk
#SBATCH --mail-type=ALL
#SBATCH --array=0-114

source $HOME/.bash_profile
conda activate R3G2

# Load software
module load samtools-uoneasy/1.18-GCC-12.3.0
module load bwa-uoneasy/0.7.17-GCCcore-12.3.0

# Load sample names into an array
mapfile -t ROOTS < /share/BioinfMSc/life4136_2526/rotation3/group2/names.txt
# Get the current sample name based on SLURM_ARRAY_TASK_ID
SAMPLE=${ROOTS[$SLURM_ARRAY_TASK_ID]}
# Set file paths - trimmed fastqs
FILE1=/share/BioinfMSc/life4136_2526/rotation3/group2/trimmed/${SAMPLE}_1.fq.gz 
FILE2=/share/BioinfMSc/life4136_2526/rotation3/group2/trimmed/${SAMPLE}_2.fq.gz
# Reference genome Needs to be indexed
REF=/share/BioinfMSc/life4136_2526/rotation3/group2/ref_genome/ROS_Cfam.fa
#Output file path
cd /share/BioinfMSc/life4136_2526/rotation3/group2 
mkdir -p BAM

bwa mem -t 8 $REF $FILE1 $FILE2 | samtools view -bh - > BAM/${SAMPLE}_aligned.bam
samtools sort BAM/${SAMPLE}_aligned.bam -o BAM/${SAMPLE}_sort.bam
samtools index BAM/${SAMPLE}_sort.bam

conda deactivate
