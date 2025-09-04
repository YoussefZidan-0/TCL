#! /c/ActiveTcl/bin/tclsh


## understand pattern
set pattern {^a.*}
set statement "Ahmed grades : 12, 34, 20, 434"
puts " Statement Start with $pattern: [regexp -nocase -all -inline $pattern $statement]"
puts " Statement Start with $pattern: [regexp -nocase -all -inline $pattern M$statement]"

set pattern {[^a]}
puts " Statement don't  have $pattern: [regexp -nocase -all -inline $pattern M$statement]"

set pattern {[^ae4]}
puts " Statement don't have  $pattern: [regexp -nocase -all -inline $pattern M$statement]"


set pattern {\w+4$}
puts " Statement ends with $pattern: [regexp -nocase -all -inline $pattern M$statement]"




## https://www.tcl-lang.org/man/tcl/TclCmd/re_syntax.htm
