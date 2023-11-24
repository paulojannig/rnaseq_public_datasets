# RNA-seq pipeline to analyse public datasets
RNA-seq pipeline using shell scripts

## USAGE: 
1. Download the SraRunTable.txt using SRA Run Selector tool (https://www.ncbi.nlm.nih.gov/Traces/study/)
    For example:
        - go to https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA648376      	
        - click on Metadata to download the SraRunTable.txt file containing all or selected samples
        - Save the file 'SraRunTable.txt' into the directory `dataset_table/`
        - Check 'SraRunTable.txt' to see if there are fastq files that belong to the same biological replicate. These files will need to be merged. To do that, adjust parameters within "scripts/01.setup.environment.sh" (# To merge fastq files from multiple lanes...)
2. Change parameters in the `config.sh` file
3. Run this script using the command: `./main.sh`

## Pipeline description:

- Download deposited Fastq files: [sradownloader](https://github.com/s-andrews/sradownloader) 
- Quality control: FastQC and TrimGalore!
- Genome alignment: STAR
- Gene level counts: featureCounts
- Pseudoalignment quantification: Kallisto

## Requirements
    - Pre-built STAR index
    - Annotation file (GTF and BED formats)
    - python3 (>= v3.6)
    - SRA toolkit https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
    - sradownloader https://github.com/s-andrews/sradownloader
    - FastQC
    - MultiQC
    - Trim Galore!
    - cutadapt
    - STAR
    - Samtools
    - infer_experiment.py (RSeQC)
    - featureCounts (from Subread package)
    - kallisto 0.46.1

# References