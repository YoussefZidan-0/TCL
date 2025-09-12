#!/usr/bin/env wish

# Capacitance Calculator GUI
# Professional Tk interface for netlist path analysis and capacitance calculation

package require Tk

# Global variables
set ::netlist_file ""
set ::start_signal ""
set ::end_signal ""
set ::input_signals [list]
set ::output_signals [list]
set ::cells_caps_dict [dict create]
set ::current_result [dict create]

# Main window configuration
wm title . "Capacitance Path Calculator"
wm geometry . "900x700"
wm minsize . 800 600

# Configure main grid weights
grid rowconfigure . 0 -weight 1
grid columnconfigure . 0 -weight 1

# Create main frame with padding
frame .main -padx 10 -pady 10
grid .main -sticky nsew
grid rowconfigure .main 5 -weight 1
grid columnconfigure .main 1 -weight 1

# Title label
label .main.title -text "Digital Circuit Capacitance Path Calculator" \
    -font {Arial 16 bold} -fg "#2c3e50"
grid .main.title -row 0 -column 0 -columnspan 3 -pady {0 20}

#=== SECTION 1: File Selection ===
labelframe .main.files -text "File Selection" -font {Arial 10 bold} -padx 10 -pady 10
grid .main.files -row 1 -column 0 -columnspan 3 -sticky ew -pady {0 10}
grid columnconfigure .main.files 1 -weight 1

# Netlist file selection
label .main.files.netlist_lbl -text "Netlist File (.v):" -anchor w
entry .main.files.netlist_entry -textvariable ::netlist_file -state readonly -bg white
button .main.files.netlist_btn -text "Browse..." -command select_netlist_file

grid .main.files.netlist_lbl -row 0 -column 0 -sticky w -padx {0 5}
grid .main.files.netlist_entry -row 0 -column 1 -sticky ew -padx {0 5}
grid .main.files.netlist_btn -row 0 -column 2 -sticky w

# Library files info
label .main.files.lib_lbl -text "Library Files:" -anchor w
label .main.files.lib_info -text "Will auto-detect all .lib files in netlist directory" \
    -fg "#7f8c8d" -anchor w
button .main.files.refresh_btn -text "Refresh Libraries" -command load_libraries

grid .main.files.lib_lbl -row 1 -column 0 -sticky w -padx {0 5} -pady {5 0}
grid .main.files.lib_info -row 1 -column 1 -sticky w -padx {0 5} -pady {5 0}
grid .main.files.refresh_btn -row 1 -column 2 -sticky w -pady {5 0}

#=== SECTION 2: Signal Selection ===
labelframe .main.signals -text "Signal Selection" -font {Arial 10 bold} -padx 10 -pady 10
grid .main.signals -row 2 -column 0 -columnspan 3 -sticky ew -pady {0 10}
grid columnconfigure .main.signals {1 3} -weight 1

# Start signal selection
label .main.signals.start_lbl -text "Start Signal:" -anchor w
ttk::combobox .main.signals.start_combo -textvariable ::start_signal -state readonly
bind .main.signals.start_combo <<ComboboxSelected>> validate_inputs

# End signal selection  
label .main.signals.end_lbl -text "End Signal:" -anchor w
ttk::combobox .main.signals.end_combo -textvariable ::end_signal -state readonly
bind .main.signals.end_combo <<ComboboxSelected>> validate_inputs

grid .main.signals.start_lbl -row 0 -column 0 -sticky w -padx {0 5}
grid .main.signals.start_combo -row 0 -column 1 -sticky ew -padx {0 20}
grid .main.signals.end_lbl -row 0 -column 2 -sticky w -padx {0 5}
grid .main.signals.end_combo -row 0 -column 3 -sticky ew

#=== SECTION 3: Action Button ===
frame .main.action
grid .main.action -row 3 -column 0 -columnspan 3 -pady 20

button .main.action.calc_btn -text "Calculate Capacitance" -font {Arial 12 bold} \
    -bg "#3498db" -fg white -padx 20 -pady 10 -state disabled \
    -command calculate_capacitance
pack .main.action.calc_btn

#=== SECTION 4: Progress Bar ===
frame .main.progress
grid .main.progress -row 4 -column 0 -columnspan 3 -sticky ew -pady {0 10}
grid columnconfigure .main.progress 0 -weight 1

ttk::progressbar .main.progress.bar -mode indeterminate
label .main.progress.status -text "Ready" -fg "#27ae60"
grid .main.progress.bar -row 0 -column 0 -sticky ew -padx {0 10}
grid .main.progress.status -row 0 -column 1 -sticky w

#=== SECTION 5: Results Display ===
labelframe .main.results -text "Analysis Results" -font {Arial 10 bold} -padx 10 -pady 10
grid .main.results -row 5 -column 0 -columnspan 3 -sticky nsew -pady {10 0}
grid rowconfigure .main.results 0 -weight 1
grid columnconfigure .main.results 0 -weight 1

# Create notebook for organized results
ttk::notebook .main.results.notebook
grid .main.results.notebook -sticky nsew

# Path Structure Tab
frame .main.results.notebook.path
.main.results.notebook add .main.results.notebook.path -text "Path Structure"

text .main.results.notebook.path.text -wrap word -yscrollcommand ".main.results.notebook.path.scroll set" \
    -font {Courier 10} -bg "#f8f9fa"
scrollbar .main.results.notebook.path.scroll -command ".main.results.notebook.path.text yview"
grid .main.results.notebook.path.text -row 0 -column 0 -sticky nsew
grid .main.results.notebook.path.scroll -row 0 -column 1 -sticky ns
grid rowconfigure .main.results.notebook.path 0 -weight 1
grid columnconfigure .main.results.notebook.path 0 -weight 1

# Gate Details Tab
frame .main.results.notebook.gates
.main.results.notebook add .main.results.notebook.gates -text "Gate Details"

# Create treeview for gate details
ttk::treeview .main.results.notebook.gates.tree -columns {type instance capacitance} \
    -show headings -yscrollcommand ".main.results.notebook.gates.scroll set"
scrollbar .main.results.notebook.gates.scroll -command ".main.results.notebook.gates.tree yview"

# Configure columns
.main.results.notebook.gates.tree heading #1 -text "Gate Type"
.main.results.notebook.gates.tree heading #2 -text "Instance Name"  
.main.results.notebook.gates.tree heading #3 -text "Capacitance (pF)"
.main.results.notebook.gates.tree column #1 -width 120
.main.results.notebook.gates.tree column #2 -width 150
.main.results.notebook.gates.tree column #3 -width 120

grid .main.results.notebook.gates.tree -row 0 -column 0 -sticky nsew
grid .main.results.notebook.gates.scroll -row 0 -column 1 -sticky ns
grid rowconfigure .main.results.notebook.gates 0 -weight 1
grid columnconfigure .main.results.notebook.gates 0 -weight 1

# Summary Tab
frame .main.results.notebook.summary  
.main.results.notebook add .main.results.notebook.summary -text "Capacitance Summary"

# Summary labels with better formatting
frame .main.results.notebook.summary.content -padx 20 -pady 20
pack .main.results.notebook.summary.content -fill both -expand 1

label .main.results.notebook.summary.content.total_lbl -text "Total Capacitance:" \
    -font {Arial 14 bold} -anchor w
label .main.results.notebook.summary.content.total_val -text "0.00 pF" \
    -font {Arial 24 bold} -fg "#e74c3c" -anchor w

label .main.results.notebook.summary.content.method_lbl -text "Calculation Method:" \
    -font {Arial 12 bold} -anchor w  
label .main.results.notebook.summary.content.method_val -text "N/A" \
    -font {Arial 12} -anchor w

label .main.results.notebook.summary.content.gates_lbl -text "Gates in Path:" \
    -font {Arial 12 bold} -anchor w
label .main.results.notebook.summary.content.gates_val -text "0" \
    -font {Arial 12} -anchor w

# Pack summary labels
foreach widget {total_lbl total_val method_lbl method_val gates_lbl gates_val} {
    pack .main.results.notebook.summary.content.$widget -anchor w -pady 2
}

#=== PROCEDURES ===

# File selection procedure
proc select_netlist_file {} {
    set file [tk_getOpenFile \
        -title "Select Netlist File" \
        -filetypes {{"Verilog Files" {.v}} {"All Files" {*}}} \
        -initialdir [pwd]]
    
    if {$file ne ""} {
        set ::netlist_file $file
        update_status "Netlist selected: [file tail $file]"
        load_libraries
        extract_signals
    }
}

# Load all .lib files from netlist directory
proc load_libraries {} {
    if {$::netlist_file eq ""} {
        return
    }
    
    set netlist_dir [file dirname $::netlist_file]
    set lib_files [glob -nocomplain -path $netlist_dir/ *.lib]
    
    if {[llength $lib_files] == 0} {
        update_status "Warning: No .lib files found in netlist directory" "warning"
        return
    }
    
    update_status "Loading libraries..." "progress"
    .main.progress.bar start
    
    # Build combined capacitance dictionary from all .lib files
    set ::cells_caps_dict [dict create]
    
    foreach lib_file $lib_files {
        if {[catch {
            source "extract_cap_new.tcl"
            set lib_caps [extract_cap $lib_file]
            dict for {cell_name cap_value} $lib_caps {
                dict set ::cells_caps_dict $cell_name $cap_value
            }
        } err]} {
            update_status "Error loading $lib_file: $err" "error"
            continue
        }
    }
    
    .main.progress.bar stop
    set lib_count [llength $lib_files]
    set cell_count [dict size $::cells_caps_dict]
    update_status "Loaded $lib_count libraries with $cell_count cell types"
    
    # Update library info display
    .main.files.lib_info configure -text "Loaded: $lib_count library files, $cell_count cell types"
}

# Extract input/output signals from netlist using extract_path.tcl engine
proc extract_signals {} {
    if {$::netlist_file eq ""} {
        return
    }
    
    update_status "Extracting signals..." "progress"
    .main.progress.bar start
    
    set ::input_signals [list]
    set ::output_signals [list]
    
    if {[catch {
        # Use the same signal extraction as extract_path.tcl
        source "extract_path.tcl"
        
        # Parse the netlist using the same engine
        set parse_result [extract_path $::netlist_file]
        set graph_info [build_signal_graph $parse_result]
        set signal_to_drivers [lindex $graph_info 0]
        set signal_to_loads [lindex $graph_info 1]
        
        # Extract actual available signals
        set driver_signals [dict keys $signal_to_drivers]
        set load_signals [dict keys $signal_to_loads]
        
        # For start signals, use signals that can be driven (have loads)
        # Filter to get meaningful input signals (primary inputs and hierarchical inputs)
        foreach sig $load_signals {
            if {[regexp {^input[AB](\[.*\])?$} $sig] || [regexp {^datapath\.|^i_\d+_\d+\.} $sig]} {
                lappend ::input_signals $sig
            }
        }
        
        # For end signals, use signals that have drivers (outputs)
        # Include both primary outputs and internal signals that can be reached
        foreach sig $driver_signals {
            if {[regexp {^(p_0\[.*\]|n_\d+|.*\.output|Sum|Carry)$} $sig] || 
                [regexp {^datapath\.|^i_\d+_\d+\.} $sig]} {
                lappend ::output_signals $sig
            }
        }
        
        # If no specific signals found, use all available
        if {[llength $::input_signals] == 0} {
            set ::input_signals [lsort [dict keys $signal_to_loads]]
        }
        if {[llength $::output_signals] == 0} {
            set ::output_signals [lsort [dict keys $signal_to_drivers]]
        }
        
    } err]} {
        .main.progress.bar stop
        update_status "Error extracting signals: $err" "error"
        return
    }
    
    .main.progress.bar stop
    
    # Update comboboxes
    .main.signals.start_combo configure -values $::input_signals
    .main.signals.end_combo configure -values $::output_signals
    
    # Clear previous selections
    set ::start_signal ""
    set ::end_signal ""
    
    update_status "Found [llength $::input_signals] inputs, [llength $::output_signals] outputs"
    validate_inputs
}

# Validate inputs and enable/disable calculate button
proc validate_inputs {} {
    set ready [expr {$::netlist_file ne "" && 
                    $::start_signal ne "" && 
                    $::end_signal ne "" && 
                    [dict size $::cells_caps_dict] > 0}]
    
    .main.action.calc_btn configure -state [expr {$ready ? "normal" : "disabled"}]
}

# Main calculation procedure
proc calculate_capacitance {} {
    update_status "Calculating capacitance path..." "progress"
    .main.progress.bar start
    
    # Clear previous results
    clear_results
    
    if {[catch {
        # Source the extract_path script
        source "extract_path.tcl"
        
        # Calculate path with capacitance
        set ::current_result [get_path_with_capacitance $::netlist_file $::start_signal $::end_signal]
        
        if {[dict get $::current_result "path_found"]} {
            display_results
            update_status "Calculation completed successfully"
        } else {
            set error_msg [dict get $::current_result "error_message"]
            update_status "No path found: $error_msg" "error"
        }
        
    } err]} {
        update_status "Calculation error: $err" "error"
        tk_messageBox -type ok -icon error -title "Calculation Error" \
            -message "An error occurred during calculation:\n\n$err"
    }
    
    .main.progress.bar stop
}

# Display calculation results
proc display_results {} {
    # Display path structure
    set path_text [dict get $::current_result "path"]
    .main.results.notebook.path.text delete 1.0 end
    .main.results.notebook.path.text insert end "Path Structure:\n"
    .main.results.notebook.path.text insert end [format_path_structure $path_text]
    
    # Display gate details in treeview
    .main.results.notebook.gates.tree delete [.main.results.notebook.gates.tree children {}]
    
    set gate_num 0
    foreach gate_detail [dict get $::current_result "gate_details"] {
        incr gate_num
        set gate_type [dict get $gate_detail "gate_type"]
        set instance [dict get $gate_detail "instance"]
        set capacitance [format "%.3f" [dict get $gate_detail "capacitance"]]
        
        .main.results.notebook.gates.tree insert {} end -values [list $gate_type $instance $capacitance]
    }
    
    # Display summary
    set total_cap [format "%.3f" [dict get $::current_result "total_capacitance"]]
    set method [dict get $::current_result "calculation_method"]
    set gate_count [llength [dict get $::current_result "gate_details"]]
    
    .main.results.notebook.summary.content.total_val configure -text "$total_cap pF"
    .main.results.notebook.summary.content.method_val configure -text $method
    .main.results.notebook.summary.content.gates_val configure -text $gate_count
    
    # Switch to summary tab
    .main.results.notebook select .main.results.notebook.summary
}

# Format path structure for display
proc format_path_structure {path} {
    set result "Raw Path: $path\n\n"
    
    # Add calculation steps if available
    if {[dict exists $::current_result "calculation_steps"]} {
        set result "${result}Calculation Steps:\n"
        set step_num 0
        foreach step [dict get $::current_result "calculation_steps"] {
            incr step_num
            set result "${result}Step $step_num: $step\n"
        }
    }
    
    return $result
}

# Clear all results displays
proc clear_results {} {
    .main.results.notebook.path.text delete 1.0 end
    .main.results.notebook.gates.tree delete [.main.results.notebook.gates.tree children {}]
    .main.results.notebook.summary.content.total_val configure -text "0.00 pF"
    .main.results.notebook.summary.content.method_val configure -text "N/A"
    .main.results.notebook.summary.content.gates_val configure -text "0"
}

# Update status message with color coding
proc update_status {message {type "normal"}} {
    .main.progress.status configure -text $message
    
    switch $type {
        "error" { .main.progress.status configure -fg "#e74c3c" }
        "warning" { .main.progress.status configure -fg "#f39c12" }
        "progress" { .main.progress.status configure -fg "#3498db" }
        default { .main.progress.status configure -fg "#27ae60" }
    }
}

# Initialize GUI
update_status "Select a netlist file to begin"

# Handle window closing
wm protocol . WM_DELETE_WINDOW {
    exit
}
