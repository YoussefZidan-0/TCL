#! /c/ActiveTcl/bin/tclsh




puts "File match :"


puts "~~~~~~~~~~~~~~~~~~"
puts " Simple Patterns :"
puts "~~~~~~~~~~~~~~~~~~"

puts "Match any file/folder name in current directory"
puts " All contents: [glob  *  ]"
puts " Directories Only: [glob -type d *]"
puts "~~~~~~~~~~~~~~~~~~"
puts "Match one or several charachter"
puts " All contents the ends with .tcl: [glob  *.tcl  ]"
puts " All contents the ends with .tcl or .txt: [glob  *{.tcl,.txt}  ]"
puts " All contents the begins with s: [glob  s*  ]"
puts "~~~~~~~~~~~~~~~~~~"
puts "Match only one charachter"
puts " For files in search directory that follow \"string_exp?.tcl\": [glob  -d search {string_exp?.tcl}  ]"
puts " For files in search directory that follow \"string_*\[1-9\].tcl\": [glob -d search  {string_*[1-9].tcl}  ]"
puts " For files in search directory that follow \"string_exp?.tcl\", omit path: [glob -tail -d search {string_exp?.tcl}  ]"
puts "~~~~~~~~~~~~~~~~~~"


