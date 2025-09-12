# Debug script to inspect the library file parsing

# Change to the script's directory to resolve relative paths
cd [file dirname [info script]]

# Source the library parsing script
source "extract_cap.tcl"

puts "--- PARSING LIBRARY FILES ---"

# Initialize an empty dictionary for all cells
set all_cells_dict [dict create]

# --- Parse scmetro_tsmc library ---
set tsmc_lib "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"
if {[file exists $tsmc_lib]} {
    puts "Parsing $tsmc_lib..."
    set tsmc_cells [extract_cap $tsmc_lib]
    dict for {cell_name max_cap} $tsmc_cells {
        dict set all_cells_dict $cell_name $max_cap
    }
    puts "Found [dict size $tsmc_cells] cells in $tsmc_lib"
} else {
    puts "ERROR: Cannot find $tsmc_lib"
}

puts ""

# --- Parse Nangate library ---
set nangate_lib "NangateOpenCellLibrary_typical.lib"
if {[file exists $nangate_lib]} {
    puts "Parsing $nangate_lib..."
    set nangate_cells [extract_cap $nangate_lib]
    dict for {cell_name max_cap} $nangate_cells {
        dict set all_cells_dict $cell_name $max_cap
    }
    puts "Found [dict size $nangate_cells] cells in $nangate_lib"
} else {
    puts "ERROR: Cannot find $nangate_lib"
}

puts ""
puts "Total unique cells found: [dict size $all_cells_dict]"

# --- Check for a specific problematic cell ---
set target_cell "AOI222X2M"
if {[dict exists $all_cells_dict $target_cell]} {
    puts "SUCCESS: Found target cell '$target_cell' in the library data."
} else {
    puts "FAILURE: Did NOT find target cell '$target_cell'. The library parser is likely broken."
}

puts "--- SCRIPT COMPLETE ---"