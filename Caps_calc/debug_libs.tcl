#!/usr/bin/env tclsh
source "extract_cap.tcl"

puts "=== Checking TSMC Library Parsing ==="

# Test if extract_cap can read TSMC library
set tsmc_cells [extract_cap "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"]
puts "TSMC library cells: [dict size $tsmc_cells]"

# Check specific UART cells
set uart_cells {NOR2X12M AO2B2X1M CLKXOR2X2M XOR3XLM XNOR2X1M DFFRQX2M DFFRHQX8M}
puts "\nChecking UART cells in TSMC library:"
foreach cell $uart_cells {
    set exists [dict exists $tsmc_cells $cell]
    if {$exists} {
        set cap [dict get $tsmc_cells $cell]
        puts "  $cell: EXISTS (cap=$cap)"
    } else {
        puts "  $cell: NOT FOUND"
    }
}

# Check nangate library too
if {[file exists "NangateOpenCellLibrary_typical.lib"]} {
    set nangate_cells [extract_cap "NangateOpenCellLibrary_typical.lib"]
    puts "\nNangate library cells: [dict size $nangate_cells]"
}
