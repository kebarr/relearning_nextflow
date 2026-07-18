//#!/usr/bin/env nextflow


/*
 * Get basic stats from  fastq file
 */
process GET_READ_STATS {

    debug true
    publishDir "${params.out_stats}", mode: 'copy'

    input:
    path input_fastq

    output:
    path "pyfastx_stats.csv"

    script:
    """
	echo "Collecting basic read stats"
	pyfastx stat $input_fastq > "pyfastx_stats.csv"
    """
}
