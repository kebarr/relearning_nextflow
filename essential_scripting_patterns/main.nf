include { GENERATE_REPORT } from './modules/generate_report.nf'
include { FASTP } from './modules/fastp.nf'
include { TRIMGALORE } from './modules/trimgalore.nf'

def validateInputs() {
    // Check input parameter is provided
    if (!params.input) {
        error("Input CSV file path not provided. Please specify --input <file.csv>")
    }

    // Check CSV file exists
    if (!file(params.input).exists()) {
        error("Input CSV file not found: ${params.input}")
    }
}

def separateMetadata(row) {
    def sample_meta = [
        id: row.sample_id.toLowerCase(),
        organism: row.organism,
        tissue: row.tissue_type.replaceAll('_', ' ').toLowerCase(),
        depth: row.sequencing_depth.toInteger(),
        quality: row.quality_score.toDouble()
    ]
    def run_id = row.run_id?.toUpperCase() ?: 'UNSPECIFIED' // specify default, if none is specified result is null
    sample_meta.run = run_id	
    def fastq_path = file(row.file_path)

    def m = (fastq_path.name =~ /^(.+)_S(\d+)_L(\d{3})_(R[12])_(\d{3})\.fastq(?:\.gz)?$/)
    def file_meta = m ? [
        sample_num: m[0][2].toInteger(),
        lane: m[0][3],
        read: m[0][4],
        chunk: m[0][5]
    ] : [:]

    def priority = sample_meta.quality > 40 ? 'high' : 'normal'
        // Validate data makes sense
    if (sample_meta.depth < 30000000) {
        log.warn "Low sequencing depth for ${sample_meta.id}: ${sample_meta.depth}"
    }

	return tuple(sample_meta + file_meta + [priority: priority], fastq_path)
}


workflow {
    main:
        validateInputs()
    	ch_samples = channel.fromPath(params.input)
	//ch_samples = channel.fromPath("./data/samples.csv")
        .splitCsv(header: true)
        .map{ row -> separateMetadata(row) }
	.view()
    	
	// Filter out invalid or low-quality samples
    ch_valid_samples = ch_samples
        .filter { meta, reads ->
            meta.id && meta.organism && meta.depth >= 25000000
        }

    trim_branches = ch_valid_samples
        .branch { meta, reads ->
            fastp: meta.organism == 'human' && meta.depth >= 30000000
            trimgalore: true
        }

	// Another powerful pattern for controlling workflow execution is the .filter() operator, which uses a closure to determine which items should continue down the pipeline. Inside the filter closure, you'll write boolean expressions that decide which items pass through.

	//Nextflow (like many dynamic languages) has a concept of "truthiness" that determines what values evaluate to true or false in boolean contexts:

	//    Truthy: Non-null values, non-empty strings, non-zero numbers, non-empty collections
	//    Falsy: null, empty strings "", zero 0, empty collections [] or [:], false


    ch_fastp = FASTP(trim_branches.fastp)
    ch_trimgalore = TRIMGALORE(trim_branches.trimgalore)
    GENERATE_REPORT(ch_samples)	

    workflow.onComplete = {
        def summary = """
        Pipeline Execution Summary
        ===========================
        Completed: ${workflow.complete}
        Duration : ${workflow.duration}
        Success  : ${workflow.success}
        Command  : ${workflow.commandLine}
        """

        println summary

        // Write to a log file
        def log_file = file("${workflow.launchDir}/pipeline_summary.txt")
        log_file.text = summary
	}

    workflow.onError = {
        println "="* 50
        println "Pipeline execution failed!"
        println "Error message: ${workflow.errorMessage}"
        println "="* 50

        // Write detailed error log
        def error_file = file("${workflow.launchDir}/error.log")
        error_file.text = """
        Workflow Error Report
        =====================
        Time: ${new Date()}
        Error: ${workflow.errorMessage}
        Error report: ${workflow.errorReport ?: 'No detailed report available'}
        """

        println "Error details written to: ${error_file}"
    }


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

//In this section, you've learned string processing techniques:

 //   Regular expressions for file parsing: Using the =~ operator and regex patterns (~/pattern/) to extract metadata from complex file naming conventions
 //   Dynamic script generation: Using conditional logic (if/else, ternary operators) to generate different script strings based on input characteristics
 //   Variable interpolation: Understanding when Nextflow interprets strings vs when the shell does
 //   ${var} - Nextflow variables (interpolated by Nextflow at workflow compile time)
 //   \${var} - Shell environment variables (escaped, passed to bash at runtime)
 //   \$(cmd) - Shell command substitution (escaped, executed by bash at runtime)

//These string processing and generation patterns are essential for handling the diverse file formats and naming conventions you'll encounter in real-world bioinformatics workflows
