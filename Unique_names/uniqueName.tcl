#! /mingw64/bin/tclsh

#example n19_basename_suffix
proc uniqueName { basename {suffix "" }} {

    if { $suffix != ""} {
        set suffix _${suffix}
    }

    regsub {^n[0-9]+_} $basename "" newbase
    
    if { ![info exists ::global_counter]} {
        set ::global_counter 0
    } 

    set newName n${::global_counter}_$newbase$suffix
    incr ::global_counter
    return $newName

}

# puts     "Creating a unique name from base 'AND' :  [uniqueName AND]"
# set newName [uniqueName AND]

# puts    "Creating a unique name from base 'AND' again : $newName "

# set anotherName [uniqueName $newName]

# puts    "Creating a unique name from previously created unique name : $anotherName "

# puts    "Creating a unique name from previously created unique name with a suffix : [uniqueName $newName RAM] "