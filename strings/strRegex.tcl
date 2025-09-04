#! /mingw64/bin/tclsh

set statement "Alan is a student"
puts [string match "*student" $statement] ;#(* ? [])

puts [format "This number is %d %s" 4 integer]
scan {planet1 0.330 planet2 4.87} {planet1 %g planet2 %g};
puts "planet1 : $planet1"
scan 12a34 {%d%[abc]%d} x - y