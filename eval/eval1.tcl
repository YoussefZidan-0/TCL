#! /c/ActiveTcl/bin/tclsh
#puts "$argc $argv $argv0"

set i 0
set cmdIncr {incr i}
# execute it any no times later in the script
while { $i < 20 } {
    puts "i = $i"
    eval $cmdIncr
}


set cmd "python hello.py"
eval exec $cmd


exec python hello.py