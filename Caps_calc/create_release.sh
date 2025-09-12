#!/bin/bash

# Project Structure Setup Script
# Creates clean directory structure for distribution

echo "📁 Setting up project structure for distribution..."

# Create main directories
mkdir -p release/capacitance-calculator
mkdir -p release/capacitance-calculator/docs
mkdir -p release/capacitance-calculator/examples
mkdir -p release/capacitance-calculator/tests

# Core files to include in release
core_files=(
    "capacitance_gui.tcl"
    "extract_path.tcl" 
    "extract_cap_new.tcl"
    "run_gui.sh"
    "install.sh"
    "README.md"
    "LICENSE"
)

# Copy core files
echo "📋 Copying core files..."
for file in "${core_files[@]}"; do
    if [[ -f "$file" ]]; then
        cp "$file" "release/capacitance-calculator/"
        echo "✅ Copied $file"
    else
        echo "⚠️  Warning: $file not found"
    fi
done

# Copy documentation
echo "📚 Copying documentation..."
if [[ -d "docs" ]]; then
    cp -r docs/* release/capacitance-calculator/docs/ 2>/dev/null || true
fi

# Copy example files (smaller ones only)
echo "🧪 Copying example files..."
example_files=(
    "demo_adderPlus.syn.v"
    "demo_parallel.syn.v" 
    "dummy_parallel.syn.v"
)

for file in "${example_files[@]}"; do
    if [[ -f "$file" ]]; then
        cp "$file" "release/capacitance-calculator/examples/"
        echo "✅ Copied example: $file"
    fi
done

# Create a minimal example library (extract from existing)
echo "📦 Creating example library..."
if [[ -f "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib" ]]; then
    # Extract first 1000 lines for a demo library
    head -1000 "scmetro_tsmc_cl013g_rvt_tt_1p2v_25c.lib" > "release/capacitance-calculator/examples/demo.lib"
    echo "library(\"demo\") {" >> "release/capacitance-calculator/examples/demo.lib"
    echo "}" >> "release/capacitance-calculator/examples/demo.lib"
    echo "✅ Created demo.lib"
fi

# Make scripts executable
chmod +x release/capacitance-calculator/*.sh

# Create VERSION file
echo "1.0.0" > release/capacitance-calculator/VERSION

# Create distribution info
cat > release/capacitance-calculator/DISTRIBUTION.md << 'EOF'
# Distribution Package

This is a portable distribution of the Digital Circuit Capacitance Path Calculator.

## Quick Start

1. Extract this package to any directory
2. Run the installation: `./install.sh --auto`
3. Launch the GUI: `./run_gui.sh`

## Package Contents

- **Core Application**: TCL/Tk based GUI and calculation engine
- **Documentation**: Complete usage guides and technical documentation  
- **Examples**: Sample netlists and libraries for testing
- **Installation**: Automated setup script for multiple platforms

## System Requirements

- TCL/Tk 8.5+ (will be installed automatically if missing)
- Linux, macOS, or Windows with WSL
- 2GB+ RAM recommended
- GUI environment (X11, macOS GUI, or Windows desktop)

For detailed instructions, see README.md
EOF

echo ""
echo "🎉 Distribution package created in: release/capacitance-calculator/"
echo ""
echo "📦 Package contents:"
ls -la release/capacitance-calculator/
echo ""
echo "🚀 To create distributable archive:"
echo "   cd release && tar -czf capacitance-calculator-v1.0.0.tar.gz capacitance-calculator/"
echo "   or"
echo "   cd release && zip -r capacitance-calculator-v1.0.0.zip capacitance-calculator/"
