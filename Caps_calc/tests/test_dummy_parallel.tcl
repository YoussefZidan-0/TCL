#!/usr/bin/env tclsh

# Source the main extraction script
source "extract_path.tcl"

# Helper function to check if result matches expected
proc verify_result {test_name expected actual} {
    puts "  Result: $actual"
    if {$expected eq $actual} {
        puts "✅ PASS: $test_name"
        return 1
    } else {
        puts "❌ FAIL: $test_name"
        puts "  Expected: $expected"
        puts "  Got:      $actual"
        return 0
    }
}

puts "========================================"
puts "COMPREHENSIVE PATH EXTRACTION TEST SUITE"
puts "========================================"

set pass_count 0
set fail_count 0

# =============================================================================
# TEST SUITE 1: dummy_parallel.syn.v (Basic Parallel Circuit)
# =============================================================================
puts "\n=== TEST SUITE 1: dummy_parallel.syn.v ==="
puts "Circuit: A branches to AND2_X1(i_0) & OR2_X1(i_1), converges at AND2_X1(i_2), then INV_X1(i_3)"

# Test 1.1: Parallel path A→K
puts "\nTest 1.1: Parallel Path A→K"
set result [get_path "dummy_parallel.syn.v" "A" "K"]
set expected "S {P {AND2_X1 (i_0)} {OR2_X1 (i_1)}} {AND2_X1 (i_2)} {INV_X1 (i_3)}"
if {[verify_result "A→K parallel path" $expected $result]} {incr pass_count} else {incr fail_count}

# Test 1.2: Series path B→K (through AND gate only)
puts "\nTest 1.2: Series Path B→K"
set result [get_path "dummy_parallel.syn.v" "B" "K"]
set expected "S {AND2_X1 (i_0)} {AND2_X1 (i_2)} {INV_X1 (i_3)}"
if {[verify_result "B→K series path" $expected $result]} {incr pass_count} else {incr fail_count}

# Test 1.3: Series path C→K (through OR gate only)
puts "\nTest 1.3: Series Path C→K"
set result [get_path "dummy_parallel.syn.v" "C" "K"]
set expected "S {OR2_X1 (i_1)} {AND2_X1 (i_2)} {INV_X1 (i_3)}"
if {[verify_result "C→K series path" $expected $result]} {incr pass_count} else {incr fail_count}

# Test 1.4: Intermediate signals
puts "\nTest 1.4: Intermediate Signal n_0→K"
set result [get_path "dummy_parallel.syn.v" "n_0" "K"]
set expected "S {AND2_X1 (i_2)} {INV_X1 (i_3)}"
if {[verify_result "n_0→K path" $expected $result]} {incr pass_count} else {incr fail_count}

puts "\nTest 1.5: Intermediate Signal n_1→K"
set result [get_path "dummy_parallel.syn.v" "n_1" "K"]
set expected "S {AND2_X1 (i_2)} {INV_X1 (i_3)}"
if {[verify_result "n_1→K path" $expected $result]} {incr pass_count} else {incr fail_count}

puts "\nTest 1.6: Convergence Point n_2→K"
set result [get_path "dummy_parallel.syn.v" "n_2" "K"]
set expected "S {INV_X1 (i_3)}"
if {[verify_result "n_2→K path" $expected $result]} {incr pass_count} else {incr fail_count}

# =============================================================================
# TEST SUITE 2: demo_parallel.syn.v (Same circuit, different file)
# =============================================================================
puts "\n=== TEST SUITE 2: demo_parallel.syn.v ==="
puts "Testing same circuit topology in different file format"

# Test 2.1: Parallel path A→K
puts "\nTest 2.1: Parallel Path A→K in demo_parallel.syn.v"
set result [get_path "demo_parallel.syn.v" "A" "K"]
set expected "S {P {AND2_X1 (i_0)} {OR2_X1 (i_1)}} {AND2_X1 (i_2)} {INV_X1 (i_3)}"
if {[verify_result "demo_parallel A→K" $expected $result]} {incr pass_count} else {incr fail_count}

# Test 2.2: Cross-file consistency check
puts "\nTest 2.2: Cross-file Consistency B→K"
set result [get_path "demo_parallel.syn.v" "B" "K"]
set expected "S {AND2_X1 (i_0)} {AND2_X1 (i_2)} {INV_X1 (i_3)}"
if {[verify_result "demo_parallel B→K" $expected $result]} {incr pass_count} else {incr fail_count}

# =============================================================================
# TEST SUITE 3: demo_adderPlus.syn.v (Complex Adder Circuit)
# =============================================================================
puts "\n=== TEST SUITE 3: demo_adderPlus.syn.v ==="
puts "Testing complex adder circuit with multiple path types"

# Test 3.1: Simple series path (half adder output)
puts "\nTest 3.1: Half Adder Direct Output inputB\[0\]→p_0\[0\]"
set result [get_path "demo_adderPlus.syn.v" "inputB\[0\]" "p_0\[0\]"]
set expected "S {HA_X1 (i_0)}"
if {[verify_result "HA direct output" $expected $result]} {incr pass_count} else {incr fail_count}

# Test 3.2: Series chain through carry path
puts "\nTest 3.2: Carry Chain inputB\[0\]→p_0\[1\]"
set result [get_path "demo_adderPlus.syn.v" "inputB\[0\]" "p_0\[1\]"]
set expected "S {HA_X1 (i_0)} {XOR2_X1 (i_8)}"
if {[verify_result "Carry chain path" $expected $result]} {incr pass_count} else {incr fail_count}

# Test 3.3: Alternative input same output
puts "\nTest 3.3: Alternative Input inputA\[0\]→p_0\[1\]"
set result [get_path "demo_adderPlus.syn.v" "inputA\[0\]" "p_0\[1\]"]
set expected "S {HA_X1 (i_0)} {XOR2_X1 (i_8)}"
if {[verify_result "Alternative input path" $expected $result]} {incr pass_count} else {incr fail_count}

# Test 3.4: Higher bit adder path
puts "\nTest 3.4: Higher Bit inputB\[1\]→p_0\[2\]"
set result [get_path "demo_adderPlus.syn.v" "inputB\[1\]" "p_0\[2\]"]
# This should go through i_1 → n_1 → i_28 → n_27 → i_9 → p_0[2]
if {[llength $result] > 0} {
    puts "✅ PASS: Higher bit path found"
    incr pass_count
    puts "  Result: $result"
} else {
    puts "❌ FAIL: Higher bit path not found"
    incr fail_count
}

# Test 3.5: Complex carry propagation
puts "\nTest 3.5: Carry Output inputB\[7\]→p_0\[8\]"
set result [get_path "demo_adderPlus.syn.v" "inputB\[7\]" "p_0\[8\]"]
if {[llength $result] > 0} {
    puts "✅ PASS: Carry propagation path found"
    incr pass_count
    puts "  Result: $result"
} else {
    puts "❌ FAIL: Carry propagation path not found"
    incr fail_count
}

# Test 3.6: Intermediate signal traversal
puts "\nTest 3.6: Intermediate Signal n_0→p_0\[1\]"
set result [get_path "demo_adderPlus.syn.v" "n_0" "p_0\[1\]"]
set expected "S {XOR2_X1 (i_8)}"
if {[verify_result "Intermediate n_0 path" $expected $result]} {incr pass_count} else {incr fail_count}

# =============================================================================
# TEST SUITE 4: Edge Cases and Error Handling
# =============================================================================
puts "\n=== TEST SUITE 4: Edge Cases ==="

# Test 4.1: Non-existent signals
puts "\nTest 4.1: Non-existent Signal"
set result [get_path "dummy_parallel.syn.v" "INVALID_SIGNAL" "K"]
if {[llength $result] == 0} {
    puts "✅ PASS: Non-existent signal correctly returns empty"
    incr pass_count
} else {
    puts "❌ FAIL: Non-existent signal should return empty"
    incr fail_count
}

# Test 4.2: Same signal (self-loop)
puts "\nTest 4.2: Self Path A→A"
set result [get_path "dummy_parallel.syn.v" "A" "A"]
set expected "S"
if {[verify_result "Self path" $expected $result]} {incr pass_count} else {incr fail_count}

# Test 4.3: Unreachable target
puts "\nTest 4.3: Unreachable Target K→A (reverse)"
set result [get_path "dummy_parallel.syn.v" "K" "A"]
if {[llength $result] == 0} {
    puts "✅ PASS: Unreachable target correctly returns empty"
    incr pass_count
} else {
    puts "❌ FAIL: Unreachable target should return empty"
    incr fail_count
}

# =============================================================================
# TEST SUITE 5: Advanced Path Analysis
# =============================================================================
puts "\n=== TEST SUITE 5: Advanced Analysis ==="

# Test 5.1: Complex adder carry chain analysis
puts "\nTest 5.1: Complex Carry Chain Analysis inputA\[1\]→p_0\[2\]"
set result [get_path "demo_adderPlus.syn.v" "inputA\[1\]" "p_0\[2\]"]
if {[llength $result] > 0} {
    puts "✅ PASS: Complex carry chain found"
    incr pass_count
    puts "  Path length: [expr [llength $result] - 1] gates"
    puts "  Result: $result"
} else {
    puts "❌ FAIL: Complex carry chain not found"
    incr fail_count
}

# Test 5.2: Multiple hop intermediate path
puts "\nTest 5.2: Multi-hop Intermediate n_2→p_0\[2\]"
set result [get_path "demo_adderPlus.syn.v" "n_2" "p_0\[2\]"]
if {[llength $result] > 0} {
    puts "✅ PASS: Multi-hop path found"
    incr pass_count
    puts "  Result: $result"
} else {
    puts "❌ FAIL: Multi-hop path not found"
    incr fail_count
}

# Test 5.3: Performance test with longer paths
puts "\nTest 5.3: Performance Test - Longest Path inputA\[0\]→p_0\[8\]"
set start_time [clock milliseconds]
set result [get_path "demo_adderPlus.syn.v" "inputA\[0\]" "p_0\[8\]"]
set end_time [clock milliseconds]
set execution_time [expr $end_time - $start_time]
if {[llength $result] > 0} {
    puts "✅ PASS: Long path found (${execution_time}ms)"
    incr pass_count
    puts "  Path has [expr [llength $result] - 1] gates"
} else {
    puts "❌ FAIL: Long path not found"
    incr fail_count
}

# =============================================================================
# TEST RESULTS SUMMARY
# =============================================================================
puts "\n========================================"
puts "TEST RESULTS SUMMARY"
puts "========================================"
puts "Total Tests: [expr $pass_count + $fail_count]"
puts "Passed: $pass_count"
puts "Failed: $fail_count"
if {$fail_count == 0} {
    puts "🎉 ALL TESTS PASSED! 🎉"
} else {
    puts "⚠️  Some tests failed. Please review the results above."
}
puts "========================================"
