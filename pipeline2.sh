#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
# Last Updated: 2023-11-21
#
# Pipeline 2: # Analyzing public datasets
#     
# DESCRIPTION:
#   - Download deposited Fastq files
#   - Quality control: FastQC and TrimGalore!
#   - Genome alignment: STAR
#   - Gene level counts: featureCounts
#
# REQUIREMENTS:
# - python3 (>= v3.6)
# - SRA toolkit https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
# - sradownloader https://github.com/s-andrews/sradownloader
# - FastQC
# - MultiQC
# - Trim Galore!
# - cutadapt
# - STAR
# - Samtools
# - infer_experiment.py (RSeQC)
# - featureCounts (from Subread package)
#
# USAGE:
#   1. Download the SraRunTable.txt using SRA Run Selector tool (https://www.ncbi.nlm.nih.gov/Traces/study/)
#       ## e.g. go to https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA648376      	
#           ## click on Metadata to download the SraRunTable.txt file containing all or selected samples
#           ## Save the file 'SraRunTable.txt' to the directory ${PROJECT_FOLDER}/02_metadata
#           ## Check if there are fastq files that belong to the same sample. This files have to be merged
#   2. Change parameters in the config.txt file
#   3. Check ./scripts/01.setup.environment.sh and modify "Organize and merge fastq files" section to your needs
#       ## merge fastq files from multiple lanes
#   4. Run this script using the command: ./main.sh
#   
#
nohup ./scripts/00.sradownloader.sh
nohup ./scripts/01.setup.environment.sh
nohup ./scripts/02.fastqc.sh >> logs/log.01.fastqc.txt
nohup ./scripts/03.trimgalore.sh >> logs/log.02.trimgalore.txt
nohup ./scripts/04.star.alignment.sh >> logs/log.03.star.alignment.txt
nohup ./scripts/05.infer_experiment.sh >> logs/log.04.infer_experiment.txt
nohup ./scripts/06.featureCounts.sh >> logs/log.05.featureCounts.txt
