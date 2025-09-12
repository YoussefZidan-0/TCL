#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Compare Signal Structures ==="

# Test dummy_parallel (working)
puts "1. Testing dummy_parallel.syn.v (working):"
set instances1 [extract_path "dummy_parallel.syn.v"]
set graph_info1 [build_signal_graph $instances1]
set signal_to_drivers1 [lindex $graph_info1 0]
set signal_to_loads1 [lindex $graph_info1 1]

if {[dict exists $signal_to_drivers1 "A"]} {
    puts "  A drivers: [dict get $signal_to_drivers1 A]"
}
if {[dict exists $signal_to_loads1 "A"]} {
    puts "  A loads: [dict get $signal_to_loads1 A]"
}

set working_result [get_path "dummy_parallel.syn.v" "A" "K"]
puts "  A->K result: $working_result"

puts "\n2. Testing UART_TX_flattened.v:"
set instances2 [extract_path "UART_TX_flattened.v"]
set graph_info2 [build_signal_graph $instances2]
set signal_to_drivers2 [lindex $graph_info2 0]
set signal_to_loads2 [lindex $graph_info2 1]

if {[dict exists $signal_to_drivers2 "par_bit"]} {
    puts "  par_bit drivers: [dict get $signal_to_drivers2 par_bit]"
}
if {[dict exists $signal_to_loads2 "par_bit"]} {
    puts "  par_bit loads: [dict get $signal_to_loads2 par_bit]"
}

# Test find_path directly on UART
puts "\nDirect find_path test:"
if {[catch {
    set uart_path [find_path "par_bit" "TX_OUT" $signal_to_drivers2 $signal_to_loads2]
    puts "  par_bit->TX_OUT result: $uart_path"
} error]} {
    puts "  Error: $error"
}
