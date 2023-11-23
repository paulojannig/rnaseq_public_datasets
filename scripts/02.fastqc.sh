#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#
# DESCRIPTION:
# This script performs FastQC on FASTQ files.
#
# USAGE:
# 1. Change parameters and follow instructions within "SETUP SCRIPT"
# 2. Run the script using the command: 
#   nohup ./03.fastqc >> ../logs/log.03.fastqc.txt
#
# REQUIREMENTS:
# - FastQC
# - MultiQC
#
# INPUT:
#   Fastq files
#     Files stored in ${PROJECT_FOLDER}/fastq/
#
###########################################################################################

# ===========================================================================================
# SETUP SCRIPT
# ===========================================================================================
source config.sh

# Name your experiment:
EXPERIMENT_NAME="FastQC"

# ===========================================================================================
# Script starts here...
# ===========================================================================================

# create dependencies ------------
mkdir -p ${PROJECT_FOLDER}/00_reports/
mkdir -p ${PROJECT_FOLDER}/02_results/quality_control/fastqc


# Start logging ------------
echo " ========================================================================================== "
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT_NAME}"
echo "========================================================================================== "
printf "\n"

cd ${PROJECT_FOLDER}/fastq/
EXTENSION=$(ls | head -1 | sed 's/.*\.//')
FQ_FORMAT=$(ls | head -1 | cut -d'.' -f2)

echo " ========================= Listing and counting fastq files =============================== "
COUNTER=0
for FILE in `ls *.${FQ_FORMAT}.${EXTENSION} | sed "s/\.${FQ_FORMAT}.${EXTENSION}//g" | sort -u`
do
((COUNTER++))
printf "\n"
echo "${FILE}.${FQ_FORMAT}.${EXTENSION}"
done
printf "\n"
echo "Number of fastq files: $COUNTER"
echo " ========================================================================================== "
printf "\n"

COUNTER_TOTAL=$COUNTER
COUNTER=0
echo " ============================== Starting analysis ..... =================================== "
for FILE in `ls *.${FQ_FORMAT}.${EXTENSION} | sed "s/\.${FQ_FORMAT}.${EXTENSION}//g" | sort -u`
do
((COUNTER++))
printf "\n"
echo " ========================================================================================== "
echo `date`
echo "Sample: ${FILE}"
echo "Sample ${COUNTER} out of ${COUNTER_TOTAL}"
echo " ========================================================================================== "
printf "\n"

echo " ==================== FastQC ==================== "
fastqc -t ${THREADN} \
  -o ${PROJECT_FOLDER}/02_results/quality_control/fastqc \
  ${FILE}.${FQ_FORMAT}.${EXTENSION}
done
printf "\n"

echo " ==================== Creating MultiQC report ==================== " `date`
multiqc \
  --force \
  --filename "01.pre_trimming.QC.html" \
  --title "${EXPERIMENT_NAME}" \
  --outdir ${PROJECT_FOLDER}/00_reports/ \
  ${PROJECT_FOLDER}/02_results/quality_control/fastqc
printf "\n"

echo " =================================== Software versions =================================== "
echo `fastqc --version`
echo `multiqc --version`
echo "Versions printed on 00_reports/software_versions.txt"
echo `fastqc --version` >> ${PROJECT_FOLDER}/00_reports/software_versions.txt
echo `multiqc --version` >> ${PROJECT_FOLDER}/00_reports/software_versions.txt
echo " ========================================================================================== "
printf "\n"
echo "Done!" `date`