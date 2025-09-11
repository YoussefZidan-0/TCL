#! /mingw64/bin/tclsh

## create entries
set color(rose) red
set color(sky) blue
set color(medal) gold
set color(leaves) green
set color(blackboard) black

array set engineering "Civil Buildings Computer Chips Communication Wifi"
set engineering(Arch) landscapes

puts " ~~~~ access an entry ~~~~"
puts "sky color is $color(sky)"
puts "Civil engineers create $engineering(Civil)"

# puts " ~~~~ access an keys ~~~~"
# puts  [array names color]

# puts " ~~~~ loop on Map ~~~~"
# # loop on all entries
foreach item [array names color]  {
    puts "$item is $color($item) "
}   ;    #(iterating through array)

# foreach  spec [array names engineering] {
#     puts "$spec engineer creates $engineering($spec)"
# }   ;    #(iterating through array)

# #we can't just read an Associative Array
# #puts "Our Map is : $color"   

# ## convert it to list
set lstColor [array get color]
puts "Our Map is : $lstColor" 

# ## convert it back to array
array set newcolor $lstColor 
puts "sky is $newcolor(sky)"

# ## check if array exists
puts [array exists newcolor]
puts [info exists newcolor]

set x 1
puts [array exists x]
puts [info exists x]

# ##check if item exists
if { [info exists newcolor(sky)]} {
    puts "color for sky is $newcolor(sky)"
} else {
    puts "color doesn't exits"
}




