#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Debug Infinite Loop Issue ==="

# Test with timeout and debug output
puts "\n1. Testing simple dummy_parallel (should work quickly):"
set start_time [clock seconds]
set dummy_result [get_path "dummy_parallel.syn.v" "A" "K"]
set end_time [clock seconds]
puts "  Result: $dummy_result"
puts "  Time taken: [expr $end_time - $start_time] seconds"

puts "\n2. Parsing UART file to check if that hangs:"
set start_time [clock seconds]
set instances [extract_path "UART_TX_flattened.v"]
set end_time [clock seconds]
puts "  Parsed [llength $instances] instances in [expr $end_time - $start_time] seconds"

puts "\n3. Building signal graph:"
set start_time [clock seconds]
if {[llength $instances] > 0} {
    set graph_info [build_signal_graph $instances]
    set end_time [clock seconds]
    puts "  Built signal graph in [expr $end_time - $start_time] seconds"

    set signal_to_drivers [lindex $graph_info 0]
    set signal_to_loads [lindex $graph_info 1]
    puts "  Drivers: [dict size $signal_to_drivers], Loads: [dict size $signal_to_loads]"

    puts "\n4. Testing find_path directly (this might hang):"
    set start_time [clock seconds]

    # Test with a very simple path that should exist
    if {[dict exists $signal_to_drivers "par_bit"]} {
        puts "  par_bit exists as driver, testing path..."
        if {[catch {
            set path_result [find_path "par_bit" "TX_OUT" $signal_to_drivers $signal_to_loads]
            set end_time [clock seconds]
            puts "  Path result: $path_result"
            puts "  Find_path took: [expr $end_time - $start_time] seconds"
        } error]} {
            puts "  Error in find_path: $error"
        }
    } else {
        puts "  par_bit not found as driver"
    }
}
