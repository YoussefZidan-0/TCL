# TCL Learning & Development Codebase Instructions

## Architecture Overview

This is a **TCL educational and development codebase** organized into self-contained learning modules and industrial applications. The architecture follows a **module-based learning pattern** with progressive complexity from basic concepts to advanced EDA (Electronic Design Automation) tools.

### Key Components

- **`Caps_calc/`** - **Main industrial project**: Verilog netlist path extraction with hierarchical module support for TSMC/Nangate libraries
- **`search/`** - Pattern matching module (regex, glob, string operations) with comprehensive examples and `SEARCH_MODULE_SUMMARY.md`  
- **`lists/`** - TCL list operations with educational examples demonstrating different list creation methods
- **`Protection_W/`** - Engineering calculation engine for protection width analysis with stress testing
- **`Questasim_reg/`** - Automated regression testing framework for Verilog simulation with Questasim
- **Educational modules**: `strings/`, `arr_n_dict/`, `eval/`, `filesOP/`, `Unique_names/` - Focused concept demonstrations

## Critical Development Patterns

### Testing Strategy
- **Comprehensive test suites**: Use pattern like `test_dummy_parallel.tcl` with pass/fail counters and expected vs actual result verification
- **Edge case coverage**: Each module includes stress testing (see `Protection_W/STRESS_TEST_ANALYSIS.md`)
- **Performance testing**: Include timing measurements for complex algorithms (`[clock milliseconds]`)

### TCL Coding Conventions
- **Procedure naming**: Use descriptive names like `extract_signal_path`, `build_signal_graph`, `verify_result`
- **Dictionary patterns**: Heavy use of `dict create/get/set/for` for structured data (see `extract_path.tcl`)
- **Error handling**: Use `catch` blocks and validation checks before operations
- **Multi-line parsing**: Handle complex file formats with state machines (see Verilog parsing in `extract_path.tcl`)

### File Organization
- **Main implementation** + **test files** + **documentation** pattern for each module
- **Progressive complexity**: Start with basic examples (`str.tcl`) before advanced (`strRegex.tcl`)
- **Cross-references**: Educational files include comprehensive summary docs (`.md` files)

## Critical Workflows

### Caps_calc Development (Main Project)
```bash
# Test basic functionality
tclsh test_dummy_parallel.tcl

# Test hierarchical UART support
tclsh test_hierarchical.tcl

# Run comprehensive validation
tclsh final_uart_test.tcl

# Library extraction
tclsh extract_cap_new.tcl scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib
```

### Questasim Regression Testing
```bash
# Automated compile, simulate, and report generation
tclsh solution.tcl
# Outputs: log/compilation.log, log/{module}.log, statistics summary
```

### Educational Module Pattern
1. **Read the summary**: Check `MODULE_SUMMARY.md` files first for learning outcomes
2. **Progressive examples**: Start with basic files (`str.tcl`) then advanced (`strAdv.tcl`)
3. **Test-driven learning**: Run comparison tests like `test_unique_names.tcl`

## Key Integration Points

### Verilog Netlist Processing (`Caps_calc/`)
- **Library integration**: Dual TSMC + Nangate library support with automatic merging
- **Hierarchical modules**: Parse both flattened and hierarchical Verilog designs
- **Path algorithms**: Complex graph traversal with cycle detection and depth limiting
- **Signal mapping**: Handle primary inputs/outputs and module boundary crossing

### Data Structures
- **Dictionaries for structured data**: `[dict create "key" "value"]` pattern throughout
- **Lists for sequences**: Use `lappend`, `lindex`, `lrange` consistently  
- **Regex capture groups**: Pattern `{([A-Za-z]*).([A-Za-z]*)}` for structured extraction

### Performance Optimization
- **Depth limiting**: Prevent infinite loops in complex algorithms (max_depth parameters)
- **Path limiting**: Cap result sets to prevent memory explosion (`[llength $all_paths] > 10`)
- **Caching**: Store parsed data in dictionaries for reuse

## Debugging Patterns

### Algorithm Development
- Use **debug scripts**: Pattern like `debug_*.tcl` for step-by-step analysis
- **Result verification**: Always include expected vs actual comparison functions
- **Incremental testing**: Build test suites that validate each component separately

### Common Issues
- **Square bracket escaping**: Use `P_DATA\[0\]` for signal names in TCL
- **Multi-line parsing**: Handle Verilog instantiations across multiple lines with state machines
- **Library compatibility**: Support both TSMC and Nangate cell libraries simultaneously

## File Naming Conventions
- **Test files**: `test_{module}.tcl` for comprehensive testing
- **Debug files**: `debug_{issue}.tcl` for specific problem analysis  
- **Implementation**: `{module}.tcl` for main functionality
- **Educational**: `{concept}{level}.tcl` (e.g., `str.tcl` → `strAdv.tcl` → `strRegex.tcl`)

Focus on **educational progression**, **comprehensive testing**, and **industrial EDA tool development** when working with this codebase.
