
proc new_name {base_name {suffix ""}} {
    # Check if base_name already follows our pattern (n<number>_<name>)
    if {[regexp -nocase {^n(\d+)_(\w+)$} $base_name full_match counter original_base]} {
        # Extract the counter and increment it
        set prefix_counter [expr {$counter + 1}]
        set base_name $original_base
    } else {
        # Start with counter 0 for new base names
        set prefix_counter 0
    }

    # Create the new name with proper format
    set prefix "n${prefix_counter}"

    # Add suffix if it exists
    if {$suffix ne ""} {
        set new_name "${prefix}_${base_name}_${suffix}"
    } else {
        set new_name "${prefix}_${base_name}"
    }

    return $new_name
}

# === Test Section ===
# Uncomment the following section to run tests

# if {[info exists argv0] && [file tail [info script]] eq [file tail $argv0]} {
#     puts "=== Testing new_name function ==="

#     # Test 1: Simple base name without suffix
#     puts "Test 1: Simple base name without suffix"
#     puts "Result: [new_name "widget"]"
#     puts "Expected: n0_widget"

#     # Test 2: Base name with suffix
#     puts "\nTest 2: Base name with suffix"
#     puts "Result: [new_name "widget" "button"]"
#     puts "Expected: n0_widget_button"

#     # Test 3: Base name that already has our pattern
#     puts "\nTest 3: Base name that already has our pattern"
#     set name1 [new_name "widget"]
#     puts "First generated name: $name1"
#     puts "Second generated name: [new_name $name1]"
#     puts "Expected second name: n1_widget"

#     # Test 4: Base name with higher counter
#     puts "\nTest 4: Base name with higher counter"
#     puts "Original: n99_widget"
#     puts "Result: [new_name "n99_widget"]"
#     puts "Expected: n100_widget"

#     # Test 5: Base name with suffix where both already exist
#     puts "\nTest 5: Base name with suffix where both already exist"
#     set name2 [new_name "widget" "panel"]
#     puts "First generated name: $name2"
#     puts "Second generated name: [new_name $name2]"
#     puts "Expected second name: n1_widget_panel"

#     puts "my test"
#     set name3 [new_name "Youssef" "Samir"]
#     puts "first name: $name3"
#     set name3 [new_name $name3]
#     puts "second name:  $name3"
#     set name3 [new_name $name3]
#     puts "third name: $name3"
#     puts "edited suffix name: [new_name "Youssef" "Samer"]"
#     puts "hacked name :-) : [new_name "n1352002_Youssef_Samir"]"

# }





