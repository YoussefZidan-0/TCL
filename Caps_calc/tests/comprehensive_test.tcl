# --- COMPREHENSIVE SELF-CONTAINED TEST SCRIPT (v2) ---

# Change to the script's directory to resolve relative paths
cd [file dirname [info script]]

# --- PROCEDURE DEFINITIONS ---

# 1. Robust library parser
proc extract_cap {filename} {
    set fp [open $filename r]
    set content [read $fp]
    close $fp
    set caps_dict [dict create]
    set cell_block_pattern {cell\s*\(([^)]+)\)\s*\{([^}]+)\}}
    set matches [regexp -all -inline $cell_block_pattern $content]
    foreach match $matches {
        set cell_name [lindex $match 1]
        set cell_body [lindex $match 2]
        set cap_pattern {max_capacitance\s*:\s*([\d\.]+)}
        if {[regexp $cap_pattern $cell_body -> cap_value]} {
            dict set caps_dict $cell_name $cap_value
        }
    }
    return $caps_dict
}

# 2. Parser for hierarchical connections
proc parse_hierarchical_connections {module_line module_type instance_name connections_dict_var} {
    upvar $connections_dict_var connections_dict
    if {[regexp {^.*\((.*)\)\s*;} $module_line -> conn_part]} {
        set conn_list [split [regsub -all {\s+} [string map {"\n" " " "\t" " "} $conn_part] " "] ","]
        foreach conn $conn_list {
            if {[regexp {\.([^(]+)\(([^)]+)\)} [string trim $conn] -> port signal]} {
                set port [string trim $port]
                set signal [string trim $signal]
                dict lappend connections_dict "${module_type}.${port}" $signal
                dict lappend connections_dict "${instance_name}.${port}" $signal
            }
        }
    }
}

# 3. Main Verilog parser
proc extract_path {netlist_filename} {
    set fp [open $netlist_filename r]
    set output_list {}
    set cells_caps_dict [dict create]
    set tsmc_lib "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"
    if {[file exists $tsmc_lib]} { dict for {k v} [extract_cap $tsmc_lib] { dict set cells_caps_dict $k $v } }
    set nangate_lib "NangateOpenCellLibrary_typical.lib"
    if {[file exists $nangate_lib]} { dict for {k v} [extract_cap $nangate_lib] { dict set cells_caps_dict $k $v } }
    set cell_types [dict keys $cells_caps_dict]
    if {[llength $cell_types] == 0} { error "No cell types found. Library parsing failed." }
    set cell_types_pattern [join $cell_types "|"]

    set hierarchical_connections [dict create]
    set multi_line_buffer ""
    set in_gate_def 0

    while {[gets $fp line] >= 0} {
        if {[regexp "^\\s*($cell_types_pattern)\\s+(\\w+)\\s+\"(" $line -> cell_type instance_name]} {
            set in_gate_def 1
            set multi_line_buffer $line
        } elseif {$in_gate_def} {
            append multi_line_buffer " " [string trim $line]
        }

        if {$in_gate_def && [regexp {\");?\s*$} $multi_line_buffer]} {
            if {[regexp "^\\s*$cell_type\\s+$instance_name\\s+\\(.*)\"" $multi_line_buffer -> conn_part]} {
                set connections [list]
                set conn_part_cleaned [regsub -all {\s+} [string map {"\n" " " "\t" " "} $conn_part] " "]
                foreach conn [split $conn_part_cleaned ","] {
                    if {[regexp {\.([^(]+)\(([^)]+)\)} [string trim $conn] -> port signal]} {
                        lappend connections [list $port $signal]
                    }
                }
                lappend output_list [dict create cell_type $cell_type instance_name $instance_name connections $connections]
            }
            set in_gate_def 0
        }

        if {[regexp {^\s*(\w+)\s+(\w+)\s*\(} $line -> module_type instance_name]} {
            if {$module_type ne "module" && ![dict exists $cells_caps_dict $module_type]} {
                parse_hierarchical_connections $line $module_type $instance_name hierarchical_connections
            }
        }
    }
    close $fp
    return [list $output_list $hierarchical_connections]
}

# 4. Output port checker
variable output_port_cache {}
proc is_output_port {gate_type port} {
    variable output_port_cache
    if {[llength $output_port_cache] == 0} {
        # Abridged list for brevity
        set output_port_cache [dict create AOI222X2M Y DFFRQX1M Q DFFRHQX8M Q OAI2BB1XLM Y OAI21X1M Y]
    }
    return [expr {[dict exists $output_port_cache $gate_type] && $port in [dict get $output_port_cache $gate_type]}]
}

# 5. Graph builder
proc build_signal_graph {parse_result} {
    lassign $parse_result instances hierarchical_connections
    set signal_to_drivers [dict create]
    set signal_to_loads [dict create]
    foreach instance $instances {
        set gate_name [dict get $instance instance_name]
        set gate_type [dict get $instance cell_type]
        foreach {port signal} [dict get $instance connections] {
            set gate_info [list $gate_name $port $gate_type]
            if {[is_output_port $gate_type $port]} { dict lappend signal_to_drivers $signal $gate_info } else { dict lappend signal_to_loads $signal $gate_info }
        }
    }
    return [list $signal_to_drivers $signal_to_loads $hierarchical_connections]
}

# 6. Helper to get gate outputs
proc get_gate_outputs {gate_name signal_to_drivers} {
    set outputs [list]
    dict for {signal driver_list} $signal_to_drivers {
        foreach driver $driver_list {
            if {[lindex $driver 0] eq $gate_name} { lappend outputs $signal }
        }
    }
    return $outputs
}

# 7. BFS Path Finder and Reconstructor
proc find_path_bfs {start_signal end_signal drivers loads hierarchy} {
    set queue [list $start_signal]
    set visited [dict create $start_signal 1]
    set parent [dict create]
    while {[llength $queue] > 0} {
        set current_signal [lindex $queue 0]
        set queue [lrange $queue 1 end]
        if {$current_signal eq $end_signal} { return [reconstruct_path $parent $end_signal] }
        set next_signals [list]
        if {[dict exists $loads $current_signal]} {
            foreach gate_info [dict get $loads $current_signal] {
                foreach output_signal [get_gate_outputs [lindex $gate_info 0] $drivers] {
                    lappend next_signals [list $output_signal $gate_info]
                }
            }
        }
        foreach {module_port signal_list} $hierarchy {
            set external_signal [lindex $signal_list 0]
            if {[regexp {^([^.]+)\.(.+)$} $module_port -> instance_name internal_port_name]} {
                if {[string match "${external_signal}*" $current_signal]} {
                    set bit_spec [string range $current_signal [string length $external_signal] end]
                    set internal_signal "${internal_port_name}${bit_spec}"
                    lappend next_signals [list $internal_signal "HIERARCHY ($instance_name)"]
                }
                if {$current_signal eq $internal_port_name} {
                     lappend next_signals [list $external_signal "HIERARCHY ($instance_name)"]
                }
            }
        }
        foreach {next_signal gate_info} $next_signals {
            if {![dict exists $visited $next_signal]} {
                dict set visited $next_signal 1
                dict set parent $next_signal [list $current_signal $gate_info]
                lappend queue $next_signal
            }
        }
    }
    return {}
}

proc reconstruct_path {parent end_signal} {
    set path [list]
    set current $end_signal
    while {[dict exists $parent $current]} {
        lassign [dict get $parent $current] prev_signal gate_info
        if {[llength $gate_info] > 1} {
            lappend path "[lindex $gate_info 2] ([lindex $gate_info 0])"
        } else {
            lappend path "$gate_info ($prev_signal -> $current)"
        }
        set current $prev_signal
    }
    return [lreverse $path]
}

# --- Main Execution Logic ---
proc run_path_analysis {netlist start end} {
    set parse_result [extract_path $netlist]
    lassign [build_signal_graph $parse_result] drivers loads hierarchy
    set path [find_path_bfs $start $end $drivers $loads $hierarchy]
    return $path
}

# --- Test Case ---
puts "--- RUNNING COMPREHENSIVE TEST (v2) ---"
set path [run_path_analysis "UART_TX_hierarchy.v" {P_DATA[0]} {TX_OUT}]

if {[llength $path] > 0} {
    puts "SUCCESS! PATH FOUND:"
    set i 0
    foreach element $path { puts "  [incr i]. $element" }
} else {
    puts "FAILURE: NO PATH FOUND."
}
puts "--- END OF TEST ---"
