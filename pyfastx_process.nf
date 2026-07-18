//#!/usr/bin/env nextflow


/*
 * Get basic stats from  fastq file
 */
process GET_READ_STATS {

    debug true

    input:
    path input_fastq

    output:
    path "pyfastx_stats.csv"

    script:
    """
	echo "Collecting basic read stats"
	echo "## $input_fastq" > "pyfastx_stats.csv"
	pyfastx stat $input_fastq >> "pyfastx_stats.csv"
    """
}
