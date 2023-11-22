# RNA-Seq Analysis Configuration
#
## Instructions:
# 1. Set the `PROJECT_FOLDER` variable to the desired path for your working folder.
# 2. Adjust the `SPECIES` variable to your target species: "mouse," "human," "pig," or "rat."
# 3. Optionally, customize other parameters like `THREADN` for the number of threads.

## Description:
#- This configuration file sets variables for an RNA-Seq analysis pipeline.
#- Specifies paths to essential files and folders, such as genome indices and annotation files.
#- Determines the file format and type (single-end or paired-end) of RNA-Seq data.
#- Provides default settings for commonly used species (mouse, human, rat).

# Adjust the following variables:

## FOR ALL PIPELINES:
PROJECT_FOLDER=~/path/to/your/project_folder ## Replace with the desired path to the working folder
SPECIES=mouse # supports "mouse", "human", or "pig"
THREADN=14 # define number of threads to use
TMP_DIR=~/rnaseq/tmp_folder ## Replace with the desired path to the working folder


## Check paths to index and annotation files ------------

MOUSE_GENOME_FASTA_FILE=/shared/genome/mm10_grcm38/ensembl/Mus_musculus.GRCm38.dna.primary_assembly.fa 
MOUSE_STAR_INDEX=/shared/genome/mm10_grcm38/index/star_r149
MOUSE_ANNOTATION=/shared/genome/mm10_grcm38/ensembl/Mus_musculus.GRCm38.102 # GTF and BED files with the same PREFIX
MOUSE_KALLISTO_INDEX=/shared/genome/mm10_grcm38/index/kallisto/Mus_musculus.GRCm38.cdna.all.idx
MOUSE_RSEM_PREFIX=

HUMAN_GENOME_FASTA_FILE=
HUMAN_STAR_INDEX=/shared/genome/grch38/star_149 
HUMAN_KALLISTO_INDEX=/shared/genome/grch38/index/kallisto/Homo_sapiens.GRCh38.cdna.all.idx
HUMAN_ANNOTATION=/shared/genome/grch38/ensembl/Homo_sapiens.GRCh38.102 # GTF and BED files with the same PREFIX
HUMAN_RSEM_PREFIX=

PIG_GENOME_FASTA_FILE=
PIG_STAR_INDEX=
PIG_ANNOTATION=/shared/genome/pig/ensembl/Sus_scrofa.Sscrofa11.1.106 # GTF and BED files with the same PREFIX
PIG_KALLISTO_INDEX=/shared/genome/pig/index/kallisto/Sus_scrofa.Sscrofa11.1.cdna.all.idx
PIG_RSEM_PREFIX=

RAT_GENOME_FASTA_FILE= 
RAT_STAR_INDEX=
RAT_KALLISTO_INDEX=
RAT_ANNOTATION= 
RAT_RSEM_PREFIX=

## SPECIFIC TO PIPELINE2
SRA_FILE="01_metadata/SraRunTable_example.txt" # if downloading public datasets

## SPECIFIC TO .... (WORKING ON)
SRC_DIR=${PROJECT_FOLDER}/source_directory # for Novogene or NGI data





# DON'T CHANGE BELOW THIS POINT 
###########################################################################################
for FILE in `ls ${PROJECT_FOLDER}/fastq* | sort -u`
do
FILENAME=`basename ${FILE}`
case "${FILENAME}" in
    *.fastq.bz2) FQ_FORMAT=.fastq.bz2 ;;
    *.fastq.gz) FQ_FORMAT=.fastq.gz ;;
    *.fa.bz2) FQ_FORMAT=.fa.bz2 ;;
    *.fa.gz) FQ_FORMAT=.fa.gz ;;
    *.fq.bz2) FQ_FORMAT=.fq.bz2 ;;
    *.fq.gz) FQ_FORMAT=.fq.gz ;;
esac
done


cd ${PROJECT_FOLDER}/fastq
EXTENSION=$(ls | head -1 | sed 's/.*\.//')
FQ_FORMAT=$(ls | head -1 | cut -d'.' -f2)

# Get the filename of the first file
FILE_TEST=$(ls | head -1)

# Check for specific patterns in the filename and set appropriate suffixes
if [[ $FILE_TEST == *_R1_001.$FQ_FORMAT.$EXTENSION ]]
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

# Determine if the file is paired-end ("PE") or single-end ("SE")
if [ -e ${FILE_TEST%%$SUFFIX1}${SUFFIX2} ]
then
  READ_TYPE="PE"  # Paired-end data
else
  READ_TYPE="SE"  # Single-end data
fi