# Test script to debug the main Verilog parser's state machine.

cd [file dirname [info script]]

source "extract_cap_new.tcl"
source "extract_path.tcl"

# Override extract_path with a heavily instrumented version
proc extract_path {netlist_filename {lib_files {}}} {
    puts "--- PARSER TRACE ---"
    set fp [open $netlist_filename r]
    set cells_caps_dict [dict create]
    set tsmc_lib "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"
    if {[file exists $tsmc_lib]} { dict for {k v} [extract_cap $tsmc_lib] { dict set cells_caps_dict $k $v } }
    set nangate_lib "NangateOpenCellLibrary_typical.lib"
    if {[file exists $nangate_lib]} { dict for {k v} [extract_cap $nangate_lib] { dict set cells_caps_dict $k $v } }
    set cell_types [dict keys $cells_caps_dict]
    set cell_types_pattern [join $cell_types "|"]

    set in_gate_def 0
    set multi_line_buffer ""
    set line_num 0

    while {[gets $fp line] >= 0} {
        incr line_num
        set trimmed_line [string trim $line]
        if {$trimmed_line eq ""} {continue}

        puts "\[L$line_num\] Line: $trimmed_line"
        puts "  -> State (before): in_gate_def=$in_gate_def"

        if {[regexp "^($cell_types_pattern)" $trimmed_line]} {
            puts "  -> MATCHED start of gate definition."
            set in_gate_def 1
            set multi_line_buffer $trimmed_line
        } elseif {$in_gate_def} {
            puts "  -> Appending to buffer."
            append multi_line_buffer " " $trimmed_line
        }

        if {$in_gate_def && [regexp {\);\s*$} $multi_line_buffer]} {
            puts "  -> MATCHED end of gate definition."
            puts "  -> BUFFER: $multi_line_buffer"
            set in_gate_def 0
            set multi_line_buffer ""
        }
        puts "  -> State (after): in_gate_def=$in_gate_def"
    }
    close $fp
    puts "--- END TRACE ---"
    return [list]
}

# Run the test
puts "--- Running Detailed Parser Trace ---"
extract_path "UART_TX_flattened.v"
puts "--- Test Complete ---"