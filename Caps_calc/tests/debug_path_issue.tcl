# Change to the script's directory to resolve relative paths
cd [file dirname [info script]]

# Load the main script
source "extract_path.tcl"

# Define the test case
set netlist "UART_TX_hierarchy.v"
set start_signal {P_DATA[0]}
set end_signal "TX_OUT"

# Run the analysis
set result [get_path_with_capacitance $netlist $start_signal $end_signal]

# Display the result
display_path_analysis $result