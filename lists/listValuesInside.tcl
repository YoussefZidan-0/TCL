#! /mingw64/bin/tclsh

proc printStat { s l} {
    puts -nonewline "set myList  $s \t:   $l" 
    puts "\tlength [llength $l], \t string length [string length $l]" 
}
set a 1
set b 2
set c 3

set myList [list a b c] ;           printStat "\[list a b c\]" $myList


# puts "\n\n~~~~~~~~~~~~~~~~~~~~"
# puts "~~ Remember Loops ~~"
# puts "~~~~~~~~~~~~~~~~~~~~"


# foreach i $myList {
#     puts $i
# }

puts "\n\n~~~~~~~~~~~~~~~~~~~~~"
puts "~~ get original Values ~~"
puts "~~~~~~~~~~~~~~~~~~~~~~~~~"

set myList {a b c};

# puts "~~~~~~~~~~~Ex 1~~~~~~~~~~~~~~"
# foreach i $myList {
#     upvar 0 $i y 
#     puts "$i : $y"
#     #puts "$$i" ; #this will ignore $, we don't have double "$", in other situation it might even generate and error
# }

# puts "~~~~~~~~~~~Ex 2~~~~~~~~~~~~~~"

# puts " \$a is same as \[set a \]"
# puts "value of a is : $a is same as [set a ]"


# set x a
# puts "Recursively get value of a  :[set [set x] ]"



# foreach i $myList {  
#     puts "$i : [set $i]"
# }

puts "~~~~~~~~~~~Ex 3~~~~~~~~~~~~~~"


foreach i $myList {
    eval set x $$i
    puts "$i : $x"
}
puts "~~~~~~~~~~~Ex 4~~~~~~~~~~~~~~"


set myList {$a $b $c} 

foreach i $myList {
    eval set x $i
    puts "$i : $x"
}
# puts "~~~~~~~~~~~~~~~~~~~~~~~~~"