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

#SCRIPT_DIR=$(dirname "$0")
#cd $SCRIPT_DIR
#echo "current path: "`pwd`

cd $(dirname "$0")
cd ..
PIPELINE_DIR=`pwd`
#echo "project_info"
#echo "current path: "`pwd`
#printf "\n"

if [ -d "${DATASET}/fastq" ]; then
    # Run your code here for the case when $DATASET/fastq exists
    echo "$DATASET/fastq exists. Running your code..."
    
    
    # Get the filename of the first file
    FILE_TEST=$(ls ${DATASET}/fastq| head -1)
    
    case "${FILE_TEST}" in
        *.fastq.bz2) FQ_FORMAT=fastq.bz2 ;;
        *.fastq.gz) FQ_FORMAT=fastq.gz ;;
        *.fa.bz2) FQ_FORMAT=fa.bz2 ;;
        *.fa.gz) FQ_FORMAT=fa.gz ;;
        *.fq.bz2) FQ_FORMAT=fq.bz2 ;;
        *.fq.gz) FQ_FORMAT=fq.gz ;;
    esac

    # Check for specific patterns in the filename and set appropriate suffixes
    if [[ $FILE_TEST == *_R1_001.$FQ_FORMAT ]]
    then
        SUFFIX1="_R1_001.$FQ_FORMAT"
        SUFFIX2="_R2_001.$FQ_FORMAT"

    elif [[ $FILE_TEST == *_R1.$FQ_FORMAT ]]
    then
        SUFFIX1="_R1.$FQ_FORMAT"
        SUFFIX2="_R2.$FQ_FORMAT"

    elif [[ $FILE_TEST == *_1.$FQ_FORMAT ]]
    then
        SUFFIX1="_1.$FQ_FORMAT"
        SUFFIX2="_2.$FQ_FORMAT"
    else
        SUFFIX1=".$FQ_FORMAT"
        SUFFIX2=".$FQ_FORMAT"
    fi

    # Determine if the file is paired-end ("PE") or single-end ("SE")
    if [ -e ${FILE_TEST%%$SUFFIX1}${SUFFIX2} ]
    then
    READ_TYPE="PE"  # Paired-end data
    else
    READ_TYPE="SE"  # Single-end data
    fi

else
    # Run your code here for the case when $DATASET/fastq does not exist
    #echo "$DATASET/fastq does not exist."
    echo ""
fi
