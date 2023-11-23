# RNA-seq pipeline to analyse public datasets
RNA-seq pipeline using shell scripts

## USAGE: 
    1. Download the SraRunTable.txt using SRA Run Selector tool (https://www.ncbi.nlm.nih.gov/Traces/study/)
        For example:
            - go to https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA648376      	
            - click on Metadata to download the SraRunTable.txt file containing all or selected samples
            - Save the file 'SraRunTable.txt' to the directory ${PROJECT_FOLDER}/01_metadata
            - Check 'SraRunTable.txt' to see if there are fastq files that belong to the same biological replicate. This files will have to be merged. For that, adjust parameters within "scripts/01.setup.environment.sh" (# To merge fastq files from multiple lanes...)
   2. Change parameters in the `config.sh` file
   4. Run this script using the command: `./main.sh`

## Pipeline description:

- Download deposited Fastq files: [sradownloader](https://github.com/s-andrews/sradownloader) 
- Quality control: FastQC and TrimGalore!
- Genome alignment: STAR
- Gene level counts: featureCounts