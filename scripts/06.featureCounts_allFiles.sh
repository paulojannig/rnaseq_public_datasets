#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#
# DESCRIPTION:
# featureCounts to obtain gene counts from the aligned reads.
#
# USAGE:
# 1. Change parameters and follow instructions within "SETUP SCRIPT"
# 2. Run the script using the command: 
#   nohup ./07.featureCounts.sh >> ../logs/log.07.featureCounts.txt
#
# REQUIREMENTS:
# - featureCounts (from Subread package)
#
# INPUT:
#   Bam files
#
###########################################################################################

# ===========================================================================================
# SETUP SCRIPT
# ===========================================================================================
source config.sh

# Name your experiment:
EXPERIMENT_NAME="featureCounts"

# ===========================================================================================
# Script starts here...
# ===========================================================================================

# create dependencies ------------
mkdir -p ${PROJECT_FOLDER}/02_results/counts/featureCounts
mkdir -p ${PROJECT_FOLDER}/02_results/deseq2/
mkdir -p ${PROJECT_FOLDER}/02_results/quality_control/counts

echo "=========================================================================================="
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT_NAME}"
echo "=========================================================================================="
cd ${PROJECT_FOLDER}/02_results/bam

if [ ${READ_TYPE} = "SE" ]
then 
  featureCounts \
    -T ${THREADN} \
    -t exon \
    -s ${STRANDNESS} \
    -a ${ANNOTATION}.gtf \
    -o ${PROJECT_FOLDER}/02_results/counts/featureCounts/featureCounts_output.txt \
    *.bam
elif [ ${READ_TYPE} = "PE" ]
then
  featureCounts \
    -T ${THREADN} \
    -B -C -t exon \
    -p --countReadPairs \
    -s ${STRANDNESS} \
    -a ${ANNOTATION}.gtf \
    -o ${PROJECT_FOLDER}/02_results/counts/featureCounts/featureCounts_output.txt \
    *.bam
else
  echo "ERROR! Specify value for READ_TYPE: "SE" for single-end or "PE" for paired-end)"
  exit 1
fi

# move summary file to quality_control folder
mv ${PROJECT_FOLDER}/02_results/counts/featureCounts/*.summary ${PROJECT_FOLDER}/02_results/quality_control/counts

# Create list of bam files
echo "bam" > ${PROJECT_FOLDER}/01_metadata/bam_files.csv
ls *.bam >> ${PROJECT_FOLDER}/01_metadata/bam_files.csv

echo " ==================== Creating MultiQC report ==================== " `date`
multiqc \
  --force \
  --filename "04.featureCounts.qc.html"\
  --outdir ${PROJECT_FOLDER}/00_reports/ \
  ${PROJECT_FOLDER}/02_results/quality_control/trimgalore \
  ${PROJECT_FOLDER}/02_results/quality_control/star \
  ${PROJECT_FOLDER}/02_results/quality_control/counts
printf "\n"

echo " =================================== Software versions =================================== "
echo `featureCounts -v 2>&1 | head -2 | tail -1`
echo `multiqc --version`
printf "\n"
echo "Versions printed on 00_reports/software_versions.txt"
echo `featureCounts -v 2>&1 | head -2 | tail -1` >> ${PROJECT_FOLDER}/00_reports/software_versions.txt
echo `multiqc --version` >> ${PROJECT_FOLDER}/00_reports/software_versions.txt
echo " ========================================================================================== "
printf "\n"
echo "Done!" `date`