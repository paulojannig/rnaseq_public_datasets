# RNA-seq pipeline to analyse public datasets
RNA-seq pipeline using shell scripts

## USAGE: 

1. Clone repository 

    ```bash
    git clone https://github.com/paulojannig/rnaseq_public_datasets.git
    cd rnaseq_public_datasets
    chmod 755 *.sh
    chmod 755 scripts/*.sh
    ```
3. Download the SraRunTable.txt using SRA Run Selector tool (https://www.ncbi.nlm.nih.gov/Traces/study/). 

    <U>Example</U>:
   - go to https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA648376
   - click on Metadata to download the SraRunTable.txt file containing all or selected samples
   - Save the file 'SraRunTable.txt' into the directory `dataset_table/`
4. Check 'SraRunTable.txt' to see if there are fastq files that belong to the same biological replicate. These files will need to be merged. To do that, adjust parameters within `scripts/03.merge_fastq.sh`
5. Change parameters in the `config.sh` file
6. Run this script using the command: `./main.sh`

### UPPMAX
If you are using [UPPMAX](https://www.uppmax.uu.se/), please update the Slurm parameters in the `uppmax_job.sh` script.

Refer to the documentation [here](https://uppmax.github.io/uppmax_intro/slurm_intro.html#interactive-jobs) for instructions on submitting jobs to UPPMAX.

## Pipeline description:

- Download deposited Fastq files: [sradownloader](https://github.com/s-andrews/sradownloader) 
- Quality control: FastQC and TrimGalore!
- Genome alignment: STAR
- Gene level counts: featureCounts
- Pseudoalignment quantification: Kallisto

## Requirements
  - Pre-built STAR index
  - Pre-built Kallisto index
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


## References