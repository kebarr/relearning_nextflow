#!/usr/bin/env nextflow

/*
    * The main workflow definition
*/

include { GET_READ_STATS } from './bioawk_process.nf'
include { COUNT_LINES } from './pyfastx_process.nf'

workflow {
   	 // Create input channel from sample sheet
    	samples_ch = Channel
        		.fromPath(params.fastq_names)

    	// Run processes
    	COUNT_LINES(samples_ch)
	GET_READ_STATS(samples_ch)	

	
}
