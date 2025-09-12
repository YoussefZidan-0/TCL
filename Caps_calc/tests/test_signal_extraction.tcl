#!/usr/bin/tclsh

# Test signal extraction from demo_adderPlus.syn.v

proc extract_signals_test {netlist_file} {
    set input_signals [list]
    set output_signals [list]

    if {[catch {
        set fp [open $netlist_file r]

        # Look for module definition and primary inputs/outputs
        while {[gets $fp line] >= 0} {
            # Primary inputs
            if {[regexp {^\s*input\s+(.+);} $line -> signals]} {
                # Handle bus notation properly: [7:0]inputA -> inputA
                if {[regexp {\[[\d:]+\](\w+)} $signals -> signal_name]} {
                    lappend input_signals $signal_name
                } else {
                    # Handle simple signals without bus notation
                    set signals [string map {"," " "} $signals]
                    foreach sig [split $signals] {
                        set sig [string trim $sig]
                        if {$sig ne ""} {
                            lappend input_signals $sig
                        }
                    }
                }
            }

            # Primary outputs
            if {[regexp {^\s*output\s+(.+);} $line -> signals]} {
                # Handle bus notation properly: [7:0]Sum -> Sum
                if {[regexp {\[[\d:]+\](\w+)} $signals -> signal_name]} {
                    lappend output_signals $signal_name
                } else {
                    # Handle simple signals without bus notation
                    set signals [string map {"," " "} $signals]
                    foreach sig [split $signals] {
                        set sig [string trim $sig]
                        if {$sig ne ""} {
                            lappend output_signals $sig
                        }
                    }
                }
            }
        }

        close $fp

    } err]} {
        puts "Error reading netlist: $err"
        return [list {} {}]
    }

    return [list $input_signals $output_signals]
}

# Test with demo file
set result [extract_signals_test "demo_adderPlus.syn.v"]
set inputs [lindex $result 0]
set outputs [lindex $result 1]

puts "=== Signal Extraction Test ==="
puts "File: demo_adderPlus.syn.v"
puts ""
puts "Input Signals:"
foreach sig $inputs {
    puts "  - $sig"
}
puts ""
puts "Output Signals:"
foreach sig $outputs {
    puts "  - $sig"
}
puts ""
puts "Total: [llength $inputs] inputs, [llength $outputs] outputs"

# Also test path finding with correct signal names
if {[llength $inputs] > 0 && [llength $outputs] > 0} {
    puts ""
    puts "=== Testing Path Finding ==="

    # Try to source the extract_path script and test
    if {[catch {
        source "extract_path.tcl"

        set start_sig [lindex $inputs 0]
        set end_sig [lindex $outputs 0]

        puts "Testing path from '$start_sig' to '$end_sig'..."

        set path_result [get_path_with_capacitance "demo_adderPlus.syn.v" $start_sig $end_sig]

        if {[dict get $path_result "path_found"]} {
            puts "✅ Path found!"
            puts "Path: [dict get $path_result "path"]"
            puts "Total Capacitance: [dict get $path_result "total_capacitance"]  "
        } else {
            puts "❌ No path found"
            if {[dict exists $path_result "error_message"]} {
                puts "Error: [dict get $path_result "error_message"]"
            }
        }

    } err]} {
        puts "❌ Error testing path: $err"
    }
}
