#!/bin/bash

# Digital Circuit Capacitance Calculator - Installation Script
# Automated setup for cross-platform deployment

set -e  # Exit on any error

echo "🚀 Digital Circuit Capacitance Calculator - Installation"
echo "====================================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions for colored output
error() { echo -e "${RED}❌ ERROR: $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  WARNING: $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  INFO: $1${NC}"; }

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if command -v apt-get &> /dev/null; then
            DISTRO="debian"
        elif command -v yum &> /dev/null; then
            DISTRO="redhat"
        elif command -v pacman &> /dev/null; then
            DISTRO="arch"
        else
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
    
    info "Detected OS: $OS ($DISTRO)"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check system requirements
check_requirements() {
    echo
    info "Checking system requirements..."
    
    local all_good=true
    
    # Check TCL
    if command_exists tclsh; then
        TCL_VERSION=$(tclsh << 'EOF'
puts $tcl_version
EOF
)
        success "TCL found: version $TCL_VERSION"
    else
        error "TCL not found"
        all_good=false
    fi
    
    # Check Wish (Tk)
    if command_exists wish; then
        success "Tk (wish) found"
    else
        error "Tk (wish) not found"
        all_good=false
    fi
    
    # Check memory (Linux/macOS only)
    if [[ "$OS" == "linux" ]]; then
        MEMORY_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        MEMORY_GB=$((MEMORY_KB / 1024 / 1024))
        if [[ $MEMORY_GB -ge 2 ]]; then
            success "Memory: ${MEMORY_GB}GB available"
        else
            warning "Low memory: ${MEMORY_GB}GB (minimum 2GB recommended)"
        fi
    fi
    
    if [[ "$all_good" != true ]]; then
        error "Some requirements are missing. See installation instructions below."
        return 1
    fi
    
    success "All requirements satisfied!"
    return 0
}

# Install dependencies
install_dependencies() {
    echo
    info "Installing dependencies for $OS ($DISTRO)..."
    
    case "$DISTRO" in
        "debian")
            info "Running: sudo apt-get update && sudo apt-get install -y tcl tk tcl-dev tk-dev"
            sudo apt-get update
            sudo apt-get install -y tcl tk tcl-dev tk-dev
            ;;
        "redhat")
            info "Running: sudo yum install -y tcl tk tcl-devel tk-devel"
            sudo yum install -y tcl tk tcl-devel tk-devel
            ;;
        "arch")
            info "Running: sudo pacman -S tk"
            sudo pacman -S tk
            ;;
    esac
    
    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            info "Running: brew install tcl-tk"
            brew install tcl-tk
        else
            warning "Homebrew not found. Please install TCL/Tk manually:"
            echo "  1. Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo "  2. Install TCL/Tk: brew install tcl-tk"
        fi
    fi
}

# Setup project files
setup_project() {
    echo
    info "Setting up project files..."
    
    # Make scripts executable
    if [[ -f "run_gui.sh" ]]; then
        chmod +x run_gui.sh
        success "Made run_gui.sh executable"
    fi
    
    if [[ -f "install.sh" ]]; then
        chmod +x install.sh
        success "Made install.sh executable"
    fi
    
    # Create docs directory if it doesn't exist
    if [[ ! -d "docs" ]]; then
        mkdir -p docs
        info "Created docs directory"
    fi
    
    # Create tests directory if it doesn't exist
    if [[ ! -d "tests" ]]; then
        mkdir -p tests
        info "Created tests directory"
    fi
    
    success "Project setup complete!"
}

# Test installation
test_installation() {
    echo
    info "Testing installation..."
    
    # Test basic TCL functionality
    if tclsh -c "puts {TCL test successful}" &> /dev/null; then
        success "TCL functionality test passed"
    else
        error "TCL functionality test failed"
        return 1
    fi
    
    # Test if main files exist
    local required_files=("capacitance_gui.tcl" "extract_path.tcl" "extract_cap_new.tcl")
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            success "Found required file: $file"
        else
            error "Missing required file: $file"
            return 1
        fi
    done
    
    # Test GUI (if DISPLAY is available)
    if [[ -n "$DISPLAY" ]] || [[ "$OS" == "macos" ]]; then
        info "Testing GUI startup (this may take a moment)..."
        timeout 5 tclsh -c "
            package require Tk
            wm withdraw .
            puts {GUI test successful}
            exit
        " &> /dev/null
        
        if [[ $? -eq 0 ]]; then
            success "GUI test passed"
        else
            warning "GUI test failed (this is OK if running headless)"
        fi
    else
        info "No display available - skipping GUI test"
    fi
    
    success "Installation test completed!"
}

# Main installation process
main() {
    echo
    detect_os
    
    # Check if --auto flag is provided
    AUTO_INSTALL=false
    for arg in "$@"; do
        if [[ "$arg" == "--auto" ]]; then
            AUTO_INSTALL=true
            break
        fi
    done
    
    # Check requirements first
    if ! check_requirements; then
        if [[ "$AUTO_INSTALL" == true ]]; then
            warning "Auto-installing dependencies..."
            install_dependencies
            echo
            info "Re-checking requirements after installation..."
            if ! check_requirements; then
                error "Installation failed. Please install dependencies manually."
                exit 1
            fi
        else
            echo
            warning "Dependencies missing. Install options:"
            echo "  1. Run this script with --auto flag: $0 --auto"
            echo "  2. Install manually using your package manager"
            echo "  3. See README.md for detailed instructions"
            exit 1
        fi
    fi
    
    setup_project
    test_installation
    
    echo
    success "🎉 Installation completed successfully!"
    echo
    info "Quick start:"
    echo "  ./run_gui.sh                    # Launch GUI"
    echo "  tclsh capacitance_gui.tcl       # Alternative launch method"
    echo
    info "Next steps:"
    echo "  1. Place your .v netlist files in this directory"
    echo "  2. Ensure corresponding .lib files are in the same directory"
    echo "  3. Launch the GUI and load your netlist"
    echo
    info "For detailed usage instructions, see README.md"
}

# Run main function
main "$@"
