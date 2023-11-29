#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#
# DESCRIPTION:
# This script removes adaptors from FASTQ files using Trim Galore! and cutadapt, 
# runs FastQC on the trimmed files, and then creates a final MultiQC report
#
# REQUIREMENTS:
# - Trim Galore!
# - cutadapt
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

EXPERIMENT_NAME="Trimming Fastq files"

if [ $THREADN > 4 ]
then 
  THREADN=4
else
  THREADN=$THREADN
fi

# create dependencies ------------
mkdir -p ${DATASET}/02_results/
mkdir -p ${DATASET}/02_results/trimgalore
mkdir -p ${DATASET}/02_results/quality_control/trimgalore

# Start logging ------------
echo "=========================================================================================="
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT_NAME}"
echo "=========================================================================================="
printf "\n"
echo "========================= Listing and counting fastq files ==============================="
printf "\n"

cd ${DATASET}/fastq
COUNTER=0
for FILE in `ls *${SUFFIX1} | sed "s/${SUFFIX1}//g" | sort -u`
do
((COUNTER++))

if [ $READ_TYPE = "PE" ]
then 
  printf "\n"
  echo "Read 1: ${FILE}${SUFFIX1}"
  echo "Read 2: ${FILE}${SUFFIX2}"
else
  echo "${FILE}${SUFFIX1}"
fi
done

printf "\n"
if [ $READ_TYPE = "PE" ]
then 
  echo "Number of paired files: $COUNTER"
else
  echo "Number of files: $COUNTER"
fi

echo "=========================================================================================="
printf "\n"

COUNTER_TOTAL=$COUNTER
COUNTER=0

echo "============================== Starting analysis ..... ==================================="
for FILE in `ls *${SUFFIX1} | sed "s/${SUFFIX1}//g" | sort -u`
do
((COUNTER++))
printf "\n"
echo "=========================================================================================="
echo `date`
echo "Sample: ${FILE}"
echo "Sample ${COUNTER} out of ${COUNTER_TOTAL}"
echo "=========================================================================================="
printf "\n"

if [ $READ_TYPE = "PE" ]
then 
  trim_galore \
  --cores $THREADN \
  --output_dir ../02_results/trimgalore \
  --paired \
  --gzip \
  --fastqc_args "-o ../02_results/quality_control/trimgalore" \
  ${FILE}${SUFFIX1} \
  ${FILE}${SUFFIX2}
else
  trim_galore \
  --cores $THREADN \
  --output_dir ../02_results/trimgalore \
  --gzip \
  --fastqc_args "-o ../02_results/quality_control/trimgalore" \
  ${FILE}${SUFFIX1}
fi

mv ../02_results/trimgalore/*_trimming_report.txt ../02_results/quality_control/trimgalore
done
echo " Trimming and QC complete! ==============================================================="
printf "\n"

cd ..
echo " ==================== Creating MultiQC report ==================== " `date`
multiqc \
  --force \
  --filename "02.post_trimming.QC.html" \
  --title "${EXPERIMENT_NAME}" \
  --outdir 00_reports/ \
  02_results/quality_control/trimgalore
printf "\n"

echo " ==================== Software versions ==================== "
echo "Trim galore" `trim_galore --version | grep -oE 'version [0-9.]+[0-9]'`
echo "cutadapt version" `cutadapt --version 2>&1 | tail -n 1`
echo `fastqc --version`
echo `multiqc --version`
printf "\n"
echo "Versions printed on 00_reports/software_versions.txt"
echo "trim galore" `trim_galore --version | grep -oE 'version [0-9.]+[0-9]' | awk '{print $2}'` >> 00_reports/software_versions.txt
echo "cutadapt" `cutadapt --version 2>&1 | tail -n 1` >> 00_reports/software_versions.txt
echo "Done!" `date`