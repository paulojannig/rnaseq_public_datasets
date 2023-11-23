#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | GitHub: https://github.com/paulojannig
#
# DESCRIPTION:
# This script will setup your RNA-seq directory by:
#   - creating subdirectories
#   - moving fastq files to working directory
#
# USAGE:
# 1. Run the script using the command: 
#   sh 01.setup.environment.sh
#
# REQUIREMENTS:
# - none
#
###########################################################################################
#
# ===========================================================================================
# Script starts here...
# ===========================================================================================
source config.sh

for FILE in `ls ${PROJECT_FOLDER}/fastq* | sort -u`
do
FILENAME=`basename ${FILE}`
case "${FILENAME}" in
    *.fastq.bz2) FQ_FORMAT=.fastq.bz2 ;;
    *.fastq.gz) FQ_FORMAT=.fastq.gz ;;
    *.fa.bz2) FQ_FORMAT=.fa.bz2 ;;
    *.fa.gz) FQ_FORMAT=.fa.gz ;;
    *.fq.bz2) FQ_FORMAT=.fq.bz2 ;;
    *.fq.gz) FQ_FORMAT=.fq.gz ;;
esac
done


cd ${PROJECT_FOLDER}/fastq
EXTENSION=$(ls | head -1 | sed 's/.*\.//')
FQ_FORMAT=$(ls | head -1 | cut -d'.' -f2)

# Get the filename of the first file
FILE_TEST=$(ls | head -1)

# Check for specific patterns in the filename and set appropriate suffixes
if [[ $FILE_TEST == *_R1_001.$FQ_FORMAT.$EXTENSION ]]
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

# Determine if the file is paired-end ("PE") or single-end ("SE")
if [ -e ${FILE_TEST%%$SUFFIX1}${SUFFIX2} ]
then
  READ_TYPE="PE"  # Paired-end data
else
  READ_TYPE="SE"  # Single-end data
fi
echo "Done!" `date`