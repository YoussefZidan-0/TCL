# A new, simpler, more robust library parser.
proc extract_cap {filename} {
    set caps_dict [dict create]
    set fp [open $filename r]

    set in_cell_block 0
    set current_cell ""

    while {[gets $fp line] >= 0} {
        # Check for the start of a cell block
        if {[regexp {cell\s*\(([^)]+)\)} $line -> cell_name]} {
            set in_cell_block 1
            set current_cell $cell_name
            continue
        }

        # If we are inside a cell block, look for the capacitance
        if {$in_cell_block} {
            if {[regexp {max_capacitance\s*:\s*([\d\.]+)} $line -> cap_value]} {
                if {$current_cell ne ""} {
                    dict set caps_dict $current_cell $cap_value
                }
            }
        }

        # Check for the end of a cell block
        if {[string match {*} $line]} {
            set in_cell_block 0
            set current_cell ""
        }
    }

    close $fp
    return $caps_dict
}