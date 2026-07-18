include { GENERATE_REPORT } from './modules/generate_report.nf'
include { FASTP } from './modules/fastp.nf'
include { TRIMGALORE } from './modules/trimgalore.nf'

def separateMetadata(row) {
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


workflow {
    main:
    ch_samples = channel.fromPath("./data/samples.csv")
        .splitCsv(header: true)
        .map{ row -> separateMetadata(row) }

    trim_branches = ch_samples
        .branch { meta, reads ->
            fastp: meta.organism == 'human' && meta.depth >= 30000000
            trimgalore: true
        }

    ch_fastp = FASTP(trim_branches.fastp)
    ch_trimgalore = TRIMGALORE(trim_branches.trimgalore)
    GENERATE_REPORT(ch_samples)	


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
