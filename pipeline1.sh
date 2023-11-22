#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | https://github.com/paulojannig
# Last Updated: 2023-11-21
#
# Pipeline 1: Analyzing home-made data
#     
# DESCRIPTION:
#   - Quality control: FastQC and TrimGalore!
#   - Genome alignment: STAR
#   - Gene level counts: featureCounts
#
# REQUIREMENTS:
# - FastQC
# - MultiQC
# - Trim Galore!
# - cutadapt
# - STAR
# - Samtools
# - infer_experiment.py (RSeQC)
# - featureCounts (from Subread package)
#
# USAGE:
#     1. Change parameters in the config.txt file
#     2. Check ./scripts/01.setup.environment.sh and modify "Organize and merge fastq files" section to your needs
#     ## e.g. files from Novogene or NGI, untar or unzip, merge fastq files from multiple lanes
#     3. Run this script using the command: ./main.sh
#   
#
nohup ./scripts/01.setup.environment.sh
nohup ./scripts/02.fastqc.sh >> logs/log.01.fastqc.txt
nohup ./scripts/03.trimgalore.sh >> logs/log.02.trimgalore.txt
nohup ./scripts/04.star.alignment.sh >> logs/log.03.star.alignment.txt
nohup ./scripts/05.infer_experiment.sh >> logs/log.04.infer_experiment.txt
nohup ./scripts/06.featureCounts.sh >> logs/log.05.featureCounts.txt
