


proc extract_path {netlist_filename} {
    set fp [open $netlist_filename r]
    source "extract_cap.tcl"
    set output_list {}

    # Get the cell capacitance dictionary directly
    set cells_caps_dict [extract_cap "NangateOpenCellLibrary_typical.lib"]
    # PROPER OUTPUT FORMAT
    # Print the dictionary in a formatted way
    set string_cells "{"
    dict for {cell_name max_cap} $cells_caps_dict {
        append string_cells "\"$cell_name\" $max_cap "
    }
    append string_cells "}"
    # puts $string_cells
    # Print the dictionary for debugging/verification
    # puts "Cell capacitance dictionary:"
    # dict for {key value} $cells_caps_dict {
    #     puts "$key -> $value"
    # }

    # Build a single optimized regex pattern with all cell types
    # This creates a pattern like: "^\\s*(CELL_TYPE1|CELL_TYPE2|...)\\s+(\\w+)\\s+\\("
    set cell_types [dict keys $cells_caps_dict]
    set cell_types_pattern [join $cell_types "|"]
    set combined_pattern "^\\s*(${cell_types_pattern})\\s+(\\w+)\\s+\\("

    # Compile the connections pattern once - simple version that works reliably
    set connections_pattern "\\.(\\w+)\\((\\w+)\\)"

    while {[gets $fp line] >= 0} {
        # Use a single regex to match any cell type at once
        if {[regexp $combined_pattern $line -> cell_type instance_name]} {
            # Look up the specific cell type in our dictionary
            if {[dict exists $cells_caps_dict $cell_type]} {
                set cap_value [dict get $cells_caps_dict $cell_type]
                puts "Found $cell_type instance: $instance_name with max capacitance: $cap_value"

                # Extract connections using split and trim - much more robust approach
                set connections [list]

                # First extract everything between the parentheses
                if {[regexp {\((.*)\);?$} $line -> conn_part]} {
                    # Split the connections by comma
                    set conn_list [split $conn_part ","]

                    foreach conn $conn_list {
                        # Parse each connection in the format .PORT(SIGNAL)
                        if {[regexp {\.(\w+)\(([^)]+)\)} [string trim $conn] -> port signal]} {
                            # Trim any whitespace from the port and signal
                            set port [string trim $port]
                            set signal [string trim $signal]
                            lappend connections [list $port $signal]
                        }
                    }
                }

                # Create an entry for this instance with cell type, instance name, and connections
                set instance_info [dict create "cell_type" $cell_type "instance_name" $instance_name "max_cap" $cap_value "connections" $connections]
                lappend output_list $instance_info
            }
        }

    }

    close $fp
    return $output_list
}

# Call the extract_path procedure and store the result
set path_data [extract_path "demo_adderPlus.syn.v"]

# Print the extracted path data in a readable format
puts "Extracted path data from netlist:"
set instance_count 0
foreach instance $path_data {
    incr instance_count
    puts "Instance #$instance_count: [dict get $instance cell_type] ([dict get $instance instance_name])"
    puts "  Max Capacitance: [dict get $instance max_cap]"
    puts "  Connections:"
    foreach conn [dict get $instance connections] {
        puts "    [lindex $conn 0] -> [lindex $conn 1]"
    }
    puts ""
}
puts "Total instances found: $instance_count"