# Change to the script's directory to resolve relative paths
cd [file dirname [info script]]

# Load the main script
source "extract_path.tcl"

# --- Redefine procedures with added debugging ---

# Redefine find_path_hierarchical to trace its execution
proc find_path_hierarchical {start_signal end_signal signal_to_drivers signal_to_loads hierarchical_connections} {
    puts "DEBUG: Starting hierarchical search from '$start_signal' to '$end_signal'"

    # First try to find direct path
    set path [find_path $start_signal $end_signal $signal_to_drivers $signal_to_loads]

    if {[llength $path] > 0} {
        puts "DEBUG: Found direct path."
        return $path
    }
    puts "DEBUG: No direct path found."

    # If direct path fails, try with hierarchical signal mapping
    puts "DEBUG: Trying hierarchical signal mapping..."
    set mapped_start [find_hierarchical_signal_mapping $start_signal $hierarchical_connections $signal_to_drivers $signal_to_loads]
    set mapped_end [find_hierarchical_signal_mapping $end_signal $hierarchical_connections $signal_to_drivers $signal_to_loads]

    if {$mapped_start ne $start_signal || $mapped_end ne $end_signal} {
        puts "DEBUG: Mapped signals: '$mapped_start' -> '$mapped_end'"
        set path [find_path $mapped_start $mapped_end $signal_to_drivers $signal_to_loads]
        if {[llength $path] > 0} {
            puts "DEBUG: Found path with mapped signals."
            return $path
        }
        puts "DEBUG: No path found with mapped signals."
    }

    # If still no path, try all possible combinations
    puts "DEBUG: Trying all signal variants..."
    set all_start_variants [get_all_signal_variants $start_signal $hierarchical_connections]
    set all_end_variants [get_all_signal_variants $end_signal $hierarchical_connections]
    puts "DEBUG: Start variants: $all_start_variants"
    puts "DEBUG: End variants: $all_end_variants"

    foreach start_variant $all_start_variants {
        foreach end_variant $all_end_variants {
            puts "DEBUG: Trying variant pair: '$start_variant' -> '$end_variant'"
            set path [find_path $start_variant $end_variant $signal_to_drivers $signal_to_loads]
            if {[llength $path] > 0} {
                puts "DEBUG: Found path with variant pair."
                return $path
            }
        }
    }

    puts "DEBUG: No path found after trying all variants."
    return {}
}

# Redefine find_all_paths to trace its execution and add a stricter limit
proc find_all_paths {current_signal target_signal drivers loads visited path {max_depth 15}} {
    # Stricter depth limit to prevent hangs
    if {[llength $path] > $max_depth} {
        puts "DEBUG: Max depth reached at signal '$current_signal'"
        return {}
    }

    if {[llength $path] < 5} {
        puts "DEBUG: find_all_paths: current='$current_signal', target='$target_signal', path_len=[llength $path]"
    }

    if {$current_signal eq $target_signal} {
        puts "DEBUG: Reached target '$target_signal'"
        return [list $path]
    }

    if {[dict exists $visited $current_signal]} {
        return {}
    }
    dict set visited $current_signal 1

    if {![dict exists $loads $current_signal]} {
        return {}
    }

    set loaded_gates [dict get $loads $current_signal]
    set all_paths [list]
    set gate_count 0
    set max_gates_per_signal 5

    foreach gate_info $loaded_gates {
        if {[incr gate_count] > $max_gates_per_signal || [llength $all_paths] > 5} {
            break
        }

        set gate_name [lindex $gate_info 0]
        set gate_type [lindex $gate_info 2]

        foreach output_signal [get_gate_outputs $gate_name $drivers] {
            if {![dict exists $visited $output_signal]} {
                set new_path [concat $path [list "$gate_type ($gate_name)"]]
                set sub_paths [find_all_paths $output_signal $target_signal $drivers $loads $visited $new_path $max_depth]
                set all_paths [concat $all_paths $sub_paths]
                if {[llength $all_paths] > 5} break
            }
        }
    }

    return $all_paths
}


# --- Main execution ---

# Define the test case
set netlist "UART_TX_hierarchy.v"
set start_signal {P_DATA[0]}
set end_signal {TX_OUT}

puts "--- STARTING DEBUG RUN ---"
# Run the analysis
set result [get_path_with_capacitance $netlist $start_signal $end_signal]

puts "
--- ANALYSIS COMPLETE ---"
# Display the result
display_path_analysis $result
puts "--- END DEBUG RUN ---"