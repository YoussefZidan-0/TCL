#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Trace Complete Path from par_bit to TX_OUT ==="

# Parse UART and build graph
set instances [extract_path "UART_TX_flattened.v"]
set graph_info [build_signal_graph $instances]
set signal_to_drivers [lindex $graph_info 0]
set signal_to_loads [lindex $graph_info 1]

# Manually trace the path step by step
puts "1. Starting from par_bit:"

set current_signals [list "par_bit"]
set step 0
set max_steps 10

while {[llength $current_signals] > 0 && $step < $max_steps} {
    incr step
    puts "\nStep $step:"
    set next_signals [list]

    foreach signal $current_signals {
        puts "  Signal: $signal"

        # Check if this is TX_OUT
        if {$signal eq "TX_OUT"} {
            puts "    *** REACHED TX_OUT! ***"
            break
        }

        # Find gates that load this signal
        if {[dict exists $signal_to_loads $signal]} {
            set loads [dict get $signal_to_loads $signal]
            foreach load $loads {
                set gate_name [lindex $load 0]
                set port [lindex $load 1]
                puts "    -> $port of $gate_name"

                # Find outputs of this gate
                set outputs [get_gate_outputs $gate_name $signal_to_drivers]
                foreach output $outputs {
                    puts "      outputs: $output"
                    if {[lsearch $next_signals $output] == -1} {
                        lappend next_signals $output
                    }
                }
            }
        } else {
            puts "    (no loads - this is an output)"
        }
    }

    set current_signals $next_signals
    puts "  Next step will check: $current_signals"

    if {[llength $current_signals] == 0} {
        puts "  No more signals to trace - path ends here"
        break
    }
}

if {$step >= $max_steps} {
    puts "\nStopped after $max_steps steps to prevent infinite loop"
}
