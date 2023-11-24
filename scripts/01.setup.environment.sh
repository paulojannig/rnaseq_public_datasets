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
source config.sh
source ./scripts/project_info.sh
#echo "setup"
#echo "current path: "`pwd`

# Create necessary directories for organization
mkdir -p ${DATASET}/00_reports
mkdir -p ${DATASET}/01_metadata
mkdir -p ${DATASET}/02_results
mkdir -p ${DATASET}/03_figures
mkdir -p ${DATASET}/04_supplements
mkdir -p ${DATASET}/logs
cp dataset_table/${SRA_FILE} ${DATASET}/01_metadata/
cp -r miscellaneous ${DATASET}/
cp -r scripts/ ${DATASET}/
cp config.sh ${DATASET}/
cp main.sh ${DATASET}/