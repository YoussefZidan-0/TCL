#!/usr/bin/tclsh

# Comprehensive test and demonstration script for capacitance calculation
source "extract_path.tcl"

proc run_comprehensive_tests {} {
    puts "=========================================================="
    puts "COMPREHENSIVE CAPACITANCE CALCULATION DEMONSTRATION"
    puts "=========================================================="
    puts ""

    # Test cases with expected results
    set test_cases [list \
        [dict create \
        "file" "demo_parallel.syn.v" \
        "start" "A" \
        "end" "K" \
        "description" "Parallel circuit with mixed series/parallel structure" \
        "expected_structure" "Two gates in parallel, then series with two more gates"] \
        [dict create \
        "file" "demo_parallel.syn.v" \
        "start" "B" \
        "end" "K" \
        "description" "Series-only path through the parallel circuit" \
        "expected_structure" "All gates in series"] \
    ]

set test_num 0
foreach test_case $test_cases {
    incr test_num
    set file [dict get $test_case "file"]
    set start [dict get $test_case "start"]
    set end [dict get $test_case "end"]
    set description [dict get $test_case "description"]

    puts "TEST $test_num: $description"
    puts "File: $file, Path: $start -> $end"
    puts [string repeat "-" 60]

    if {![file exists $file]} {
        puts "ERROR: File $file not found"
        puts ""
        continue
    }

    if {[catch {
        set result [get_path_with_capacitance $file $start $end]

        if {[dict get $result "path_found"]} {
            puts "✓ PATH FOUND"
            puts "  Structure: [dict get $result "path"]"
            puts "  Total Capacitance: [dict get $result "total_capacitance"] pF"
            puts "  Method: [dict get $result "calculation_method"]"
            puts "  Gates: [llength [dict get $result "gate_details"]]"

            if {[dict exists $result "calculation_steps"]} {
                puts ""
                puts "  Calculation Steps:"
                foreach step [dict get $result "calculation_steps"] {
                    puts "    $step"
                }
            }

            puts ""
            puts "✓ TEST PASSED"
        } else {
            puts "✗ No path found"
        }
    } error_msg]} {
        puts "✗ ERROR: $error_msg"
    }

    puts ""
    puts [string repeat "=" 60]
    puts ""
}
}

proc demonstrate_gui_features {} {
    puts "=========================================================="
    puts "GUI INTEGRATION DEMONSTRATION"
    puts "=========================================================="
    puts ""

    if {![file exists "demo_parallel.syn.v"]} {
        puts "Demo file not available for GUI demonstration"
        return
    }

    puts "1. GUI-Ready Data Structure:"
    puts [string repeat "-" 30]

    set gui_data [get_gui_path_data "demo_parallel.syn.v" "A" "K"]

    if {[dict get $gui_data "success"]} {
        set data [dict get $gui_data "data"]

        puts "✓ Success: true"
        puts "✓ Available data keys:"
        foreach key [lsort [dict keys $data]] {
            puts "    - $key"
        }

        puts ""
        puts "✓ Key values for GUI display:"
        puts "    Total Capacitance: [dict get $data "total_capacitance"] pF"
        puts "    Individual Caps: [dict get $data "individual_capacitances"]"
        puts "    Calculation Method: [dict get $data "calculation_method"]"
        puts "    Number of Gates: [llength [dict get $data "gate_details"]]"

        puts ""
        puts "✓ Gate Details (for GUI table):"
        set gate_num 0
        foreach gate [dict get $data "gate_details"] {
            incr gate_num
            puts "    Gate $gate_num: [dict get $gate gate_type] ([dict get $gate instance]) = [dict get $gate capacitance] pF"
        }

        if {[dict exists $data "calculation_steps"]} {
            puts ""
            puts "✓ Calculation Steps (for GUI trace):"
            set step_num 0
            foreach step [dict get $data "calculation_steps"] {
                incr step_num
                puts "    $step_num. $step"
            }
        }
    } else {
        puts "✗ GUI data fetch failed"
    }

    puts ""
    puts "2. Export Functions for GUI:"
    puts [string repeat "-" 30]

    set functions [export_gui_functions]
    dict for {func_name func_desc} $functions {
        puts "✓ $func_name: $func_desc"
    }
}

proc validate_calculations_manually {} {
    puts ""
    puts "=========================================================="
    puts "MANUAL CALCULATION VALIDATION"
    puts "=========================================================="
    puts ""

    puts "Testing Calculate_capacitance function directly:"

    # Test 1: Parallel capacitances
    set caps1 [list 60.577400 60.577400]
    set result1 [Calculate_capacitance $caps1 1]
    set expected1 [expr {60.577400 + 60.577400}]
    puts "Parallel Test: $caps1"
    puts "  Result: $result1 pF"
    puts "  Expected: $expected1 pF"
    puts "  Status: [expr {abs($result1 - $expected1) < 0.001 ? "✓ PASS" : "✗ FAIL"}]"
    puts ""

    # Test 2: Series capacitances
    set caps2 [list 121.1548 60.577400 60.730000]
    set result2 [Calculate_capacitance $caps2 0]
    set expected2 [expr {1.0 / (1.0/121.1548 + 1.0/60.577400 + 1.0/60.730000)}]
    puts "Series Test: $caps2"
    puts "  Result: $result2 pF"
    puts "  Expected: $expected2 pF"
    puts "  Status: [expr {abs($result2 - $expected2) < 0.001 ? "✓ PASS" : "✗ FAIL"}]"
    puts ""

    # Test 3: Full calculation validation
    puts "Full Calculation Validation:"
    puts "  Step 1: Parallel of 60.577400 + 60.577400 = $result1 pF"
    puts "  Step 2: Series of $result1, 60.577400, 60.730000 = $result2 pF"
    puts "  Expected final result: ~24.26 pF"
    puts "  Status: [expr {$result2 >= 24.0 && $result2 <= 25.0 ? "✓ PASS" : "✗ FAIL"}]"
}

# Main execution
if {[info exists argv0] && [file tail [info script]] eq [file tail $argv0]} {
    run_comprehensive_tests
    demonstrate_gui_features
    validate_calculations_manually

    puts ""
    puts "=========================================================="
    puts "USAGE SUMMARY FOR GUI DEVELOPMENT"
    puts "=========================================================="
    puts ""
    puts "Main functions for GUI integration:"
    puts "  1. get_path_with_capacitance netlist start end"
    puts "     - Returns complete analysis with capacitance calculation"
    puts ""
    puts "  2. get_gui_path_data netlist start end"
    puts "     - Returns GUI-friendly data structure"
    puts ""
    puts "  3. display_path_analysis result"
    puts "     - Formatted display of analysis results"
    puts ""
    puts "Key result fields:"
    puts "  - total_capacitance: Final calculated capacitance"
    puts "  - individual_capacitances: List of gate capacitances"
    puts "  - gate_details: Detailed gate information"
    puts "  - calculation_steps: Step-by-step calculation trace"
    puts "  - calculation_method: Series/Parallel/Mixed description"
    puts "  - path: Original path structure"
    puts ""
}
