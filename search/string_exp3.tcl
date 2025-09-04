#! /c/ActiveTcl/bin/tclsh

puts "~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts " New Line impact "
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~"

regexp -nocase   {([A-Z]*.([A-Z]+))} "Tcl\nTutorial" a b c
puts {regexp -nocase   {([A-Z]*.([A-Z]+))} "Tcl\nTutorial" a b c}
puts "\tFull Match: $a"
puts "\tSub Match1: $b"
puts "\tSub Match1: $c"
puts " ----"

regexp -nocase -line  {([A-Z]*.([A-Z]+))} "Tcl\nTutorial" a b
puts {regexp -nocase -line  {([A-Z]*.([A-Z]+))} "Tcl\nTutorial" a b}
puts "\tFull Match: $a"
puts "\tSub Match1: $b"
puts " ----"

regexp -nocase -start 4 -line  {([A-Z]*.([A-Z]*))} "Tcl \nTutorial" a b
puts {regexp -nocase -start 4 -line  {([A-Z]*.([A-Z]*))} "Tcl \nTutorial" a b}
puts "\tFull Match: $a"
puts "\tSub Match1: $b"





## https://www.tcl-lang.org/man/tcl/TclCmd/re_syntax.htm

regexp -nocase   {my.([A-Z]+)} "This is my Life" a b c

regexp -nocase -line  {([1-9]+)} "This is first statement\n123 Alo" a b