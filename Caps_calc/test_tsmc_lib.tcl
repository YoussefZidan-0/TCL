#!/usr/bin/env tclsh
source "extract_cap_new.tcl"

puts "=== Testing extract_cap_new.tcl with TSMC Library ==="

# Test TSMC library
puts "Testing TSMC library..."
set tsmc_dict [extract_cap "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"]
puts "TSMC cells found: [dict size $tsmc_dict]"

if {[dict size $tsmc_dict] > 0} {
    puts "First 10 TSMC cells:"
    set count 0
    dict for {cell_name max_cap} $tsmc_dict {
        if {$count < 10} {
            puts "  $cell_name: $max_cap"
            incr count
        }
    }

    # Check for UART cell types
    set uart_cells {NOR2X12M AO2B2X1M CLKXOR2X2M XOR3XLM XNOR2X1M DFFRX1M DFFRQX2M}
    puts "\nChecking UART cell types:"
    foreach cell $uart_cells {
        if {[dict exists $tsmc_dict $cell]} {
            puts "  ✅ $cell: [dict get $tsmc_dict $cell]"
        } else {
            puts "  ❌ $cell: NOT FOUND"
        }
    }
} else {
    puts "ERROR: No TSMC cells found!"
}
