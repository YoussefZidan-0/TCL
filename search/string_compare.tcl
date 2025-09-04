#! /c/ActiveTcl/bin/tclsh

set str1 "First String"
set str2 "First String"
set str3 "first String"
set str4 "First Strin"
set str5 "irst String"

puts "String compare :"

if { [string compare $str1 $str2 ] == 0 } { puts "Exact matches"} else { puts "dont Exact match" }
if { [string compare -nocase $str1 $str3 ] == 0 } { puts "Ignore case matches"} else { puts "dont match ignoring case" }
if { [string compare -length 5 $str1 $str4 ] == 0 } { puts "Prefix matches"} else { puts "dont match Prefix" }
if { [string compare -length 5 $str1 $str5 ] == 0 } { puts "Substring matches"} else { puts "dont match Substring" }

puts "is '$str1' before '$str5' is in alphabet?  : [string compare -length 5 $str1 $str5 ] "