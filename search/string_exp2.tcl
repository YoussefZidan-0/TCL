#! /c/ActiveTcl/bin/tclsh

puts "~~~~~~~~~~~~~~~~~~"
puts " Complex Patterns :"
puts "~~~~~~~~~~~~~~~~~~"

set statement "Tcl Tutorial"
puts [ regexp {([A-Za-z]*).([A-Za-z]*)} $statement  a b c ]
puts {regexp {([A-Za-z]*).([A-Za-z]*)} $statement  a b c}
puts "\tFull Match: $a"  ;# Tcl Tutorial
puts "\tSub Match1: $b"  ;# Tcl
puts "\tSub Match2: $c"  ;# Tutorial
puts "--"

regexp -nocase {([a-z]*).([a-z]*)} $statement a b c
puts {regexp -nocase {([a-z]*).([a-z]*)} $statement a b c}
puts "\tFull Match: $a"  ;# Tcl Tutorial
puts "\tSub Match1: $b"  ;# Tcl
puts "\tSub Match2: $c"  ;# Tutorial
puts "--"

regexp   {([[:alpha:]]*).([[:alpha:]]*)} $statement a b c
puts { regexp   {([[:alpha:]]*).([[:alpha:]]*)} $statement a b c }
puts "\tFull Match: $a"  ;# Tcl Tutorial
puts "\tSub Match1: $b"  ;# Tcl
puts "\tSub Match2: $c"  ;# Tutorial
puts "--"

set pattern {([[:alpha:]]{4}).([[:alpha:]]{2,})}
regexp  $pattern  $statement a b c
puts " regexp   $pattern $statement a b c "
puts "\tFull Match: $a"  ;# Tcl Tutorial
puts "\tSub Match1: $b"  ;# Tcl
puts "\tSub Match2: $c"  ;# Tutorial
puts "--"



## https://www.tcl-lang.org/man/tcl/TclCmd/re_syntax.htm
