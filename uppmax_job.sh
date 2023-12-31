#!/bin/bash -l 
# tell it is bash language and -l is for starting a session with a "clean environment, e.g. with no modules loaded and paths reset"

#SBATCH -A naiss2023-XX-XXXX  # Which compute project?

#SBATCH -p core  # Type of queue? core, node, (for short development jobs and tests: devcore, devel)

#SBATCH -n 4  # How many cores?

#SBATCH -t 0-03:00:00  # How long at most?

#SBATCH -J NRTN_test  # Name of the job

# go to directory
cd /proj/yourProjectFolder/rnaseq_public_datasets
pwd -P

# load software modules
module load python/3.6.0
module load bioinfo-tools
module load FastQC/0.11.9
module load MultiQC/1.12
module load TrimGalore/0.6.1
module load cutadapt/4.5
module load samtools/1.10
module load htslib/1.10
module load star/2.7.11a
module load rseqc/2.6.4
module load subread/2.0.3

# Run script
./main.sh