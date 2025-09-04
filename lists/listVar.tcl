#! /mingw64/bin/tclsh

set arr {a b c}
# lassign $arr x y z       ;# Empty return
# puts $x                     ;# Prints "a"
# puts $y                     ;# Prints "b"
# puts $z                     ;# Prints "c"
# puts "~~~~~~~~~~~~~~~~~~~~"
# lassign $arr x y z m         ;# Empty return
# puts $x                     ;# Prints "a"
# puts $y                     ;# Prints "b"
# puts $z                     ;# Prints "c"
# puts $m                     ;# Prints ""
# puts "~~~~~~~~~~~~~~~~~~~~"
# lassign $arr x y            ;# Returns "c"
# puts $x                     ;# Prints "a"
# puts $y                     ;# Prints "b"
# puts "~~~~~~~~~~~~~~~~~~~~"
# #Can you use lassign to shift ?

set arr [lassign $arr x]
puts $arr