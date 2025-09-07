#! /c/ActiveTcl/bin/tclsh

set fRead [open source.txt r]
set fWrite [open target.txt w]
while {![eof $fRead]} {
    set strLine [read $fRead] ;#or gets $fRead strLine
    regsub -nocase -all "fan" $strLine "kristy" strLine
    puts $fWrite $strLine
    puts  $strLine
}
close $fRead
close $fWrite
