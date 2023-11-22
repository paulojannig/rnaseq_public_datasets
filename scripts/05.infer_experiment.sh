#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#
# DESCRIPTION:
# This scripts will infer strandness of reads from BAM files and add the results to a file
# named strandness.csv
#
# USAGE:
# 1. Change parameters and follow instructions within "SETUP SCRIPT"
# 2. Run the script using the command: 
#   nohup ./05.infer_experiment.sh >> ../logs/log.05.infer_experiment.txt
#
# REQUIREMENTS:
# - infer_experiment.py (RSeQC)
#
# INPUT:
#   Bam files
#     Files stored in ${PROJECT_FOLDER}/02_results/bam
#
###########################################################################################

# ===========================================================================================
# SETUP SCRIPT
# ===========================================================================================
source config.sh

# Name your experiment:
EXPERIMENT_NAME="Inferring strandness of reads"

# ===========================================================================================
# Script starts here...
# ===========================================================================================
# create dependencies ------------
mkdir -p ${PROJECT_FOLDER}/02_results/quality_control/infer_experiment
echo "bam,fraction,strandness,htseq-count,featureCounts" > ${PROJECT_FOLDER}/02_results/quality_control/infer_experiment/strandness.csv

echo "=========================================================================================="
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT_NAME}"
echo "=========================================================================================="
printf "\n"

cd ${PROJECT_FOLDER}/02_results/bam

printf "\n"
echo "============================= Inferring strandness of reads =============================="
for FILE in `ls *.bam | sed "s/\.bam//g" | sort -u`
do
echo "Sample: ${FILE}.bam"
infer_experiment.py \
  -i ${FILE}.bam \
  -r ${ANNOTATION}.bed > ${PROJECT_FOLDER}/02_results/quality_control/infer_experiment/${FILE}.infer_experiment.txt
printf "\n"

fraction=$(tail -n 1 ${PROJECT_FOLDER}/02_results/quality_control/infer_experiment/${FILE}.infer_experiment.txt | rev | cut -c 1-6 | rev)
# Compare the fraction and determine the result
if (( $(bc <<< "$fraction > 0.7") ))
then
  echo "${FILE}.bam,$fraction,reverse,reverse,2" >> ${PROJECT_FOLDER}/02_results/quality_control/infer_experiment/strandness.csv
elif (( $(bc <<< "$fraction < 0.3") ))
then
  echo "${FILE}.bam,$fraction,forward,yes,1" >> ${PROJECT_FOLDER}/02_results/quality_control/infer_experiment/strandness.csv
else
  echo "${FILE}.bam,$fraction,unstranded,no,0" >> ${PROJECT_FOLDER}/02_results/quality_control/infer_experiment/strandness.csv
fi
done

# Add strandness info to 01_metadata/sampleInfo.csv
paste -d ',' ${PROJECT_FOLDER}/01_metadata/sampleInfo.csv ${PROJECT_FOLDER}/02_results/quality_control/infer_experiment/strandness.csv > ${PROJECT_FOLDER}/01_metadata/sampleInfo_temp.csv
mv ${PROJECT_FOLDER}/01_metadata/sampleInfo_temp.csv ${PROJECT_FOLDER}/01_metadata/sampleInfo.csv


printf "\n"
echo "Creating strandness_interpretation.txt file .... "
echo "
============================= Estimation of the strandness ===============================
|----------------------|------------------|------------------|--------------------|-------------|----------------|
| Library type         | Infer Experiment | TopHat           | HISAT              | htseq-count | featureCounts  |
|----------------------|------------------|------------------|--------------------|-------------|----------------|
| Paired-End (PE) - SF | 1++,1–,2+-,2-+   | FR Second Strand | Second Strand F/FR | yes         | Forward (1)    |
| PE - SR              | 1+-,1-+,2++,2–-  | FR First Strand  | First Strand R/RF  | reverse     | Reverse (2)    |
| Single-End (SE) - SF | +,–              | FR Second Strand | Second Strand F/FR | yes         | Forward (1)    |
| SE - SR              | +-,-+            | FR First Strand  | First Strand R/RF  | reverse     | Reverse (2)    |
| PE, SE - U           | undecided        | FR Unstranded    | default            | no          | Unstranded (0) |
|----------------------|------------------|------------------|--------------------|-------------|----------------|
source: https://artbio.github.io/startbio/reference_based_RNAseq/strandness/

" > ${PROJECT_FOLDER}/02_results/quality_control/infer_experiment/strandness_interpretation.txt
echo "List of bam files with corresponding strandedness printed on 02_results/quality_control/infer_experiment/strandness.csv"
printf "\n"

echo "=================================== Software versions =================================== "
echo `infer_experiment.py --version`
printf "\n"
echo "Versions printed on 00_reports/software_versions.txt"
echo `infer_experiment.py --version` >> ${PROJECT_FOLDER}/00_reports/software_versions.txt
echo " ======================================================================================== "
printf "\n"
echo "Done!" `date`
