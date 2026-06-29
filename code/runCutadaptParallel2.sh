#!/bin/bash

export PYTHONPATH=/programs/cutadapt-4.9/lib/python3.9/site-packages:/programs/cutadapt-4.9/lib64/python3.9/site-packages
export PATH=/programs/cutadapt-4.9/bin:$PATH

# Define function for cutadapt processing
process_file() {
	file_R1="$1"
	file_R2="${file_R1/_R1.fastq.gz/_R2.fastq.gz}"	#use the first read file name to find the second paired read
	
	#echo "$fileR1"
	#echo "$fileR2"

	#check that it found both read files:
	if [[ ! -f "$file_R2" ]]; then
		echo "Skipping $file_R1: matching _R2 file not found!"
		return
	fi
	
	#Extract base name without _R1/_R2 suffix
	base=$(basename "$file_R1" _R1.fastq.gz)
	#echo "${base}"

	#Run cutadapt for paired-end trimming
	cutadapt -m 18 -a "polyA=A{10}" -A "polyA=A{10}" \
	       	-a "QUALITY=G{10}" -A "QUALITY=G{10}" -G "polyA=A{10}" -G "polyT=T{10}" \
	       	-n 2 --json="./trimmed/${base}_poly.cutadapt.json" \
		-o "./trimmed/${base}_R1_trimmed1.fastq.gz" -p "./trimmed/${base}_R2_trimmed1.fastq.gz" \
		"$file_R1" "$file_R2"

	cutadapt -m 18 -u 12 -O 3 -q 20,20 -a "AGATCGGAAGAGCACACGTCTGAACTCCAGTCAC" -A "AGATCGGAAGAG" \
	--overlap 3 --error-rate 0.1 --json="./trimmed/${base}.cutadapt.json" \
	-o "./trimmed/${base}_R1_trimmed2.fastq.gz" -p "./trimmed/${base}_R2_trimmed2.fastq.gz" \
	"./trimmed/${base}_R1_trimmed1.fastq.gz" "./trimmed/${base}_R2_trimmed1.fastq.gz" 
}
export -f process_file  # Export function for GNU Parallel
# Run in parallel using -j CPU cores
find /workdir/ssv42/RNAseq_yr2/TCDM3-4 -name "*_R1.fastq.gz" | parallel -j 20 process_file
