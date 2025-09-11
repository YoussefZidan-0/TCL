


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
    # This creates a pattern like: "^\\s*(CELL_TYPE1|CELL_TYPE2|...)\\s+(\\w+)\\s+\\((.*)\\)"
    set cell_types [dict keys $cells_caps_dict]
    set cell_types_pattern [join $cell_types "|"]
    set combined_pattern "^\\s*(${cell_types_pattern})\\s+(\\w+)\\s+\\((.*)\\)"
    # We don't need the connections pattern anymore since we'll capture the entire connections part
    # and use split to parse it

    while {[gets $fp line] >= 0} {
        # Use a single regex to match any cell type at once and capture the connection part
        if {[regexp $combined_pattern $line -> cell_type instance_name conn_part]} {
            # Look up the specific cell type in our dictionary
            if {[dict exists $cells_caps_dict $cell_type]} {
                # Value should always exist it's coming from the same keys as the pattern
                set cap_value [dict get $cells_caps_dict $cell_type]
                # puts "Found $cell_type instance: $instance_name with max capacitance: $cap_value"

                # Extract connections using split and trim - much more robust approach
                set connections [list]

                # Split the connections by comma - the conn_part is already captured by the regex
                set conn_list [split $conn_part ","]

                foreach conn $conn_list {
                    # Parse each connection in the format .PORT(SIGNAL)
                    set conn [string trim $conn]
                    if {[regexp {\.([^(]+)\(([^)]+)\)} $conn -> port signal]} {
                        lappend connections [list $port $signal]
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

# Helper function to determine if a port is an output port
proc is_output_port {gate_type port} {
    set output_ports [dict create \
        "HA_X1" [list "CO" "S"] \
        "XOR2_X1" [list "Z"] \
        "XNOR2_X1" [list "ZN"] \
        "AND2_X1" [list "ZN"] \
        "OR2_X1" [list "ZN"] \
        "INV_X1" [list "ZN"] \
        "AOI21_X1" [list "ZN"] \
    ]

if {[dict exists $output_ports $gate_type]} {
    return [expr {$port in [dict get $output_ports $gate_type]}]
}
return 0
}

# Build signal graph from instances
proc build_signal_graph {instances} {
    # signal_to_drivers: signal -> list of {gate_instance, output_port}
    # signal_to_loads: signal -> list of {gate_instance, input_port}
    set signal_to_drivers [dict create]
    set signal_to_loads [dict create]
    set gate_to_info [dict create]

    foreach instance $instances {
        set gate_name [dict get $instance instance_name]
        set gate_type [dict get $instance cell_type]

        # Store gate info for later use
        dict set gate_to_info $gate_name [dict create "type" $gate_type "instance" $instance]

        foreach conn [dict get $instance connections] {
            set port [lindex $conn 0]
            set signal [lindex $conn 1]

            # Determine if port is input or output based on gate type
            if {[is_output_port $gate_type $port]} {
                dict lappend signal_to_drivers $signal [list $gate_name $port $gate_type]
            } else {
                dict lappend signal_to_loads $signal [list $gate_name $port $gate_type]
            }
        }
    }

    return [list $signal_to_drivers $signal_to_loads $gate_to_info]
}

# Find path between two signals with parallel path detection
proc find_path {start_signal end_signal signal_to_drivers signal_to_loads} {
    # If start and end are the same, return empty path
    if {$start_signal eq $end_signal} {
        return [list "S"]
    }

    # Find all possible paths first, then structure them
    set all_paths [find_all_paths $start_signal $end_signal $signal_to_drivers $signal_to_loads [dict create] [list]]

    if {[llength $all_paths] == 0} {
        return {}
    } elseif {[llength $all_paths] == 1} {
        # Single path
        return [concat [list "S"] [lindex $all_paths 0]]
    } else {
        # Multiple paths - need to structure them properly
        return [structure_parallel_paths $all_paths]
    }
}

# Find all possible paths from start to end signal
proc find_all_paths {current_signal target_signal drivers loads visited path} {
    # If we reached the target signal
    if {$current_signal eq $target_signal} {
        return [list $path]
    }

    # Mark current signal as visited for this path
    dict set visited $current_signal 1

    # Get all gates that use this signal as input
    if {![dict exists $loads $current_signal]} {
        return {}  # Dead end
    }

    set loaded_gates [dict get $loads $current_signal]
    set all_paths [list]

    # For each gate that loads this signal
    foreach gate_info $loaded_gates {
        set gate_name [lindex $gate_info 0]
        set gate_type [lindex $gate_info 2]

        # Find output signals of this gate
        set gate_outputs [get_gate_outputs $gate_name $drivers]

        foreach output_signal $gate_outputs {
            if {![dict exists $visited $output_signal]} {
                # Create new path with this gate added
                set new_path [concat $path [list "$gate_type ($gate_name)"]]
                # Continue recursively
                set sub_paths [find_all_paths $output_signal $target_signal $drivers $loads $visited $new_path]
                set all_paths [concat $all_paths $sub_paths]
            }
        }
    }

    return $all_paths
}

# Structure paths to show parallel sections
proc structure_parallel_paths {paths} {
    # For now, simple approach: if multiple paths, show first gate of each as parallel
    # This works for the basic parallel case but could be enhanced for complex scenarios

    if {[llength $paths] <= 1} {
        if {[llength $paths] == 1} {
            return [concat [list "S"] [lindex $paths 0]]
        }
        return {}
    }

    # Find the common suffix (convergence point)
    set shortest_path [lindex $paths 0]
    foreach path $paths {
        if {[llength $path] < [llength $shortest_path]} {
            set shortest_path $path
        }
    }

    # Find where paths converge by comparing from the end
    set common_suffix [list]
    set min_len [llength $shortest_path]

    for {set i 1} {$i <= $min_len} {incr i} {
        set pos [expr {[llength $shortest_path] - $i}]
        set gate [lindex $shortest_path $pos]

        set all_have_gate 1
        foreach path $paths {
            set path_pos [expr {[llength $path] - $i}]
            if {$path_pos < 0 || [lindex $path $path_pos] ne $gate} {
                set all_have_gate 0
                break
            }
        }

        if {$all_have_gate} {
            set common_suffix [concat [list $gate] $common_suffix]
        } else {
            break
        }
    }

    # Extract the parallel section (everything before the common suffix)
    set parallel_gates [list]
    foreach path $paths {
        set parallel_len [expr {[llength $path] - [llength $common_suffix]}]
        if {$parallel_len > 0} {
            lappend parallel_gates [lindex $path 0]
        }
    }

    # Build the result
    set result [list "S"]
    if {[llength $parallel_gates] > 1} {
        lappend result [concat [list "P"] $parallel_gates]
    } else {
        lappend result [lindex $parallel_gates 0]
    }

    # Add the common suffix
    foreach gate $common_suffix {
        lappend result $gate
    }

    return $result
}

# Helper function to get all output signals for a given gate
proc get_gate_outputs {gate_name signal_to_drivers} {
    set outputs [list]
    dict for {signal driver_list} $signal_to_drivers {
        foreach driver $driver_list {
            set driver_gate [lindex $driver 0]
            if {$driver_gate eq $gate_name} {
                lappend outputs $signal
            }
        }
    }
    return $outputs
}

# Main procedure to extract path between two signals
proc extract_signal_path {netlist_filename start_signal end_signal} {
    # Get the parsed instances
    set instances [extract_path $netlist_filename]

    # Build the signal graph
    set graph_info [build_signal_graph $instances]
    set signal_to_drivers [lindex $graph_info 0]
    set signal_to_loads [lindex $graph_info 1]
    set gate_to_info [lindex $graph_info 2]

    # Find the path
    set path [find_path $start_signal $end_signal $signal_to_drivers $signal_to_loads]

    return $path
}

# Convenience function for interactive use
proc get_path {netlist start end} {
    return [extract_signal_path $netlist $start $end]
}

# # Call the extract_path procedure and store the result
# set path_data [extract_path "demo_adderPlus.syn.v"]

# # Print the extracted path data in a readable format
# puts "Extracted path data from netlist:"
# set instance_count 0
# foreach instance $path_data {
#     incr instance_count
#     puts "Instance #$instance_count: [dict get $instance cell_type] ([dict get $instance instance_name])"
#     puts "  Max Capacitance: [dict get $instance max_cap]"
#     puts "  Connections:"
#     foreach conn [dict get $instance connections] {
#         puts "    [lindex $conn 0] -> [lindex $conn 1]"
#     }
#     puts ""
# }
# puts "Total instances found: $instance_count"

# # Test path extraction examples
# puts "\n=== PATH EXTRACTION TESTS ==="

# # Test 1: Extract Path inputB[0]:p_0[0] (should be: {S, HA_X1 (i_0)})
# puts "\nTest 1: Extract Path inputB\[0\]:p_0\[0\]"
# set path1 [extract_signal_path "demo_adderPlus.syn.v" "inputB\[0\]" "p_0\[0\]"]
# puts "Result: $path1"

# # Test 2: Extract Path inputB[0]:p_0[1] (should be: {S, HA_X1 (i_0), XOR2_X1(i_8)})
# puts "\nTest 2: Extract Path inputB\[0\]:p_0\[1\]"
# set path2 [extract_signal_path "demo_adderPlus.syn.v" "inputB\[0\]" "p_0\[1\]"]
# puts "Result: $path2"

# # Test 3: Extract Path inputA[0]:p_0[1]
# puts "\nTest 3: Extract Path inputA\[0\]:p_0\[1\]"
# set path3 [extract_signal_path "demo_adderPlus.syn.v" "inputA\[0\]" "p_0\[1\]"]
# puts "Result: $path3"

# # Test 4: Parallel circuit example - Extract Path A:K
# puts "\nTest 4: Parallel Circuit - Extract Path A:K"
# set path4 [extract_signal_path "demo_parallel.syn.v" "A" "K"]
# puts "Expected: {S, {P, AND2_X1 (i_0), OR2_X1 (i_1)}, AND2_X1 (i_2), INV_X1 (i_3)}"
# puts "Result: $path4"

# # Test 5: Simple series path in parallel circuit - B:K
# puts "\nTest 5: Series Path B:K in parallel circuit"
# set path5 [extract_signal_path "demo_parallel.syn.v" "B" "K"]
# puts "Result: $path5"

# puts "\n=== USAGE EXAMPLE ==="
# puts "To extract a path, use: get_path <netlist_file> <start_signal> <end_signal>"
# puts "Example: set path \[get_path \"demo_parallel.syn.v\" \"A\" \"K\"\]"