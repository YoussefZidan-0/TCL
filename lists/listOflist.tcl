#! /mingw64/bin/tclsh

set a [list [list x y z] ]
puts "0: [lindex $a 0]"
puts "1: [lindex [lindex $a 0] 1]"
puts "2: [lindex [lindex $a 1] 0]"               ;#(unexpected result)
set a [list x [list [list y] [list z]]]
##=> How to get to the z?
puts "~~~~~~~~~~~~~~~~~~~~"
set arg1 [list a1 [list b1 [list c1 [list d1 e1]]] [list f1 g1] h1]
set arg2 [list a2 [list b2 [list c2 [list d2 e2]]] [list f2 g2] h2]
set both [list $arg1 $arg2]
puts "3: $both"
puts "~~~~~~~~~~~~~~~~~~~~"
## flatten 
puts "4: $arg1 "
puts "4: [join $arg1 ]"
puts "~~~~~~~~~~~~~~~~~~~~"
puts "5: [list a  b] [list c d]"
puts "5: [join [list a  b] [list c d]]"
puts "~~~~~~~~~~~~~~~~~~~~"
puts "6: [list a  b c d]"
puts "6: [join [list a  b c d] ,]"

puts "~~~~~~~~~~~~~~~~~~~~"
## merge ?
set l1 [list a  b] ; set l2 [list c d]
puts "7: $l1 $l2"
puts "7: [concat $l1 $l2]"

lappend l1 {*}$l2
puts "8: $l1 "