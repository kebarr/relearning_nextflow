def sample_ids = ['sample_001', 'sample_002', 'sample_003']

// channel.collect() - groups multiple channel emissions into one
ch_input = channel.fromList(sample_ids)
ch_input.view { sample -> "Individual channel item: ${sample}" }
ch_collected = ch_input.collect()
ch_collected.view { list -> "channel.collect() result: ${list} (${list.size()} items grouped into 1)" }

// Steps:

//    Define a List of sample IDs
//    Create a channel with fromList() that emits each sample ID separately
//    Print each item with view() as it flows through
//    Gather all items into a single list with the channel's collect() operator
//    Print the collected result (single item containing all sample IDs) with a second view()

//We've changed the structure of the channel, but we haven't changed the data itself.


// List.collect() - transforms each element, preserves structure
def formatted_ids = sample_ids.collect { id ->
    id.toUpperCase().replace('SAMPLE_', 'SPECIMEN_')
}
println "List.collect() result: ${formatted_ids} (${sample_ids.size()} items transformed into ${formatted_ids.size()})"

//In this new snippet we:

//  Define a new variable formatted_ids that uses the List's collect method to transform each sample ID in the original list
//  Print the result using println


// Spread operator - concise property access
def sample_data = [[id: 's1', quality: 38.5], [id: 's2', quality: 42.1], [id: 's3', quality: 35.2]]
def all_ids = sample_data*.id
println "Spread operator result: ${all_ids}"

The spread operator *. is a shorthand for a common collect pattern:

// These are equivalent:
//def ids = samples*.id
//def ids = samples.collect { it.id }

// Also works with method calls:
//def names = files*.getName()
//def names = files.collect { it.getName() }

