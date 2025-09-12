# Simple debug script to find all lines containing P_DATA

set filename "Caps_calc/UART_TX_hierarchy.v"

if {![file exists $filename]} {
    puts "ERROR: Cannot find file $filename"
    exit 1
}

set fp [open $filename r]

puts "--- Searching for P_DATA in $filename ---"
while {[gets $fp line] >= 0} {
    if {[string match {*P_DATA*} $line]} {
        puts $line
    }
}
close $fp
puts "--- Search complete ---"