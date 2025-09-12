#!/usr/bin/tclsh

# Test script for enhanced path extraction with capacitance calculation
# This script demonstrates the new capacitance calculation features

source "extract_path.tcl"

proc run_capacitance_tests {} {
    puts "================================================"
    puts "ENHANCED PATH EXTRACTION WITH CAPACITANCE TESTS"
    puts "================================================"
    puts ""

    # Test files to use
    set test_files [list "demo_parallel.syn.v" "dummy_parallel.syn.v" "demo_adderPlus.syn.v"]

    # Test cases: {netlist_file start_signal end_signal description}
    set test_cases [list \
        {"demo_parallel.syn.v" "A" "K" "Parallel circuit A to K"} \
        {"demo_parallel.syn.v" "B" "K" "Series path B to K"} \
        {"dummy_parallel.syn.v" "A" "Y" "Dummy parallel A to Y"} \
        {"demo_adderPlus.syn.v" "inputB\[0\]" "p_0\[0\]" "Adder inputB[0] to p_0[0]"} \
        {"demo_adderPlus.syn.v" "inputA\[0\]" "p_0\[1\]" "Adder inputA[0] to p_0[1]"} \
    ]

set test_num 0
set passed_tests 0
set failed_tests 0

foreach test_case $test_cases {
    incr test_num
    set netlist [lindex $test_case 0]
    set start [lindex $test_case 1]
    set end [lindex $test_case 2]
    set description [lindex $test_case 3]

    puts "TEST $test_num: $description"
    puts "File: $netlist, From: $start, To: $end"
    puts [string repeat "-" 50]

    # Check if netlist file exists
    if {![file exists $netlist]} {
        puts "ERROR: Netlist file '$netlist' not found"
        incr failed_tests
        puts ""
        continue
    }

    # Try the enhanced path extraction with error handling
    if {[catch {
        set result [get_path_with_capacitance $netlist $start $end]

        if {[dict get $result "path_found"]} {
            display_path_analysis $result
            incr passed_tests
            puts "RESULT: PASS"
        } else {
            puts "No path found: [dict get $result "error_message"]"
            incr failed_tests
            puts "RESULT: FAIL (No path)"
        }
    } error_msg]} {
        puts "ERROR during test execution: $error_msg"
        incr failed_tests
        puts "RESULT: FAIL (Error)"
    }

    puts ""
    puts [string repeat "=" 60]
    puts ""
}

# Summary
puts "TEST SUMMARY:"
puts "Total Tests: $test_num"
puts "Passed: $passed_tests"
puts "Failed: $failed_tests"
puts "Success Rate: [expr {$test_num > 0 ? ($passed_tests * 100.0) / $test_num : 0}]%"
}

proc demonstrate_gui_data_format {} {
    puts ""
    puts "================================================"
    puts "GUI-READY DATA FORMAT DEMONSTRATION"
    puts "================================================"
    puts ""

    if {[file exists "demo_parallel.syn.v"]} {
        puts "Getting GUI-ready data for demo_parallel.syn.v A->K:"

        if {[catch {
            set gui_data [get_gui_path_data "demo_parallel.syn.v" "A" "K"]

            puts "GUI Data Structure:"
            puts "Success: [dict get $gui_data "success"]"

            if {[dict get $gui_data "success"]} {
                set data [dict get $gui_data "data"]
                puts ""
                puts "Available data keys:"
                foreach key [dict keys $data] {
                    puts "  - $key"
                }
                puts ""
                puts "Key data for GUI:"
                puts "  Total Capacitance: [dict get $data "total_capacitance"]  "
                puts "  Calculation Method: [dict get $data "calculation_method"]"
                puts "  Number of Gates: [llength [dict get $data "gate_details"]]"
                puts "  Path Structure: [dict get $data "path"]"
            }
        } error_msg]} {
            puts "Error getting GUI data: $error_msg"
        }
    } else {
        puts "demo_parallel.syn.v not found - skipping GUI demo"
    }
}

proc test_capacitance_calculation_methods {} {
    puts ""
    puts "================================================"
    puts "CAPACITANCE CALCULATION METHOD TESTS"
    puts "================================================"
    puts ""

    # Test the Calculate_capacitance function directly
    puts "Testing Calculate_capacitance function:"

    # Test parallel calculation
    set parallel_caps [list 0.1 0.2 0.3]
    set parallel_result [Calculate_capacitance $parallel_caps 1]
    puts "Parallel caps $parallel_caps -> $parallel_result  "

    # Test series calculation
    set series_caps [list 0.1 0.2 0.3]
    set series_result [Calculate_capacitance $series_caps 0]
    puts "Series caps $series_caps -> $series_result  "

    # Verify calculations manually
    set expected_parallel [expr {0.1 + 0.2 + 0.3}]
    set expected_series [expr {1.0 / (1.0/0.1 + 1.0/0.2 + 1.0/0.3)}]

    puts ""
    puts "Verification:"
    puts "Expected parallel: $expected_parallel, Got: $parallel_result"
    puts "Expected series: $expected_series, Got: $series_result"

    set parallel_ok [expr {abs($parallel_result - $expected_parallel) < 0.001}]
    set series_ok [expr {abs($series_result - $expected_series) < 0.001}]

    puts "Parallel calculation: [expr {$parallel_ok ? "PASS" : "FAIL"}]"
    puts "Series calculation: [expr {$series_ok ? "PASS" : "FAIL"}]"
}

# Run all tests
if {[info exists argv0] && [file tail [info script]] eq [file tail $argv0]} {
    puts "Starting Enhanced Path Extraction Tests..."
    puts ""

    test_capacitance_calculation_methods
    run_capacitance_tests
    demonstrate_gui_data_format

    puts ""
    puts "Tests completed!"
}
