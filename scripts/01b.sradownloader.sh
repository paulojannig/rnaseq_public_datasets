#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#
# DESCRIPTION:
# This script downloads the Fastq files using SRA-tools.
#
# USAGE:
# 1. Change parameters and follow instructions within "SETUP SCRIPT"
# 2. Run the script using the command: 
#   nohup ./sradownloader.sh >> ../log.sradownloader.txt
#
# REQUIREMENTS:
# - python3 (>= v3.6)
# - SRA toolkit https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
# - sradownloader https://github.com/s-andrews/sradownloader
#
# USAGE: 
#   - Download the SraRunTable.txt using SRA Run Selector tool (https://www.ncbi.nlm.nih.gov/Traces/study/)
#       For example:
#           - go to https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA648376      	
#           - click on Metadata to download the SraRunTable.txt file containing all or selected samples
#           - Save the file 'SraRunTable.txt' to the directory ${PROJECT_FOLDER}/01_metadata
#           - Check 'SraRunTable.txt' to see if there are fastq files that belong to the same biological replicate. This files will have to be merged. 
#               - For that, adjust parameters within "scripts/01.setup.environment.sh" (# To merge fastq files from multiple lanes...)
#
###########################################################################################

# ===========================================================================================
# SETUP SCRIPT
# ===========================================================================================
# Name your experiment:
EXPERIMENT_NAME="Download FASTQ files"

# ===========================================================================================
# Script starts here...
# ===========================================================================================
source config.sh

# Change to the main directory:
cd ${PROJECT_FOLDER}

# Start logging ------------
echo "=========================================================================================="
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT_NAME}"
echo "=========================================================================================="
printf "\n"
echo "================= Downloading Fastq files ================= " `date`
printf "\n"
sradownloader --outdir ${PROJECT_FOLDER}/fastq --threads ${THREADN} ${PROJECT_FOLDER}/${SRA_FILE}
printf "\n"
echo " ================= Listing all downloaded files ........ =================" `date`
ls ${PROJECT_FOLDER}/fastq
ls ${PROJECT_FOLDER}/fastq > ${PROJECT_FOLDER}/01_metadata/downloaded_fastq_files.txt
printf "\n"
echo "=========================================================================================="
echo "Done!" `date`
