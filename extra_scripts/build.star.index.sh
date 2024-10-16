

#!/bin/bash

###########################################################################################
# Author: Paulo Jannig | GitHub: https://github.com/paulojannig
#
# DESCRIPTION:
# This script downloads FASTA and GTF files from Ensembl and creates a STAR index for genome of interest
# Supported species:
#   - Human [GRCh38] (release-102)
#   - Mouse [GRCm38] (release-102)
#   - Pig [Sscrofa11.1] (release-106)
#   - Rat [mRatBN7.2] (release-112)
#
# Human genome: [GRCh38] (release-102)
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
# Rat genome: [mRatBN7.2] (release-112)
#   Genome FASTA file: [Rattus_norvegicus.mRatBN7.2.dna.primary_assembly.*.fa.gz](https://ftp.ensembl.org/pub/release-112/fasta/rattus_norvegicus/dna/Rattus_norvegicus.mRatBN7.2.dna.primary_assembly.*.fa.gz)
#   GTF annotation file: [Rattus_norvegicus.mRatBN7.2.112.gtf.gz](https://ftp.ensembl.org/pub/release-112/gtf/rattus_norvegicus/Rattus_norvegicus.mRatBN7.2.112.gtf.gz) 
#   Transcriptome (cDNA) FASTA file: [Rattus_norvegicus.mRatBN7.2.cdna.all.fa.gz](https://ftp.ensembl.org/pub/release-112/fasta/rattus_norvegicus/cdna/Rattus_norvegicus.mRatBN7.2.cdna.all.fa.gz)
#
# REQUIREMENTS:
# - STAR
# - gtfToGenePred
# - genePredToBed
#
###########################################################################################
#GENOME_FOLDER=/proj/yourProjectFolder/genomes
#SPECIES=human # supports "mouse", "human", "pig" and "rat"
#THREADN=10 # define number of threads to use

# If using UPPMAX, load software modules
module load bioinfo-tools star/2.7.11a
module load bioinfo-tools ucsc-utilities/v421


if [ -d "${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/star_index_149" ]
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
        GENOME_VERSION=GRCm38.102
    elif [ $SPECIES = "human" ]
    then     
        FASTA_LINK=https://ftp.ensembl.org/pub/release-102/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
        GTF_LINK=https://ftp.ensembl.org/pub/release-102/gtf/homo_sapiens/Homo_sapiens.GRCh38.102.gtf.gz
        FASTA_FILE=Homo_sapiens.GRCh38.dna.primary_assembly.fa
        GTF_FILE=Homo_sapiens.GRCh38.102.gtf
        GENOME_VERSION=GRCh38.102
    elif [ $SPECIES = "pig" ]
    then
        FASTA_LINK=https://ftp.ensembl.org/pub/release-106/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna.chromosome.*.fa.gz
        GTF_LINK=https://ftp.ensembl.org/pub/release-106/gtf/sus_scrofa/Sus_scrofa.Sscrofa11.1.106.gtf.gz
        FASTA_FILE=Sus_scrofa.Sscrofa11.1.dna.chromosome.*.fa
        GTF_FILE=Sus_scrofa.Sscrofa11.1.106.gtf
        GENOME_VERSION=Sscrofa11.1.106
    elif [ $SPECIES = "rat" ]
    then
        FASTA_LINK=https://ftp.ensembl.org/pub/release-112/fasta/rattus_norvegicus/dna/Rattus_norvegicus.mRatBN7.2.dna.primary_assembly.*.fa.gz
        GTF_LINK=https://ftp.ensembl.org/pub/release-112/gtf/rattus_norvegicus/Rattus_norvegicus.mRatBN7.2.112.gtf.gz
        FASTA_FILE=Rattus_norvegicus.mRatBN7.2.dna.primary_assembly.*.fa
        GTF_FILE=Rattus_norvegicus.mRatBN7.2.112.gtf
        GENOME_VERSION=mRatBN7.2
    else
        echo "Unsupported species: $SPECIES"
        exit 1
    fi

    INDEX_FOLDER=${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/star_index_149
    mkdir -p ${INDEX_FOLDER}

    wget --continue ${FASTA_LINK} -P ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/
    wget --continue ${GTF_LINK} -P ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/
    gunzip ${GENOME_FOLDER}/${SPECIES}/*.gz

    # Create STAR index
    STAR \
        --runMode genomeGenerate \
        --runThreadN $THREADN \
        --genomeDir $INDEX_FOLDER \
        --genomeFastaFiles ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/${FASTA_FILE} \
        --sjdbGTFfile ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/${GTF_FILE} \
        --sjdbOverhang 149
    gzip ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/*.fa
    
    # Create reference BED files 
    GTF_PREFIX=${GTF_FILE%.gtf}
    
    gtfToGenePred -geneNameAsName2 \
        ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/${GTF_FILE} \
        ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/${GTF_PREFIX}.genePred

    genePredToBed \
        ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/${GTF_PREFIX}.genePred \
        ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/${GTF_PREFIX}.bed

    echo "STAR version " `STAR --version` >> ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/genome_info.txt
    echo "gtfToGenePred to convert GTF to genePred" >> ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/genome_info.txt
    echo "genePredToBed to convert genePred to bed" >> ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/genome_info.txt
    echo "FASTA files downloaded from: " ${FASTA_LINK} >> ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/genome_info.txt
    echo "GTF file downloaded from: " ${GTF_LINK} >> ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/genome_info.txt
    echo "Genome version: " ${GENOME_VERSION} >> ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/genome_info.txt
    echo "Downloaded on "`date` >> ${GENOME_FOLDER}/${SPECIES}/${GENOME_VERSION}/genome_info.txt
    echo "Done!" `date`

fi


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
#   Genome FASTA file: [Rattus_norvegicus.mRatBN7.2.dna.primary_assembly.*.fa.gz](https://ftp.ensembl.org/pub/release-112/fasta/rattus_norvegicus/dna/Rattus_norvegicus.mRatBN7.2.dna.primary_assembly.*.fa.gz)
#   GTF annotation file: [Rattus_norvegicus.mRatBN7.2.112.gtf.gz](https://ftp.ensembl.org/pub/release-112/gtf/rattus_norvegicus/Rattus_norvegicus.mRatBN7.2.112.gtf.gz) 
#   Transcriptome (cDNA) FASTA file: [Rattus_norvegicus.mRatBN7.2.cdna.all.fa.gz](https://ftp.ensembl.org/pub/release-112/fasta/rattus_norvegicus/cdna/Rattus_norvegicus.mRatBN7.2.cdna.all.fa.gz)
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
        FASTA_LINK=https://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Rattus_norvegicus/reference/GCF_036323735.1_GRCr8/GCF_036323735.1_GRCr8_genomic.fna.gz
        GTF_LINK=https://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_mammalian/Rattus_norvegicus/reference/GCF_036323735.1_GRCr8/GCF_036323735.1_GRCr8_genomic.gtf.gz
        FASTA_FILE=GCF_036323735.1_GRCr8_genomic.fna
        GTF_FILE=GCF_036323735.1_GRCr8_genomic.gtf
    else
        echo "Unsupported species: $SPECIES"
        exit 1
    fi

    INDEX_FOLDER=${GENOME_FOLDER}/${SPECIES}/star_index_149
    mkdir -p ${INDEX_FOLDER}

    wget --continue ${FASTA_LINK} -P ${GENOME_FOLDER}/${SPECIES}/
    wget --continue ${GTF_LINK} -P ${GENOME_FOLDER}/${SPECIES}/
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
