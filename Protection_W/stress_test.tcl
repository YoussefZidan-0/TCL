#!/usr/bin/env tclsh

# Source the implementation file
source main_fixed.tcl

puts "\n===== COMPREHENSIVE STRESS TEST =====\n"

# Save the original records_by_id
set original_records_by_id $records_by_id

# Function to run test with specific input file and display results
proc run_test {input_file output_file} {
    global records_by_id

    # Clear old data
    set records_by_id {}
    set all_records {}

    # Read the test input file
    set input_file [open $input_file r]
    puts "Reading test input from: $input_file"

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

    # Create output file for test
    set output [open $output_file w]
    close $output

    # Run the calculation
    puts "\nTesting calculation with the input file..."
    set start_time [clock milliseconds]

    # Calculate protection widths
    set protection_widths [calc_prot_width $records_by_id]

    # Create output file
    set output_file_handle [open $output_file w]

    # Process and write results
    dict for {line_id intersections} $protection_widths {
        set final_width [process_line_widths $records_by_id $line_id $intersections]

        # Format and write to file
        set line "$line_id line : $final_width"
        puts $output_file_handle $line

        # Also print to console
        puts $line
    }

    close $output_file_handle

    set end_time [clock milliseconds]
    set elapsed [expr {$end_time - $start_time}]

    # Show results
    puts "\nTest completed in $elapsed ms"
    puts "Results written to: $output_file"

    # Print the results
    puts "\n=== Protection Width Results ==="
    if {[file exists $output_file]} {
        set result_file [open $output_file r]
        while {[gets $result_file line] >= 0} {
            puts $line
        }
        close $result_file
    } else {
        puts "Error: Output file not found!"
    }
}

# Run the test
run_test "test_input.txt" "test_output.txt"

# Analyze the results for issues
proc analyze_results {output_file} {
    puts "\n=== Analysis ==="

    if {![file exists $output_file]} {
        puts "Error: Cannot analyze results, output file not found!"
        return
    }

    set results {}
    set result_file [open $output_file r]
    while {[gets $result_file line] >= 0} {
        if {[regexp {([0-9]+)\s+line\s+:\s+([0-9.]+)} $line -> id value]} {
            dict set results $id $value
            puts "Found result: Line ID $id = $value"
        }
    }
    close $result_file

    # Analyze specific cases
    puts "Case 1 (only crosses): [dict exists $results 100]"
    puts "Case 2 (mixed): [dict exists $results 101]"
    puts "Case 3 (direct only): [dict exists $results 102]"
    puts "Case 4 (equal via cross): [dict exists $results 103]"
    puts "Case 5 (single cross): [dict exists $results 104]"
    puts "Case 6 (vside dominant): [dict exists $results 105]"
    puts "Case 7 (complex mix): [dict exists $results 106]"
    puts "Case 8 (extreme values): [dict exists $results 107]"
    puts "Case 9 (missing refs): [dict exists $results 108]"
    puts "Case 10 (empty): [dict exists $results 109]"

    puts "\nTotal results: [dict size $results]"
    if {[dict size $results] != 12} {
        puts "Warning: Expected 12 results but got [dict size $results]"
    }

    # Check for specific values
    set case5_id 104
    if {[dict exists $results $case5_id]} {
        set case5_value [dict get $results $case5_id]
        # For case 5, we expect 1.0 + 2.0 + min(1.0, 2.0) = 4.0
        if {$case5_value != 4.0} {
            puts "Warning: Case 5 should be 4.0 but got $case5_value"
        } else {
            puts "Case 5 test passed!"
        }
    }

    set case6_id 105
    if {[dict exists $results $case6_id]} {
        set case6_value [dict get $results $case6_id]
        # For case 6, we have more vsides, total length should be 10.0
        # Two hsides (3.0 + 2.0 = 5.0) and three vsides (1.0 + 1.5 + 2.5 = 5.0)
        # Since vside is dominant, it might add some cross value
        puts "Case 6 value: $case6_value (expected around 10.0)"
    }
}

# Analyze the test results
analyze_results "test_output.txt"

# Restore original data
set records_by_id $original_records_by_id
