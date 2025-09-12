#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Debugging UART_TX_flattened.v Parsing ==="

# Parse the netlist and check what signals exist
puts "Parsing UART_TX_flattened.v..."
set instances [extract_path "UART_TX_flattened.v"]

puts "Number of parsed instances: [llength $instances]"
puts "\nFirst 5 instances:"
for {set i 0} {$i < [expr min(5, [llength $instances])]} {incr i} {
    set inst [lindex $instances $i]
    puts "Instance $i keys: [dict keys $inst]"
    if {[dict exists $inst instance_name] && [dict exists $inst cell_type]} {
        puts "Instance $i: [dict get $inst instance_name] ([dict get $inst cell_type])"
    }
}

# Build signal graph and check signals
puts "\nBuilding signal graph..."
set graph_info [build_signal_graph $instances]
set signal_to_drivers [lindex $graph_info 0]
set signal_to_loads [lindex $graph_info 1]

puts "Number of signals with drivers: [dict size $signal_to_drivers]"
puts "Number of signals with loads: [dict size $signal_to_loads]"

# Show some example signals
puts "\nFirst 10 signals with drivers:"
set count 0
dict for {signal drivers} $signal_to_drivers {
    if {$count < 10} {
        puts "  $signal -> $drivers"
        incr count
    }
}

# Check if the test signals exist
set test_signals {P_DATA DATA_VALID TX_OUT PAR_TYP par_bit ser_data ser_en}
puts "\nChecking test signals:"
foreach signal $test_signals {
    set has_driver [dict exists $signal_to_drivers $signal]
    set has_load [dict exists $signal_to_loads $signal]
    puts "  $signal: driver=$has_driver, load=$has_load"
}
