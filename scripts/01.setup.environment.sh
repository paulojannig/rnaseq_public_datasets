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
source ./scripts/fastq_info.sh

# Create necessary directories for organization
mkdir -p ${PROJECT_FOLDER}/00_reports
mkdir -p ${PROJECT_FOLDER}/01_metadata
mkdir -p ${PROJECT_FOLDER}/02_results
mkdir -p ${PROJECT_FOLDER}/03_figures
mkdir -p ${PROJECT_FOLDER}/04_supplements
mkdir -p ${PROJECT_FOLDER}/logs


echo $EXTENSION
echo $FQ_FORMAT
echo $FILE_TEST
echo $SUFFIX1
echo $SUFFIX2
echo $READ_TYPE

echo "Done!" `date`