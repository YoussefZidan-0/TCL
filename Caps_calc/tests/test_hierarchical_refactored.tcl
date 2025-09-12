# Comprehensive test suite for the refactored hierarchical path extraction

source "extract_path.tcl"

proc run_test {test_name netlist start_signal end_signal expected_path_found} {
    puts "Running test: $test_name"
    set result [get_path_with_capacitance $netlist $start_signal $end_signal]
    set path_found [dict get $result path_found]

    if {$path_found == $expected_path_found} {
        puts "  -> PASSED"
        if {$path_found} {
            puts "     Path: [dict get $result path]"
        }
    } else {
        puts "  -> FAILED"
        puts "     Expected path_found=$expected_path_found, but got $path_found"
        if {$path_found} {
            puts "     Path found: [dict get $result path]"
        } else {
            puts "     Error: [dict get $result error_message]"
        }
    }
    puts ""
}

# --- Simple Netlist Tests (Backward Compatibility) ---
puts "--- Running Simple Netlist Tests ---"
run_test "Simple Parallel" "demo_parallel.syn.v" "A" "K" 1
run_test "Simple Adder" "demo_adderPlus.syn.v" "inputA[0]" "p_0[0]" 1
run_test "Dummy Parallel" "dummy_parallel.syn.v" "A" "K" 1

# --- UART Flattened Netlist Tests ---
puts "\n--- Running UART Flattened Netlist Tests ---"
run_test "UART Flat 1" "UART_TX_flattened.v" "CLK" "TX_OUT" 1
run_test "UART Flat 2" "UART_TX_flattened.v" "P_DATA[0]" "Busy" 1
run_test "UART Flat 3 (No Path)" "UART_TX_flattened.v" "RST" "DATA_VALID" 0

# --- UART Hierarchical Netlist Tests ---
puts "\n--- Running UART Hierarchical Netlist Tests ---"
# Test path from a top-level input to a top-level output
run_test "UART Hierarchical Top to Top" "UART_TX_hierarchy.v" "CLK" "TX_OUT" 1
# Test path from a top-level input into a submodule
run_test "UART Hierarchical Top to Submodule" "UART_TX_hierarchy.v" "DATA_VALID" "ser_done" 1
# Test path within a single submodule
# Note: This requires the new engine to correctly identify the signal's scope.
# The start/end signals are local to the 'serializer' module.
# This test might fail if the scope resolution is not perfect.
run_test "UART Hierarchical Submodule Internal" "UART_TX_hierarchy.v" "SER_EN" "SER_DONE" 1
# Test path that traverses from one submodule, up to the parent, and into another submodule
run_test "UART Hierarchical Inter-Module" "UART_TX_hierarchy.v" "ser_done" "par_bit" 1
# Test a known non-existent path
run_test "UART Hierarchical No Path" "UART_TX_hierarchy.v" "RST" "P_DATA" 0

puts "--- Test Suite Finished ---"
