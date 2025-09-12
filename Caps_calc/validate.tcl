#!/usr/bin/env tclsh

# Validation Script for Capacitance Calculator
# Tests core functionality to ensure portability

puts "🧪 Digital Circuit Capacitance Calculator - Validation Tests"
puts "=========================================================="
puts ""

set test_count 0
set pass_count 0
set fail_count 0

# Test result tracking
proc test_result {name result details} {
    global test_count pass_count fail_count
    incr test_count

    if {$result} {
        puts "✅ PASS: $name"
        incr pass_count
    } else {
        puts "❌ FAIL: $name"
        puts "   Details: $details"
        incr fail_count
    }
}

# Test 1: TCL Version
puts "Test 1: TCL Version Compatibility"
set tcl_version_ok [expr {$tcl_version >= 8.5}]
test_result "TCL Version >= 8.5" $tcl_version_ok "Found: $tcl_version"

# Test 2: Required Packages
puts "\nTest 2: Required Packages"
set tk_available [expr {![catch {package require Tk}]}]
test_result "Tk Package Available" $tk_available "GUI support needed"

# Test 3: Core Files Exist
puts "\nTest 3: Core Files Existence"
set required_files {capacitance_gui.tcl extract_path.tcl extract_cap_new.tcl}
foreach file $required_files {
    set file_exists [file exists $file]
    test_result "File: $file" $file_exists "Required core file"
}

# Test 4: Core Functions Load
puts "\nTest 4: Core Functions Loading"
set extract_path_loads [expr {![catch {source extract_path.tcl}]}]
test_result "Load extract_path.tcl" $extract_path_loads "Core algorithms"

if {$extract_path_loads} {
    # Test 5: Function Availability
    puts "\nTest 5: Function Availability"
    set functions {extract_verilog_signals build_signal_graph find_path_hierarchical get_path_with_capacitance}

    foreach func $functions {
        set func_exists [expr {[info procs $func] ne ""}]
        test_result "Function: $func" $func_exists "Core functionality"
    }

    # Test 6: Basic Functionality (if demo file exists)
    puts "\nTest 6: Basic Functionality"
    if {[file exists "demo_adderPlus.syn.v"]} {
        set basic_test_ok [catch {
            set result [extract_verilog_signals "demo_adderPlus.syn.v"]
            set inputs [lindex $result 0]
            set outputs [lindex $result 1]
            expr {[llength $inputs] > 0 && [llength $outputs] > 0}
        } basic_error]

        set basic_test_pass [expr {!$basic_test_ok}]
        test_result "Signal Extraction" $basic_test_pass "Basic parsing functionality"

        if {$basic_test_pass} {
            # Test path finding if signals available
            if {[llength $inputs] > 0 && [llength $outputs] > 0} {
                set start_sig [lindex $inputs 0]
                set end_sig [lindex $outputs 0]

                set path_test_ok [catch {
                    get_path_with_capacitance "demo_adderPlus.syn.v" $start_sig $end_sig
                } path_error]

                set path_test_pass [expr {!$path_test_ok}]
                test_result "Path Calculation" $path_test_pass "End-to-end functionality"
            }
        }
    } else {
        test_result "Demo File Available" 0 "demo_adderPlus.syn.v not found for testing"
    }
}

# Test 7: GUI Loading (if display available)
puts "\nTest 7: GUI Components"
if {$tk_available && [info exists env(DISPLAY)]} {
    set gui_test_ok [catch {
        # Create minimal GUI test
        toplevel .test_gui
        wm withdraw .test_gui
        ttk::notebook .test_gui.nb
        destroy .test_gui
    } gui_error]

    set gui_test_pass [expr {!$gui_test_ok}]
    test_result "GUI Components" $gui_test_pass "Tk widgets functional"
} else {
    test_result "GUI Components" 0 "No display or Tk not available (OK for headless)"
}

# Test 8: File Permissions
puts "\nTest 8: File Permissions"
set scripts {run_gui.sh install.sh}
foreach script $scripts {
    if {[file exists $script]} {
        set executable [file executable $script]
        test_result "Executable: $script" $executable "Script permissions"
    }
}

# Summary
puts "\n"
puts "📊 Test Summary"
puts "==============="
puts "Total Tests: $test_count"
puts "Passed: $pass_count"
puts "Failed: $fail_count"
puts "Success Rate: [expr {$test_count > 0 ? ($pass_count * 100 / $test_count) : 0}]%"

if {$fail_count == 0} {
    puts ""
    puts "🎉 All tests passed! The system is ready for distribution."
    exit 0
} elseif {$fail_count <= 2} {
    puts ""
    puts "⚠️  Minor issues detected. Review failed tests above."
    puts "The system may still be functional for most use cases."
    exit 1
} else {
    puts ""
    puts "❌ Multiple critical issues detected. Please resolve before distribution."
    exit 2
}
