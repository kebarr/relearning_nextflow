//#!/usr/bin/env nextflow

/*
 * Count reads in fastq file
 */
process COUNT_LINES {


    input:
    path input_fastq

    output:
    path "summary.tsv"

    script:
    """
	echo "Counting reads in file"
	echo -e "fastq_name\tnumber_reads" > summary.tsv
	read_count="$( bioawk -c fastx 'END{print NR}' $input_fastq)"
    	echo "$input_fastq\t$read_count\n" > summary.tsv
	echo "Fastq $input_fastq contains $read_count reads"
    """
}
