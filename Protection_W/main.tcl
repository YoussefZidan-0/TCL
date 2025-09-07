
# Function to parse a line and create a record dictionary
proc parse_line {line} {
    # Extract the ID and type part, and the data part
    if {![regexp {([0-9]+)\s+([a-z]+)\s*:\s*(.*)} $line -> id type data_str]} {
        puts "Error parsing line: $line"
        return {}
    }

    # Process data part - split by commas and trim
    set data_list {}
    foreach item [split $data_str ","] {
        lappend data_list [string trim $item]
    }

    # Create and return the dictionary
    return [dict create \
        id $id \
        type $type \
        data $data_list \
    ]
}

# Create a list to store all records and a dictionary for indexed access by ID
set all_records {}
set records_by_id {}

# Read the input file
set input_file [open "input.txt" r]
while {[gets $input_file line] >= 0} {
    set record [parse_line $line]
    if {[dict size $record] > 0} {
        # Add to the sequential list
        lappend all_records $record

        # Add to the indexed dictionary using ID as key
        dict set records_by_id [dict get $record id] $record
    }
}
close $input_file

# # Display all records for verification
# puts "All Records:"
# set record_count 0
# foreach record $all_records {
#     incr record_count
#     puts "\nRecord $record_count:"
#     puts "  ID: [dict get $record id]"
#     puts "  Type: [dict get $record type]"
#     puts "  Data elements: [dict get $record data]"

#     # Demonstrate access to individual data elements
#     puts "  Individual data elements:"
#     foreach item [dict get $record data] {
#         puts "    $item"
#     }
# }

# # Example: Access a record by ID
# puts "\nDemonstrating access by ID:"
# set example_id 12

# # Check if a record with the given ID exists
# if {[dict exists $records_by_id $example_id]} {
#     set record [dict get $records_by_id $example_id]
#     puts "Found record with ID $example_id:"
#     puts "  Type: [dict get $record type]"
#     puts "  Data: [dict get $record data]"

#     # Access specific data elements
#     set data_elements [dict get $record data]
#     puts "  First data element: [lindex $data_elements 0]"
#     puts "  Number of data elements: [llength $data_elements]"
# } else {
#     puts "Record with ID $example_id not found"
# }


proc calc_prot_width {records_dict} {
    set protection_widths {}

    # First process all line types
    dict for {id record} $records_dict {
        if {[dict get $record type] eq "line"} {
            set data_list [dict get $record data]
            set intersections {}

            # For each intersection point in this line
            foreach intersection_id $data_list {
                # Skip if intersection ID doesn't exist
                if {![dict exists $records_dict $intersection_id]} {
                    puts "Warning: Intersection ID $intersection_id not found"
                    continue
                }

                # Get the width information for this intersection
                set width [return_length $records_dict $intersection_id]
                lappend intersections "$intersection_id:$width"
            }

            # Add this line and its protection widths to the result
            dict set protection_widths $id $intersections
        }
    }

    return $protection_widths
}


proc return_length {records_dict id} {
    # Get the record with the specified ID
    if {![dict exists $records_dict $id]} {
        return "Error: ID $id not found"
    }

    set record [dict get $records_dict $id]
    set type [dict get $record type]
    set data_list [dict get $record data]

    if {$type == "cross"} {
        # For cross type, we need to look up the referenced IDs
        set id1 [lindex $data_list 0]
        set id2 [lindex $data_list 1]

        # Look up record for first ID
        if {![dict exists $records_dict $id1] || ![dict exists $records_dict $id2]} {
            return "Error: Referenced ID not found"
        }

        set record1 [dict get $records_dict $id1]
        set record2 [dict get $records_dict $id2]
        set type1 [dict get $record1 type]
        set type2 [dict get $record2 type]

        # Determine which is hside and which is vside
        if {$type1 == "hside" && $type2 == "vside"} {
            set h_val [lindex [dict get $record1 data] 0]
            set v_val [lindex [dict get $record2 data] 0]
        } elseif {$type1 == "vside" && $type2 == "hside"} {
            set v_val [lindex [dict get $record1 data] 0]
            set h_val [lindex [dict get $record2 data] 0]
        } else {
            return "Error: Cross must reference one hside and one vside"
        }

        return "${h_val}_c_h,${v_val}_c_v"
    } elseif {$type == "hside"} {
        # For hside, simply return the first data value
        set h_val [lindex $data_list 0]
        return "${h_val}_h"
    } elseif {$type == "vside"} {
        # For vside, simply return the first data value
        set v_val [lindex $data_list 0]
        return "${v_val}_v"
    } else {
        return "Error: Unknown type: $type"
    }
}

# Examples to test the procedures

# Uncomment to test individual length calculations
# puts "\nDemonstrating the return_length procedure:"
# set cross_id 34
# puts "Length for ID $cross_id: [return_length $records_by_id $cross_id]"
# set hside_id 2
# puts "Length for ID $hside_id: [return_length $records_by_id $hside_id]"
# set vside_id 6
# puts "Length for ID $vside_id: [return_length $records_by_id $vside_id]"
proc process_line_widths {records_dict line_id intersections} {
    # Count hside and vside elements
    set hside_count 0
    set vside_count 0
    set hside_length 0
    set vside_length 0
    set cross_min_value 999999

    foreach intersection $intersections {
        # Split the intersection ID and width information
        set parts [split $intersection ":"]
        set id [lindex $parts 0]
        set width_info [lindex $parts 1]

        # Check if width_info contains _c_h or _c_v (cross type)
        if {[string match "*_c_h,*_c_v" $width_info]} {
            # This is a cross type - extract the values
            set width_parts [split $width_info ","]

            set h_part [lindex $width_parts 0]
            set v_part [lindex $width_parts 1]

            set h_value [string trimright $h_part "_c_h"]
            set v_value [string trimright $v_part "_c_v"]

            # Track the minimum of these values for later
            if {$h_value < $cross_min_value} {
                set cross_min_value $h_value
            }
            if {$v_value < $cross_min_value} {
                set cross_min_value $v_value
            }
        } elseif {[string match "*_h" $width_info]} {
            # This is an hside
            incr hside_count
            set h_value [string trimright $width_info "_h"]
            set hside_length [expr {$hside_length + $h_value}]
        } elseif {[string match "*_v" $width_info]} {
            # This is a vside
            incr vside_count
            set v_value [string trimright $width_info "_v"]
            set vside_length [expr {$vside_length + $v_value}]
        }
    }

    # Calculate total base length
    set total_length [expr {$hside_length + $vside_length}]

    # Determine which type is dominant
    set dominant_flag 0
    if {$hside_count > $vside_count} {
        set dominant_flag 1
    } elseif {$vside_count > $hside_count} {
        set dominant_flag -1
    }

    # Add cross value based on dominance
    set cross_addition 0
    if {$cross_min_value != 999999} {
        if {$dominant_flag == 0} {
            # Equal counts, use minimum value
            set cross_addition $cross_min_value
        } elseif {$dominant_flag == 1} {
            # hside dominant
            foreach intersection $intersections {
                if {[string match "*_c_h,*_c_v" [lindex [split $intersection ":"] 1]]} {
                    set width_parts [split [lindex [split $intersection ":"] 1] ","]
                    set h_part [lindex $width_parts 0]
                    set h_value [string trimright $h_part "_c_h"]
                    set cross_addition $h_value
                    break
                }
            }
        } elseif {$dominant_flag == -1} {
            # vside dominant
            foreach intersection $intersections {
                if {[string match "*_c_h,*_c_v" [lindex [split $intersection ":"] 1]]} {
                    set width_parts [split [lindex [split $intersection ":"] 1] ","]
                    set v_part [lindex $width_parts 1]
                    set v_value [string trimright $v_part "_c_v"]
                    set cross_addition $v_value
                    break
                }
            }
        }
    }

    # Add cross value to total
    set final_length [expr {$total_length + $cross_addition}]

    return $final_length
}

proc main_flow {records_dict} {
    puts "\nCalculating protection widths for all lines:"
    set protection_widths [calc_prot_width $records_dict]

    # Create output file
    set output_file [open "output.txt" w]

    # Process and write results
    dict for {line_id intersections} $protection_widths {
        set final_width [process_line_widths $records_dict $line_id $intersections]

        # Format and write to file
        set line "$line_id line : $final_width"
        puts $output_file $line

        # Also print to console
        puts $line
    }

    close $output_file
    puts "\nResults written to output.txt"
}