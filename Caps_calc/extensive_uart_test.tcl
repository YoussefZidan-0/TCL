#!/usr/bin/tclsh

# Extensive UART Path Finding Test Suite
# Tests all possible signal combinations and analyzes connectivity issues

source "extract_path.tcl"

set netlist_file "UART_TX_flattened.v"

proc extensive_uart_test {} {
    global netlist_file
    
    puts "🚀 EXTENSIVE UART PATH FINDING TEST"
    puts "=================================="
    puts "File: $netlist_file"
    puts ""
    
    # Step 1: Extract all signals using our enhanced extraction
    puts "📋 STEP 1: Signal Extraction Analysis"
    puts "------------------------------------"
    
    set signal_result [extract_verilog_signals $netlist_file]
    set verilog_inputs [lindex $signal_result 0]
    set verilog_outputs [lindex $signal_result 1] 
    set verilog_wires [lindex $signal_result 2]
    
    puts "Verilog-level signals:"
    puts "  Inputs ([llength $verilog_inputs]): [lrange $verilog_inputs 0 9]..."
    puts "  Outputs ([llength $verilog_outputs]): $verilog_outputs"
    puts "  Wires ([llength $verilog_wires]): [lrange $verilog_wires 0 19]..."
    puts ""
    
    # Step 2: Build signal graph and analyze connectivity
    puts "🔗 STEP 2: Signal Graph Analysis"
    puts "-------------------------------"
    
    set parse_result [extract_path $netlist_file]
    set graph_info [build_signal_graph $parse_result]
    set signal_to_drivers [lindex $graph_info 0]
    set signal_to_loads [lindex $graph_info 1]
    set gate_to_info [lindex $graph_info 2]
    
    set all_driver_signals [dict keys $signal_to_drivers]
    set all_load_signals [dict keys $signal_to_loads]
    
    puts "Graph connectivity:"
    puts "  Signals with drivers ([llength $all_driver_signals]): [lrange $all_driver_signals 0 9]..."
    puts "  Signals with loads ([llength $all_load_signals]): [lrange $all_load_signals 0 9]..."
    puts ""
    
    # Step 3: Test primary I/O connections
    puts "🎯 STEP 3: Primary I/O Path Testing"
    puts "----------------------------------"
    
    set primary_inputs [list "P_DATA\[0\]" "P_DATA\[1\]" "CLK" "RST" "PAR_TYP" "PAR_EN" "DATA_VALID"]
    set primary_outputs [list "TX_OUT" "Busy"]
    
    set io_test_count 0
    set io_success_count 0
    
    foreach input $primary_inputs {
        foreach output $primary_outputs {
            incr io_test_count
            puts -nonewline "Testing $input → $output: "
            flush stdout
            
            if {[catch {
                set result [get_path_with_capacitance $netlist_file $input $output]
                if {[dict get $result path_found]} {
                    puts "✅ FOUND - [format "%.3f" [dict get $result total_capacitance]] pF"
                    incr io_success_count
                } else {
                    puts "❌ NO PATH"
                }
            } err]} {
                puts "❌ ERROR: $err"
            }
        }
    }
    
    puts ""
    puts "Primary I/O Results: $io_success_count/$io_test_count paths found"
    puts ""
    
    # Step 4: Test internal signal connectivity
    puts "🔧 STEP 4: Internal Signal Path Testing"
    puts "--------------------------------------"
    
    # Test key internal signals
    set internal_signals [list \
        "ser_data" "par_bit" "MUX_unit_mux_comb" \
        "FSM_unit_current_state\[0\]" "FSM_unit_current_state\[1\]" "FSM_unit_current_state\[2\]" \
        "serializer_unit_SER_COUNTER\[0\]" "serializer_unit_SER_COUNTER\[1\]" "serializer_unit_SER_COUNTER\[2\]" \
        "n2" "n3" "n4" "ser_en" "ser_done" \
        "mux_sel\[0\]" "mux_sel\[1\]"
    ]
    
    set internal_test_count 0
    set internal_success_count 0
    
    # Test internal to primary output paths
    foreach signal $internal_signals {
        if {[dict exists $signal_to_drivers $signal]} {
            incr internal_test_count
            puts -nonewline "Testing $signal → TX_OUT: "
            flush stdout
            
            if {[catch {
                set result [get_path_with_capacitance $netlist_file $signal "TX_OUT"]
                if {[dict get $result path_found]} {
                    puts "✅ FOUND - [format "%.3f" [dict get $result total_capacitance]] pF"
                    incr internal_success_count
                } else {
                    puts "❌ NO PATH"
                }
            } err]} {
                puts "❌ ERROR: $err"
            }
        }
    }
    
    puts ""
    puts "Internal Signal Results: $internal_success_count/$internal_test_count paths found"
    puts ""
    
    # Step 5: Analyze signal connectivity patterns
    puts "📊 STEP 5: Connectivity Pattern Analysis"
    puts "---------------------------------------"
    
    analyze_signal_connectivity_patterns $signal_to_drivers $signal_to_loads
    
    # Step 6: Test specific functional unit paths
    puts "🏗️ STEP 6: Functional Unit Path Testing"
    puts "--------------------------------------"
    
    test_functional_unit_paths
    
    # Step 7: Detailed path analysis for working paths
    puts "🔍 STEP 7: Detailed Path Analysis"
    puts "--------------------------------"
    
    analyze_working_paths
    
    puts ""
    puts "✅ EXTENSIVE TEST COMPLETED"
    puts "=========================="
}

proc analyze_signal_connectivity_patterns {drivers loads} {
    puts "Signal connectivity patterns:"
    
    # Analyze primary inputs
    set primary_inputs [list "P_DATA\[0\]" "P_DATA\[1\]" "P_DATA\[2\]" "CLK" "RST" "DATA_VALID"]
    foreach sig $primary_inputs {
        if {[dict exists $loads $sig]} {
            set load_count [llength [dict get $loads $sig]]
            puts "  $sig has $load_count connections"
        } else {
            puts "  $sig has NO LOADS ❌"
        }
    }
    
    # Analyze primary outputs  
    set primary_outputs [list "TX_OUT" "Busy"]
    foreach sig $primary_outputs {
        if {[dict exists $drivers $sig]} {
            set driver_count [llength [dict get $drivers $sig]]
            puts "  $sig has $driver_count drivers"
        } else {
            puts "  $sig has NO DRIVERS ❌"
        }
    }
    
    # Find isolated signals
    set total_signals [llength [lsort -unique [concat [dict keys $drivers] [dict keys $loads]]]]
    set connected_signals [llength [dict keys $drivers]]
    puts "  Total unique signals: $total_signals"
    puts "  Signals with drivers: $connected_signals"
    puts ""
}

proc test_functional_unit_paths {} {
    global netlist_file
    
    puts "Testing functional unit connections:"
    
    # Test serializer unit paths
    puts "  Serializer Unit:"
    set serializer_tests [list \
        [list "P_DATA\[0\]" "ser_data" "Data to serializer"] \
        [list "ser_en" "serializer_unit_SER_COUNTER\[0\]" "Enable to counter"] \
        [list "serializer_unit_SER_COUNTER\[2\]" "ser_done" "Counter to done"]
    ]
    
    foreach test $serializer_tests {
        set start [lindex $test 0]
        set end [lindex $test 1] 
        set desc [lindex $test 2]
        
        puts -nonewline "    $desc ($start → $end): "
        flush stdout
        
        if {[catch {
            set path [get_path $netlist_file $start $end]
            if {$path ne ""} {
                puts "✅ FOUND"
            } else {
                puts "❌ NO PATH"
            }
        } err]} {
            puts "❌ ERROR"
        }
    }
    
    # Test FSM unit paths
    puts "  FSM Unit:"
    set fsm_tests [list \
        [list "DATA_VALID" "FSM_unit_current_state\[0\]" "Input to state"] \
        [list "ser_done" "FSM_unit_next_state\[1\]" "Done to next state"] \
        [list "FSM_unit_current_state\[1\]" "ser_en" "State to enable"]
    ]
    
    foreach test $fsm_tests {
        set start [lindex $test 0]
        set end [lindex $test 1] 
        set desc [lindex $test 2]
        
        puts -nonewline "    $desc ($start → $end): "
        flush stdout
        
        if {[catch {
            set path [get_path $netlist_file $start $end]
            if {$path ne ""} {
                puts "✅ FOUND"
            } else {
                puts "❌ NO PATH"
            }
        } err]} {
            puts "❌ ERROR"
        }
    }
    
    # Test MUX unit paths  
    puts "  MUX Unit:"
    set mux_tests [list \
        [list "ser_data" "MUX_unit_mux_comb" "Serial data to mux"] \
        [list "par_bit" "MUX_unit_mux_comb" "Parity to mux"] \
        [list "MUX_unit_mux_comb" "TX_OUT" "Mux to output"]
    ]
    
    foreach test $mux_tests {
        set start [lindex $test 0]
        set end [lindex $test 1] 
        set desc [lindex $test 2]
        
        puts -nonewline "    $desc ($start → $end): "
        flush stdout
        
        if {[catch {
            set path [get_path $netlist_file $start $end]
            if {$path ne ""} {
                puts "✅ FOUND"
            } else {
                puts "❌ NO PATH"
            }
        } err]} {
            puts "❌ ERROR"
        }
    }
    puts ""
}

proc analyze_working_paths {} {
    global netlist_file
    
    puts "Analyzing working paths in detail:"
    
    # Test some paths that should definitely work
    set definite_tests [list \
        [list "MUX_unit_mux_comb" "TX_OUT"] \
        [list "ser_data" "TX_OUT"] \
        [list "par_bit" "TX_OUT"]
    ]
    
    foreach test $definite_tests {
        set start [lindex $test 0]
        set end [lindex $test 1]
        
        puts ""
        puts "Detailed analysis: $start → $end"
        
        if {[catch {
            set result [get_path_with_capacitance $netlist_file $start $end]
            if {[dict get $result path_found]} {
                puts "  ✅ Path found!"
                puts "  Structure: [dict get $result path]"
                puts "  Capacitance: [format "%.6f" [dict get $result total_capacitance]] pF"
                puts "  Method: [dict get $result calculation_method]"
                puts "  Gates: [llength [dict get $result gate_details]]"
            } else {
                puts "  ❌ No path found"
                puts "  Error: [dict get $result error_message]"
            }
        } err]} {
            puts "  ❌ Error during analysis: $err"
        }
    }
}

# Run the extensive test
extensive_uart_test
