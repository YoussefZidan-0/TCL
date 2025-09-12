# Test script to debug the cell_types_pattern variable.

# Change to the script's directory
cd [file dirname [info script]]

# 1. Source all original files to load all procedures
source "extract_cap_new.tcl"
source "calcu_cap.tcl"
source "extract_path.tcl"

# 2. Now, OVERRIDE extract_path with a debug version
proc extract_path {netlist_filename {lib_files {}}} {
    # This procedure now only checks the library parsing.
    set cells_caps_dict [dict create]
    
    set tsmc_lib "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"
    if {[file exists $tsmc_lib]} {
        dict for {k v} [extract_cap $tsmc_lib] { dict set cells_caps_dict $k $v } 
    }
    
    set nangate_lib "NangateOpenCellLibrary_typical.lib"
    if {[file exists $nangate_lib]} { 
        dict for {k v} [extract_cap $nangate_lib] { dict set cells_caps_dict $k $v } 
    }

    set cell_types [dict keys $cells_caps_dict]
    if {[llength $cell_types] == 0} { 
        puts "ERROR: No cell types found. Library parsing failed."
        return
    }
    set cell_types_pattern [join $cell_types "|"]

    # --- DEBUG PRINT ---
    puts "--- DEBUG: CELL TYPES PATTERN ---"
    if {[regexp {OAI2BB1X2M} $cell_types_pattern]} {
        puts "SUCCESS: Found OAI2BB1X2M in cell types pattern."
    } else {
        puts "FAILURE: OAI2BB1X2M is MISSING from cell types pattern."
    }
    puts "--- END DEBUG ---"
    
    return [list]
}

# 3. Run the test
puts "--- Running Parser Debug Test ---"
# Calling a function that uses our overridden proc
get_path_with_capacitance "UART_TX_flattened.v" {P_DATA[0]} {TX_OUT}
puts "--- Test Complete ---"