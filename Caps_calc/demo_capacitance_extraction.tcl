#!/usr/bin/tclsh

# Simple demonstration of the enhanced path extraction with capacitance calculation
# This script shows the basic usage for end users and GUI integration

source "extract_path.tcl"

proc simple_demo {} {
    puts "Enhanced Path Extraction with Capacitance Calculation"
    puts "====================================================="
    puts ""

    # Example 1: Basic usage
    puts "Example 1: Basic Path with Capacitance"
    puts "--------------------------------------"

    if {[file exists "demo_parallel.syn.v"]} {
        set result [get_path_with_capacitance "demo_parallel.syn.v" "A" "K"]

        if {[dict get $result "path_found"]} {
            puts "✓ Path found!"
            puts "  From: [dict get $result "start_signal"]"
            puts "  To: [dict get $result "end_signal"]"
            puts "  Total Capacitance: [dict get $result "total_capacitance"] pF"
            puts "  Method: [dict get $result "calculation_method"]"
            puts "  Gates in path: [llength [dict get $result "gate_details"]]"
        } else {
            puts "✗ No path found"
        }
    } else {
        puts "Demo file not available"
    }

    puts ""

    # Example 2: Detailed analysis
    puts "Example 2: Detailed Analysis Display"
    puts "-----------------------------------"

    if {[file exists "demo_parallel.syn.v"]} {
        set result [get_path_with_capacitance "demo_parallel.syn.v" "A" "K"]
        display_path_analysis $result
    }

    puts ""

    # Example 3: GUI-ready data
    puts "Example 3: GUI-Ready Data Format"
    puts "--------------------------------"

    if {[file exists "demo_parallel.syn.v"]} {
        set gui_data [get_gui_path_data "demo_parallel.syn.v" "A" "K"]

        if {[dict get $gui_data "success"]} {
            set data [dict get $gui_data "data"]
            puts "GUI Integration Data:"
            puts "  Success: ✓"
            puts "  Total Capacitance: [dict get $data "total_capacitance"]"
            puts "  Individual Caps: [dict get $data "individual_capacitances"]"
            puts "  Gate Count: [llength [dict get $data "gate_details"]]"
            puts "  Path: [dict get $data "path"]"
        }
    }
}

# Interactive mode function for testing different paths
proc interactive_demo {} {
    puts ""
    puts "Interactive Demo Mode"
    puts "===================="
    puts ""

    # List available netlists
    set netlists [glob -nocomplain "*.v"]
    if {[llength $netlists] == 0} {
        puts "No Verilog netlist files found in current directory"
        return
    }

    puts "Available netlists:"
    set i 0
    foreach netlist $netlists {
        incr i
        puts "  $i. $netlist"
    }
    puts ""

    puts "Example usage commands:"
    puts "# For path with capacitance:"
    puts "set result \[get_path_with_capacitance \"[lindex $netlists 0]\" \"signal1\" \"signal2\"\]"
    puts "display_path_analysis \$result"
    puts ""
    puts "# For GUI integration:"
    puts "set gui_data \[get_gui_path_data \"[lindex $netlists 0]\" \"signal1\" \"signal2\"\]"
    puts ""
    puts "# Basic path only (original function):"
    puts "set path \[get_path \"[lindex $netlists 0]\" \"signal1\" \"signal2\"\]"
}

# Function to validate installation
proc validate_installation {} {
    puts "Installation Validation"
    puts "======================"
    puts ""

    set required_files [list "extract_path.tcl" "extract_cap_new.tcl" "calcu_cap.tcl"]
    set missing_files [list]

    foreach file $required_files {
        if {[file exists $file]} {
            puts "✓ $file found"
        } else {
            puts "✗ $file MISSING"
            lappend missing_files $file
        }
    }

    if {[llength $missing_files] == 0} {
        puts ""
        puts "✓ All required files present"
        puts "✓ Installation is complete"
        return 1
    } else {
        puts ""
        puts "✗ Missing files: [join $missing_files ", "]"
        puts "✗ Installation incomplete"
        return 0
    }
}

# Main execution
if {[info exists argv0] && [file tail [info script]] eq [file tail $argv0]} {
    if {[validate_installation]} {
        simple_demo
        interactive_demo
    }
}

# Export the key functions for GUI use
proc export_gui_functions {} {
    return [dict create \
        "get_path_with_capacitance" "get_path_with_capacitance netlist start end" \
        "get_gui_path_data" "get_gui_path_data netlist start end" \
        "display_path_analysis" "display_path_analysis result_dict" \
    ]
}
