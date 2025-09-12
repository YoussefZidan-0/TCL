#!/usr/bin/env tclsh

source "extract_path.tcl"

puts "=== Testing P_DATA\[0\] to TX_OUT Path ==="

# Test the full hierarchical path
puts "Testing path P_DATA\[0\] to TX_OUT..."
set path [extract_signal_path "UART_TX_hierarchy.v" "P_DATA\[0\]" "TX_OUT"]
puts "Path result:"
puts "$path"

puts "\n=== Testing Other UART Paths ==="

# Test a few other interesting paths
puts "\nTesting P_DATA\[1\] to TX_OUT..."
set path2 [extract_signal_path "UART_TX_hierarchy.v" "P_DATA\[1\]" "TX_OUT"]
puts "Path2 result:"
puts "$path2"

puts "\nTesting CLK to TX_OUT..."
set path3 [extract_signal_path "UART_TX_hierarchy.v" "CLK" "TX_OUT"]
puts "Path3 result:"
puts "$path3"
