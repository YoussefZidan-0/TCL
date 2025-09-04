#!/usr/bin/env tclsh
# arrays_vs_dicts.tcl
# Comprehensive examples showing differences between Tcl associative arrays (array) and dict values (dict).
# Notes:
# - Requires Tcl 8.5+ for dict and {*} argument expansion used in a couple of conversion examples.

proc header {title} {
    puts "\n===== $title ====="
}

header "Short summary"
puts {
    Associative arrays (array) are variable-level data structures: they live in the variable table and
    are accessed using array element syntax (var(key)).

    Dicts are value-level data structures: a dict is a single Tcl value (a list of key/value pairs) and
    must be stored into a variable. Dicts are copied when passed around; arrays are mutated by reference
    through their variable name or with upvar.
}

header "Create and inspect"

# Associative array
array set arr {one 1 two 2}
puts "array elements (array get): [array get arr]"
puts "arr(one) = $arr(one)"

# Dict
set d [dict create one 1 two 2]
puts "dict literal: $d"
puts "dict get one: [dict get $d one]"

header "Mutating: arrays (in-place) vs dicts (functional)"

puts "-- mutate associative array in place --"
set arr(three) 3
puts "arr(three) = $arr(three)"

puts "-- mutate dict: dict set returns a new value; assign back to keep change --"
set d2 [dict set $d three 3]
puts "original dict (d) still: $d"
puts "new dict (d2): $d2"

header "Passing to procedures"

proc add_to_array {arrName key value} {
    # mutate the caller's array using upvar
    upvar 1 $arrName a
    set a($key) $value
}

proc add_to_dict {dictVal key value} {
    # returns a changed copy; caller must capture the return
    return [dict set $dictVal $key $value]
}

add_to_array arr four 4
puts "after add_to_array arr(four) = $arr(four)"

set d2 [add_to_dict $d two 22]
puts "after add_to_dict original d: $d"
puts "after add_to_dict returned d2: $d2"

header "Iteration"

puts "-- iterate associative array via array names --"
foreach k [array names arr] {
    puts "arr($k) => $arr($k)"
}

puts "-- iterate dict via dict for --"
dict for {k v} $d2 {
    puts "dict $k => $v"
}

header "Nesting and complex structures"

puts "-- nested dicts are trivial values --"
set nestedDict [dict create inner 100 other 200]
set dNested [dict set $d nested $nestedDict]
puts "dNested: $dNested"
puts "dNested nested inner: [dict get $dNested nested inner]"

puts "-- arrays can't directly hold an array value in one element; you typically either:
1) use multiple arrays with naming convention (like arr(sub,key)) or
2) store a serialized value (e.g., list or dict) as the element value --"

# example: using namespaced array keys
set contact(home,phone)  "+1-555-000"
set contact(home,name)   "Alice"
puts "contact(home,name) = $contact(home,name)"

header "Conversion between the two"

puts "-- array -> dict --"
set d_from_array [dict create {*}[array get arr]]
puts "dict created from array: $d_from_array"

puts "-- dict -> array --"
# safely unset any existing 'tmp' array
catch {array unset tmp}
array set tmp $d_from_array
puts "array 'tmp' built from dict: [array get tmp]"

header "Memory / semantics notes"
puts {
    - Arrays are variables; you mutate elements directly (set var(key) val). You can share an array
    with a proc by name (upvar) and mutate it in-place.
    - Dicts are values; operations like dict set/dict unset return new dict values. Use them when you
    want simple value semantics, immutability-style updates, or easy passing of structured data.
    - Dicts are easy to nest and serialize. Arrays are convenient when you want a mutable, variable-backed
    keyed container and fast per-key access without copying the whole structure.
}

header "Quick checklist (practical differences)"
puts {
    1) Lifetime: array is a variable; dict is a value stored in a variable.
    2) Mutation: array mutates in-place; dict operations return new values.
    3) Passing: arrays are passed by name (or serialized); dicts are copied by value when passed.
    4) Nesting: dicts nest naturally; arrays can emulate nesting using naming conventions.
    5) Conversion: easy to convert between them using [array get]/[array set] and [dict create]/list expansion.
}

header "Simple checks (exit with non-zero on failure)"

if {$arr(one) != 1} {puts "FAIL: arr(one) wrong"; exit 1}
if {[dict get $d one] != 1} {puts "FAIL: dict one wrong"; exit 2}
if {$arr(four) != 4} {puts "FAIL: array mutation failed"; exit 3}
if {[dict get $d2 two] != 22} {puts "FAIL: dict mutation/return failed"; exit 4}

puts "\nAll checks passed."

exit 0
