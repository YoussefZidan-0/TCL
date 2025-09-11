#! /mingw64/bin/tclsh

## All keys are Strings, but we can get benefit of it to make multidimensional key

## create entries
set arr(1,1) "item1"
set arr(1,2) "item2"
set arr(1,3) "item3"
set arr(2,1) "item4"
set arr(2,2) "item5"
set arr(2,3) "item6"

puts " ~~~~ loop on Map ~~~~"
# loop on all entries
foreach item [array names arr]  {
    puts "$item is $arr($item) "
}   ;    #(iterating through array)

set a 1
puts $arr($a,$a)