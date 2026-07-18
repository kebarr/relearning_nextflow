#!/usr/bin/env nextflow

/*
    * The main workflow definition
*/

params.input_fastq = "./data/sample_40_shigella_flex_reads.fastq"
params.out_count = "./results/count_summary_tsv"
params.out_stats = "./results/stats_summary_tsv"

include { COUNT_LINES } from './bioawk_process.nf'
include { GET_READ_STATS } from './pyfastx_process.nf'

workflow {
   	 // Create input channel from sample sheet
    input_ch = Channel.fromPath(params.input_fastq, checkIfExists: true)


    	// Run processes
    	COUNT_LINES(input_ch)
	GET_READ_STATS(input_ch)	

	
}
