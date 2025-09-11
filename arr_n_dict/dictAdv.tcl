#! /mingw64/bin/tclsh

puts "$argc $argv $argv0"
dict set ldifValues level0 {
    level1 {key3 er key4 sdf}
    key1  value1
    key2  value2

}

puts [dict get $ldifValues level0 level1 key4 ]

puts [dict get $ldifValues level0 ]
#puts $ldifValues
