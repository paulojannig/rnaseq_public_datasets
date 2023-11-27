
#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | GitHub: https://github.com/paulojannig
#
# DESCRIPTION:
# This script creates a STAR index for genome of interest
#
# Human genome: [GRCh38 (release-102)]
#   Genome FASTA file: [Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz](https://ftp.ensembl.org/pub/release-102/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz)
#   GTF annotation file: [Homo_sapiens.GRCh38.102.gtf.gz](https://ftp.ensembl.org/pub/release-102/gtf/homo_sapiens/Homo_sapiens.GRCh38.102.gtf.gz)
#   Transcriptome (cDNA) FASTA file: 
#
# Mouse genome: [GRCm38] (release-102)
#   Genome FASTA file: [Mus_musculus.GRCm38.dna.primary_assembly.fa.gz](https://ftp.ensembl.org/pub/release-102/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz)
#   GTF annotation file: [Mus_musculus.GRCm38.102.chr.gtf.gz](http://ftp.ensembl.org/pub/release-102/gtf/mus_musculus/Mus_musculus.GRCm38.102.chr.gtf.gz)
#   Transcriptome (cDNA) FASTA file: 
#
# Pig genome: [Sscrofa11.1] (release-106)
#   Genome FASTA file: [Sus_scrofa.Sscrofa11.1.dna.chromosome.*.fa.gz](https://ftp.ensembl.org/pub/release-106/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna.chromosome.*.fa.gz)
#   GTF annotation file: [Sus_scrofa.Sscrofa11.1.106.gtf.gz](https://ftp.ensembl.org/pub/release-106/gtf/sus_scrofa/Sus_scrofa.Sscrofa11.1.106.gtf.gz)
#   Transcriptome (cDNA) FASTA file: [Sus_scrofa.Sscrofa11.1.cdna.all.fa.gz](https://ftp.ensembl.org/pub/release-106/fasta/sus_scrofa/cdna/Sus_scrofa.Sscrofa11.1.cdna.all.fa.gz)
#
# Rat genome:
#   Genome FASTA file: 
#   GTF annotation file:
#   Transcriptome (cDNA) FASTA file: 
#
# REQUIREMENTS:
# - STAR
#
###########################################################################################
GENOME_FOLDER=/proj/yourProjectFolder/genomes
SPECIES=human # supports "mouse", "human", "pig" and "rat"
THREADN=10 # define number of threads to use

# If using UPPMAX, load software modules
module load bioinfo-tools star/2.7.11a
module load bioinfo-tools ucsc-utilities/v421


if [ -d "${GENOME_FOLDER}/${SPECIES}/star_index_149" ]
then
    # Run your code here for the case when $DATASET/fastq exists
    echo "STAR index for $SPECIES already exists..."
    exit 1
else
    # Run your code here for the case when ${GENOME_FOLDER}/${SPECIES}/star_index_149 does not exist
    # Create path to index and annotation files
    if [ $SPECIES = "mouse" ]
    then 
        FASTA_LINK=https://ftp.ensembl.org/pub/release-102/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.primary_assembly.fa.gz
        GTF_LINK=http://ftp.ensembl.org/pub/release-102/gtf/mus_musculus/Mus_musculus.GRCm38.102.chr.gtf.gz
        FASTA_FILE=Mus_musculus.GRCm38.dna.primary_assembly.fa
        GTF_FILE=Mus_musculus.GRCm38.102.chr.gtf
    elif [ $SPECIES = "human" ]
    then     
        FASTA_LINK=https://ftp.ensembl.org/pub/release-102/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
        GTF_LINK=https://ftp.ensembl.org/pub/release-102/gtf/homo_sapiens/Homo_sapiens.GRCh38.102.gtf.gz
        FASTA_FILE=Homo_sapiens.GRCh38.dna.primary_assembly.fa
        GTF_FILE=Homo_sapiens.GRCh38.102.gtf
    elif [ $SPECIES = "pig" ]
    then
        FASTA_LINK=https://ftp.ensembl.org/pub/release-106/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna.chromosome.*.fa.gz
        GTF_LINK=https://ftp.ensembl.org/pub/release-106/gtf/sus_scrofa/Sus_scrofa.Sscrofa11.1.106.gtf.gz
        FASTA_FILE=Sus_scrofa.Sscrofa11.1.dna.chromosome.*.fa
        GTF_FILE=Sus_scrofa.Sscrofa11.1.106.gtf
    elif [ $SPECIES = "rat" ]
    then
        FASTA_LINK=
        GTF_LINK=
        FASTA_FILE=
        GTF_FILE=
    else
        echo "Unsupported species: $SPECIES"
        exit 1
    fi

    INDEX_FOLDER=${GENOME_FOLDER}/${SPECIES}/star_index_149
    mkdir -p ${INDEX_FOLDER}

    #wget --continue ${FASTA_LINK} -P ${GENOME_FOLDER}/${SPECIES}/
    #wget --continue ${GTF_LINK} -P ${GENOME_FOLDER}/${SPECIES}/
    gunzip ${GENOME_FOLDER}/${SPECIES}/*.gz

    # Create STAR index
    STAR \
        --runMode genomeGenerate \
        --runThreadN $THREADN \
        --genomeDir $INDEX_FOLDER \
        --genomeFastaFiles ${GENOME_FOLDER}/${SPECIES}/${FASTA_FILE} \
        --sjdbGTFfile ${GENOME_FOLDER}/${SPECIES}/${GTF_FILE} \
        --sjdbOverhang 149
    gzip ${GENOME_FOLDER}/${SPECIES}/*.fa
    
    # Create reference BED files 
    GTF_PREFIX=${GTF_FILE%.gtf}
    
    gtfToGenePred -geneNameAsName2 \
        ${GENOME_FOLDER}/${SPECIES}/${GTF_FILE} \
        ${GENOME_FOLDER}/${SPECIES}/${GTF_PREFIX}.genePred

    genePredToBed \
        ${GENOME_FOLDER}/${SPECIES}/${GTF_PREFIX}.genePred \
        ${GENOME_FOLDER}/${SPECIES}/${GTF_PREFIX}.bed

    echo "STAR" `STAR --version` >> ${GENOME_FOLDER}/${SPECIES}/star_index.txt
    echo "ucsc-utilities/v421" >> ${GENOME_FOLDER}/${SPECIES}/star_index.txt
    
    echo "Done!" `date`

fi