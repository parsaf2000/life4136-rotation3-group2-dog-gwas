#!/bin/bash
#SBATCH --partition=defq
#SBATCH --job-name=makebam
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --mem=16g
#SBATCH --time=1:00:00
#SBATCH --output=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logOut/slurm-%x-%j.out
#SBATCH --error=/share/BioinfMSc/life4136_2526/rotation3/group2/scripts/logErr/slurm-%x-%j.err
#SBATCH --mail-user=mbxhb5@nottingham.ac.uk
#SBATCH --mail-type=ALL

module load bwa-uoneasy/0.7.17-GCCcore-12.3.0

bwa index /share/BioinfMSc/life4136_2526/rotation3/group2/ref_genome/ROS_Cfam.fa
