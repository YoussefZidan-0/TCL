# Digital Circuit Capacitance Path Calculator

A professional EDA tool for analyzing capacitance paths in digital circuits with support for Verilog netlists and standard cell libraries.

![GUI Screenshot](docs/screenshot.png)

## 🚀 Features

- **Intelligent Signal Parsing**: Automatic extraction of inputs, outputs, and internal signals from Verilog netlists
- **Bus Signal Expansion**: Supports bus signals like `[7:0] P_DATA` with automatic bit expansion
- **Multi-Library Support**: Compatible with TSMC and Nangate standard cell libraries
- **Advanced Path Finding**: Hierarchical path analysis with cycle detection and depth limiting
- **Professional GUI**: Clean, intuitive interface with tabbed results display
- **Comprehensive Analysis**: Path structure, gate details, and capacitance calculations
- **No Unit Dependencies**: Clean numeric output without library-specific units

## 📋 Requirements

### System Requirements
- **Operating System**: Linux, macOS, or Windows with WSL
- **TCL/Tk**: Version 8.5 or higher
- **Memory**: Minimum 2GB RAM (4GB+ recommended for large netlists)
- **Disk Space**: 100MB for installation + space for your netlist files

### Software Dependencies
```bash
# Ubuntu/Debian
sudo apt-get install tcl tk tcl-dev tk-dev

# CentOS/RHEL/Fedora
sudo yum install tcl tk tcl-devel tk-devel

# macOS (with Homebrew)
brew install tcl-tk

# Check installation
tclsh --version
wish --version
```

## 🛠️ Installation

### Quick Start
```bash
# Clone the repository
git clone https://github.com/YoussefZidan-0/TCL.git
cd TCL/Caps_calc

# Make scripts executable
chmod +x *.sh

# Launch the GUI
./run_gui.sh
```

### Manual Installation
1. Download and extract the project files
2. Ensure all `.tcl` and `.sh` files are in the same directory
3. Place your `.lib` library files in the same directory as your netlists
4. Run `./run_gui.sh` or `tclsh capacitance_gui.tcl`

## 📖 Usage Guide

### 1. Load Netlist File
- Click **"Browse..."** to select your Verilog netlist (`.v` file)
- Library files (`.lib`) will be automatically detected from the netlist directory
- Status will show "Loaded: X library files, Y cell types"

### 2. Select Signals
- **Start Signal**: Choose from dropdown (inputs and internal nodes)
- **End Signal**: Choose from dropdown (outputs and internal nodes)
- Both dropdowns are automatically populated from your netlist

### 3. Calculate Capacitance
- Click **"Calculate Capacitance"** when both signals are selected
- View results in three tabs:
  - **Path Structure**: Gate-by-gate path visualization
  - **Gate Details**: Individual gate types and capacitances
  - **Capacitance Summary**: Total result and calculation method

### 4. Interpret Results
- **Total Capacitance**: Final calculated value (library units)
- **Calculation Method**: Series, Parallel, or Mixed combination
- **Gates in Path**: Number of gates traversed
- **Path Structure**: Complete signal flow from start to end

## 📁 File Structure

```
Caps_calc/
├── README.md                 # This file
├── capacitance_gui.tcl      # Main GUI application
├── extract_path.tcl         # Core path finding algorithms
├── extract_cap_new.tcl      # Library capacitance extraction
├── run_gui.sh              # Launch script
├── docs/                   # Documentation
│   ├── GUI_USAGE_GUIDE.md
│   ├── PROJECT_COMPLETION_SUMMARY.md
│   └── SIGNAL_EXTRACTION_TEST_RESULTS.md
├── tests/                  # Test files and examples
│   ├── UART_TX_flattened.v    # Example UART netlist
│   ├── demo_adderPlus.syn.v   # Example adder netlist
│   └── *.lib                  # Standard cell libraries
└── old/                    # Legacy versions
```

## 🧪 Example Usage

### Command Line Interface
```bash
# Test basic path finding
tclsh -c "
source extract_path.tcl
set result [get_path_with_capacitance \"UART_TX_flattened.v\" \"CLK\" \"TX_OUT\"]
puts \"Total Capacitance: [dict get \$result \"total_capacitance\"]\"
"
```

### GUI Mode
1. Launch: `./run_gui.sh`
2. Load: `UART_TX_flattened.v`
3. Test Path: `CLK` → `TX_OUT`
4. Expected Result: ~0.080 capacitance units

## 🔧 Troubleshooting

### Common Issues

**"No .lib files found"**
- Ensure library files are in the same directory as your netlist
- Supported formats: `.lib` (Liberty format)
- Check file permissions (must be readable)

**"No path found between signals"**
- Verify signal names exist in the netlist
- Check for typos in signal names (case-sensitive)
- Some paths may not exist due to register boundaries (this is normal)

**"TCL/Tk not found"**
- Install TCL/Tk using your system package manager
- On Windows, use ActiveTcl or WSL with Linux TCL/Tk

**GUI doesn't start**
- Check if `wish` is in your PATH: `which wish`
- Try running directly: `tclsh capacitance_gui.tcl`
- Ensure X11 forwarding if using SSH: `ssh -X username@hostname`

### Debug Mode
```bash
# Enable detailed output
export TCL_DEBUG=1
./run_gui.sh
```

## 📚 Technical Details

### Supported Netlist Formats
- **Verilog**: `.v` files with module instantiations
- **Signal Types**: input, output, wire declarations
- **Bus Signals**: `[MSB:LSB]` notation with automatic expansion

### Library Support
- **TSMC Libraries**: `scmetro_tsmc_*.lib`
- **Nangate Libraries**: `NangateOpenCellLibrary_*.lib`
- **Custom Libraries**: Any Liberty format `.lib` file

### Algorithm Features
- **Path Finding**: Breadth-first search with depth limiting
- **Cycle Detection**: Prevents infinite loops in complex circuits
- **Hierarchical Support**: Handles both flat and hierarchical netlists
- **Capacitance Calculation**: Series/parallel combination analysis

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes with tests
4. Submit a pull request

### Development Setup
```bash
git clone https://github.com/YoussefZidan-0/TCL.git
cd TCL/Caps_calc

# Run tests
tclsh tests/comprehensive_test.tcl

# Test specific functionality
tclsh tests/test_signal_extraction.tcl
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/YoussefZidan-0/TCL/issues)
- **Documentation**: Check the `docs/` folder for detailed guides
- **Email**: [Add your contact email]

## 🏆 Acknowledgments

- Built for EDA (Electronic Design Automation) workflows
- Supports industry-standard Liberty library format
- Designed for digital circuit analysis and verification

---

**Version**: 1.0.0  
**Last Updated**: September 2025  
**Tested On**: Ubuntu 20.04+, CentOS 8+, macOS 12+
