#!/bin/bash -l 
# tell it is bash language and -l is for starting a session with a "clean environment, e.g. with no modules loaded and paths reset"

#SBATCH -A naiss2023-22-1042  # Project name

#SBATCH -p core  # Asking for cores (for test jobs and as opposed to multiple nodes) 

#SBATCH -n 16  # Number of cores

#SBATCH -t 7-00:00:00  # 7 days

#SBATCH -J rnaseq_public_datasets  # Name of the job

# go to directory
cd /proj/ramuscleweakness-2024/rnaseq_public_datasets
pwd -P

# load software modules
module load python/3.6.0
module load bioinfo-tools FastQC/0.11.9
module load bioinfo-tools MultiQC/1.12
module load bioinfo-tools TrimGalore/0.6.1
module load bioinfo-tools cutadapt/4.5

# Run script
./main.sh

#interactive -A naiss2023-22-1042 -p core -n 1 -t 10:00