#! /c/ActiveTcl/bin/tclsh


set str1 "First String"
set str2 "First String"
set str3 "first String"
set str4 "First Strin"
set str5 "irst String"

puts "Regex :"

if { [regexp $str1 $str2 ]  } { puts "Exact matches"} else { puts "dont Exact match" }
if { [regexp -nocase $str1 $str3] } { puts "Ignore case matches"} else { puts "dont match ignoring case" }
if { [regexp  "${str4}" $str1  ]  } { puts "Prefix matches"} else { puts "dont match Prefix" }
if { [regexp  "${str5}" $str1  ] } { puts "Substring matches"} else { puts "dont match Substring" }

## https://www.tcl-lang.org/man/tcl/TclCmd/re_syntax.htm
