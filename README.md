# RNA-seq-pipeline
RNA-seq pipeline using shell scripts

## Edit config.sh file
1. Set the `PROJECT_FOLDER` variable to the desired path for your working folder.
2. Adjust the `SPECIES` variable to your target species: "mouse," "human," "pig," or "rat."
3. Optionally, customize other parameters like `THREADN` for the number of threads.


## Pipelines description:

## Pipeline 1: Analyzing home-made data
run with `./pipeline1.sh`

- Quality control: FastQC and TrimGalore!
- Genome alignment: STAR
- Gene level counts: featureCounts

## Pipeline 2: Analyzing public datasets
run with `./pipeline2.sh`

- Download deposited Fastq files
- Quality control: FastQC and TrimGalore!
- Genome alignment: STAR
- Gene level counts: featureCounts


## Pipeline 2: Analyzing public datasets
run with `./pipeline3.sh`

- Download deposited Fastq files
- Quality control: FastQC and TrimGalore!
- Pseudoalignment quantification: Kallisto
