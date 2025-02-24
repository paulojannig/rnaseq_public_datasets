#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
#     
# DESCRIPTION:
#   - Download genome files
#   - build STAR index
#   - Quality control: FastQC and TrimGalore!
#   - Genome alignment: STAR
#   - Gene level counts: featureCounts
#
#   Run this script using the command: ./main.sh
#
# More details: README.md 
#
source config.sh

./scripts/01.setup.environment.sh
./scripts/02.sradownloader.sh
./scripts/03.merge_fastq.sh
nohup ./scripts/04.fastqc.sh >> ${DATASET}/logs/log.01.fastqc.txt
nohup ./scripts/05.trimgalore.sh >> ${DATASET}/logs/log.02.trimgalore.txt
nohup ./scripts/06.star.alignment.sh >> ${DATASET}/logs/log.03.star.alignment.txt
nohup ./scripts/07.infer_experiment.sh >> ${DATASET}/logs/log.04.infer_experiment.txt
nohup ./scripts/08.featureCounts.sh >> ${DATASET}/logs/log.05.featureCounts.txt
nohup ./scripts/09.kallisto.quant.sh >> ${DATASET}/logs/log.06.kallisto.quant.txt
