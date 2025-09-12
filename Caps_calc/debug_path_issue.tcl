#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Debug Path Finding Issue ==="

# Parse UART and build graph
set instances [extract_path "UART_TX_flattened.v"]
set graph_info [build_signal_graph $instances]
set signal_to_drivers [lindex $graph_info 0]
set signal_to_loads [lindex $graph_info 1]

# Check both signals exist
puts "1. Signal existence check:"
puts "  par_bit drives: [dict exists $signal_to_drivers par_bit]"
puts "  TX_OUT drives: [dict exists $signal_to_drivers TX_OUT]"

# Check what drives TX_OUT
puts "\n2. TX_OUT driver chain:"
if {[dict exists $signal_to_drivers TX_OUT]} {
    set tx_driver [dict get $signal_to_drivers TX_OUT]
    puts "  TX_OUT <- $tx_driver"

    # Find what connects to TX_OUT's driver gate
    set driver_gate [lindex $tx_driver 0]
    puts "  Driver gate name: '$driver_gate'"
    puts "  Inputs to $driver_gate:"

    dict for {signal loads} $signal_to_loads {
        foreach load $loads {
            set load_gate [lindex $load 0]
            if {$load_gate eq $driver_gate} {
                puts "    $signal -> [lindex $load 1] of $load_gate"
            }
        }
    }
}

# Manual path trace: Does par_bit connect to anything that eventually reaches TX_OUT?
puts "\n3. Manual path trace from par_bit:"
if {[dict exists $signal_to_loads par_bit]} {
    set par_loads [dict get $signal_to_loads par_bit]
    puts "  par_bit connects to:"

    foreach load $par_loads {
        set gate_name [lindex $load 0]
        set port [lindex $load 1]
        puts "    -> $port of $gate_name"

        # Find outputs of this gate
        dict for {signal drivers} $signal_to_drivers {
            if {[llength $drivers] >= 1 && [lindex $drivers 0] eq $gate_name} {
                puts "      $gate_name outputs: $signal"
            }
        }
    }
}

# Test the find_path algorithm step by step
puts "\n4. Testing find_path algorithm:"
puts "  Calling find_path par_bit TX_OUT..."
set debug_path [find_path "par_bit" "TX_OUT" $signal_to_drivers $signal_to_loads]
puts "  Result: '$debug_path'"
puts "  Length: [llength $debug_path]"
