#!/usr/bin/env tclsh
source "extract_path.tcl"

puts "=== Testing Both UART Files ==="

# Test 1: Flattened UART
puts "\n1. Testing UART_TX_flattened.v:"
set instances_flat [extract_path "UART_TX_flattened.v"]
puts "  Instances parsed: [llength $instances_flat]"

if {[llength $instances_flat] > 0} {
    set graph_info_flat [build_signal_graph $instances_flat]
    set signal_to_drivers_flat [lindex $graph_info_flat 0]
    set signal_to_loads_flat [lindex $graph_info_flat 1]
    puts "  Signals with drivers: [dict size $signal_to_drivers_flat]"
    puts "  Signals with loads: [dict size $signal_to_loads_flat]"

    # Test a simple path
    set flat_result [get_path "UART_TX_flattened.v" "DATA_VALID" "Busy"]
    puts "  DATA_VALID->Busy: $flat_result"
}

# Test 2: Hierarchical UART
puts "\n2. Testing UART_TX_hierarchy.v:"
set instances_hier [extract_path "UART_TX_hierarchy.v"]
puts "  Instances parsed: [llength $instances_hier]"

if {[llength $instances_hier] > 0} {
    set graph_info_hier [build_signal_graph $instances_hier]
    set signal_to_drivers_hier [lindex $graph_info_hier 0]
    set signal_to_loads_hier [lindex $graph_info_hier 1]
    puts "  Signals with drivers: [dict size $signal_to_drivers_hier]"
    puts "  Signals with loads: [dict size $signal_to_loads_hier]"

    # Test a simple path
    set hier_result [get_path "UART_TX_hierarchy.v" "DATA_VALID" "Busy"]
    puts "  DATA_VALID->Busy: $hier_result"
}

# Test 3: Show module structure for hierarchical
puts "\n3. Analyzing hierarchical structure:"
if {[llength $instances_hier] > 0} {
    puts "  First 5 instances in hierarchical UART:"
    for {set i 0} {$i < [expr min(5, [llength $instances_hier])]} {incr i} {
        set inst [lindex $instances_hier $i]
        if {[dict exists $inst instance_name] && [dict exists $inst cell_type]} {
            set inst_name [dict get $inst instance_name]
            set cell_type [dict get $inst cell_type]
            if {[dict exists $inst parent_module]} {
                set parent [dict get $inst parent_module]
                puts "    $inst_name ($cell_type) in module: $parent"
            } else {
                puts "    $inst_name ($cell_type) - no parent info"
            }
        }
    }
}
