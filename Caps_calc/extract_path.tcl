


proc extract_path {netlist_filename} {
    set fp [open $netlist_filename r]
    source "extract_cap_new.tcl"
    set output_list {}

    # Get the cell capacitance dictionary directly
    set cells_caps_dict [extract_cap "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"]

    # Append Nangate library for backward compatibility with old tests
    if {[file exists "NangateOpenCellLibrary_typical.lib"]} {
        set nangate_caps_dict [extract_cap "NangateOpenCellLibrary_typical.lib"]
        # Merge the dictionaries - Nangate cells will be added to the existing dict
        dict for {cell_name max_cap} $nangate_caps_dict {
            dict set cells_caps_dict $cell_name $max_cap
        }
    }
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

    # Track module hierarchy for nested module support
    set current_module ""
    set module_hierarchy [dict create]
    set module_instances [list]
    set hierarchical_connections [dict create]

    set multi_line_buffer ""
    set in_gate_def 0
    set current_cell_type ""
    set current_instance_name ""
    set in_module_inst 0
    set module_inst_buffer ""
    set current_module_type ""
    set current_module_instance ""

    while {[gets $fp line] >= 0} {
        # Check for module definition
        if {[regexp {^\s*module\s+(\w+)} $line -> module_name]} {
            set current_module $module_name
            dict set module_hierarchy $module_name [list]
        }

        # Check for module instantiation (for hierarchical paths)
        if {[regexp {^\s*(\w+)\s+(\w+)\s*\(} $line -> module_type instance_name]} {
            if {$module_type ne "module" && ![dict exists $cells_caps_dict $module_type]} {
                # This is a module instantiation, not a primitive cell
                lappend module_instances [dict create "module_type" $module_type "instance_name" $instance_name "parent_module" $current_module]
                
                # Start capturing module instantiation for hierarchical connections
                set in_module_inst 1
                set current_module_type $module_type
                set current_module_instance $instance_name
                set module_inst_buffer $line
            }
        }

        # Handle multi-line module instantiations for hierarchical connections
        if {$in_module_inst} {
            append module_inst_buffer " " [string trim $line]
            # Check if we've reached the end of the module instantiation
            if {[regexp {\);\s*$} $module_inst_buffer]} {
                # Parse the complete module instantiation for signal connections
                parse_hierarchical_connections $module_inst_buffer $current_module_type $current_module_instance hierarchical_connections
                set in_module_inst 0
                set module_inst_buffer ""
                set current_module_type ""
                set current_module_instance ""
            }
        }

        # Handle multi-line gate instantiations
        # Check if this line starts a new gate definition
        if {[regexp "^\\s*(${cell_types_pattern})\\s+(\\w+)\\s+\\(" $line -> cell_type instance_name]} {
            # This is the start of a gate definition
            set in_gate_def 1
            set current_cell_type $cell_type
            set current_instance_name $instance_name
            set multi_line_buffer $line
        } elseif {$in_gate_def} {
            # We're continuing a multi-line gate definition
            append multi_line_buffer " " [string trim $line]
        }

        # Check if we've reached the end of the gate definition (contains closing parenthesis and semicolon)
        if {$in_gate_def && [regexp {\);?\s*$} $multi_line_buffer]} {
            # Process the complete gate definition
            if {[regexp "^\\s*${current_cell_type}\\s+${current_instance_name}\\s+\\((.*)\\)" $multi_line_buffer -> conn_part]} {
                # Look up the specific cell type in our dictionary
                if {[dict exists $cells_caps_dict $current_cell_type]} {
                    # Value should always exist it's coming from the same keys as the pattern
                    set cap_value [dict get $cells_caps_dict $current_cell_type]

                    # Extract connections using split and trim - much more robust approach
                    set connections [list]

                    # Clean up the connection part and split by comma
                    set conn_part [string map {"\n" " " "\t" " "} $conn_part]
                    set conn_part [regsub -all {\s+} $conn_part " "]
                    set conn_part [string trim $conn_part]
                    # Remove trailing ); if present
                    set conn_part [regsub {\s*\);\s*$} $conn_part ""]

                    set conn_list [split $conn_part ","]

                    foreach conn $conn_list {
                        # Parse each connection in the format .PORT(SIGNAL)
                        set conn [string trim $conn]
                        if {[regexp {\.([^(]+)\(([^)]+)\)} $conn -> port signal]} {
                            lappend connections [list $port $signal]
                        }
                    }

                    # Enhanced instance info with hierarchy support
                    set instance_info [dict create \
                        "cell_type" $current_cell_type \
                        "instance_name" $current_instance_name \
                        "max_cap" $cap_value \
                        "connections" $connections \
                        "parent_module" $current_module \
                        "hierarchical_path" "${current_module}/${current_instance_name}" \
                    ]
                lappend output_list $instance_info

                # Track instances within modules
                if {[dict exists $module_hierarchy $current_module]} {
                    dict lappend module_hierarchy $current_module $instance_info
                }
            }
        }
        # Reset for next gate
        set in_gate_def 0
        set multi_line_buffer ""
        set current_cell_type ""
        set current_instance_name ""
    }
}

close $fp

# Store hierarchical connections for later use in path finding
set output_list [list $output_list $hierarchical_connections $module_instances]
return $output_list
}

# Parse hierarchical module connections
proc parse_hierarchical_connections {module_line module_type instance_name connections_dict_var} {
    upvar $connections_dict_var connections_dict
    
    # Extract port connections from module instantiation
    # Format: module_type instance_name ( .port1(signal1), .port2(signal2), ... );
    if {[regexp {^.*?\(\s*(.*)\s*\)\s*;\s*$} $module_line -> conn_part]} {
        # Clean up the connection part
        set conn_part [string map {"\n" " " "\t" " "} $conn_part]
        set conn_part [regsub -all {\s+} $conn_part " "]
        set conn_part [string trim $conn_part]
        
        set conn_list [split $conn_part ","]
        
        foreach conn $conn_list {
            set conn [string trim $conn]
            if {[regexp {\.([^(]+)\(([^)]+)\)} $conn -> port signal]} {
                set port [string trim $port]
                set signal [string trim $signal]
                
                # Store the hierarchical connection mapping
                # This maps external signals to internal module signals
                if {![dict exists $connections_dict "${module_type}.${port}"]} {
                    dict set connections_dict "${module_type}.${port}" [list]
                }
                if {![dict exists $connections_dict "${instance_name}.${port}"]} {
                    dict set connections_dict "${instance_name}.${port}" [list]
                }
                dict lappend connections_dict "${module_type}.${port}" $signal
                dict lappend connections_dict "${instance_name}.${port}" $signal
            }
        }
    }
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
        "DFFRQX1M" [list "Q"] \
        "DFFRQX2M" [list "Q"] \
        "DFFRQX4M" [list "Q"] \
        "DFFSX2M" [list "Q" "QN"] \
        "DFFSRHQX1M" [list "Q"] \
        "DFFRHQX8M" [list "Q"] \
        "DFFRX1M" [list "Q" "QN"] \
        "DFFRX2M" [list "Q" "QN"] \
        "AOI222X2M" [list "Y"] \
        "AOI211X2M" [list "Y"] \
        "AOI32X1M" [list "Y"] \
        "AOI33X2M" [list "Y"] \
        "AOI21X1M" [list "Y"] \
        "AOI21X2M" [list "Y"] \
        "OAI211X1M" [list "Y"] \
        "OAI211X2M" [list "Y"] \
        "OAI21X1M" [list "Y"] \
        "OAI21X2M" [list "Y"] \
        "OAI31X2M" [list "Y"] \
        "OAI31X4M" [list "Y"] \
        "OAI2BB1XLM" [list "Y"] \
        "OAI2BB1X2M" [list "Y"] \
        "OAI2BB2X1M" [list "Y"] \
        "OAI2BB2X2M" [list "Y"] \
        "NAND2X1M" [list "Y"] \
        "NAND2XLM" [list "Y"] \
        "NAND2X2M" [list "Y"] \
        "NAND2BX1M" [list "Y"] \
        "NAND2BXLM" [list "Y"] \
        "NAND3X2M" [list "Y"] \
        "NOR2X1M" [list "Y"] \
        "NOR2X2M" [list "Y"] \
        "NOR2X8M" [list "Y"] \
        "NOR2X12M" [list "Y"] \
        "NOR2BX1M" [list "Y"] \
        "NOR3X12M" [list "Y"] \
        "CLKINVX1M" [list "Y"] \
        "CLKINVX2M" [list "Y"] \
        "CLKINVX4M" [list "Y"] \
        "INVX2M" [list "Y"] \
        "INVX8M" [list "Y"] \
        "BUFX5M" [list "Y"] \
        "BUFX10M" [list "Y"] \
        "CLKBUFX4M" [list "Y"] \
        "CLKBUFX6M" [list "Y"] \
        "CLKBUFX8M" [list "Y"] \
        "AND3X2M" [list "Y"] \
        "AO22XLM" [list "Y"] \
        "AO22X1M" [list "Y"] \
        "AO2B2X1M" [list "Y"] \
        "AOI2BB2X2M" [list "Y"] \
        "XOR3X1M" [list "Y"] \
        "XOR3XLM" [list "Y"] \
        "XNOR2X1M" [list "Y"] \
        "CLKXOR2X2M" [list "Y"] \
        "CLKXOR2X1M" [list "Y"] \
        "OAI2B2X1M" [list "Y"] \
        "MUX2X1M" [list "Y"] \
        "MUX2X2M" [list "Y"] \
        "TBUF_X1" [list "Y"] \
        "TBUF_X2" [list "Y"] \
        "TBUF_X4" [list "Y"] \
        "TBUF_X8" [list "Y"] \
        "DLL_X1" [list "Q"] \
        "DLL_X2" [list "Q"] \
        "DLH_X1" [list "Q"] \
        "DLH_X2" [list "Q"] \
        "FA_X1" [list "CO" "S"] \
    ]

if {[dict exists $output_ports $gate_type]} {
    return [expr {$port in [dict get $output_ports $gate_type]}]
}
return 0
}

# Build signal graph from instances with hierarchical support
proc build_signal_graph {parse_result} {
    # Handle new return format from extract_path
    set instances [lindex $parse_result 0]
    set hierarchical_connections [lindex $parse_result 1]
    set module_instances [lindex $parse_result 2]
    
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

    # Add hierarchical connections to the signal graph
    add_hierarchical_connections signal_to_drivers signal_to_loads $hierarchical_connections

    return [list $signal_to_drivers $signal_to_loads $gate_to_info $hierarchical_connections $module_instances]
}

# Add hierarchical module connections to signal graph
proc add_hierarchical_connections {drivers_var loads_var hierarchical_connections} {
    upvar $drivers_var signal_to_drivers
    upvar $loads_var signal_to_loads
    
    # Create signal aliases for hierarchical connections
    dict for {module_port signal_list} $hierarchical_connections {
        foreach signal $signal_list {
            # For each hierarchical connection, create bidirectional mapping
            # This allows path finding to traverse module boundaries
            
            # If the signal has drivers, make them drive the module port too
            if {[dict exists $signal_to_drivers $signal]} {
                set drivers [dict get $signal_to_drivers $signal]
                dict set signal_to_drivers $module_port $drivers
            }
            
            # If the signal has loads, make the module port have the same loads
            if {[dict exists $signal_to_loads $signal]} {
                set loads [dict get $signal_to_loads $signal]
                dict set signal_to_loads $module_port $loads
            }
            
            # Create reverse mapping - module port can drive the signal
            dict lappend signal_to_drivers $signal [list "HIER_${module_port}" "OUT" "HIERARCHICAL"]
            dict lappend signal_to_loads $module_port [list "HIER_${signal}" "IN" "HIERARCHICAL"]
        }
    }
}

# Find path between two signals with hierarchical module support
proc find_path_hierarchical {start_signal end_signal signal_to_drivers signal_to_loads hierarchical_connections} {
    # First try to find direct path
    set path [find_path $start_signal $end_signal $signal_to_drivers $signal_to_loads]
    
    if {[llength $path] > 0} {
        return $path
    }
    
    # If direct path fails, try with hierarchical signal mapping
    set mapped_start [find_hierarchical_signal_mapping $start_signal $hierarchical_connections $signal_to_drivers $signal_to_loads]
    set mapped_end [find_hierarchical_signal_mapping $end_signal $hierarchical_connections $signal_to_drivers $signal_to_loads]
    
    if {$mapped_start ne $start_signal || $mapped_end ne $end_signal} {
        # Try with mapped signals
        set path [find_path $mapped_start $mapped_end $signal_to_drivers $signal_to_loads]
        if {[llength $path] > 0} {
            return $path
        }
    }
    
    # If still no path, try all possible combinations
    set all_start_variants [get_all_signal_variants $start_signal $hierarchical_connections]
    set all_end_variants [get_all_signal_variants $end_signal $hierarchical_connections]
    
    foreach start_variant $all_start_variants {
        foreach end_variant $all_end_variants {
            set path [find_path $start_variant $end_variant $signal_to_drivers $signal_to_loads]
            if {[llength $path] > 0} {
                return $path
            }
        }
    }
    
    return {}
}

# Find path between two signals with parallel path detection
proc find_path {start_signal end_signal signal_to_drivers signal_to_loads} {
    # If start and end are the same, return empty path
    if {$start_signal eq $end_signal} {
        return [list "S"]
    }

    # Find all possible paths first, then structure them
    set all_paths [find_all_paths $start_signal $end_signal $signal_to_drivers $signal_to_loads [dict create] [list] 15]

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

# Find all possible paths from start to end signal with depth limit
proc find_all_paths {current_signal target_signal drivers loads visited path {max_depth 20}} {
    # Depth limit to prevent infinite loops in complex circuits
    if {[llength $path] > $max_depth} {
        return {}
    }
    
    # If we reached the target signal
    if {$current_signal eq $target_signal} {
        return [list $path]
    }

    # Check for cycles - prevent infinite loops
    if {[dict exists $visited $current_signal]} {
        return {}  # Cycle detected
    }

    # Mark current signal as visited for this path branch only
    set new_visited [dict create {*}$visited]
    dict set new_visited $current_signal 1

    # Get all gates that use this signal as input
    if {![dict exists $loads $current_signal]} {
        return {}  # Dead end
    }

    set loaded_gates [dict get $loads $current_signal]
    set all_paths [list]

    # Limit the number of paths to explore to prevent explosion
    set gate_count 0
    set max_gates_per_signal 5

    # For each gate that loads this signal
    foreach gate_info $loaded_gates {
        incr gate_count
        if {$gate_count > $max_gates_per_signal} {
            break
        }
        
        set gate_name [lindex $gate_info 0]
        set gate_type [lindex $gate_info 2]

        # Find output signals of this gate
        set gate_outputs [get_gate_outputs $gate_name $drivers]

        foreach output_signal $gate_outputs {
            if {![dict exists $new_visited $output_signal]} {
                # Create new path with this gate added
                set new_path [concat $path [list "$gate_type ($gate_name)"]]
                # Continue recursively with branch-specific visited list
                set sub_paths [find_all_paths $output_signal $target_signal $drivers $loads $new_visited $new_path $max_depth]
                set all_paths [concat $all_paths $sub_paths]
                
                # Limit total paths found to prevent memory explosion
                if {[llength $all_paths] > 10} {
                    break
                }
            }
        }
        
        if {[llength $all_paths] > 10} {
            break
        }
    }

    return $all_paths
}

# Structure paths to show parallel sections with support for complex nested structures
proc structure_parallel_paths {paths} {
    # Enhanced algorithm to handle:
    # 1. Multi-level parallel structures
    # 2. Nested parallelism
    # 3. Complex convergence patterns
    # 4. Hierarchical module paths

    if {[llength $paths] <= 1} {
        if {[llength $paths] == 1} {
            return [concat [list "S"] [lindex $paths 0]]
        }
        return {}
    }

    # Use advanced path analysis for complex structures
    return [analyze_complex_parallel_structure $paths]
}

# Advanced parallel structure analysis
proc analyze_complex_parallel_structure {paths} {
    # Step 1: Build path similarity matrix to identify convergence points
    set convergence_matrix [build_convergence_matrix $paths]

    # Step 2: Identify hierarchical parallel sections
    set parallel_sections [identify_parallel_sections $paths $convergence_matrix]

    # Step 3: Build nested structure representation
    return [build_nested_structure $parallel_sections]
}

# Build matrix showing where paths converge
proc build_convergence_matrix {paths} {
    set matrix [dict create]
    set max_len 0

    # Find maximum path length for normalization
    foreach path $paths {
        if {[llength $path] > $max_len} {
            set max_len [llength $path]
        }
    }

    # Build convergence analysis
    for {set pos 0} {$pos < $max_len} {incr pos} {
        set gates_at_pos [list]
        foreach path $paths {
            if {$pos < [llength $path]} {
                lappend gates_at_pos [lindex $path $pos]
            }
        }
        dict set matrix $pos $gates_at_pos
    }

    return $matrix
}

# Identify sections where paths run in parallel vs converge
proc identify_parallel_sections {paths convergence_matrix} {
    set sections [list]
    set current_section [dict create "type" "unknown" "gates" [list] "start_pos" 0]

    dict for {pos gates_list} $convergence_matrix {
        set unique_gates [lsort -unique $gates_list]

        if {[llength $unique_gates] > 1} {
            # Multiple different gates = parallel section
            if {[dict get $current_section type] ne "parallel"} {
                # Start new parallel section
                if {[dict get $current_section type] ne "unknown"} {
                    lappend sections $current_section
                }
                set current_section [dict create "type" "parallel" "gates" $unique_gates "start_pos" $pos]
            } else {
                # Continue parallel section
                dict set current_section "gates" [concat [dict get $current_section gates] $unique_gates]
            }
        } else {
            # Single gate = series section
            if {[dict get $current_section type] ne "series"} {
                # Start new series section
                if {[dict get $current_section type] ne "unknown"} {
                    lappend sections $current_section
                }
                set current_section [dict create "type" "series" "gates" $unique_gates "start_pos" $pos]
            } else {
                # Continue series section
                dict set current_section "gates" [concat [dict get $current_section gates] $unique_gates]
            }
        }
    }

    # Add final section
    if {[dict get $current_section type] ne "unknown"} {
        lappend sections $current_section
    }

    return $sections
}

# Build nested structure from identified sections with deep nesting support
proc build_nested_structure {sections} {
    set result [list "S"]

    foreach section $sections {
        set type [dict get $section type]
        set gates [lsort -unique [dict get $section gates]]

        if {$type eq "parallel"} {
            if {[llength $gates] > 1} {
                # Check for sub-parallel structures within this parallel section
                set nested_parallel [analyze_sub_parallel_structures $gates]
                lappend result $nested_parallel
            } else {
                lappend result [lindex $gates 0]
            }
        } else {
            # Series section - add each gate
            foreach gate $gates {
                if {$gate ne ""} {
                    lappend result $gate
                }
            }
        }
    }

    return $result
}

# Analyze sub-parallel structures within a parallel section
proc analyze_sub_parallel_structures {gates} {
    # For now, simple grouping but can be enhanced for complex nesting
    # Future enhancement: detect sub-groups that have internal parallelism

    if {[llength $gates] <= 1} {
        return [lindex $gates 0]
    }

    # Group gates by similarity (e.g., same type, similar naming pattern)
    set grouped_gates [group_similar_gates $gates]

    if {[llength $grouped_gates] > 1} {
        # Multiple groups = nested parallel structure
        set nested_result [list "P"]
        foreach group $grouped_gates {
            if {[llength $group] > 1} {
                # Sub-parallel group
                lappend nested_result [concat [list "P"] $group]
            } else {
                # Single gate
                lappend nested_result [lindex $group 0]
            }
        }
        return $nested_result
    } else {
        # Single group = flat parallel
        return [concat [list "P"] $gates]
    }
}

# Group similar gates for nested structure detection
proc group_similar_gates {gates} {
    set groups [dict create]

    foreach gate $gates {
        # Extract gate type for grouping
        if {[regexp {(\w+)\s*\(} $gate -> gate_type]} {
            dict lappend groups $gate_type $gate
        } else {
            dict lappend groups "unknown" $gate
        }
    }

    set result [list]
    dict for {type gate_list} $groups {
        lappend result $gate_list
    }

    return $result
}

# Find hierarchical signal mapping for a given signal
proc find_hierarchical_signal_mapping {signal hierarchical_connections signal_to_drivers signal_to_loads} {
    # Look for the signal in hierarchical connections
    dict for {module_port signal_list} $hierarchical_connections {
        if {$signal in $signal_list} {
            # Check if the module port has better connectivity
            if {[dict exists $signal_to_drivers $module_port] || [dict exists $signal_to_loads $module_port]} {
                return $module_port
            }
        }
    }
    
    # Look for direct module port match
    dict for {module_port signal_list} $hierarchical_connections {
        if {[string match "*${signal}*" $module_port]} {
            return $module_port
        }
    }
    
    return $signal
}

# Get all possible signal variants including hierarchical mappings
proc get_all_signal_variants {signal hierarchical_connections} {
    set variants [list $signal]
    
    # Add hierarchical variants
    dict for {module_port signal_list} $hierarchical_connections {
        if {$signal in $signal_list} {
            lappend variants $module_port
        }
        if {[string match "*${signal}*" $module_port]} {
            lappend variants $module_port
        }
    }
    
    # Add variants from the reverse mapping
    dict for {module_port signal_list} $hierarchical_connections {
        foreach mapped_signal $signal_list {
            if {[string match "*${signal}*" $mapped_signal]} {
                lappend variants $mapped_signal
                lappend variants $module_port
            }
        }
    }
    
    return [lsort -unique $variants]
}

# Performance optimization for large circuits
proc optimize_path_finding {signal_to_drivers signal_to_loads} {
    # Cache frequently accessed signals
    # Prune unreachable branches early
    # Use heuristics for large fan-out signals

    set optimized_drivers $signal_to_drivers
    set optimized_loads $signal_to_loads

    # Remove signals with no loads (dead ends)
    dict for {signal driver_list} $signal_to_drivers {
        if {![dict exists $signal_to_loads $signal]} {
            dict unset optimized_drivers $signal
        }
    }

    return [list $optimized_drivers $optimized_loads]
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
    # Get the parsed instances and hierarchical info
    set parse_result [extract_path $netlist_filename]

    # Build the signal graph
    set graph_info [build_signal_graph $parse_result]
    set signal_to_drivers [lindex $graph_info 0]
    set signal_to_loads [lindex $graph_info 1]
    set gate_to_info [lindex $graph_info 2]
    set hierarchical_connections [lindex $graph_info 3]
    set module_instances [lindex $graph_info 4]

    # Find the path with hierarchical support
    set path [find_path_hierarchical $start_signal $end_signal $signal_to_drivers $signal_to_loads $hierarchical_connections]

    return $path
}

# Convenience function for interactive use
proc get_path {netlist start end} {
    return [extract_signal_path $netlist $start $end]
}

# Enhanced hierarchical path extraction with module support
proc get_hierarchical_path {netlist start end {module_context ""}} {
    set parse_result [extract_path $netlist]

    # Build hierarchical signal graph
    set graph_info [build_hierarchical_signal_graph $parse_result]
    set signal_to_drivers [lindex $graph_info 0]
    set signal_to_loads [lindex $graph_info 1]
    set module_map [lindex $graph_info 2]

    # Find path with module boundary crossing support
    return [find_hierarchical_path $start $end $signal_to_drivers $signal_to_loads $module_map $module_context]
}

# Build signal graph with hierarchical module support
proc build_hierarchical_signal_graph {parse_result} {
    # Handle new return format
    set instances [lindex $parse_result 0]
    set hierarchical_connections [lindex $parse_result 1]
    set module_instances [lindex $parse_result 2]
    set signal_to_drivers [dict create]
    set signal_to_loads [dict create]
    set module_map [dict create]

    foreach instance $instances {
        set gate_name [dict get $instance instance_name]
        set gate_type [dict get $instance cell_type]
        set parent_module [dict get $instance parent_module]
        set hierarchical_path [dict get $instance hierarchical_path]

        # Store hierarchical information
        dict set module_map $hierarchical_path $instance

        foreach conn [dict get $instance connections] {
            set port [lindex $conn 0]
            set signal [lindex $conn 1]

            # Create hierarchical signal names
            set hierarchical_signal "${parent_module}/${signal}"

            if {[is_output_port $gate_type $port]} {
                dict lappend signal_to_drivers $hierarchical_signal [list $hierarchical_path $port $gate_type]
                # Also add non-hierarchical for backward compatibility
                dict lappend signal_to_drivers $signal [list $gate_name $port $gate_type]
            } else {
                dict lappend signal_to_loads $hierarchical_signal [list $hierarchical_path $port $gate_type]
                # Also add non-hierarchical for backward compatibility
                dict lappend signal_to_loads $signal [list $gate_name $port $gate_type]
            }
        }
    }

    return [list $signal_to_drivers $signal_to_loads $module_map]
}

# Find path with support for crossing module boundaries
proc find_hierarchical_path {start_signal end_signal drivers loads module_map {module_context ""}} {
    # Try both hierarchical and flat signal names
    set search_variants [list]

    if {$module_context ne ""} {
        lappend search_variants "${module_context}/${start_signal}"
        lappend search_variants "${module_context}/${end_signal}"
    }
    lappend search_variants $start_signal
    lappend search_variants $end_signal

    # Find best matching signals
    set actual_start $start_signal
    set actual_end $end_signal

    foreach variant $search_variants {
        if {[dict exists $loads $variant] || [dict exists $drivers $variant]} {
            if {[string match "*${start_signal}" $variant]} {
                set actual_start $variant
            }
            if {[string match "*${end_signal}" $variant]} {
                set actual_end $variant
            }
        }
    }

    # Use enhanced path finding
    return [find_path $actual_start $actual_end $drivers $loads]
}

# Complex structure test function
proc test_complex_structures {} {
    puts "Testing complex parallel structure detection..."

    # Test with multiple convergence levels
    set test_paths [list \
        [list "A_gate" "B_gate" "CONV1_gate" "D_gate" "FINAL_gate"] \
        [list "A_gate" "C_gate" "CONV1_gate" "E_gate" "FINAL_gate"] \
        [list "A_gate" "F_gate" "CONV2_gate" "D_gate" "FINAL_gate"] \
    ]

set result [structure_parallel_paths $test_paths]
puts "Complex structure result: $result"
return $result
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