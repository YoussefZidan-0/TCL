#!/usr/bin/tclsh


set statement "    Fan is a student    "
set statement [string trim $statement]
puts "length of statment is : [string length $statement]"
puts "Take care of the \$ [string length statement]"
puts "Fifth charachter is: [string index $statement 4]"
puts "Last charachter is [string index $statement end]"
puts "Search for first string in second: [string first "is" $statement] "
puts "Take care of the order: [string first $statement "is"]"
puts "Subset string: [string range $statement 4 end]"
puts "replacement [string replace $statement 9 end "professor"]"
puts "Original String $statement"

# Split the cleaned statement into words and iterate each word
set words [split $statement]
puts "\nWords in statement:"
foreach w $words {
    puts " - $w"
}

# Create a version that inserts '*' after an arbitrary zero-based index `pointstart`
# `pointstart` is the index of the character after which '*' will be inserted.
# Examples (for word "Fan"):
#  pointstart 0 -> "F*an"
#  pointstart 1 -> "Fa*n"
#  pointstart 2 -> "Fan*" (star appended)

set starred_words {}
# change this to any zero-based index where you want the '*' inserted before that character
# Semantics: pointstart == 0 -> prefix ("*word"), pointstart == 1 -> insert before second char ("F*an"),
# pointstart == len -> append at end ("word*")
set pointstart 0

foreach w $words {
    if {[string length $w] == 0} { continue }

    set len [string length $w]
    # normalize p: clamp to [0..len]
    set p $pointstart
    if {$p < 0} { set p 0 }
    if {$p > $len} { set p $len }

    if {$p == 0} {
        # prefix
        lappend starred_words "*${w}"
    } elseif {$p == $len} {
        # append
        lappend starred_words "${w}*"
    } else {
        # insert before character at index p
        set left [string range $w 0 [expr {$p - 1}]]
        set right [string range $w $p end]
        lappend starred_words "${left}*${right}"
    }
}

set starred_statement [join $starred_words " "]
puts "\nStarred-after-pointstart($pointstart): $starred_statement"

# Iterate characters for each word and store the characters in a dict
set chars {}
foreach w $words {
    set chlist {}
    set len [string length $w]
    for {set i 0} {$i < $len} {incr i} {
        set ch [string index $w $i]
        puts "Char $i of \"$w\": $ch"
        lappend chlist $ch
    }
    dict set chars $w $chlist
}

puts "\nAccessing stored characters later:"
# Example: access first char of "Fan"
if {[dict exists $chars Fan]} {
    puts "First char of Fan: [lindex [dict get $chars Fan] 0]"
    puts "Chars of Fan: [dict get $chars Fan]"
} else {
    puts "Word 'Fan' not found in dict keys"
}
