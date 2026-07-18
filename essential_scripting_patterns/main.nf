workflow {
    main:
    ch_samples = channel.fromPath("./data/samples.csv")
        .splitCsv(header: true)
	.map { row ->
	    // Scripting for data transformation
            def sample_meta = [
                id: row.sample_id.toLowerCase(),
                organism: row.organism,
                tissue: row.tissue_type.replaceAll('_', ' ').toLowerCase(),
                depth: row.sequencing_depth.toInteger(),
                quality: row.quality_score.toDouble()
            ]
	   
  	    def fastq_path = file(row.file_path)

            def m = (fastq_path.name =~ /^(.+)_S(\d+)_L(\d{3})_(R[12])_(\d{3})\.fastq(?:\.gz)?$/)
            def file_meta = m ? [
                sample_num: m[0][2].toInteger(),
                lane: m[0][3],
                read: m[0][4],
                chunk: m[0][5]
            ] : [:]

            def priority = sample_meta.quality > 40 ? 'high' : 'normal'
            return tuple(sample_meta + file_meta + [priority: priority], fastq_path)
 
	}
        .view()

    publish:
    reports = channel.empty()
}

output {
    reports {
        path 'reports'
    }
}

// map is a closure- like an anaonymous function in python

// Pattern Matching and Regular Expressions¶

//Bioinformatics files often have complex naming conventions encoding metadata. Let's extract this automatically using pattern matching with regular expressions.

//We're going to return to our main.nf workflow and add some pattern matching logic to extract additional sample information from file names. The FASTQ files in our dataset follow Illumina-style naming conventions with names like SAMPLE_001_S1_L001_R1_001.fastq.gz. These might look cryptic, but they actually encode useful metadata like sample ID, lane number, and read direction. We're going to use regex capabilities to parse these names.
