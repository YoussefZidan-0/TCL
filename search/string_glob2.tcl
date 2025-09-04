#! /c/ActiveTcl/bin/tclsh




##loop recursively ####

proc printFiles { {directory "./"} } {
    set fileName [glob -d $directory *.tcl  ]
    foreach name  $fileName {
        puts "Name : $name"
    }
}

proc goRecursive { vdir } {

    set Directories [glob -type d -nocomplain -tail -d ${vdir}/ -- {[A-Za-z]*} ]
    printFiles ${vdir}

    foreach dir $Directories {
        #printFiles ${vdir}/$dir
        goRecursive ${vdir}/$dir
    }
}

set initialDir "."
goRecursive $initialDir



# MY VERSIONN !!

# proc printtcl {dir} {
#     set scripts [glob -d $dir *.tcl]
#     foreach script $scripts {
#         puts "found script ${script} in ${dir}"
#     }
# }

# proc Recusive_dir {inti_dir} {

#     set dirs [glob -type d -nocomplain -tail -d ${inti_dir} -- {[a-zA-Z]*}]
#     printtcl $inti_dir
#     foreach dir $dirs {
#         Recusive_dir "$inti_dir/$dir"
#     }

# }

# set initialDir "."
# Recusive_dir $initialDir

