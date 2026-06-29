#!/bin/bash

export PATH=/programs/STAR-2.7.11b:$PATH

STAR --genomeLoad LoadAndExit --genomeDir /workdir/ssv42/Mesc671_v8_assembly/Mesc671_v8_index

# Define function for read processing
align_reads() {

	file_R1="$1"
	file_R2="${file_R1/_R1_trimmed2.fastq.gz/_R2_trimmed2.fastq.gz}"  #use the first read file name to find the second paired read
	base=$(basename "$file_R1" _R1_trimmed2.fastq.gz)

	echo "$file_R1"
	echo "$file_R2"
	echo "$base"

	STAR --quantMode GeneCounts --genomeDir /workdir/ssv42/Mesc671_v8_assembly/Mesc671_v8_index --runThreadN 4 \
		--readFilesIn "$file_R1" "$file_R2" --readFilesCommand zcat  --outFileNamePrefix "/workdir/ssv42/RNAseq_yr2/STARalignedreads_PE/${base}_" \
		--outFilterMultimapNmax 10 --outFilterMismatchNmax 10 --outFilterIntronMotifs RemoveNoncanonicalUnannotated --outFilterMismatchNoverLmax 0.06 \
		--alignIntronMax 20000 --outReadsUnmapped Fastx --outSAMtype BAM SortedByCoordinate --genomeLoad LoadAndKeep --limitBAMsortRAM 8000000000
}

export -f align_reads

# Run in parallel using all available CPU cores (or specify a number with `-j #`)
find /workdir/ssv42/RNAseq_yr2/trimmed -name "*R1_trimmed2.fastq.gz" | parallel -j 9 align_reads

