proc build_adjacency_list {verilog_file} {
    set adjacency_dict [dict create]
    set fh [open $verilog_file r]
    
    while {[gets $fh line] >= 0} {
        # Look for lines with gate instantiations
        if {[regexp {i_\d+\s+\(\.(A|B|B1|B2|ZN|Z|CO|S)\(([^)]+)\)} $line -> pin_type node]} {
            # Add this connection to the adjacency list
            if {![dict exists $adjacency_dict $node]} {
                dict set adjacency_dict $node [list]
            }
            
            # Extract the gate name
            regexp {i_\d+} $line gate_name
            dict lappend adjacency_dict $node $gate_name
        }
    }
    
    close $fh
    return $adjacency_dict
}

# Usage
set adj_list [build_adjacency_list "demo_parallel.syn.v"]
puts "Adjacency list for n_0: [dict get $adj_list n_0]"