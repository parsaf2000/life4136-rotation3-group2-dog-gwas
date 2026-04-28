#!/bin/bash
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=20g
#SBATCH --time=2:00:00
#SBATCH --job-name=fastqc
#SBATCH --output=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logOut/slurm-%x-%j.out
#SBATCH --error=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logErr/slurm-%x-%j.err
#SBATCH --array=0-114 
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mbxhb5@nottngham.ac.uk

#source bash profile to use conda
source $HOME/.bash_profile

#activate conda environment
conda activate R3G2

cd /share/BioinfMSc/Hannah_resources/doggies/fastqs

mapfile -t ROOTS < /share/BioinfMSc/life4136_2526/rotation3/group2/names.txt

SAMPLE=${ROOTS[$SLURM_ARRAY_TASK_ID]}
R1=${SAMPLE}_1.fastq.gz
R2=${SAMPLE}_2.fastq.gz
OUTDIR=/share/BioinfMSc/life4136_2526/rotation3/group2/fastqc

#Run fastqc on R1 reads
fastqc \
 -t 8 \
 --fastq "$R1" \
 -o "$OUTDIR"

 #Run fastqc on R2 reads
fastqc \
 -t 8 \
 --fastq "$R2" \
 -o "$OUTDIR"

conda deactivate

