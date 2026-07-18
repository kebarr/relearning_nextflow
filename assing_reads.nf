process assign_reads {
    input:
    path blast_result
    val run_name

    output:
    path "frequency_table_LCA_$run_name.txt", emit: read_assignments

    script:
    """
    $lca_script lca --names /root/blast_dbs/taxonomy/names.dmp --nodes /root/blast_dbs/taxonomy/nodes.dmp --input $blast_result --output frequency_table_LCA_$run_name.txt ---blast "qaccver+pident+qcovs+staxid" --pident 90 --qcov 90
    """
}