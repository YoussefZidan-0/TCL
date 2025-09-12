#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Debug Signal Graph Structure ==="

# Parse the UART file
set instances [extract_path "UART_TX_flattened.v"]
set graph_info [build_signal_graph $instances]
set signal_to_drivers [lindex $graph_info 0]
set signal_to_loads [lindex $graph_info 1]

# Check a specific signal that should have connections
set test_signal "par_bit"

puts "Checking signal: $test_signal"
if {[dict exists $signal_to_drivers $test_signal]} {
    set drivers [dict get $signal_to_drivers $test_signal]
    puts "  Drivers: $drivers"
} else {
    puts "  No drivers found for $test_signal"
}

if {[dict exists $signal_to_loads $test_signal]} {
    set loads [dict get $signal_to_loads $test_signal]
    puts "  Loads: $loads"
} else {
    puts "  No loads found for $test_signal"
}

# Check TX_OUT
set test_signal2 "TX_OUT"
puts "\nChecking signal: $test_signal2"
if {[dict exists $signal_to_drivers $test_signal2]} {
    set drivers [dict get $signal_to_drivers $test_signal2]
    puts "  Drivers: $drivers"
} else {
    puts "  No drivers found for $test_signal2"
}

# Show first few signal connections to understand the structure
puts "\nFirst 5 signal-to-driver mappings:"
set count 0
dict for {signal drivers} $signal_to_drivers {
    if {$count < 5} {
        puts "  $signal -> $drivers"
        incr count
    }
}

# Check if find_path function exists
puts "\nChecking if find_path function exists:"
if {[info procs find_path] ne ""} {
    puts "  find_path function EXISTS"
} else {
    puts "  find_path function NOT FOUND"
}
