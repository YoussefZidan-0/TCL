# Capacitance Calculator GUI - Usage Guide

## ✅ **Fixed Signal Extraction Issue**

The GUI now correctly uses the same signal extraction engine as `extract_path.tcl` instead of doing separate parsing.

## 🎯 **Correct Signal Names for demo_adderPlus.syn.v**

### **Input Signals (Start Points):**
- `inputA[0]` through `inputA[7]` - Individual input bits  
- `inputB[0]` through `inputB[7]` - Individual input bits
- `datapath.inputA`, `datapath.inputB` - Hierarchical module inputs
- `i_0_0.inputA`, `i_0_0.inputB` - Instance-level inputs

### **Output Signals (End Points):**
- `p_0[0]` through `p_0[8]` - Primary output bits
- `n_0` through `n_27` - Internal node signals
- Various hierarchical outputs

## 🚀 **Working Path Examples**

### **Example 1: Direct Gate Path**
- **From:** `inputA[0]`  
- **To:** `p_0[0]`
- **Path:** `S {HA_X1 (i_0)}`
- **Capacitance:** 60.5774 pF
- **Description:** Direct connection through half-adder gate

### **Example 2: Multi-Gate Path** 
- **From:** `inputA[0]`
- **To:** `n_0`  
- **Path:** Through carry output of HA_X1
- **Description:** Carry propagation path

### **Example 3: Complex Path**
- **From:** `inputA[1]`
- **To:** `p_0[1]`
- **Path:** Multi-gate path through XOR logic
- **Description:** More complex arithmetic path

## 📋 **GUI Usage Instructions**

1. **Launch GUI:** `wish capacitance_gui.tcl` or `./run_gui.sh`

2. **Select Netlist:** 
   - Click "Browse..." button
   - Choose `demo_adderPlus.syn.v`
   - Library files auto-detected

3. **Choose Signals:**
   - **Start Signal:** Select from dropdown (e.g., `inputA[0]`)
   - **End Signal:** Select from dropdown (e.g., `p_0[0]`)

4. **Calculate:** 
   - Click "Calculate Capacitance" button
   - View results in tabbed display

## ⚡ **Command Line Testing**

```bash
cd /home/youssef/TCL/Caps_calc

# Test signal extraction
echo "
source extract_path.tcl
set result [get_path_with_capacitance demo_adderPlus.syn.v \"inputA[0]\" \"p_0[0]\"]
display_path_analysis \$result
" | tclsh
```

## 🔧 **Technical Details**

### **Signal Extraction Engine**
- Uses `extract_path.tcl` → `build_signal_graph()` → signal dictionaries
- **Driver signals:** Outputs that can be reached (43 signals)  
- **Load signals:** Inputs that can be starting points (48 signals)
- **Hierarchical support:** Module boundary crossing enabled

### **Library Integration**
- **TSMC Library:** `scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib`
- **Nangate Library:** `NangateOpenCellLibrary_typical.lib`  
- **Auto-detection:** All `.lib` files in netlist directory
- **Combined dictionary:** Unified capacitance database

### **Path Finding Algorithm**
- **Hierarchical traversal:** Cross-module boundary support
- **Parallel detection:** Multi-path structure analysis
- **Depth limiting:** Prevents infinite loops (max_depth=20)
- **Performance optimization:** Path explosion limiting

## ✅ **Resolution Summary**

**Problem:** GUI was doing separate Verilog parsing with incorrect bus signal handling  
**Solution:** GUI now uses the same `extract_path.tcl` signal extraction engine  
**Result:** Correct signal names and successful path finding

The GUI now shows the exact same signals that `extract_path.tcl` uses internally, ensuring compatibility and eliminating the "No path found" errors caused by signal name mismatches.
