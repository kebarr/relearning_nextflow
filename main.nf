#!/usr/bin/env nextflow

/*
    * The main workflow definition
*/


include { COUNT_LINES } from './bioawk_process.nf'
include { GET_READ_STATS } from './pyfastx_process.nf'
include { BLAST } from './BLAST.nf'


workflow {
    // Create one channel entry per fastq file found in the input directory
    fastq_ch = Channel.fromPath("${params.input_dir}/*.fastq", checkIfExists: true)

    // Run processes once per fastq file
    COUNT_LINES(fastq_ch)
    GET_READ_STATS(fastq_ch)
    BLAST(fastq_ch)


    // Merge every sample's output into one combined report file
    COUNT_LINES.out
        .collectFile(name: 'count_summary.tsv', storeDir: params.out_count, keepHeader: true, skip: 1)

    GET_READ_STATS.out
        .collectFile(name: 'pyfastx_stats.csv', storeDir: params.out_stats)

    BLAST.out
        .collectFile(name: params.run_name, storeDir: params.out_alignment)
}


// when nextflow pulls a docker container, does it do it every time it runs or just once?
//Just once (per machine) — Nextflow itself doesn't do the pulling; it just runs docker run <image> ... for each task, and Docker's own daemon checks its local image cache first. If the image (matching tag/digest) is already there, it runs it straight from cache with no network activity. It only actually pulls over the network the first time, or if you've since removed it locally (docker image prune, etc.) or if you're using a mutable tag like :latest and force a re-pull.

//So across multiple pipeline runs, and even across different processes in the same pipeline that reference the same image, you only pay the pull cost once — subsequent runs reuse the cached layers.

//One nuance: if you ever run on a cluster/cloud executor where each job lands on a different node (not relevant to your current local setup), each new node would need to pull it the first time it's used there, since the Docker cache is per-machine, not shared globally.