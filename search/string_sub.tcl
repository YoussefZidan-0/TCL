#! /c/ActiveTcl/bin/tclsh

puts "~~~~~~~~~~~~~~~~~~"
puts " substitute :"
puts "~~~~~~~~~~~~~~~~~~"

set lstStudents [list Ahmed "Mohamed" "Maha" "Hoda" Ashraf Mary]

puts "\n~~~~~~~Use regsub ~~~~~~"
puts "Original list: $lstStudents"
regsub "Hoda" $lstStudents "Nour" newlst
puts "Modified list: $newlst"

puts "\n~~~~~~~Patterns to modify in place~~~~~~"
puts "Original list: $lstStudents"
puts "[regexp -all -inline {(\w+)} $lstStudents]"
regsub -all {(\w+)} $lstStudents "_&_" newlst
puts "Modified list: $newlst"

set lstStudents [list Ahmed "Mohamed" "Maha" "Hoda" Ashraf Mary]
puts "Original list: $lstStudents"
set index [lsearch -all -regexp $lstStudents {(M\w+)} ]
puts "indices of people start with M : $index"

set names [lsearch -all -inline -regexp $lstStudents {(M\w+)} ]
puts "Names of people start with M : $names"

set names [lsearch -all -inline -glob $lstStudents {M*} ]
puts "Names of people start with M : $names"

puts "\n~~~~~~~Patterns to modify in place with grouping ~~~~~~"

regsub {([^\.]*)\.c$} file.c {cc -c & -o \1.o} ccCmd
puts "Modified cmd: $ccCmd"
