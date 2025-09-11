#! /mingw64/bin/tclsh

dict set colours color1 red
dict set colours color2 blue
set coldict [dict create c1 "black" c2 "white"]

puts "~~ we can print dictionary without looping as array ~~"
puts $coldict
puts [lindex $coldict 1]
puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts "~~ access value of dictionary by loop ~~"
foreach item [dict keys $colours] {
 	  set value [dict get $colours $item]
   	  puts "for key $item value : $value"
	}

puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
puts "~~ access all value of dictionary ~~" 
set values [dict values $colours]
puts "$values"

# puts [dict exists colours ]
puts [array exists colours]
puts [info exists colours ]
puts [dict exists $colours color1]
