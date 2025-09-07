#! /c/ActiveTcl/bin/tclsh

puts "~~~~~~~~~~~~~~~~~~"
puts " substitute :"
puts "~~~~~~~~~~~~~~~~~~"

## Remember ##
## IF I want to replace Hoda with Nour, I will probably search for Hoda first
puts "\n~~~~~Use lsearch & lreplace ~~~~~~~~"
set lstStudents [list Ahmed "Mohamed" "Maha" "Hoda" Ashraf Mary]
puts "Original list: $lstStudents"
set index [lsearch $lstStudents "Hoda" ]
if { $index >= 0 } {
    puts "Modified list: [lreplace $lstStudents $index $index "Nour" ]"
}

puts "\n~~~~~~~Patterns to modify in place~~~~~~"
set lstStudents [list Ahmed "Mohamed" "Maha" "Hoda" Ashraf Mary]
puts "Original list: $lstStudents"
set index [lsearch -all -regexp $lstStudents {(M\w+)} ]
puts "indices of people start with M : $index"

puts "\n~~~~~~~ Different Patterns ~~~~~~"

set names [lsearch -all -inline -regexp $lstStudents {(M\w+)} ]
puts "Names of people start with M : $names"

set names [lsearch -all -inline -nocase -glob $lstStudents {M*} ]
puts "Names of people start with M using glob {M*} : $names"
set names [lsearch -all -inline -nocase -regex $lstStudents {^M+} ]
puts "Names of people start with M using regex {^M+} : $names"

puts "\n~~~~~~~ Beware Regex and glob are not the same ~~~~~~"
set names [lsearch -all -inline -regex $lstStudents {M*} ]
puts "Search  using regex {M*} is not the same as glob {M*}, regex {M*}: $names"

set names [lsearch -all -inline -nocase -regex $lstStudents {M+} ]
puts "Search  using regex {^M+} is not the same as  {M+} : $names"