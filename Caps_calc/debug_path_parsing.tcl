#!/usr/bin/tclsh

source "extract_path.tcl"

# Debug the path structure
puts "Debugging path extraction..."

if {[file exists "demo_parallel.syn.v"]} {
    set path [get_path "demo_parallel.syn.v" "A" "K"]
    puts "Raw path: $path"
    puts "Path length: [llength $path]"

    # Let's also debug the capacitance extraction
    set result [get_path_with_capacitance "demo_parallel.syn.v" "A" "K"]
    puts "Result keys: [dict keys $result]"
    puts "Gate details: [dict get $result "gate_details"]"

    # Test the gate parsing logic manually
    puts ""
    puts "Testing gate parsing logic:"
    set test_gates [list "AND2_X1 (i_0)" "OR2_X1 (i_1)" "INV_X1 (i_3)"]
    foreach gate $test_gates {
        if {[regexp {(\w+)\s*\(([^)]+)\)} $gate -> gate_type instance_name]} {
            puts "  Gate: $gate -> Type: $gate_type, Instance: $instance_name"
        } else {
            puts "  Gate: $gate -> NO MATCH"
        }
    }
}
