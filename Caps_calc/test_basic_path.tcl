#!/usr/bin/env tclsh

source "extract_path.tcl"
S {P {{AND2_X1 (i_0)}} {{OR2_X1 (i_1)}}} AND2_X1 (i_2) INV_X1 (i_3)
puts "=== Testing Basic Path Finding (No Hierarchical) ==="

# Get instances without hierarchical processing
set parse_result [extract_path "UART_TX_hierarchy.v"]
set instances [lindex $parse_result 0]

# Build basic signal graph without hierarchical connections
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

puts "Basic graph built. Drivers: [dict size $signal_to_drivers], Loads: [dict size $signal_to_loads]"

# Test basic path finding
puts "\nTesting basic path P_DATA\[0\] to MUX_OUT..."
set path [find_path "P_DATA\[0\]" "MUX_OUT" $signal_to_drivers $signal_to_loads]
puts "Basic path result: $path"
