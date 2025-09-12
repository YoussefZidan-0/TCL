# Test script for Calculate_capacitance proc

# Source the script with the procedure
source "calcu_cap.tcl"
# Test case 1: Parallel calculation
set caps1 {1 2 3 4}
set caps2 {1 2 3 4}
puts [Calculate_capacitance $caps1 1]
puts [Calculate_capacitance $caps2 0]