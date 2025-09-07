#! /mingw64/bin/tclsh

## 1. Prepare appropriate Data Structure
## 2. Read Data From file and fill Structure
## 3. loop on the lines and calculate width per each line and store it in a file.

## 1. Prepare appropriate Data Structure
####  DS for lines, cross, hside, vside & IDs
array set cross ""
array set line ""
array set hside ""
array set vside ""
array set IDs ""


## 2. Read Data From file and fill Structure
## create pattern of format 
#line example: 33 line : 34 , 67 , 63
set pattern {^([0-9]+)\s+(line|cross|hside|vside)\s+:(.*)$}
set fRead [open test_input.txt r]

while {![eof $fRead]} {
    set strLine [read $fRead] ;#or gets $fRead strLine
    set lines [split $strLine "\n"]  ;# split lines based on end of line
    foreach cline $lines {
        #line example: 33 line : 34 , 67 , 63
        set found [regexp  $pattern $cline fullmatch ID type value] ; #find pattern and add it
        if { $found } {
            set IDs($ID) $type 
            regsub -all {\s+} $value "" trimmedValue ;#remove extra strings
            set ${type}($ID) [split $trimmedValue ","] 
        } 
    }
}
close $fRead


## 3. loop on the lines and calculate width per each line and store it in a file.
set fWrite [open output.txt w]
foreach item [array names line]  {
    set hcount 0
    set vcount 0
    set width 0.0
    set cross_array [list]
    foreach id $line($item) {
        #check id type
        if {$IDs($id) == "cross" } {
            lappend cross_array $id
            continue
        }
        if { $IDs($id) == "hside"  } {
            set width [expr $width + $hside($id)]
            incr hcount
            continue
        }
        if { $IDs($id) == "vside"  } {
            set width [expr $width + $vside($id)]
            incr vcount
            continue
        }
    }

    if { $hcount > $vcount} {
        foreach citem $cross_array { 
            foreach id $cross($citem) {  
                if { $IDs($id) == "hside"  } {
                    set width [expr $width + $hside($id)]
                    break
                }
            }
        }
    }  
    
    if { $hcount < $vcount} {
            foreach citem $cross_array { 
                foreach id $cross($citem)   {
                    if { $IDs($id) == "vside"  } {
                        set width [expr $width + $vside($id)]
                        break
                    }
                }
            }
     } 

     if { $hcount == $vcount} {
        
   
        foreach citem $cross_array { 
            set minWidth 100000
            foreach id $cross($citem)   {
                if { $IDs($id) == "hside"  } {
                    set temp_width  $hside($id)
                }

                if { $IDs($id) == "vside"  } {
                    set temp_width  $vside($id)
                }

                if { $temp_width < $minWidth } {
                    set minWidth $temp_width
                }
            }
            set width [expr $width + $minWidth]
        }
        

     }
    
    unset cross_array
    #format  12 line :  12.1
    puts $fWrite  "$item line : $width"

}  
close $fWrite


