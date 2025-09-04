#! /mingw64/bin/tclsh

set lstStudents [list Ahmed "Mohamed" "Maha" "Hoda" Ashraf Mary]
puts "1: [lindex $lstStudents 0]"
puts "2: [lindex $lstStudents end-2 ]"
puts "3: [llength lstStudents]"  ;#(unexpected result!)
puts "4: [llength $lstStudents]"

lappend $lstStudents "Peter"  ;#(wrong!)
puts "5: $lstStudents"

lappend lstStudents "Michael"
puts "6: $lstStudents"

linsert $lstStudents 2 "Radwa"
puts "7: $lstStudents"

set lstStudents [linsert $lstStudents 2 "Zeina"]
puts "8: $lstStudents"

linsert lstStudents 2 "Sameh"  ;#(wrong!)
puts "9: $lstStudents"

set lstStudents [linsert lstStudents 2 "Mostafa"]  ;#(wrong!)
puts "10: $lstStudents"


