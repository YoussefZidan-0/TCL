#!/usr/bin/tclsh

# Debug signal extraction from dummy_parallel.syn.v

set fp [open "dummy_parallel.syn.v" r]
set content ""
while {[gets $fp line] >= 0} {
    append content "$line\n"
}
close $fp

puts "=== File Content ==="
puts $content
puts ""

# Test simple patterns
puts "=== Testing Simple Patterns ==="

# Look for input declarations
set input_matches [regexp -all -inline {input\s+([^;]+);} $content]
puts "Input matches: $input_matches"

# Look for output declarations
set output_matches [regexp -all -inline {output\s+([^;]+);} $content]
puts "Output matches: $output_matches"

# Parse the matches
if {[llength $input_matches] >= 2} {
    set input_decl [lindex $input_matches 1]
    puts "Input declaration: '$input_decl'"

    # Split by commas and clean up
    set input_list [split $input_decl ","]
    puts "Input signals:"
    foreach sig $input_list {
        set sig [string trim $sig]
        puts "  - '$sig'"
    }
}

if {[llength $output_matches] >= 2} {
    set output_decl [lindex $output_matches 1]
    puts "Output declaration: '$output_decl'"

    # Split by commas and clean up
    set output_list [split $output_decl ","]
    puts "Output signals:"
    foreach sig $output_list {
        set sig [string trim $sig]
        puts "  - '$sig'"
    }
}
