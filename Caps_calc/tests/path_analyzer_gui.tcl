# Efficient Path Finding Algorithm using Breadth-First Search (BFS)

proc find_path_bfs {start_signal end_signal drivers loads gates hierarchy} {
    set queue [list $start_signal]
    set visited [dict create $start_signal 1]
    set parent [dict create]

    while {[llength $queue] > 0} {
        set current_signal [lindex $queue 0]
        set queue [lrange $queue 1 end]

        if {$current_signal eq $end_signal} {
            return [reconstruct_path $parent $start_signal $end_signal]
        }

        set next_signals [list]

        if {[dict exists $loads $current_signal]} {
            foreach gate_info [dict get $loads $current_signal] {
                set gate_name [lindex $gate_info 0]
                foreach output_signal [get_gate_outputs $gate_name $drivers] {
                    lappend next_signals [list $output_signal $gate_info]
                }
            }
        }

        foreach {module_port signal_list} $hierarchy {
            set external_signal [lindex $signal_list 0]
            regexp {^([^.]+)\.(.+)$} $module_port -> instance_name internal_port_name

            if {[string match "${external_signal}*" $current_signal]} {
                set bit_spec [string range $current_signal [string length $external_signal] end]
                set internal_signal "${internal_port_name}${bit_spec}"
                lappend next_signals [list $internal_signal "HIERARCHY ($instance_name)"]
            }

            if {$current_signal eq $internal_port_name} {
                 lappend next_signals [list $external_signal "HIERARCHY ($instance_name)"]
            }
        }

        foreach next_info $next_signals {
            set next_signal [lindex $next_info 0]
            set gate_info [lindex $next_info 1]
            if {![dict exists $visited $next_signal]} {
                dict set visited $next_signal 1
                dict set parent $next_signal [list $current_signal $gate_info]
                lappend queue $next_signal
            }
        }
    }
    return {}
}

# CORRECTED version of reconstruct_path
proc reconstruct_path {parent start_signal end_signal} {
    set path [list]
    set current $end_signal
    # Loop until we can no longer find a parent, which means we've hit the start
    while {[dict exists $parent $current]} {
        set parent_info [dict get $parent $current]
        set prev_signal [lindex $parent_info 0]
        set gate_info [lindex $parent_info 1]

        if {[llength $gate_info] > 1} {
            set gate_type [lindex $gate_info 2]
            set gate_name [lindex $gate_info 0]
            lappend path "$gate_type ($gate_name)"
        } else {
            # Make the hierarchy jump more descriptive
            lappend path "$gate_info ($prev_signal -> $current)"
        }
        set current $prev_signal
    }
    return [lreverse $path]
}