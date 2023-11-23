# RNA-Seq Analysis Configuration

# Adjust the following variables:

## FOR ALL PIPELINES:
PROJECT_FOLDER=~/path/to/your/project_folder ## Replace with the desired path to the working folder
SRA_FILE="01_metadata/SraRunTable_example.txt" # if downloading public datasets
MULTIPLE_LANES=no # "yes" or "no" to merge fastq files from multiple lanes
SPECIES=mouse # supports "mouse", "human", or "pig"
THREADN=14 # define number of threads to use
TMP_DIR=~/rnaseq/tmp_folder ## Replace with the desired path to the working folder


## Check paths to index and annotation files ------------
MOUSE_STAR_INDEX=/shared/genome/mm10_grcm38/index/star_r149
MOUSE_ANNOTATION=/shared/genome/mm10_grcm38/ensembl/Mus_musculus.GRCm38.102 # GTF and BED files with the same PREFIX

HUMAN_STAR_INDEX=/shared/genome/grch38/star_149 
HUMAN_ANNOTATION=/shared/genome/grch38/ensembl/Homo_sapiens.GRCh38.102 # GTF and BED files with the same PREFIX

PIG_STAR_INDEX=
PIG_ANNOTATION=/shared/genome/pig/ensembl/Sus_scrofa.Sscrofa11.1.106 # GTF and BED files with the same PREFIX

RAT_STAR_INDEX=
RAT_ANNOTATION=