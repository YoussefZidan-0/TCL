
proc extract_cap {filename} {
    # Open the .lib file
    set fp [open $filename r]
    set caps_dict [dict create]
    set current_cell ""
    set cell_name_pattern {\s*cell\s+\((\w+)\)\s*\{}
    # Pattern for max_capacitance (with or without semicolon)
    set max_cap_pattern {\s*max_capacitance\s*:\s*([\d\.]+);?}

    # Read file line by line
    while {[gets $fp line] >= 0} {

        # Check if we're starting a new cell
        if {[regexp $cell_name_pattern $line -> cell]} {
            set current_cell $cell
            continue
        }

        # Look for max_capacitance in this line
        if {$current_cell ne "" && [regexp $max_cap_pattern $line -> value]} {
            dict set caps_dict $current_cell $value
            set current_cell ""
        }
    }

    close $fp

    # Return the dictionary directly
    return $caps_dict
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
    set caps_dict [extract_cap $filename]

    # Output the result
    if {[dict size $caps_dict] == 0} {
        puts "No capacitance values found in $filename"
        exit 1
    } else {
        puts "Capacitance values found in $filename:"
        puts "======================================="

        # Print the dictionary in a formatted way
        set output_string "{"
        dict for {cell_name max_cap} $caps_dict {
            append output_string "\"$cell_name\" $max_cap "
        }
        append output_string "}"
        puts $output_string
    }
}