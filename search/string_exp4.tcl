#! /c/ActiveTcl/bin/tclsh


## understand pattern

set pattern {(\w+)\s+grades\s+:([\d\s,]*)}
set statement "Ahmed grades : 12, 34, 20, 434"
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts " Complex pattern grouping "
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts [ regexp   $pattern $statement a b c d]
puts "Full Match: $a"  ;# Tcl Tutorial
puts "Sub Match1: $b"  ;# Tcl
puts "Sub Match2: $c"  ;# Tutorial
puts "Sub Match3: $d"  ;# Tutorial
# GRADES IN A STRUCTURED DICT
# Initialize the grades dictionary
array set gradesDict {}

# Process Ahmed's grades
set gradeNum 1
foreach grade [split [string trim $c] ","] {
    set grade [string trim $grade]
    set gradesDict($b,grade$gradeNum) $grade
    incr gradeNum
}

# Display the grades in a structured format
puts "-$b"
set gradeNum 1
foreach grade [split [string trim $c] ","] {
    set grade [string trim $grade]
    puts "  -- grade$gradeNum: $grade"
    incr gradeNum
}

# Example of adding another student
set anotherStudent "Sara"
set saraGrades [list 95 88 76 91]
set gradeNum 1
foreach grade $saraGrades {
    set gradesDict($anotherStudent,grade$gradeNum) $grade
    incr gradeNum
}

# Display Sara's grades
puts "-$anotherStudent"
set gradeNum 1
foreach grade $saraGrades {
    puts "  -- grade$gradeNum: $grade"
    incr gradeNum
}

puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~"

puts "Number of matches: [ regexp -all   {(\d+)[,\s]*} $c]"
puts "first: [ regexp -inline   {(\d+)[,\s]*} $c]"
puts "Flatten List of matches: [ regexp -all -inline   {(\d+)[,\s]*} $c]"
#################

puts "Indices: [ regexp  -indices  $pattern $statement a b c d]"
puts "Full Match: $a"  ;# Tcl Tutorial
puts "Sub Match1: $b"  ;# Tcl
puts "Sub Match2: $c"  ;# Tutorial
puts "Sub Match3: $d"  ;# Tutorial
###############
puts [regexp  -inline -- {\w(\w)} " inlined "]
puts [regexp -all -inline -- {\w(\w)} " inlined "]

## https://www.tcl-lang.org/man/tcl/TclCmd/re_syntax.htm
