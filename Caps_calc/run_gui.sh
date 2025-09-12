#!/bin/bash

# Capacitance Calculator GUI Test Script
# This script demonstrates how to use the GUI

echo "🚀 Capacitance Calculator GUI Test"
echo "=================================="
echo ""

# Check if required files exist
echo "📁 Checking required files..."
if [ ! -f "capacitance_gui.tcl" ]; then
    echo "❌ ERROR: capacitance_gui.tcl not found!"
    exit 1
fi

if [ ! -f "extract_path.tcl" ]; then
    echo "❌ ERROR: extract_path.tcl not found!"
    exit 1
fi

if [ ! -f "extract_cap_new.tcl" ]; then
    echo "❌ ERROR: extract_cap_new.tcl not found!"
    exit 1
fi

echo "✅ All required files found"
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
