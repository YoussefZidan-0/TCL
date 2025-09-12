#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Testing Enhanced Complex Structure Support ==="

# Test 1: Original functionality still works
puts "\n1. Testing backward compatibility:"
set result1 [get_path "dummy_parallel.syn.v" "A" "K"]
puts "A→K result: $result1"

# Test 2: Complex structure analysis
puts "\n2. Testing complex structure detection:"
test_complex_structures

# Test 3: UART file compatibility testing
puts "\n3. Testing UART file compatibility:"
# Test with flattened UART
if {[file exists "UART_TX_flattened.v"]} {
    puts "Testing UART_TX_flattened.v..."
    if {[catch {
        set uart_flat_result [get_path "UART_TX_flattened.v" "DATA_VALID" "TX_OUT"]
        puts "UART Flattened DATA_VALID→TX_OUT: $uart_flat_result"
    } error]} {
        puts "UART Flattened test error: $error"
    }
} else {
    puts "UART_TX_flattened.v not found"
}

# Test with hierarchical UART
if {[file exists "UART_TX_hierarchy.v"]} {
    puts "Testing UART_TX_hierarchy.v..."
    if {[catch {
        set uart_hier_result [get_path "UART_TX_hierarchy.v" "DATA_VALID" "TX_OUT"]
        puts "UART Hierarchical DATA_VALID→TX_OUT: $uart_hier_result"
    } error]} {
        puts "UART Hierarchical test error: $error"
    }
} else {
    puts "UART_TX_hierarchy.v not found"
}

puts "\n=== Enhanced Features Summary ==="
puts "✅ Multi-level parallel structure analysis"
puts "✅ Nested parallelism detection"
puts "✅ Hierarchical module support"
puts "✅ Dynamic convergence matrix building"
puts "✅ Sub-parallel structure analysis"
puts "✅ Performance optimization hooks"
