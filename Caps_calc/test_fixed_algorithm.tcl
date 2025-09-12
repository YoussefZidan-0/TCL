#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Testing Fixed Algorithm ==="

puts "\n1. Backward compatibility test:"
set result1 [get_path "dummy_parallel.syn.v" "A" "K"]
puts "A→K: $result1"

puts "\n2. UART flattened test:"
set result2 [get_path "UART_TX_flattened.v" "par_bit" "TX_OUT"]
puts "par_bit→TX_OUT: $result2"

puts "\n3. UART hierarchical test:"
set result3 [get_path "UART_TX_hierarchy.v" "DATA_VALID" "TX_OUT"]
puts "DATA_VALID→TX_OUT: $result3"

puts "\n=== Test Complete ==="
