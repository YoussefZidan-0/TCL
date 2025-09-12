# ===================================================================
# GUI for Verilog Path and Capacitance Analyzer
# Filename: path_analyzer_gui.tcl
# ===================================================================

package require Tk
package require Ttk

# --- Load the backend logic from the refactored script
if {[catch {source "path_analyzer_backend.tcl"} err]} {
    tk_messageBox -icon error -title "Fatal Error" \
        -message "Could not load backend logic from 'path_analyzer_backend.tcl'. Please ensure the file exists and is in the same directory.\n\nError: $err"
    exit
}

# --- Global variables to hold GUI state
namespace eval ::gui_state {
    variable netlist ""
    variable libs {}
}

##
# Creates and lays out all the GUI widgets.
#
proc create_gui {} {
    # --- Style and Main Window Setup ---
    ttk::style theme use clam
    wm title . "Verilog Path Capacitance Analyzer"
    wm minsize . 650 500

    # --- Main Content Frame ---
    ttk::frame .main -padding 10
    grid .main -row 0 -column 0 -sticky nsew
    grid rowconfigure . 0 -weight 1
    grid columnconfigure . 0 -weight 1

    # --- WIDGET DEFINITIONS ---

    # File Selection
    ttk::label .main.lbl_netlist -text "Netlist File:"
    ttk::entry .main.ent_netlist -textvariable ::gui_state::netlist -state readonly
    ttk::button .main.btn_netlist -text "Browse..." -command select_netlist

    ttk::label .main.lbl_libs -text "Library File(s):"
    ttk::entry .main.ent_libs -state readonly
    ttk::button .main.btn_libs -text "Browse..." -command select_libs

    # Signal Selection
    ttk::panedwindow .main.panes -orient horizontal

    # Input signals pane
    ttk::frame .main.f_in
    ttk::label .main.f_in.lbl -text "Start Signal (Inputs)"
    listbox .main.f_in.lb -exportselection 0 -width 30
    ttk::scrollbar .main.f_in.sb -orient vertical -command ".main.f_in.lb yview"
    .main.f_in.lb configure -yscrollcommand ".main.f_in.sb set"
    .main.panes add .main.f_in -weight 1

    # Output signals pane
    ttk::frame .main.f_out
    ttk::label .main.f_out.lbl -text "End Signal (Outputs)"
    listbox .main.f_out.lb -exportselection 0 -width 30
    ttk::scrollbar .main.f_out.sb -orient vertical -command ".main.f_out.lb yview"
    .main.f_out.lb configure -yscrollcommand ".main.f_out.sb set"
    .main.panes add .main.f_out -weight 1

    # Action Button
    ttk::button .main.btn_calc -text "Calculate Capacitance" -command run_calculation

    # Results Display
    ttk::labelframe .main.results -text "Results" -padding 10
    ttk::label .main.results.lbl_path -text "Extracted Path:"
    text .main.results.txt_path -height 4 -wrap word -state disabled -font {Courier 9}
    ttk::label .main.results.lbl_cap -text "Total Capacitance (pF):"
    ttk::entry .main.results.ent_cap -state readonly -width 20 -justify center -font {Helvetica 10 bold}

    # Status Bar
    ttk::label .main.status -text "Ready." -anchor w -relief sunken -padding 3

    # --- WIDGET LAYOUT ---

    # Row 0: Netlist
    grid .main.lbl_netlist -row 0 -column 0 -sticky w -pady 2
    grid .main.ent_netlist -row 0 -column 1 -sticky ew -padx 5
    grid .main.btn_netlist -row 0 -column 2 -sticky e

    # Row 1: Libraries
    grid .main.lbl_libs -row 1 -column 0 -sticky w -pady 2
    grid .main.ent_libs -row 1 -column 1 -sticky ew -padx 5
    grid .main.btn_libs -row 1 -column 2 -sticky e

    # Row 2: Signal Panes
    grid .main.panes -row 2 -column 0 -columnspan 3 -sticky nsew -pady 10

    grid .main.f_in.lbl  -row 0 -column 0 -columnspan 2 -sticky w
    grid .main.f_in.lb   -row 1 -column 0 -sticky nsew
    grid .main.f_in.sb   -row 1 -column 1 -sticky ns
    grid rowconfigure .main.f_in 1 -weight 1
    grid columnconfigure .main.f_in 0 -weight 1

    grid .main.f_out.lbl -row 0 -column 0 -columnspan 2 -sticky w
    grid .main.f_out.lb  -row 1 -column 0 -sticky nsew
    grid .main.f_out.sb  -row 1 -column 1 -sticky ns
    grid rowconfigure .main.f_out 1 -weight 1
    grid columnconfigure .main.f_out 0 -weight 1

    # Row 3: Calculate Button
    grid .main.btn_calc -row 3 -column 0 -columnspan 3 -pady 5

    # Row 4: Results Frame
    grid .main.results -row 4 -column 0 -columnspan 3 -sticky nsew -pady 5
    grid .main.results.lbl_path -row 0 -column 0 -sticky w
    grid .main.results.txt_path -row 1 -column 0 -sticky nsew -pady 2
    grid .main.results.lbl_cap  -row 2 -column 0 -sticky w -pady {5 0}
    grid .main.results.ent_cap  -row 3 -column 0 -sticky w -pady 2
    grid columnconfigure .main.results 0 -weight 1
    grid rowconfigure .main.results 1 -weight 1

    # Row 5: Status Bar
    grid .main.status -row 5 -column 0 -columnspan 3 -sticky ew -pady {10 0}

    # Configure resizing behavior
    grid columnconfigure .main 1 -weight 1
    grid rowconfigure .main 2 -weight 1
    grid rowconfigure .main 4 -weight 1
}

##
# Opens a file dialog to select the Verilog netlist file.
#
proc select_netlist {} {
    set types {{{Verilog Files} {.v .vh .syn.v}} {{All Files} *}}
    set file [tk_getOpenFile -title "Select Netlist File" -filetypes $types]
    if {$file ne ""} {
        set ::gui_state::netlist $file
        populate_signals_from_netlist $file
    }
}

##
# Opens a file dialog to select one or more library files.
#
proc select_libs {} {
    set types {{{Library Files} {.lib}} {{All Files} *}}
    set files [tk_getOpenFile -title "Select Library Files" -filetypes $types -multiple 1]
    if {$files ne ""} {
        set ::gui_state::libs $files
        .main.ent_libs configure -state normal
        .main.ent_libs delete 0 end
        # Display only the filenames for brevity
        .main.ent_libs insert 0 [join [lmap f $files {file tail $f}] ", "]
        .main.ent_libs configure -state readonly
    }
}

##
# Parses the selected netlist to find top-level I/O ports.
# @param filepath The path to the netlist file.
#
proc populate_signals_from_netlist {filepath} {
    set_status "Parsing netlist for I/O ports..."
    .main.f_in.lb delete 0 end
    .main.f_out.lb delete 0 end

    if {![file exists $filepath]} {
        set_status "Error: Netlist file not found."
        return
    }

    set fp [open $filepath r]
    while {[gets $fp line] >= 0} {
        # Simple regex to find input/output declarations
        if {[regexp {^\s*(input|output)\s+.*?\s*([^;,\s\(\)]+)\s*[,;]} $line -> type signal]} {
            if {$type eq "input"} {
                .main.f_in.lb insert end $signal
            } else {
                .main.f_out.lb insert end $signal
            }
        }
    }
    close $fp
    set_status "Ready. Please select library files and signals."
}

##
# Executes the main calculation logic from the backend script.
#
proc run_calculation {} {
    # --- Input Validation ---
    if {$::gui_state::netlist eq ""} {
        tk_messageBox -icon warning -title "Input Missing" -message "Please select a netlist file."
        return
    }
    if {[llength $::gui_state::libs] == 0} {
        tk_messageBox -icon warning -title "Input Missing" -message "Please select at least one library file."
        return
    }
    if {[llength [.main.f_in.lb curselection]] == 0} {
        tk_messageBox -icon warning -title "Input Missing" -message "Please select a start signal."
        return
    }
    if {[llength [.main.f_out.lb curselection]] == 0} {
        tk_messageBox -icon warning -title "Input Missing" -message "Please select an end signal."
        return
    }

    set start_signal [.main.f_in.lb get [.main.f_in.lb curselection]]
    set end_signal   [.main.f_out.lb get [.main.f_out.lb curselection]]

    set_status "Calculating path from '$start_signal' to '$end_signal'..."

    # --- Execute Backend ---
    if {[catch {
        set result [get_path_with_capacitance $::gui_state::netlist $start_signal $end_signal $::gui_state::libs]
    } err]} {
        set_status "Error during calculation."
        tk_messageBox -icon error -title "Execution Error" -message "An error occurred:\n\n$err"
        return
    }

    # --- Display Results ---
    clear_results
    if {[dict get $result path_found]} {
        set path [dict get $result path]
        set cap [format "%.4f" [dict get $result total_capacitance]]

        update_text_widget .main.results.txt_path $path

        .main.results.ent_cap configure -state normal
        .main.results.ent_cap insert 0 $cap
        .main.results.ent_cap configure -state readonly

        set_status "Calculation complete."
    } else {
        set err_msg [dict get $result error_message]
        update_text_widget .main.results.txt_path "Path not found."
        set_status "Path not found."
        tk_messageBox -icon info -title "No Path Found" -message $err_msg
    }
}

# --- GUI Helper Procs ---

proc set_status {msg} {
    .main.status configure -text $msg
    update idletasks
}

proc update_text_widget {w content} {
    $w configure -state normal
    $w delete 1.0 end
    $w insert 1.0 $content
    $w configure -state disabled
}

proc clear_results {} {
    update_text_widget .main.results.txt_path ""
    .main.results.ent_cap configure -state normal
    .main.results.ent_cap delete 0 end
    .main.results.ent_cap configure -state readonly
}


# ===================================================================
# Application Entry Point
# ===================================================================
create_gui