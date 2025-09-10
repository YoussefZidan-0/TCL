
proc extract_cap {filename} {
    # Access global pattern

    # Open the .lib file
    set fp [open $filename r]
    set caps_data [dict create]
    set module_pattern {^\s+\/\*{5,}}
    set in_module 0
    set current_cell ""
    set cell_name_pattern {\s+cell\s+\((\w+)\)\s*\{}
    set max_cap_pattern {\s+max_capacitance\s*:\s*([\d\.]+)}
    # Read file line by line
    while {[gets $fp line] >= 0} {
        # Check for module start/end pattern
        if {[regexp $module_pattern $line -> value]} {
            # Toggle the module state
            if {!$in_module} {
                set in_module 1
            } else {
                set in_module 0
                # Reset current cell when exiting a module
                set current_cell ""
            }
            continue
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

    return $caps_data
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
    set caps_data [extract_cap $filename]

    # Output the result
    if {[dict size $caps_data] == 0} {
        puts "No capacitance values found in $filename"
        exit 1
    } else {
        puts "Capacitance values found in $filename:"
        puts "======================================="

        # Format and display the capacitance values
        dict for {cell_name cell_data} $caps_data {
            puts "$cell_name:"

            if {[dict exists $cell_data "max_capacitance"]} {
                set max_cap [dict get $cell_data "max_capacitance"]
                puts "  Max Capacitance: $max_cap"
            } else {
                puts "  No max capacitance value found"
            }
            puts ""
        }
    }
}