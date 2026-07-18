#!/usr/bin/env nextflow

/*
    * The main workflow definition
*/


include { COUNT_LINES } from './bioawk_process.nf'
include { GET_READ_STATS } from './pyfastx_process.nf'

workflow {
    // Create one channel entry per fastq file found in the input directory
    fastq_ch = Channel.fromPath("${params.input_dir}/*.fastq", checkIfExists: true)

    // Run processes once per fastq file
    COUNT_LINES(fastq_ch)
    GET_READ_STATS(fastq_ch)

    // Merge every sample's output into one combined report file
    COUNT_LINES.out
        .collectFile(name: 'count_summary.tsv', storeDir: params.out_count, keepHeader: true, skip: 1)

    GET_READ_STATS.out
        .collectFile(name: 'pyfastx_stats.csv', storeDir: params.out_stats)
}
