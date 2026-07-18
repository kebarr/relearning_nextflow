//#!/usr/bin/env nextflow

/*
 * Count reads in fastq file
 */
process COUNT_LINES {

    publishDir "${params.out_count}", mode: 'copy'

    input:
    path input_fastq

    output:
    path "count_summary.tsv"

    script:
    """
	echo "Counting reads in file"
	echo -e "fastq_name\tnumber_reads" > count_summary.tsv
	read_count="$( bioawk -c fastx 'END{print NR}' $input_fastq)"
    	echo "$input_fastq\t\$read_count\n" > count_summary.tsv
	echo "Fastq $input_fastq contains \$read_count reads"
    """
}