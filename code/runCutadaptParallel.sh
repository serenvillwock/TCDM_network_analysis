#!/bin/bash

# Define function for cutadapt processing
process_file() {
	file="$1"
	base=$(basename "$file" .fastq.gz)
	
	export PYTHONPATH=/programs/cutadapt-4.9/lib/python3.9/site-packages:/programs/cutadapt-4.9/lib64/python3.9/site-packages
	export PATH=/programs/cutadapt-4.9/bin:$PATH

	cutadapt -m 18 -a "polyA=A{10}" -a "QUALITY=G{10}" -n 2 --json="./trimmed/${base}_poly.cutadapt.json" "$file" | \
	cutadapt -m 18 -u 12 -O 3 --nextseq-trim=10 -a "AGATCGGAAGAG" --overlap 3 --error-rate 0.1 --json="./trimmed/${base}.cutadapt.json" - | \
	cutadapt -m 18 -O 18 -g "AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC" --overlap 20 --discard-trimmed -o "./trimmed/${base}_trimmed.fastq.gz" -
}
export -f process_file  # Export function for GNU Parallel

# Run in parallel using all available CPU cores (or specify a number with `-j #`)
find /workdir/ssv42/RNAseq/TCDM* -name "*.fastq.gz" | parallel -j 30 process_file
