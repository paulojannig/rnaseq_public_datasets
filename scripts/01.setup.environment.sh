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

# Create necessary directories for organization
mkdir -p ${PROJECT_FOLDER}/00_reports
mkdir -p ${PROJECT_FOLDER}/01_metadata
mkdir -p ${PROJECT_FOLDER}/02_results
mkdir -p ${PROJECT_FOLDER}/03_figures
mkdir -p ${PROJECT_FOLDER}/04_supplements
mkdir -p ${PROJECT_FOLDER}/logs


# ============================== Organize and merge fastq files =============================


# ===========================================================================================
# For NGI data...
# ===========================================================================================
## all files from NGI stored in $SRC_DIR

# Find all files in the SRC_DIR and its subdirectories and move them to PROJECT_FOLDER/fastq
find "$SRC_DIR" -type f -exec mv {} "$PROJECT_FOLDER/fastq" \;

# Remove the original source directory as it is now empty
rm -r $SRC_DIR


# ===========================================================================================
# FOR Novogene data...
# ===========================================================================================
## all files (including tar file) from Novogene stored in $SRC_DIR

mkdir -p ${PROJECT_FOLDER}/fastq # creates the folder where fastq files will be stored
cd ${PROJECT_FOLDER} # go to project folder
tar -xvf $SRC_DIR/*.tar # untar files

cd $SRC_DIR

for FILE in `ls *.tar | sed "s/\.tar//g" | sort -u`
do
# Find all files in the source directory and its subdirectories and move to fastq folder
find "${FILE}/01.RawData" -type f -exec mv {} "${PROJECT_FOLDER}/fastq/" \;
rm ${PROJECT_FOLDER}/fastq/MD5.txt
rm -r "${FILE}/01.RawData"
done

# ===========================================================================================
# To merge fastq files from multiple lanes...
# ===========================================================================================
# 
# EXAMPLE:
# - Samples F_1_EKRN230018719 and B_1_EKRN230016099 were run on separate lanes and have multiple files (done to generate the minimum amount of data (6 Gb))
#
# Files: 
#   F_1_EKRN230018719:
#       Pair 1:
#           F_1_EKRN230018719-1A_HCKHGDSX7_L3_1.fq.gz
#           F_1_EKRN230018719-1A_HCKHGDSX7_L3_2.fq.gz
#       Pair 2:
#           F_1_EKRN230018719-1A_H3HGVDSX7_L3_1.fq.gz
#           F_1_EKRN230018719-1A_H3HGVDSX7_L3_2.fq.gz
#   B_1_EKRN230016099:
#       Pair 1:
#           B_1_EKRN230016099-1A_HWNVTDSX5_L3_1.fq.gz
#           B_1_EKRN230016099-1A_HWNVTDSX5_L3_2.fq.gz
#       Pair 2:
#           B_1_EKRN230016099-1A_HYCHTDSX5_L2_1.fq.gz
#           B_1_EKRN230016099-1A_HYCHTDSX5_L2_2.fq.gz
# Thus, we'll have to merge those files into only one pair

mkdir -p ${PROJECT_FOLDER}/fastq_multiple_lanes # creates folder where unmerged fastq files will be stored
mv ${PROJECT_FOLDER}/fastq/F_1_EKRN230018719-1A_* ${PROJECT_FOLDER}/fastq_multiple_lanes # move files there
mv ${PROJECT_FOLDER}/fastq/B_1_EKRN230016099-1A* ${PROJECT_FOLDER}/fastq_multiple_lanes # move files there

# merging F_1 files
cat ${PROJECT_FOLDER}/fastq_multiple_lanes/F_1_EKRN230018719*_1.fq.gz > ${PROJECT_FOLDER}/fastq/F_1_EKRN230018719-1A_merged_L3_1.fq.gz # creates merged read1
cat ${PROJECT_FOLDER}/fastq_multiple_lanes/F_1_EKRN230018719*_2.fq.gz > ${PROJECT_FOLDER}/fastq/F_1_EKRN230018719-1A_merged_L3_2.fq.gz # creates merged read2

# merging B_1 files
cat ${PROJECT_FOLDER}/fastq_multiple_lanes/B_1_EKRN230016099*_1.fq.gz > ${PROJECT_FOLDER}/fastq/B_1_EKRN230016099-1A_merged_L3_1.fq.gz # creates merged read1
cat ${PROJECT_FOLDER}/fastq_multiple_lanes/B_1_EKRN230016099*_2.fq.gz > ${PROJECT_FOLDER}/fastq/B_1_EKRN230016099-1A_merged_L3_2.fq.gz # creates merged read2

# ===========================================================================================
# Create list of fastq files
# ===========================================================================================
echo "sample,fastq_1,fastq_2" > ${PROJECT_FOLDER}/01_metadata/sampleInfo.csv

cd ${PROJECT_FOLDER}/fastq
for FILE in `ls *${SUFFIX1} | sed "s/${SUFFIX1}//g" | sort -u`
do
FASTQ1=${FILE}${SUFFIX1}
if [ $READ_TYPE = "PE" ]
then
  FASTQ2=${FILE}${SUFFIX2}
else
  FASTQ2=""
fi
echo "${FILE},${FASTQ1},${FASTQ2}" >> ${PROJECT_FOLDER}/01_metadata/sampleInfo.csv
done


echo "Done!" `date`