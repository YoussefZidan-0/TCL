#!/usr/bin/tclsh

source "extract_path.tcl"

# Debug version of calculate_path_capacitance to see what's happening
proc debug_calculate_path_capacitance {path gate_to_info cells_caps_dict} {
    # Extract capacitances and gate details
    set cap_result [extract_path_capacitances $path $gate_to_info $cells_caps_dict]
    set all_capacitances [lindex $cap_result 0]
    set gate_details [lindex $cap_result 1]

    puts "DEBUG: All capacitances: $all_capacitances"
    puts "DEBUG: Number of capacitances: [llength $all_capacitances]"

    if {[llength $all_capacitances] == 0} {
        return [dict create \
            "total_capacitance" 0 \
            "individual_capacitances" [list] \
            "gate_details" $gate_details \
            "calculation_method" "No gates found" \
            "structures" [list]]
    }

    # Analyze path structure to determine calculation method
    set structures [analyze_path_structure $path]
    puts "DEBUG: Number of structures: [llength $structures]"

    # For complex paths with parallel sections, we need to calculate step by step
    if {[llength $structures] > 1} {
        puts "DEBUG: Using multiple sections branch"
        # Multiple sections - calculate each section and combine in series
        set section_results [list]
        set cap_index 0

        foreach structure $structures {
            set struct_type [dict get $structure "type"]
            set struct_content [dict get $structure "content"]
            puts "DEBUG: Processing structure type '$struct_type' with content: $struct_content"

            # Count gates in this section to get correct capacitance values
            set section_caps [list]
            set gates_in_section [count_gates_in_element $struct_content]
            puts "DEBUG: Gates in section: $gates_in_section"

            for {set i 0} {$i < $gates_in_section} {incr i} {
                if {$cap_index < [llength $all_capacitances]} {
                    set cap_val [lindex $all_capacitances $cap_index]
                    lappend section_caps $cap_val
                    puts "DEBUG: Adding capacitance $cap_val to section (index $cap_index)"
                    incr cap_index
                }
            }

            puts "DEBUG: Section capacitances: $section_caps"

            if {[llength $section_caps] > 0} {
                if {$struct_type eq "parallel"} {
                    set section_total [Calculate_capacitance $section_caps 1]
                    puts "DEBUG: Parallel calculation: $section_caps -> $section_total"
                } else {
                    set section_total [Calculate_capacitance $section_caps 0]
                    puts "DEBUG: Series calculation: $section_caps -> $section_total"
                }
                lappend section_results $section_total
            }
        }

        puts "DEBUG: Section results: $section_results"

        # Combine all sections in series (different sections are always in series)
        if {[llength $section_results] > 1} {
            set total_cap [Calculate_capacitance $section_results 0]
            set calculation_method "Mixed: Parallel sections combined in series"
            puts "DEBUG: Final series combination: $section_results -> $total_cap"
        } elseif {[llength $section_results] == 1} {
            set total_cap [lindex $section_results 0]
            set calculation_method "Single section"
        } else {
            set total_cap 0
            set calculation_method "No valid sections"
        }
    } else {
        puts "DEBUG: Using simple path branch"
        # Simple path - all gates in series or all in parallel
        if {[llength $structures] == 1} {
            set struct_type [dict get [lindex $structures 0] "type"]
            if {$struct_type eq "parallel"} {
                set total_cap [Calculate_capacitance $all_capacitances 1]
                set calculation_method "Parallel"
            } else {
                set total_cap [Calculate_capacitance $all_capacitances 0]
                set calculation_method "Series"
            }
        } else {
            # Default to series for simple paths
            set total_cap [Calculate_capacitance $all_capacitances 0]
            set calculation_method "Series (default)"
        }
    }

    puts "DEBUG: Final result - Total: $total_cap, Method: $calculation_method"

    return [dict create \
        "total_capacitance" $total_cap \
        "individual_capacitances" $all_capacitances \
        "gate_details" $gate_details \
        "calculation_method" $calculation_method \
        "structures" $structures]
}

# Test with the parallel circuit
if {[file exists "demo_parallel.syn.v"]} {
    puts "Testing debug calculation..."
    set parse_result [extract_path "demo_parallel.syn.v"]
    set graph_info [build_signal_graph $parse_result]
    set signal_to_drivers [lindex $graph_info 0]
    set signal_to_loads [lindex $graph_info 1]
    set gate_to_info [lindex $graph_info 2]
    set hierarchical_connections [lindex $graph_info 3]

    set path [find_path_hierarchical "A" "K" $signal_to_drivers $signal_to_loads $hierarchical_connections]
    puts "Path: $path"

    set cells_caps_dict [extract_cap "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"]

    set result [debug_calculate_path_capacitance $path $gate_to_info $cells_caps_dict]
}
