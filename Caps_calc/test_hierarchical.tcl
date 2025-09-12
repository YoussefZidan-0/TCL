#!/usr/bin/env tclsh

source "extract_path.tcl"

puts "=== Testing Hierarchical UART Path Extraction ==="

# Test 1: Check signal connectivity
puts "\n1. Checking signal connectivity..."
set parse_result [extract_path "UART_TX_hierarchy.v"]
set graph_info [build_signal_graph $parse_result]
set signal_to_drivers [lindex $graph_info 0]
set signal_to_loads [lindex $graph_info 1]

puts "Available P_DATA signals in loads:"
foreach signal [dict keys $signal_to_loads] {
    if {[string match "*P_DATA*" $signal]} {
        puts "  $signal"
    }
}

puts "\nAvailable output signals in drivers:"
foreach signal [dict keys $signal_to_drivers] {
    if {[string match "*OUT*" $signal]} {
        puts "  $signal"
    }
}

# Test 2: Simple path extraction
puts "\n2. Testing simple path P_DATA\[0\] to MUX_OUT..."
set start_signal "P_DATA\[0\]"
set end_signal "MUX_OUT"

puts "Start signal: $start_signal"
puts "End signal: $end_signal"

# Check if signals exist
if {[dict exists $signal_to_loads $start_signal]} {
    puts "Start signal exists in loads"
} else {
    puts "Start signal NOT found in loads"
}

if {[dict exists $signal_to_drivers $end_signal]} {
    puts "End signal exists in drivers"
} else {
    puts "End signal NOT found in drivers"
}

# Try path extraction with timeout protection
puts "\n3. Attempting path extraction..."
set path [extract_signal_path "UART_TX_hierarchy.v" $start_signal $end_signal]
puts "Path result: $path"
