#! /mingw64/bin/tclsh

proc printStat { s l} {
    puts -nonewline "set myList  $s \t:   $l" 
    puts "\tlength [llength $l], \t string length [string length $l]" 
}
set a 1
set b 2
set c 3

set myList [list a b c] ;           printStat "\[list a b c\]" $myList

set myList [list a   b   c];        printStat "\[list a  b  c\]" $myList

set myList "a b c";                 printStat "\"a b c\"\t" $myList

set myList "a  b  c";               printStat "\"a  b  c\"\t" $myList

set myList {a b c};                 printStat "{a b c}\t" $myList

set myList [split "a_b_c" _];       printStat "\[split \"a_b_c\" _\]" $myList

set myList [list $a $b $c];         printStat "\[list $a $b $c\]" $myList 

set myList {$a $b $c}  ;            printStat "{\$a \$b \$c}\t" $myList


