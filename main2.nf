#!/usr/bin/env nextflow

//params.input_fastq: "data/sample_40_shigella_flex_reads.fastq"
//params.input_dir: "data"
//params.outdir: "results"

params.input_fastq = "./data/sample_40_shigella_flex_reads.fastq"
params.out_count = "./results/count_summary_tsv"
params.out_stats = "./results/stats_summary_tsv"

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
//#!/usr/bin/env nextflow

/*
    * The main workflow definition
*/



//include { GET_READ_STATS } from './bioawk_process.nf'
//include { COUNT_LINES } from './pyfastx_process.nf'

workflow {
    // Create input channel from the fastq file path
    input_ch = Channel.fromPath(params.input_fastq, checkIfExists: true)

    // Run processes
    COUNT_LINES(input_ch)
    GET_READ_STATS(input_ch)
}
