#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Debug find_path Function ==="

# Parse and build graph
set instances [extract_path "UART_TX_flattened.v"]
set graph_info [build_signal_graph $instances]
set signal_to_drivers [lindex $graph_info 0]
set signal_to_loads [lindex $graph_info 1]

# Test find_path directly
puts "Testing find_path function directly..."
puts "From par_bit to TX_OUT:"

if {[catch {
    set path [find_path "par_bit" "TX_OUT" $signal_to_drivers $signal_to_loads]
    puts "Path result: $path"
    puts "Path length: [llength $path]"
} error]} {
    puts "Error in find_path: $error"
}

# Test with a simpler path - from a driver signal to its immediate load
puts "\nTesting simpler path: serializer_unit_n6 -> ?"
if {[dict exists $signal_to_loads "serializer_unit_n6"]} {
    set loads [dict get $signal_to_loads "serializer_unit_n6"]
    puts "serializer_unit_n6 loads: $loads"

    # Try to find path to first load
    if {[llength $loads] > 0} {
        set first_load [lindex $loads 0]
        set target_signal [lindex $first_load 0]  # Get the signal name from the load info
        puts "Trying path from serializer_unit_n6 to first connected signal..."

        if {[catch {
            set simple_path [find_path "serializer_unit_n6" $target_signal $signal_to_drivers $signal_to_loads]
            puts "Simple path result: $simple_path"
        } error]} {
            puts "Error in simple path: $error"
        }
    }
}
