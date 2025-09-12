#!/usr/bin/env tclsh
source "extract_cap.tcl"

puts "=== Debug Cell Pattern Matching ==="

# Build cell dictionary
set cells_caps_dict [extract_cap "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"]
if {[file exists "NangateOpenCellLibrary_typical.lib"]} {
    set nangate_caps_dict [extract_cap "NangateOpenCellLibrary_typical.lib"]
    dict for {cell_name max_cap} $nangate_caps_dict {
        dict set cells_caps_dict $cell_name $max_cap
    }
}

puts "Total cells in library: [dict size $cells_caps_dict]"

# Check if UART cell types are in our library
set uart_cells {NOR2X12M AO2B2X1M CLKXOR2X2M XOR3XLM XNOR2X1M}
puts "\nChecking if UART cell types are in library:"
foreach cell $uart_cells {
    set exists [dict exists $cells_caps_dict $cell]
    puts "  $cell: $exists"
}

# Try to match a specific line from UART
set test_line "  NOR2X12M serializer_unit_U19 ( .A(serializer_unit_n3), .B(n3), .Y("
puts "\nTesting line: $test_line"

set cell_types [dict keys $cells_caps_dict]
set cell_types_pattern [join $cell_types "|"]
puts "Pattern will be: ^\\s*(${cell_types_pattern})\\s+(\\w+)\\s+\\("

if {[regexp "^\\s*(${cell_types_pattern})\\s+(\\w+)\\s+\\(" $test_line -> cell_type instance_name]} {
    puts "MATCH: cell_type=$cell_type, instance_name=$instance_name"
} else {
    puts "NO MATCH"
}
