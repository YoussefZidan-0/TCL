#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Debug get_gate_outputs Function ==="

# Parse UART and build graph
set instances [extract_path "UART_TX_flattened.v"]
set graph_info [build_signal_graph $instances]
set signal_to_drivers [lindex $graph_info 0]
set signal_to_loads [lindex $graph_info 1]

# Test the get_gate_outputs function
puts "1. Testing get_gate_outputs function:"

# Get gates that par_bit connects to
if {[dict exists $signal_to_loads par_bit]} {
    set par_loads [dict get $signal_to_loads par_bit]
    puts "  par_bit loads: $par_loads"

    foreach load $par_loads {
        set gate_name [lindex $load 0]
        puts "\n  Testing gate: '$gate_name'"

        # Call get_gate_outputs
        set outputs [get_gate_outputs $gate_name $signal_to_drivers]
        puts "    Outputs found: $outputs"
        puts "    Number of outputs: [llength $outputs]"

        # Manual check - search drivers dictionary
        puts "    Manual search in drivers:"
        set found_manually 0
        dict for {signal driver_list} $signal_to_drivers {
            foreach driver $driver_list {
                set driver_gate [lindex $driver 0]
                if {$driver_gate eq $gate_name} {
                    puts "      -> $signal (driver: $driver)"
                    set found_manually 1
                }
            }
        }
        if {!$found_manually} {
            puts "      -> No outputs found manually either"
        }
    }
}

# Check if there are any drivers at all with correct format
puts "\n2. Sample of driver format:"
set count 0
dict for {signal driver_list} $signal_to_drivers {
    if {$count < 3} {
        puts "  $signal:"
        foreach driver $driver_list {
            puts "    driver: $driver"
            puts "    gate: '[lindex $driver 0]'"
            puts "    port: '[lindex $driver 1]'"
            puts "    type: '[lindex $driver 2]'"
        }
        incr count
    }
}
