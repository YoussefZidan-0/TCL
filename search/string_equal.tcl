#! /c/ActiveTcl/bin/tclsh

set str1 "First String"
set str2 "First String"
set str3 "first String"
set str4 "First Strin"
set str5 "irst String"

puts "string equal results:"

if { [string equal $str1 $str2 ] } { puts "Exact matches"} else { puts "dont Exact match" }
if { [string equal  $str1 $str3 ] } { puts "Ignore case matches"} else { puts "dont match ignoring case" }
if { [string equal -nocase $str1 $str3 ] } { puts "Ignore case matches"} else { puts "dont match ignoring case" }
if { [string equal -length 5 $str1 $str4 ] } { puts "Prefix matches"} else { puts "dont match Prefix" }
if { [string equal -length 5 $str1 $str5 ] } { puts "Substring matches"} else { puts "dont match Substring" }
if { [string equal  $str1 $str4 ] } { puts "Prefix matches"} else { puts "dont match Prefix" }
