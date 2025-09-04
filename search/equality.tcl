#! /c/ActiveTcl/bin/tclsh

set str1 "First String"
set str2 "First String"
set str3 "first String"
set str4 "First Strin"
set str5 "irst String"

puts " ==  matches:"

if { $str1 == $str2 } { puts "Exact matches"} else { puts "dont Exact match" }
if { $str1 == $str3 } { puts "Ignore case matches"} else { puts "dont match ignoring case" }
if { $str1 == $str4 } { puts "Prefix matches"} else { puts "dont match Prefix" }
if { $str1 == $str5 } { puts "Substring matches"} else { puts "dont match Substring" }

puts "EQ results:"
if { $str1 eq $str2 } { puts "Exact matches"} else { puts "dont Exact match" }
if { $str1 eq $str3 } { puts "Ignore case matches"} else { puts "dont match ignoring case" }
if { $str1 eq $str4 } { puts "Prefix matches"} else { puts "dont match Prefix" }
if { $str1 eq $str5 } { puts "Substring matches"} else { puts "dont match Substring" }
