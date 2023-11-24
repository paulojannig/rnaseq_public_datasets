#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#
# DESCRIPTION:
# This script performs genome alignment for RNA-seq samples using STAR, 
# generates quality control metrics with Samtools, and then a MultiQC report
#
# REQUIREMENTS:
# - STAR
# - Samtools
# - MultiQC
#
# INPUT:
#   Fastq files after quality control with trimgalore
#     Files stored in ${PROJECT_FOLDER}/02_results/trimgalore
#
###########################################################################################
source config.sh
source ./scripts/project_info.sh

EXPERIMENT_NAME="STAR alignment RNA-seq"

# create dependencies ------------
mkdir -p ${DATASET}/02_results/bam
mkdir -p ${DATASET}/02_results/quality_control/star
mkdir -p ${DATASET}/02_results/quality_control/samtools

mkdir -p ${TMP_DIR}/02_results/bam
ln -s ${PIPELINE_DIR}/${DATASET}/02_results/trimgalore ${TMP_DIR}/02_results/trimgalore


# Start logging ------------
echo "=========================================================================================="
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT_NAME}"
echo "=========================================================================================="
printf "\n"

cd ${DATASET}/fastq

# Create list of fastq files (before trimming)
echo "sample,fastq_1,fastq_2" > ../01_metadata/sampleInfo.csv

for FILE in `ls *${SUFFIX1} | sed "s/${SUFFIX1}//g" | sort -u`
do
FASTQ1=${FILE}${SUFFIX1}
if [ $READ_TYPE = "PE" ]
then
  FASTQ2=${FILE}${SUFFIX2}
else
  FASTQ2=""
fi
echo "${FILE},${FASTQ1},${FASTQ2}" >> ../01_metadata/sampleInfo.csv
done

# Create path to index and annotation files
if [ $SPECIES = "mouse" ]
then 
  STAR_INDEX=${MOUSE_STAR_INDEX}
  ANNOTATION=${MOUSE_ANNOTATION}
elif [ $SPECIES = "human" ]
then
  STAR_INDEX=${HUMAN_STAR_INDEX}
  ANNOTATION=${HUMAN_ANNOTATION}
elif [ $SPECIES = "pig" ]
then
  STAR_INDEX=${PIG_STAR_INDEX}
  ANNOTATION=${PIG_ANNOTATION}
elif [ $SPECIES = "rat" ]
then
  STAR_INDEX=${RAT_STAR_INDEX}
  ANNOTATION=${RAT_ANNOTATION}
else
  echo "Unsupported species: $SPECIES"
  exit 1
fi

cd ${TMP_DIR}/02_results/trimgalore

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

# Determine the compression command based on the file extension
if [ $EXTENSION = "gz" ]
then 
  COMPRESSION=zcat
else
  COMPRESSION=bzcat
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

if [ $READ_TYPE = "PE" ]
then 
  STAR_INPUT="${TMP_DIR}/02_results/trimgalore/${FILE}${SUFFIX1} ${TMP_DIR}/02_results/trimgalore/${FILE}${SUFFIX2}"
else
  STAR_INPUT="${TMP_DIR}/02_results/trimgalore/${FILE}${SUFFIX1}"
fi

echo " ==================== STAR alignment ==================== " `date`
STAR \
  --runThreadN ${THREADN} \
  --genomeDir ${STAR_INDEX} \
  --genomeLoad LoadAndKeep \
  --readFilesIn ${STAR_INPUT} \
  --outFileNamePrefix ${TMP_DIR}/02_results/bam/${FILE}. \
  --readFilesCommand ${COMPRESSION} -c \
  --limitBAMsortRAM 20000000000 \
  --outSAMtype BAM SortedByCoordinate \
  --outSAMattributes NH HI NM MD AS XS \
  --outFilterMismatchNmax 10 \
  --outFilterScoreMinOverLread 0.7 \
  --outFilterMatchNminOverLread 0.7 \
  --outSAMheaderHD @HD VN:1.4 \
  --outSAMstrandField intronMotif \
  --outFilterMultimapNmax 50 \
  --outFilterMultimapScoreRange 3 \
  --alignIntronMax 500000 \
  --alignMatesGapMax 1000000 \
  --sjdbScore 2 \
  --seedPerWindowNmax 50

printf "\n"
echo " ==================== Samtools QC ==================== " `date`
echo " creating index file... " `date`
samtools index -@ ${THREADN} ${TMP_DIR}/02_results/bam/${FILE}*.bam
echo " creating stats file... " `date`
samtools stats -@ ${THREADN} ${TMP_DIR}/02_results/bam/${FILE}*.bam > ${TMP_DIR}/02_results/quality_control/samtools/${FILE}.bam.samtools.stats.txt
echo " creating idxstats file... " `date`
samtools idxstats -@ ${THREADN} ${TMP_DIR}/02_results/bam/${FILE}*.bam > ${TMP_DIR}/02_results/quality_control/samtools/${FILE}.bam.samtools.idxstats.txt
echo " creating flagstat file... " `date`
samtools flagstat -@ ${THREADN} ${TMP_DIR}/02_results/bam/${FILE}*.bam > ${TMP_DIR}/02_results/quality_control/samtools/${FILE}.bam.samtools.flagstat.txt
printf "\n"

echo " ==================== Organizing files ==================== " `date`
echo "Moving STAR logs to 02_results/quality_control/star" `date`
rm ${TMP_DIR}/02_results/bam/*.Log.progress.out ${TMP_DIR}/02_results/bam/*.SJ.out.tab
mv ${TMP_DIR}/02_results/bam/*Log* ${PIPELINE_DIR}/${DATASET}/02_results/quality_control/star/

echo "Moving BAM file to DATASET/02_results/bam/" `date`
mv ${TMP_DIR}/02_results/bam/* ${PIPELINE_DIR}/${DATASET}/02_results/bam/
rm ${TMP_DIR}/02_results/bam/*

done
printf "\n"

cd ${PIPELINE_DIR}/${DATASET}
echo " ==================== Creating MultiQC report ==================== " `date`
multiqc \
  --force \
  --filename "03.alignment.QC.star.html"\
  --title "${EXPERIMENT_NAME}" \
  --outdir 00_reports/ \
  02_results/quality_control/star \
  02_results/quality_control/samtools
printf "\n"

echo " =================================== Software versions =================================== "
printf "\n"
echo "STAR version" `STAR --version`
samtools --version 2>&1 | head -n 2 | sed '2s/Using //'
printf "\n"
echo "Versions printed on 00_reports/software_versions.txt"
echo "STAR" `STAR --version` >> 00_reports/software_versions.txt
samtools --version 2>&1 | head -n 2 | sed '2s/Using //' >> 00_reports/software_versions.txt
echo " ========================================================================================== "
printf "\n"
rm -r ${TMP_DIR}/
echo "Done!" `date`