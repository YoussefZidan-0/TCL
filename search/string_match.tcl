#! /c/ActiveTcl/bin/tclsh

set str1 "First String"
set str2 "First String"
set str3 "first String"
set str4 "First Strin"
set str5 "irst String"
set str6 ${str1}6
puts "String match :"

if { [string match $str1 $str2 ]  } { puts "Exact matches"} else { puts "dont Exact match" }
if { [string match -nocase $str1 $str3] } { puts "Ignore case matches"} else { puts "dont match ignoring case" }
if { [string match  "${str4}*" $str1  ]  } { puts "Prefix matches"} else { puts "dont match Prefix" }
if { [string match  "${str4}?" $str6  ]  } { puts "Prefix matches"} else { puts "dont match Prefix" }
if { [string match  "?$str5"   $str1  ] } { puts "Substring matches"} else { puts "dont match Substring" }


puts "~~~~~~~~~~~~~~~~~~"
puts " Simple Patterns :"
puts "~~~~~~~~~~~~~~~~~~"

puts "Match any length"
puts " [string match * $str1 ]"
puts " [string match -nocase {*[fs]*} $str1 ]"
puts "~~~~~~~~~~~~~~~~~~"
puts "Match only one charachter"
puts " [string match ? $str1 ]"
puts " [string match -nocase {?[fs]*} $str1 ]"
puts "~~~~~~~~~~~~~~~~~~"
puts "handle escapes"
set a {2\3}
puts $a
puts  "[string match {?\\*} $a ]"
