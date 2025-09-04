#! /mingw64/bin/tclsh

set lstStudents [list Ahmed "Mohamed" "Maha" "Hoda" Ashraf Mary]

set lstStudents [lreplace $lstStudents 3 5 "Nour" "Samy"]   ; puts "1: $lstStudents"
set lstStudents [lreplace $lstStudents 3 5 "Anwer  Amgad"]  ; puts "2: $lstStudents"
set lstStudents [lreplace $lstStudents end end]             ; puts "3: $lstStudents"
set lstStudents [lrange $lstStudents 1 end]                 ; puts "4: $lstStudents"
set lstStudents [lsort -ascii $lstStudents]                 ; puts "5: $lstStudents"
lset lstStudents 1 "Ayman"                                  ; puts "6: $lstStudents"
set lstStudents [lreplace $lstStudents 1 1 "Ayman"]         ; puts "7: $lstStudents"
puts "8: Search for Ayman found in  [lsearch  $lstStudents "Ayman"] "



