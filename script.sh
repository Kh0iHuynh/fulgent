#!/bin/bash


###
# Download .bas and chekc for study with highest quality read
###
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA12878/exome_alignment/NA12878.alt_bwamem_GRCh38DH.20150826.CEU.exome.bam.bas 




###
# Download read from the SRR with highest read quality
###
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR151/003/SRR1518133/SRR1518133_1.fastq.gz

###
# index hg38 for bwa alignment
###
bwa index hg38.fa

###
# alignment with BWA
###
bwa mem hg38.fa <(zcat SRR1518133_1.fastq.gz) | samtools view -bS - > out.bam

###
# Remove unmapped, mate unmapped
# not primary alignment, reads failing platform
# Only keep properly paired reads
# Obtain name sorted BAM file
###
samtools view -F 524 -f 2 -u out.bam > out.2.bam
samtools sort -n out.2.bam -o out.sorted.bam
samtools index out.sorted.bam


###
# Remove duplicates
###
java -jar picard_2_18_7.jar MarkDuplicates I=out.sorted.bam O=out.dedup.bam M=out.dups.txt REMOVE_DUPLICATES=true

###
# create bed file for gene of interest CD4
# CD4 locates in chr12:6772520-6839847
###
echo "chr12 6772520 6839847" | sed 's/ /\t/g' > bybase.bed

###
# calculate per base coverage using bedtools
###
bedtools coverage -a bybase.bed -b out.dedup.bam -d




