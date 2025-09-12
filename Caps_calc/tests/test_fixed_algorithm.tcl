# Test script to debug the core Verilog parser in extract_path

# Change to the script's directory to resolve relative paths
cd [file dirname [info script]]

# Source all original dependencies FIRST
source "extract_cap.tcl"
source "calcu_cap.tcl"
source "extract_path.tcl" ;# This loads all original procs, including get_path_with_capacitance

# NOW, override extract_path with our debug version
proc extract_path {netlist_filename {lib_files {}}} {
    # This is a copy of the original proc with one debug print added.
    if {![file exists $netlist_filename]} { error "Netlist file '$netlist_filename' not found" }
    set fp [open $netlist_filename r]
    set output_list {}
    set cells_caps_dict [dict create]

    if {[llength $lib_files] > 0} {
        foreach lib_file $lib_files {
            if {[file exists $lib_file]} {
                set lib_dict [extract_cap $lib_file]
                dict for {cell_name max_cap} $lib_dict {
                    dict set cells_caps_dict $cell_name $max_cap
                }
            }
        }
    } else {
        if {[file exists "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"]} {
            set cells_caps_dict [extract_cap "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib"]
        }
        if {[file exists "NangateOpenCellLibrary_typical.lib"]} {
            set nangate_caps_dict [extract_cap "NangateOpenCellLibrary_typical.lib"]
            dict for {cell_name max_cap} $nangate_caps_dict {
                dict set cells_caps_dict $cell_name $max_cap
            }
        }
    }
    set cell_types [dict keys $cells_caps_dict]
    set cell_types_pattern [join $cell_types "|"]

    set current_module ""
    set module_hierarchy [dict create]
    set module_instances [list]
    set hierarchical_connections [dict create]

    set multi_line_buffer ""
    set in_gate_def 0
    set current_cell_type ""
    set current_instance_name ""
    set in_module_inst 0
    set module_inst_buffer ""
    set current_module_type ""
    set current_module_instance ""

    while {[gets $fp line] >= 0} {
        if {[regexp {^\s*module\s+(\w+)} $line -> module_name]} {
            set current_module $module_name
            dict set module_hierarchy $module_name [list]
        }

        if {[regexp {^\s*(\w+)\s+(\w+)\s*\(} $line -> module_type instance_name]} {
            if {$module_type ne "module" && ![dict exists $cells_caps_dict $module_type]} {
                lappend module_instances [dict create "module_type" $module_type "instance_name" $instance_name "parent_module" $current_module]
                set in_module_inst 1
                set current_module_type $module_type
                set current_module_instance $instance_name
                set module_inst_buffer $line
            }
        }

        if {$in_module_inst} {
            append module_inst_buffer " " [string trim $line]
            if {[regexp {\);\s*$} $module_inst_buffer]} {
                parse_hierarchical_connections $module_inst_buffer $current_module_type $current_module_instance hierarchical_connections
                set in_module_inst 0
                set module_inst_buffer ""
                set current_module_type ""
                set current_module_instance ""
            }
        }

        if {[regexp {^\s*(${cell_types_pattern})\s+(\w+)\s+\(