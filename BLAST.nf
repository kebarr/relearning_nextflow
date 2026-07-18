process BLAST {
    input:
    path input_fastq
    path db
    val db_name
    val run_name

    output:
    path "top_hits_$run_name", emit: top_hits
    path "blast_result_$run_name", emit: blast_result

    script:
    """
    seqtk seq -A $input_fastq > query.fa
    blastn -db $db/$db_name -query query.fa -outfmt 6 > blast_result_$run_name
    cat blast_result_$run_name | head -n 10 | cut -f 2 > top_hits_$run_name
    """
}