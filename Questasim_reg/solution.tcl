#! /mingw64/bin/tclsh
#check if work exists delete
if { [file exists work]} {
    file delete -force work
}
#create work library
exec vlib work


#check if log folder exists delete
if { [file exists log] } {
    file delete -force log
}
#create log folder
file mkdir log
#compile code
exec vlog src/*.v >> log/compilation.log
puts "done"
#

#from compilation log, get the names of top level modules, report compilation errors
set log [open log/compilation.log r ]
set firstPattern "Top level modules:"
set secondPattern "(tb_.*)"
set modulesFound 0
set modules [list]
while { ![eof $log]} {
    set log_data [gets $log]
    if { $modulesFound } {
        #puts "current line is$log_data"
        if { [ regexp $secondPattern $log_data _t moduleName ] } {
            lappend modules $moduleName
            puts "pattern found line is: $moduleName"
        } else {
            if { $log_data == ""} {
                break
            }
            #puts "pattern NOT found line is$log_data"
        }
    } else {

        set modulesFound [ regexp    $firstPattern $log_data d ]
        puts "Modules Found in line $log_data : $modulesFound"
    }
}

close $log

#loop on top level modules and simulate them
foreach module $modules {
    exec vsim -batch $module -do "run -all;quit" > log/${module}.log
}

#for each simulation get line that state the number of testcases and errors
set count_pass 0
set count_total 0


set pattern {Total.*([0-9]+).*/.*([0-9]+)}
foreach m $modules {
    set log [open log/${m}.log r ]
    while { ![eof $log]} {
        set log_data [gets $log]
        if { [ regexp $pattern $log_data _t pass total ] } {
            puts "found $pass $total"
            incr count_pass $pass
            incr count_total $total
            set result($m) [list $pass $total]
            break
        }

    }

    close $log
}

# #make the final report
# ## write final results ###############################
puts "##################### Statistics ############################\n"
puts "\tModule\tPass / Total\n"
foreach module $modules {
    puts "\t$module\t[lindex $result($module) 0] / [lindex $result($module) 1]\n"
}

puts "##################### Final Statistics ############################\n"
puts "Total Passed: $count_pass / $count_total \n"