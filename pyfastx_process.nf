//#!/usr/bin/env nextflow

/*
 * Get basic stats from  fastq file
 */
process GET_READ_STATS {


    input:
    path input_fastq

    output:
    path "summary.tsv"

    script:
    """
	echo "Collecting basic read stats"
	pyfastx stat $input_fastq > summary.tsv
    """
}
