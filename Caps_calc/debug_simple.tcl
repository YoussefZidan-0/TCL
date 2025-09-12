#!/usr/bin/env tclsh

# Simple debug to check regex pattern matching
source "extract_cap.tcl"

puts "=== Debug Multi-line Parsing ==="

# Build cell dictionary first
set cells_caps_dict [extract_cap "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"]


if {[regexp "^\\s*(${cell_types_pattern})\\s+(\\w+)\\s+\\(" $line -> cell_type instance_name]} {
    puts "  --> MATCH: $cell_type $instance_name"
}
}

close $fp

puts "\nFirst few cell types from library:"
set count 0
dict for {cell_name cap} $cells_caps_dict {
    if {$count < 10} {
        puts "  $cell_name"
        incr count
    }
}
