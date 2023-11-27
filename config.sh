# RNA-Seq Analysis Configuration

# Adjust the following variables:

## FOR ALL PIPELINES:
#PROJECT_FOLDER=~/fyfa/paulo/tmp/rnaseq_public_datasets ## Replace with the desired path to the working folder
DATASET=PJ1_correia_muscle_nrtn_GSE155068 # Name your experimental folder (e.g. PJ1_correia_muscle_nrtn_GSE155068)
SRA_FILE="SraRunTable_example_GSE155068.txt" # file name for SRA table saved within `dataset_table` folder (e.g. SraRunTable_example_GSE155068.txt)
MULTIPLE_LANES=no # "yes" or "no" to merge fastq files from multiple lanes. If "yes", adjust `scripts/03.merge_fastq.sh` accordingly.
SPECIES=mouse # supports "mouse", "human", "pig" and "rat"
THREADN=16 # define number of threads to use
PROJECT_FOLDER=/proj/yourProjectFolder # Path to where you store genome files
TMP_DIR=${PROJECT_FOLDER}/tmp_folder ## Replace with the desired path to the temporary folder


## Check paths to index and annotation files ------------
MOUSE_STAR_INDEX=${PROJECT_FOLDER}/genomes/mouse/star_index_149 # Path to STAR index
MOUSE_ANNOTATION=${PROJECT_FOLDER}/genomes/mouse/Mus_musculus.GRCm38.102.chr.gtf # GTF file

HUMAN_STAR_INDEX=${PROJECT_FOLDER}/genomes/human/star_149 # Path to STAR index
HUMAN_ANNOTATION=${PROJECT_FOLDER}/genomes/human/Homo_sapiens.GRCh38.102.gtf # GTF file

PIG_STAR_INDEX=${PROJECT_FOLDER}/genomes/pig/star_r149 # Path to STAR index
PIG_ANNOTATION=${PROJECT_FOLDER}/genomes/pig/Sus_scrofa.Sscrofa11.1.106.gtf # GTF file

RAT_STAR_INDEX=${PROJECT_FOLDER}/genomes/rat/star_r149
RAT_ANNOTATION=${PROJECT_FOLDER}/genomes/rat/