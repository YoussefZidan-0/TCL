#! /c/ActiveTcl/bin/tclsh
#puts "$argc $argv $argv0"

set i 0
set cmdIncr {incr i}
# execute it any no times later in the script
while { $i < 20 } {
    puts "i = $i"
    puts "cmdIncr = [eval $cmdIncr]"
}
puts "cmdInter and i after loop are $cmdIncr and $i"


set cmd "python3 hello.py"
puts [eval exec $cmd]


puts [exec python3 hello.py]