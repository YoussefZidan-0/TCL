
proc extract_cap {filename} {
    # Access global pattern

    # Open the .lib file
    set fp [open $filename r]
    set caps_data [dict create]
    set module_start_1 {^\s+\/\*{5,}}
    set module_start_2 {^\s+\*{5,}\/}
    set in_module 0
    set current_cell ""
    set cell_name_pattern {\s+cell\s+\((\w+)\)\s*\{}
    # Pattern for max_capacitance (with or without semicolon)
    set max_cap_pattern {\s+max_capacitance\s*:\s*([\d\.]+);?}

    # Initialize tracking variables
    set partial_in_1 0
    set partial_in_2 0

    # Read file line by line
    while {[gets $fp line] >= 0} {
        # Check for module start patterns
        if {[regexp $module_start_1 $line]} {
            set partial_in_1 1
            set partial_in_2 0
            # If we see a new module start, the previous one ends
            if {$in_module} {
                set in_module 0
                set current_cell ""
            }
        }

        if {$partial_in_1 && [regexp $module_start_2 $line]} {
            set in_module 1
            set partial_in_1 0
        }

        # Check for cell name pattern when we're in a module
        if {$in_module && [regexp $cell_name_pattern $line -> cell]} {
            set current_cell $cell
            # Initialize entry for this cell
            dict set caps_data $current_cell [dict create]
            continue
        }

        # Process capacitance info if we have a current cell
        if {$in_module && $current_cell != ""} {
            # Check for max capacitance
            if {[regexp $max_cap_pattern $line -> value]} {
                dict set caps_data $current_cell "max_capacitance" $value
            }
        }
    }

    # Close the file
    close $fp

    # Handle the last cell in the file since there's no next module to toggle the in_module flag
    # This ensures the last module in the file is properly processed

    set output_list "{"
    dict for {cell_name cell_data} $caps_data {
        if {[dict exists $cell_data "max_capacitance"]} {
            set max_cap [dict get $cell_data "max_capacitance"]
            append output_list "\"$cell_name\" $max_cap "
        }
    }
    append output_list "}"
    # puts $output_list
    return $output_list
}




# Check if the script is being run from command line
if {[info exists argv0] && [file tail [info script]] eq [file tail $argv0]} {
    # Check if a filename was provided as an argument
    if {[llength $argv] < 1} {
        puts "Usage: tclsh [file tail $argv0] filename.lib"
        exit 1
    }

    # Get the filename from command line arguments
    set filename [lindex $argv 0]

    # Call the extract_cap procedure with the filename
    set caps_list [extract_cap $filename]

    # Output the result
    if {$caps_list eq "{}"} {
        puts "No capacitance values found in $filename"
        exit 1
    } else {
        puts "Capacitance values found in $filename:"
        puts "======================================="
        puts $caps_list
        # Format the output as a list of pairs (cell_name and capacitance)
    }
}