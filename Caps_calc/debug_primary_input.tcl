#!/usr/bin/env tclsh

source "extract_path.tcl"

puts "=== Debugging Primary Input Issue ==="

# Get basic signal graph
set parse_result [extract_path "UART_TX_hierarchy.v"]
set instances [lindex $parse_result 0]

set signal_to_drivers [dict create]
set signal_to_loads [dict create]

foreach instance $instances {
    set gate_name [dict get $instance instance_name]
    set gate_type [dict get $instance cell_type]

    foreach conn [dict get $instance connections] {
        set port [lindex $conn 0]
        set signal [lindex $conn 1]

        if {[is_output_port $gate_type $port]} {
            dict lappend signal_to_drivers $signal [list $gate_name $port $gate_type]
        } else {
            dict lappend signal_to_loads $signal [list $gate_name $port $gate_type]
        }
    }
}

# Check P_DATA[0] connectivity
puts "P_DATA\[0\] connectivity:"
if {[dict exists $signal_to_drivers "P_DATA\[0\]"]} {
    puts "  Has drivers: [dict get $signal_to_drivers \"P_DATA\[0\]\"]"
} else {
    puts "  NO DRIVERS (primary input)"
}

if {[dict exists $signal_to_loads "P_DATA\[0\]"]} {
    puts "  Has loads: [dict get $signal_to_loads \"P_DATA\[0\]\"]"
} else {
    puts "  NO LOADS"
}

# Check what P_DATA[0] drives
if {[dict exists $signal_to_loads "P_DATA\[0\]"]} {
    set loads [dict get $signal_to_loads "P_DATA\[0\]"]
    puts "P_DATA\[0\] loads [llength $loads] gates:"
    foreach load $loads {
        set gate_name [lindex $load 0]
        set gate_type [lindex $load 2]
        puts "  -> $gate_type ($gate_name)"
        
        # Check what this gate outputs
        set gate_outputs [get_gate_outputs $gate_name $signal_to_drivers]
        puts "     Outputs: $gate_outputs"
    }
}
