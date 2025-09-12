#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Testing UART_TX_flattened.v Path Extraction ==="

# Test 1: Try a simple path from input to internal signal
puts "\n1. Testing P_DATA\[0\] to ser_data:"
if {[catch {
    set result1 [get_path "UART_TX_flattened.v" "P_DATA\[0\]" "ser_data"]
    puts "Result: $result1"
} error]} {
    puts "Error: $error"
}

# Test 2: Try DATA_VALID to an internal control signal
puts "\n2. Testing DATA_VALID to ser_en:"
if {[catch {
    set result2 [get_path "UART_TX_flattened.v" "DATA_VALID" "ser_en"]
    puts "Result: $result2"
} error]} {
    puts "Error: $error"
}

# Test 3: Try from input to output
puts "\n3. Testing DATA_VALID to TX_OUT:"
if {[catch {
    set result3 [get_path "UART_TX_flattened.v" "DATA_VALID" "TX_OUT"]
    puts "Result: $result3"
} error]} {
    puts "Error: $error"
}

# Test 4: Try a shorter path with par_bit
puts "\n4. Testing PAR_TYP to par_bit:"
if {[catch {
    set result4 [get_path "UART_TX_flattened.v" "PAR_TYP" "par_bit"]
    puts "Result: $result4"
} error]} {
    puts "Error: $error"
}

puts "\n=== UART Test Complete ==="
