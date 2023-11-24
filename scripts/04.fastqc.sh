#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#
# DESCRIPTION:
# This script performs FastQC on FASTQ files.
#
# REQUIREMENTS:
# - FastQC
# - MultiQC
#
# INPUT:
#   Fastq files
#     Files stored in ${DATASET}/fastq/
#
###########################################################################################
source config.sh
source ./scripts/project_info.sh

EXPERIMENT_NAME="FastQC"

# create dependencies ------------
mkdir -p ${DATASET}/02_results/quality_control/fastqc

# Start logging ------------
echo " ========================================================================================== "
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT_NAME}"
echo "========================================================================================== "
printf "\n"

cd ${DATASET}/fastq/
#EXTENSION=$(ls | head -1 | sed 's/.*\.//')
#FQ_FORMAT=$(ls | head -1 | cut -d'.' -f2)

echo " ========================= Listing and counting fastq files =============================== "
COUNTER=0
for FILE in `ls *.${FQ_FORMAT} | sed "s/\.${FQ_FORMAT}//g" | sort -u`
do
((COUNTER++))
printf "\n"
echo "${FILE}.${FQ_FORMAT}"
done
printf "\n"
echo "Number of fastq files: $COUNTER"
echo " ========================================================================================== "
printf "\n"

COUNTER_TOTAL=$COUNTER
COUNTER=0
echo " ============================== Starting analysis ..... =================================== "
for FILE in `ls *.${FQ_FORMAT} | sed "s/\.${FQ_FORMAT}//g" | sort -u`
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
  -o ../02_results/quality_control/fastqc \
  ${FILE}.${FQ_FORMAT}
done
printf "\n"

cd ..
echo " ==================== Creating MultiQC report ==================== " `date`
multiqc \
  --force \
  --filename "01.pre_trimming.QC.html" \
  --title "${EXPERIMENT_NAME}" \
  --outdir 00_reports/ \
  02_results/quality_control/fastqc
printf "\n"

echo " =================================== Software versions =================================== "
echo `fastqc --version`
echo `multiqc --version`
echo "Versions printed on 00_reports/software_versions.txt"
echo `fastqc --version` >> 00_reports/software_versions.txt
echo `multiqc --version` >> 00_reports/software_versions.txt
echo " ========================================================================================== "
printf "\n"
echo "Done!" `date`