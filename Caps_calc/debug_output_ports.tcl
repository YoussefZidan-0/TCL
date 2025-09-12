#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Debug Output Port Recognition ==="

# Test some UART gate types
set uart_gates {
    {"NOR2X2M" "Y"}
    {"OAI2BB2X1M" "Y"}
    {"DFFRHQX8M" "Q"}
    {"AO2B2X1M" "Y"}
    {"OAI2B2X1M" "Y"}
}

foreach gate_info $uart_gates {
    set gate_type [lindex $gate_info 0]
    set port [lindex $gate_info 1]
    set is_output [is_output_port $gate_type $port]
    puts "$gate_type.$port -> is_output: $is_output"
}

# Check what cell types we have in our library
puts "\nChecking if UART gate types exist in our library:"
set cells_caps_dict [extract_cap "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"]
if {[file exists "NangateOpenCellLibrary_typical.lib"]} {
    set nangate_caps_dict [extract_cap "NangateOpenCellLibrary_typical.lib"]
    dict for {cell_name max_cap} $nangate_caps_dict {
        dict set cells_caps_dict $cell_name $max_cap
    }
}

set test_cells {NOR2X2M OAI2BB2X1M DFFRHQX8M AO2B2X1M OAI2B2X1M}
foreach cell $test_cells {
    set exists [dict exists $cells_caps_dict $cell]
    puts "$cell in library: $exists"
}
