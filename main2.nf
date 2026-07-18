#!/usr/bin/env nextflow

//params.input_fastq: "data/sample_40_shigella_flex_reads.fastq"
//params.input_dir: "data"
//params.outdir: "results"

params {
	input_fastq: Path = "data/sample_40_shigella_flex_reads.fastq"
	outdir: Path = "results/summary_tsv"
}
/*
 * Count reads in fastq file
 */
process COUNT_LINES {

    publishDir "${params.outdir}", mode: 'copy'

    input:
    path input_fastq

    output:
    path outdir

    script:
    """
	echo "Counting reads in file"
	echo -e "fastq_name\tnumber_reads" > summary.tsv
	read_count="$( bioawk -c fastx 'END{print NR}' $input_fastq)"
    	echo "$input_fastq\t$read_count\n" > summary.tsv
	echo "Fastq $input_fastq contains $read_count reads"
    """
}
//#!/usr/bin/env nextflow

/*
 * Get basic stats from  fastq file
 */
process GET_READ_STATS {

    publishDir "${params.outdir}", mode: 'copy'

    input:
	path: input_fastq

    output:
    path "summary.tsv"

    script:
    """
	echo "Collecting basic read stats"
	pyfastx stat $input_fastq > summary.tsv
    """
}
//#!/usr/bin/env nextflow

/*
    * The main workflow definition
*/



//include { GET_READ_STATS } from './bioawk_process.nf'
//include { COUNT_LINES } from './pyfastx_process.nf'

workflow {
   	 // Create input channel from sample sheet
    	//samples_ch = Channel
        //		.fromPath(params.fastq_names)

    	// Run processes
    	COUNT_LINES(params.input_fastq)
	GET_READ_STATS(params.input_fastq)	

	
}
