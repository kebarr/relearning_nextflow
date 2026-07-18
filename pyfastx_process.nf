//#!/usr/bin/env nextflow


/*
 * Get basic stats from  fastq file
 */
process GET_READ_STATS {

    //publishDir "${params.outdir}", mode: 'copy'

    input:
    path input_fastq

    output:
    path "stats_summary.tsv"

    script:
    """
	echo "Collecting basic read stats"
	pyfastx stat $input_fastq > stats_summary.tsv
    """
}
