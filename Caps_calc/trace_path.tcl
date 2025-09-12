#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Manual Path Tracing ==="

# Parse UART
set instances [extract_path "UART_TX_flattened.v"]
set graph_info [build_signal_graph $instances]
set signal_to_drivers [lindex $graph_info 0]
set signal_to_loads [lindex $graph_info 1]

# Trace path manually
puts "1. par_bit loads:"
if {[dict exists $signal_to_loads "par_bit"]} {
    set par_loads [dict get $signal_to_loads "par_bit"]
    foreach load $par_loads {
        puts "  -> [lindex $load 0] ([lindex $load 1]) [lindex $load 2]"
    }
}

puts "\n2. TX_OUT driver:"
if {[dict exists $signal_to_drivers "TX_OUT"]} {
    set tx_driver [dict get $signal_to_drivers "TX_OUT"]
    puts "  <- [lindex $tx_driver 0] ([lindex $tx_driver 1]) [lindex $tx_driver 2]"
}

puts "\n3. MUX_unit_mux_comb (MUX output that drives TX_OUT):"
if {[dict exists $signal_to_drivers "MUX_unit_mux_comb"]} {
    set mux_driver [dict get $signal_to_drivers "MUX_unit_mux_comb"]
    puts "  MUX_unit_mux_comb driver: $mux_driver"
}

if {[dict exists $signal_to_loads "MUX_unit_mux_comb"]} {
    set mux_loads [dict get $signal_to_loads "MUX_unit_mux_comb"]
    puts "  MUX_unit_mux_comb loads: $mux_loads"
}

# Check what loads par_bit connects to - these might connect to MUX inputs
puts "\n4. Checking par_bit load connections:"
if {[dict exists $signal_to_loads "par_bit"]} {
    set par_loads [dict get $signal_to_loads "par_bit"]
    foreach load $par_loads {
        set gate_name [lindex $load 0]
        puts "  Gate $gate_name:"

        # Find outputs of this gate
        set found_output 0
        dict for {signal drivers} $signal_to_drivers {
            if {[llength $drivers] >= 3} {
                set driver_gate [lindex $drivers 0]
                if {$driver_gate eq $gate_name} {
                    puts "    -> output: $signal"
                    set found_output 1
                }
            }
        }
        if {!$found_output} {
            puts "    -> No outputs found for $gate_name"
        }
    }
}

# Check if MUX_unit_mux_comb has a driver
puts "\n5. MUX_unit_mux_comb driver:"
if {[dict exists $signal_to_drivers "MUX_unit_mux_comb"]} {
    puts "  Driver: [dict get $signal_to_drivers MUX_unit_mux_comb]"
} else {
    puts "  No driver found for MUX_unit_mux_comb"
}
