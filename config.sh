# RNA-Seq Analysis Configuration

# Adjust the following variables:

## FOR ALL PIPELINES:
#PROJECT_FOLDER=~/fyfa/paulo/tmp/rnaseq_public_datasets ## Replace with the desired path to the working folder
DATASET=PJ1_correia_muscle_nrtn_GSE155068 # Name your experimental folder (e.g. PJ1_correia_muscle_nrtn_GSE155068)
SRA_FILE="SraRunTable_example_GSE155068.txt" # file name for SRA table saved within `dataset_table` folder (e.g. SraRunTable_example_GSE155068.txt)
MULTIPLE_LANES=no # "yes" or "no" to merge fastq files from multiple lanes. If "yes", adjust `scripts/03.merge_fastq.sh` accordingly.
SPECIES=mouse # supports "mouse", "human", "pig" and "rat"
THREADN=16 # define number of threads to use
TMP_DIR=/proj/ramuscleweakness-2024/tmp_folder ## Replace with the desired path to the working folder


## Check paths to index and annotation files ------------
MOUSE_STAR_INDEX=/shared/genome/mm10_grcm38/index/star_r149
MOUSE_ANNOTATION=/shared/genome/mm10_grcm38/ensembl/Mus_musculus.GRCm38.102 # GTF and BED files with the same PREFIX

HUMAN_STAR_INDEX=/shared/genome/grch38/star_149 
HUMAN_ANNOTATION=/shared/genome/grch38/ensembl/Homo_sapiens.GRCh38.102 # GTF and BED files with the same PREFIX

PIG_STAR_INDEX=
PIG_ANNOTATION=/shared/genome/pig/ensembl/Sus_scrofa.Sscrofa11.1.106 # GTF and BED files with the same PREFIX

RAT_STAR_INDEX=
RAT_ANNOTATION=