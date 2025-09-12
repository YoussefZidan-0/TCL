# Final test script for the UART path from P_DATA[0] to TX_OUT

# Change to the script's directory to resolve relative paths
cd [file dirname [info script]]

# --- Source all dependencies ---
source "extract_cap_new.tcl" ;# The user-provided CORRECT library parser
source "calcu_cap.tcl"
source "path_analyzer_gui.tcl" ;# The new, efficient BFS pathfinder
source "extract_path.tcl"      ;# The main script with parsing logic

# --- Define a new top-level function to use the BFS finder ---
proc get_path_bfs {netlist_filename start_signal end_signal} {
    set parse_result [extract_path $netlist_filename]
    set graph_info [build_signal_graph $parse_result]
    set signal_to_drivers [lindex $graph_info 0]
    set signal_to_loads [lindex $graph_info 1]
    set gate_to_info [lindex $graph_info 2]
    set hierarchical_connections [lindex $graph_info 3]

    # Call the efficient BFS pathfinder
    set path [find_path_bfs $start_signal $end_signal $signal_to_drivers $signal_to_loads $gate_to_info $hierarchical_connections]
    return $path
}

# --- Main execution ---
set netlist "UART_TX_hierarchy.v"
set start_signal {P_DATA[0]}
set end_signal {TX_OUT}

puts "--- RUNNING FINAL TEST ---"

set path [get_path_bfs $netlist $start_signal $end_signal]

puts "--- ANALYSIS COMPLETE ---"

if {[llength $path] > 0} {
    puts "SUCCESS! PATH FOUND:"
    set i 0
    foreach element $path {
        puts "  [incr i]. $element"
    }
} else {
    puts "FAILURE: NO PATH FOUND."
}

puts "--- END OF TEST ---"