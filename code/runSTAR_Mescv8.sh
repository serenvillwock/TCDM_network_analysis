#!/bin/bash
export PATH=/programs/STAR-2.7.11b:$PATH
	
# Define function for read processing
align_reads() {
	file="$1"
	base=$(basename "$file" .fastq.gz)

	STAR --quantMode GeneCounts --genomeDir /workdir/ssv42/Mesc671_v8_assembly/Mesc671_v8_index --runThreadN 2 \
		--readFilesIn "$file" --readFilesCommand zcat  --outFileNamePrefix "/workdir/ssv42/RNAseq/STAR_v8alignedreads/${base}_" \
		--outFilterMultimapNmax 10 --outFilterMismatchNmax 10 --outFilterIntronMotifs RemoveNoncanonicalUnannotated --outFilterMismatchNoverLmax 0.06 \
		--alignIntronMax 20000 --outReadsUnmapped Fastx --outSAMtype BAM SortedByCoordinate
}
export -f align_reads 

# Run in parallel using all available CPU cores (or specify a number with `-j #`)
find /workdir/ssv42/RNAseq/trimmed -name "*.fastq.gz" | parallel -j 15 align_reads
