#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#
# DESCRIPTION:
# Performs Kallisto quantification on trimmed fastq files (TrimGalore!)
#
# REQUIREMENTS:
# - kallisto
#
# INPUT:
#   Fastq files after quality control with trimgalore
#     Files stored in ${DATASET}/02_results/trimgalore
#
###########################################################################################
source config.sh
source ./scripts/project_info.sh

EXPERIMENT_NAME="Kallisto quantification"

# create dependencies ------------
mkdir -p ${DATASET}/02_results/kallisto


# Start logging ------------
echo "=========================================================================================="
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT_NAME}"
echo "=========================================================================================="
printf "\n"

cd ${DATASET}/02_results/trimgalore

# Get the file extension of the first file in the current directory
EXTENSION=$(ls | head -1 | sed 's/.*\.//')

# Get the second part of the filename separated by a dot (FQ_FORMAT)
FQ_FORMAT=$(ls | head -1 | cut -d'.' -f2)

# Get the filename of the first file
FILE_TEST=$(ls | head -1)

# Check for specific patterns in the filename and set appropriate suffixes
if [[ $FILE_TEST == *_R1_001_val_1.$FQ_FORMAT.$EXTENSION ]]
then
    SUFFIX1="_R1_001_val_1.$FQ_FORMAT.$EXTENSION"
    SUFFIX2="_R2_001_val_2.$FQ_FORMAT.$EXTENSION"
elif [[ $FILE_TEST == *_1_val_1.$FQ_FORMAT.$EXTENSION ]]
then
    SUFFIX1="_1_val_1.$FQ_FORMAT.$EXTENSION"
    SUFFIX2="_2_val_2.$FQ_FORMAT.$EXTENSION"
elif [[ $FILE_TEST == *_val_1.$FQ_FORMAT.$EXTENSION ]]
then
    SUFFIX1="_val_1.$FQ_FORMAT.$EXTENSION"
    SUFFIX2="_val_2.$FQ_FORMAT.$EXTENSION"
elif [[ $FILE_TEST == *_1_trimmed.$FQ_FORMAT.$EXTENSION ]]
then
    SUFFIX1="_1_trimmed.$FQ_FORMAT.$EXTENSION"
    SUFFIX2="_2_trimmed.$FQ_FORMAT.$EXTENSION"

elif [[ $FILE_TEST == *_R1_001.$FQ_FORMAT.$EXTENSION ]]
then
    SUFFIX1="_R1_001.$FQ_FORMAT.$EXTENSION"
    SUFFIX2="_R2_001.$FQ_FORMAT.$EXTENSION"

elif [[ $FILE_TEST == *_R1.$FQ_FORMAT.$EXTENSION ]]
then
    SUFFIX1="_R1.$FQ_FORMAT.$EXTENSION"
    SUFFIX2="_R2.$FQ_FORMAT.$EXTENSION"

elif [[ $FILE_TEST == *_1.$FQ_FORMAT.$EXTENSION ]]
then
    SUFFIX1="_1.$FQ_FORMAT.$EXTENSION"
    SUFFIX2="_2.$FQ_FORMAT.$EXTENSION"
else
    SUFFIX1=".$FQ_FORMAT.$EXTENSION"
    SUFFIX2=".$FQ_FORMAT.$EXTENSION"
fi

echo "========================= Listing and counting fastq files ==============================="
printf "\n"
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
echo " ==================== Kallisto quantification ==================== "

if [ $READ_TYPE = "PE" ]
then 
  KALLISTO_INPUT="${DATASET}/02_results/trimgalore/${FILE}${SUFFIX1} ${DATASET}/02_results/trimgalore/${FILE}${SUFFIX2}"
else
  KALLISTO_INPUT="${DATASET}/02_results/trimgalore/${FILE}${SUFFIX1}"
fi

kallisto quant \
    -t ${THREADN} \
    -i ${KALLISTO_INDEX} \
    -o ${DATASET}/02_results/kallisto/${FILE} \
    ${KALLISTO_INPUT}
done

echo " =================================== Software versions =================================== "
printf "\n"
kallisto version
kallisto cite
printf "\n"
echo "Versions printed on 00_reports/software_versions.txt"
kallisto version >> ${DATASET}/00_reports/software_versions.txt
echo " ========================================================================================== "
printf "\n"
echo "Done!" `date`