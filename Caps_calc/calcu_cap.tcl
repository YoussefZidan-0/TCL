
proc Calculate_capacitance {C_list {Flag 1}} {
    # if flag is 1 then this is parallel else series
    set result 0
    if {$Flag == 1} {

        foreach cap $C_list {
            set result [expr {$result + $cap}]
        }
    } else {
        # Perform calculation for other flags
        if {[llength $C_list] == 0} {
            return 0
        }
        set result 0.0
        foreach cap $C_list {
            set result [expr {$result + 1.0 / $cap}]
        }
        set result [expr {1.0 / $result}]
    }
    return $result
}
