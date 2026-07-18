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
    blastn -db $db/$db_name -task megablast -evalue 0.001 -max_target_seqs 25 -num_threads 10 -query query.fa -outfmt "6 qaccver pident qcovs staxid" > blast_result_$run_name
    cat blast_result_$run_name | head -n 10 | cut -f 2 > top_hits_$run_name
    """
}

// for LCA  ./LCA_BLAST_calculator.py lca --names /root/blast_dbs/taxonomy/names.dmp --nodes /root/blast_dbs/taxonomy/nodes.dmp --input blast_results.txt --output frequency_table_LCA.txt ---blast "qaccver+pident+qcovs+staxid" --pident 90 --qcov 90