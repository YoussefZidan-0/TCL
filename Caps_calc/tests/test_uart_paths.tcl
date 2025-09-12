# Test script for UART pathfinding using the efficient BFS algorithm

# Ensure we are in the correct directory
cd [file dirname [info script]]

# 1. Source the existing project files
source "extract_cap_new.tcl" ;# Defines the correct extract_cap
source "calcu_cap.tcl"       ;# Defines Calculate_capacitance
source "extract_path.tcl"      ;# Defines the Verilog parser and other helpers

# 2. Define the new, efficient pathfinder and the corrected is_output_port

# CORRECTED version of is_output_port
variable output_port_cache {}
proc is_output_port {gate_type port} {
    variable output_port_cache
    if {[llength $output_port_cache] == 0} {
        # This is the original dictionary from extract_path.tcl, with the missing gate added
        set output_port_cache [dict create \
            "OAI2BB1X2M" [list "Y"] \
            "AOI22X1M" [list "Y"] \
            "HA_X1" [list "CO" "S"] "XOR2_X1" [list "Z"] "XNOR2_X1" [list "ZN"] \
            "AND2_X1" [list "ZN"] "OR2_X1" [list "ZN"] "INV_X1" [list "ZN"] \
            "AOI21_X1" [list "ZN"] "DFFRQX1M" [list "Q"] "DFFRQX2M" [list "Q"] \
            "DFFRQX4M" [list "Q"] "DFFSX2M" [list "Q" "QN"] "DFFSRHQX1M" [list "Q"] \
            "DFFRHQX8M" [list "Q"] "DFFRX1M" [list "Q" "QN"] "DFFRX2M" [list "Q" "QN"] \
            "AOI222X2M" [list "Y"] "AOI211X2M" [list "Y"] "AOI32X1M" [list "Y"] \
            "AOI33X2M" [list "Y"] "AOI21X1M" [list "Y"] "AOI21X2M" [list "Y"] \
            "OAI211X1M" [list "Y"] "OAI211X2M" [list "Y"] "OAI21X1M" [list "Y"] \
            "OAI21X2M" [list "Y"] "OAI31X2M" [list "Y"] "OAI31X4M" [list "Y"] \
            "OAI2BB1XLM" [list "Y"] "OAI2BB1X2M" [list "Y"] "OAI2BB2X1M" [list "Y"] \
            "OAI2BB2X2M" [list "Y"] "NAND2X1M" [list "Y"] "NAND2XLM" [list "Y"] \
            "NAND2X2M" [list "Y"] "NAND2BX1M" [list "Y"] "NAND2BXLM" [list "Y"] \
            "NAND3X2M" [list "Y"] "NOR2X1M" [list "Y"] "NOR2X2M" [list "Y"] \
            "NOR2X8M" [list "Y"] "NOR2X12M" [list "Y"] "NOR2BX1M" [list "Y"] \
            "NOR3X12M" [list "Y"] "CLKINVX1M" [list "Y"] "CLKINVX2M" [list "Y"] \
            "CLKINVX4M" [list "Y"] "INVX2M" [list "Y"] "INVX8M" [list "Y"] \
            "BUFX5M" [list "Y"] "BUFX10M" [list "Y"] "CLKBUFX4M" [list "Y"] \
            "CLKBUFX6M" [list "Y"] "CLKBUFX8M" [list "Y"] "AND3X2M" [list "Y"] \
            "AO22XLM" [list "Y"] "AO22X1M" [list "Y"] "AO2B2X1M" [list "Y"] \
            "AOI2BB2X2M" [list "Y"] "XOR3X1M" [list "Y"] "XOR3XLM" [list "Y"] \
            "XNOR2X1M" [list "Y"] "CLKXOR2X2M" [list "Y"] "CLKXOR2X1M" [list "Y"] \
            "OAI2B2X1M" [list "Y"] "MUX2X1M" [list "Y"] "MUX2X2M" [list "Y"] \
            "TBUF_X1" [list "Y"] "TBUF_X2" [list "Y"] "TBUF_X4" [list "Y"] \
            "TBUF_X8" [list "Y"] "DLL_X1" [list "Q"] "DLL_X2" [list "Q"] \
            "DLH_X1" [list "Q"] "DLH_X2" [list "Q"] "FA_X1" [list "CO" "S"]]
    }
    return [expr {[dict exists $output_port_cache $gate_type] && $port in [dict get $output_port_cache $gate_type]}]
}

proc find_path_bfs {start_signal end_signal drivers loads hierarchy} {

    puts "\n--- BFS TRACE ---"
    set queue [list $start_signal]
    set visited [dict create $start_signal 1]
    set parent [dict create]
    set count 0
    while {[llength $queue] > 0 && [incr count] < 50} {
        set current_signal [lindex $queue 0]
        set queue [lrange $queue 1 end]
        puts "\[[format %02d $count]\\] Dequeue: '$current_signal'"

        if {$current_signal eq $end_signal} {
            puts "  -> Found end signal!"
            return [reconstruct_path $parent $end_signal] 
        }

        if {[dict exists $loads $current_signal]} {
            puts "  -> Loads: [dict get $loads $current_signal]"
            foreach gate_info [dict get $loads $current_signal] {
                set gate_name [lindex $gate_info 0]
                set output_signals [get_gate_outputs $gate_name $drivers]
                puts "    -> Gate '$gate_name' drives: $output_signals"
                foreach output_signal $output_signals {
                    if {![dict exists $visited $output_signal]} {
                        puts "      -> Enqueue: '$output_signal'"
                        dict set visited $output_signal 1
                        dict set parent $output_signal [list $current_signal $gate_info]
                        lappend queue $output_signal
                    }
                }
            }
        } else {
            puts "  -> No loads found."
        }
    }
    puts "--- BFS END ---"
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

# 3. Define a top-level procedure to run the analysis
proc run_efficient_path_analysis {netlist start end} {
    # Use the original parser from extract_path.tcl
    set parse_result [extract_path $netlist]
    # Use the original graph builder from extract_path.tcl
    lassign [build_signal_graph $parse_result] drivers loads _ hierarchy

    # --- DEBUG THE GRAPH STRUCTURE ---
    puts "--- GRAPH DEBUG ---"
    foreach signal [dict keys $loads] {
        if {[string match {*P_DATA*} $signal] || [string match {*ser_data*} $signal] || [string match {*TX_OUT*} $signal]} {
            puts "LOADS for '$signal': [dict get $loads $signal]"
        }
    }
    foreach signal [dict keys $drivers] {
        if {[string match {*P_DATA*} $signal] || [string match {*ser_data*} $signal] || [string match {*TX_OUT*} $signal]} {
            puts "DRIVERS for '$signal': [dict get $drivers $signal]"
        }
    }
    puts "--- END GRAPH DEBUG ---"

    # Use the NEW efficient pathfinder
    set path [find_path_bfs $start $end $drivers $loads $hierarchy]
    return $path
}

# 4. Execute the test case
set netlist "UART_TX_flattened.v"
set start_signal {P_DATA[0]}
set end_signal {TX_OUT}

puts "--- Running UART Path Test ---"
set path [run_efficient_path_analysis $netlist $start_signal $end_signal]

if {[llength $path] > 0} {
    puts "SUCCESS! Path found:"
    set i 0
    foreach element $path {
        puts "  [incr i]. $element"
    }
} else {
    puts "FAILURE: No path found."
}
puts "--- Test Complete ---"