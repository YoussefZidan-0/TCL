#!/bin/bash

# Digital Circuit Capacitance Path Calculator - Launcher
# Professional EDA tool for capacitance analysis

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Digital Circuit Capacitance Path Calculator${NC}"
echo "=============================================="
echo ""

# Check system requirements
echo -e "${BLUE}� Checking system requirements...${NC}"

# Check TCL/Tk
if ! command -v tclsh &> /dev/null; then
    echo -e "${RED}❌ ERROR: TCL not found!${NC}"
    echo "Please install TCL/Tk:"
    echo "  Ubuntu/Debian: sudo apt-get install tcl tk"
    echo "  CentOS/RHEL: sudo yum install tcl tk"
    echo "  macOS: brew install tcl-tk"
    exit 1
fi

if ! command -v wish &> /dev/null; then
    echo -e "${RED}❌ ERROR: Tk (wish) not found!${NC}"
    echo "Please install Tk package for GUI support"
    exit 1
fi

echo -e "${GREEN}✅ TCL/Tk found${NC}"

# Check if required files exist
echo -e "${BLUE}📁 Checking required files...${NC}"
required_files=("capacitance_gui.tcl" "extract_path.tcl" "extract_cap_new.tcl")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ ERROR: $file not found!${NC}"
        echo "Please ensure all project files are in the current directory"
        exit 1
    fi
done

echo -e "${GREEN}✅ All required files found${NC}"
echo ""

# Check for sample files
echo "📋 Available test files:"
ls -la *.v 2>/dev/null || echo "  No .v files found"
ls -la *.lib 2>/dev/null || echo "  No .lib files found"
echo ""

echo "🎯 GUI Features Overview:"
echo "========================="
echo "1. 📂 File Selection:"
echo "   • Browse and select netlist (.v) files"
echo "   • Auto-detects all .lib files in netlist directory"
echo "   • Builds combined cell capacitance dictionary"
echo ""

echo "2. 🔍 Signal Selection:"  
echo "   • Automatically extracts input/output signals"
echo "   • Dropdown menus for start/end signal selection"
echo "   • Real-time validation of selections"
echo ""

echo "3. ⚡ Capacitance Calculator:"
echo "   • Calculate button (enabled when all inputs valid)"
echo "   • Progress indicator during calculation"
echo "   • Comprehensive error handling"
echo ""

echo "4. 📊 Results Display:"
echo "   • Path Structure tab: Shows signal path"
echo "   • Gate Details tab: Detailed gate information"
echo "   • Summary tab: Total capacitance and method"
echo ""

echo "🚀 Starting GUI..."
echo "=================="
echo ""

# Launch the GUI
echo "💡 Usage Instructions:"
echo "1. Click 'Browse...' to select a netlist file (e.g., demo_adderPlus.syn.v)"
echo "2. Library files will be auto-detected from the netlist directory"
echo "3. Select start signal (input) and end signal (output)"
echo "4. Click 'Calculate Capacitance' to perform analysis"
echo "5. View results in the tabbed display"
echo ""

echo "🎨 GUI will open in a new window..."
wish capacitance_gui.tcl &

echo ""
echo "✨ GUI launched successfully!"
echo "🔧 For debugging, check the terminal for error messages"
echo "📝 Close the GUI window when finished"
