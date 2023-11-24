#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#
# DESCRIPTION:
# This script downloads the Fastq files using SRA-tools.
#
# REQUIREMENTS:
# - python3 (>= v3.6)
# - SRA toolkit https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
# - sradownloader https://github.com/s-andrews/sradownloader
#
# USAGE: 
#   - Download the SraRunTable.txt using SRA Run Selector tool (https://www.ncbi.nlm.nih.gov/Traces/study/)
#        For example:
#            - go to https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA648376      	
#            - click on Metadata to download the SraRunTable.txt file containing all or selected samples
#            - Save the file 'SraRunTable.txt' into the directory `dataset_table/`
#            - Check 'SraRunTable.txt' to see if there are fastq files that belong to the same biological replicate. These files will need to be merged. To do that, adjust parameters within "scripts/01.setup.environment.sh" (# To merge fastq files from multiple lanes...)
#
###########################################################################################
source config.sh
source ./scripts/project_info.sh

cd ${DATASET}

echo "================= Downloading Fastq files ================= " `date`
printf "\n"
sradownloader --outdir fastq --threads ${THREADN} 01_metadata/${SRA_FILE}
# Run again in case of failed samples
sradownloader --outdir fastq --threads ${THREADN} 01_metadata/${SRA_FILE}

ls fastq
ls fastq > 01_metadata/downloaded_fastq_files.txt

printf "\n"
echo "Done!" `date`
