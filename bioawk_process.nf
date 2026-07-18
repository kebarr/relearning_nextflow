//#!/usr/bin/env nextflow

/*
 * Count reads in fastq file
 */
process COUNT_LINES {

    debug true

    input:
    path input_fastq

    output:
    path "count_summary.tsv"

    shell:
    '''
    echo "Counting reads in file"
    echo -e "fastq_name\tnumber_reads" > count_summary.tsv
    read_count=$(bioawk -c fastx 'END{print NR}' !{input_fastq})
    echo -e "!{input_fastq}\t$read_count" >> count_summary.tsv
    echo "Fastq !{input_fastq} contains $read_count reads"
    '''
}