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
	    def priority = sample_meta.quality > 40 ? 'high' : 'normal'
            return sample_meta + [priority: priority]
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
