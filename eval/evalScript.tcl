#! /mingw64/bin/tclsh
set Script {
  set Number1 17
  set Number2 25
  set Result [expr $Number1 + $Number2]
  set y
}
set a 9
set i a
eval $Script $$i


puts $y
puts $Result

