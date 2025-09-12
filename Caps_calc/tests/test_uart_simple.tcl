#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Testing UART with Actual Signal Names ==="

# Test with actual parsed signals
puts "
1. Testing serializer_unit_n6 to TX_OUT:"
set result1 [get_path "UART_TX_flattened.v" "serializer_unit_n6" "TX_OUT"]
puts "Result: $result1"

puts "
2. Testing parity_calc_unit_n16 to par_bit:"
set result2 [get_path "UART_TX_flattened.v" "parity_calc_unit_n16" "par_bit"]
puts "Result: $result2"

puts "
3. Testing par_bit to MUX_unit_mux_comb:"
set result3 [get_path "UART_TX_flattened.v" "par_bit" "MUX_unit_mux_comb"]
puts "Result: $result3"

# List some available signals for reference
puts "\n4. Available driver signals (first 10):"
set instances [extract_path "UART_TX_flattened.v"]
set graph_info [build_signal_graph $instances]
set signal_to_drivers [lindex $graph_info 0]

set count 0
dict for {signal drivers} $signal_to_drivers {
    if {$count < 10} {
        puts "  $signal"
        incr count
    }
}
