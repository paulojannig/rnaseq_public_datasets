#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#
# DESCRIPTION:
# featureCounts to obtain gene counts from the aligned reads.
#
# REQUIREMENTS:
# - featureCounts (from Subread package)
#
# INPUT:
#   Bam files
#     Files stored in ${DATASET}/02_results/bam
#
###########################################################################################
source config.sh
source ./scripts/project_info.sh

EXPERIMENT_NAME="featureCounts"

# retrieve path to annotation file
if [ $SPECIES = "mouse" ]
then 
  ANNOTATION=${MOUSE_ANNOTATION}
elif [ $SPECIES = "human" ]
then
  ANNOTATION=${HUMAN_ANNOTATION}
elif [ $SPECIES = "pig" ]
then
  ANNOTATION=${PIG_ANNOTATION}
elif [ $SPECIES = "rat" ]
then
  ANNOTATION=${RAT_ANNOTATION}
else
  echo "Unsupported species: $SPECIES"
  exit 1
fi

# ===========================================================================================
# Script starts here...
# ===========================================================================================

# create dependencies ------------
mkdir -p ${DATASET}/02_results/counts/featureCounts
mkdir -p ${DATASET}/02_results/deseq2/
mkdir -p ${DATASET}/02_results/quality_control/counts

echo "=========================================================================================="
echo "Date: "`date`
echo "Experiment: ${EXPERIMENT_NAME}"
echo "=========================================================================================="

cd ${DATASET}

# Assuming strandedness.csv contains columns: bam,fraction,strandness,htseq_count,featureCounts
# Loop through the strandness.csv file line by line
while IFS=',' read -r bam fraction strandness htseq_count featureCounts; do
  # Determine ${STRANDNESS} based on the "featureCounts" value
  case "$featureCounts" in
    "0") STRANDNESS=0 ;;
    "1") STRANDNESS=1 ;;
    "2") STRANDNESS=2 ;;
    *) STRANDNESS=0 ;; # Default to unstranded if the value is not recognized
  esac
  # Skip the header line
  if [ "$bam" != "bam" ]; then 
    # Run the featureCounts command
    if [ ${READ_TYPE} = "SE" ]
    then 
      featureCounts \
        -T ${THREADN} \
        -t exon \
        -s ${STRANDNESS} \
        -a ${ANNOTATION} \
        -o 02_results/counts/featureCounts/${bam}.featureCounts.txt \
        02_results/bam/${bam}
    elif [ ${READ_TYPE} = "PE" ]
    then
      featureCounts \
        -T ${THREADN} \
        -B -C -t exon \
        -p --countReadPairs \
        -s ${STRANDNESS} \
        -a ${ANNOTATION} \
        -o 02_results/counts/featureCounts/${bam}.featureCounts.txt \
        02_results/bam/${bam}
    else
      echo "ERROR! Specify value for READ_TYPE: "SE" for single-end or "PE" for paired-end)"
      exit 1
    fi
  fi

done < 02_results/quality_control/infer_experiment/strandness.csv

# move summary file to quality_control folder
mv 02_results/counts/featureCounts/*.summary 02_results/quality_control/counts

# Create list of featureCount files and add to sampleInfo.csv
echo "featureCounts_files" > 01_metadata/featureCounts_files.csv
ls 02_results/counts/featureCounts/*.featureCounts.txt | xargs -n 1 basename >> 01_metadata/featureCounts_files.csv
paste -d ',' 01_metadata/sampleInfo.csv 01_metadata/featureCounts_files.csv > 01_metadata/sampleInfo_temp.csv
mv 01_metadata/sampleInfo_temp.csv 01_metadata/sampleInfo.csv


echo " ==================== Creating MultiQC report ==================== " `date`
multiqc \
  --force \
  --filename "04.featureCounts.QC.html"\
  --outdir 00_reports/ \
  02_results/quality_control/trimgalore \
  02_results/quality_control/star \
  02_results/quality_control/counts
printf "\n"

echo " =================================== Software versions =================================== "
echo `featureCounts -v 2>&1 | head -2 | tail -1`
echo `multiqc --version`
printf "\n"
echo "Versions printed on 00_reports/software_versions.txt"
echo `featureCounts -v 2>&1 | head -2 | tail -1` >> 00_reports/software_versions.txt
echo `multiqc --version` >> 00_reports/software_versions.txt
echo " ========================================================================================== "
printf "\n"
echo "Done!" `date`