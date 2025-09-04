#!/usr/bin/tclsh

# ============================================================================
# TCL LISTS EDUCATIONAL EXAMPLES
# ============================================================================
# This file demonstrates various ways to work with lists in TCL

puts "=== TCL Lists Tutorial ==="
puts ""

# ============================================================================
# 1. CREATING LISTS
# ============================================================================
puts "1. Different ways to create lists:"
puts "--------------------------------"

# Method 1: Using the 'list' command (recommended)
# The 'list' command properly handles spaces and special characters
set mylist [list 1 2 3 4 5]
puts "Using \[list\]: $mylist"

# Method 2: Direct string assignment (be careful with spaces!)
# When using quotes, multiple spaces are preserved as-is
set mylist "a  b  c  d  e"
puts "Direct string: \"$mylist\""

# Method 3: Using split to create lists from strings
# Split breaks a string into list elements using a delimiter
set mylist [split "A_B_C_D_E" _]
puts "Using split: $mylist"

# Method 4: Empty list
set empty_list {}
puts "Empty list: $empty_list"

# Method 5: List with mixed data types
set mixed_list [list "hello" 42 3.14 "world"]
puts "Mixed types: $mixed_list"

puts ""

# ============================================================================
# 2. UTILITY PROCEDURE FOR ANALYSIS
# ============================================================================
# This procedure helps us understand the difference between list length and string length
proc prinstat {description list_var} {
    puts -nonewline "$description"
    puts "\t -> List: $list_var"
    puts "\t    List length: [llength $list_var] elements"
    puts "\t    String length: [string length $list_var] characters"
    # STRING LENGTH returns the full length of the string representation with spaces
    puts ""
}

# ============================================================================
# 3. ANALYZING DIFFERENT LIST REPRESENTATIONS
# ============================================================================
puts "2. List vs String analysis:"
puts "---------------------------"

prinstat "Original split result:" $mylist

# Let's create a list with extra spaces to show the difference
set spaced_list [list 1    2       3 4 5]
prinstat "List with extra spaces in creation:" $spaced_list

# Compare with string that has multiple spaces
set spaced_string "1    2       3 4 5"
prinstat "String with multiple spaces:" $spaced_string

# ============================================================================
# 4. LIST MANIPULATION OPERATIONS
# ============================================================================
puts "3. List manipulation operations:"
puts "--------------------------------"

# Create a sample list for demonstrations
set demo_list [list apple banana cherry date elderberry]
puts "Demo list: $demo_list"
puts ""

# LAPPEND - Add elements to the end of a list
set fruits $demo_list
lappend fruits fig grape
puts "After lappend fig grape: $fruits"
# TO APPEND TWO LISTS use lappend list1 {*}$list2

# LINSERT - Insert elements at specific positions
set fruits2 [linsert $demo_list 2 coconut]
puts "Insert 'coconut' at position 2: $fruits2"
# HERE linsert took the list as $demo_list
# so it returns a copy of the new list with the required change

# LINDEX - Get element at specific index (0-based)
puts "Element at index 0: [lindex $demo_list 0]"
puts "Element at index 2: [lindex $demo_list 2]"
puts "Element at index -1 (last): [lindex $demo_list end]"

# LRANGE - Get a range of elements
puts "Elements 1-3: [lrange $demo_list 1 3]"
puts "Elements from 2 to end: [lrange $demo_list 2 end]"

# LREPLACE - Replace elements in a list
set modified [lreplace $demo_list 1 2 orange pear]
# if set modified [lreplace $demo_list 1 2 "orange pear"] this would make {orange pear}

puts "Replace elements 1-2 with orange,pear: $modified"

# LSEARCH - Find element in list
set position [lsearch $demo_list cherry]
# Search by pattern too
puts "Position of 'cherry': $position"

# LSORT - Sort a list
set sorted [lsort --ascii $demo_list]
puts "Sorted list: $sorted"

# LLENGTH - Get list length (we've seen this already)
puts "List length: [llength $demo_list]"

puts ""

# ============================================================================
# 5. NESTED LISTS (LISTS OF LISTS)
# ============================================================================
puts "4. Nested lists:"
puts "----------------"

# Create a list of lists (2D structure)
set matrix [list [list 1 2 3] [list 4 5 6] [list 7 8 9]]
puts "Matrix (list of lists): $matrix"
# Index of String

set s1 "Hello World"
set s2 "o"
puts "First occurrence of $s2 in s1"
puts [string first $s2 $s1]
puts "Character at index 0 in s1"
puts [string index $s1 0]
puts "Last occurrence of $s2 in s1"
puts [string last $s2 $s1]
puts "Word end index in s1"
puts [string wordend $s1 20]
puts "Word start index in s1"
puts [string wordstart $s1 20]

# When the above code is compiled and executed, it produces the following result −

# First occurrence of o in s1
# 4
# Character at index 0 in s1
# H
# Last occurrence of o in s1
# 7
# Word end index in s1
# 11
# Word start index in s1
# 6

# Access nested elements
puts "First row: [lindex $matrix 0]"
puts "Element at row 1, column 2: [lindex [lindex $matrix 1] 2]"
puts "Or more directly: [lindex $matrix 1 2]"

# Student records example
set students [list \
    [list "John" "Doe" 85 92 78] \
    [list "Jane" "Smith" 90 88 95] \
    [list "Bob" "Johnson" 78 85 82]]

puts ""
puts "Student records:"
foreach student $students {
    set first [lindex $student 0]
    set last [lindex $student 1]
    set grades [lrange $student 2 end]
    puts "Student: $first $last, Grades: $grades"
}

puts ""

# ============================================================================
# 6. SPECIAL CHARACTERS AND QUOTING
# ============================================================================
puts "5. Special characters in lists:"
puts "-------------------------------"

# Lists handle special characters automatically
set special_list [list "hello world" {multiple words} \$variable \{braces\}]
puts "List with special chars: $special_list"
puts "Length: [llength $special_list] elements"

# Each element as shown by foreach
puts "Individual elements:"
set counter 0
foreach element $special_list {
    puts "  Element $counter: '$element'"
    incr counter
}

puts ""

# ============================================================================
# 7. LIST vs STRING OPERATIONS COMPARISON
# ============================================================================
puts "6. List vs String operations:"
puts "-----------------------------"

set test_data "one two three four five"
puts "Original data: '$test_data'"

# Treat as string
set as_string $test_data
puts "As string - length: [string length $as_string] chars"
puts "String words using split: [split $as_string]"

# Treat as list
set as_list $test_data
puts "As list - length: [llength $as_list] elements"
puts "List elements: $as_list"

# Show the difference with data containing multiple spaces
set spaced_data "one  two   three    four"
puts ""
puts "Data with multiple spaces: '$spaced_data'"
puts "Split as string: [split $spaced_data]"
puts "Treated as list: $spaced_data ([llength $spaced_data] elements)"

puts ""

# ============================================================================
# 8. PRACTICAL EXAMPLES
# ============================================================================
puts "7. Practical examples:"
puts "----------------------"

# Example 1: Processing command line arguments
proc process_args {args} {
    puts "Received [llength $args] arguments:"
    set i 1
    foreach arg $args {
        puts "  Arg $i: $arg"
        incr i
    }
}

puts "Simulating command line processing:"
process_args hello world "quoted string" 123

# Example 2: Simple statistics
proc calculate_average {numbers} {
    if {[llength $numbers] == 0} {
        return 0
    }
    set sum 0
    foreach num $numbers {
        set sum [expr {$sum + $num}]
    }
    return [expr {double($sum) / [llength $numbers]}]
}

set grades [list 85 92 78 90 88]
puts ""
puts "Grades: $grades"
puts "Average: [calculate_average $grades]"

# Example 3: List filtering
proc filter_even {numbers} {
    set result {}
    foreach num $numbers {
        if {$num % 2 == 0} {
            lappend result $num
        }
    }
    return $result
}

set numbers [list 1 2 3 4 5 6 7 8 9 10]
puts ""
puts "Numbers: $numbers"
puts "Even numbers: [filter_even $numbers]"

puts ""
puts "=== End of TCL Lists Tutorial ==="