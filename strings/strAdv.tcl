#! /mingw64/bin/tclsh

set statement "    _Fan is a student_    "
set statement2 "    Alan is a student    "
set statement [string trim $statement]
set statement [string trim $statement _]
puts [string trimleft $statement _]
puts [string trimright $statement _]
puts [string compare $statement $statement2]
puts [string tolower $statement]
puts [string toupper $statement]
puts [string wordend $statement 1]
puts [string wordstart $statement 1]

puts [string match "*student" $statement] ; 


