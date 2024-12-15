#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC2296,SC2299,SC2300,SC2301

###################################################
# Main setup script for macOS development environment
###################################################

# Set strict error handling
setopt ERR_EXIT
setopt PIPE_FAIL
setopt NO_UNSET

# Set script version
SCRIPT_VERSION="2.0.0"

# Get the directory where the script is located
SCRIPT_DIR="${0:A:h}"

# Set up cleanup trap
cleanup() {
    local exit_code=$?
    print_message "blue" "Cleaning up..."
    
    # Remove any temporary files or directories here
    rm -rf "${SCRIPT_DIR}/.tmp" 2>/dev/null
    
    # Report final status
    if (( exit_code == 0 )); then
        print_message "green" "Setup completed successfully"
    else
        print_message "red" "Setup failed with exit code $exit_code"
    fi
    
    exit "$exit_code"
}

# Set up signal handlers
handle_signal() {
    local signal=$1
    print_message "yellow" "Received signal: $signal"
    cleanup
}

# Register cleanup and signal handlers
trap cleanup EXIT
trap 'handle_signal INT' INT
trap 'handle_signal TERM' TERM

# Function to check system requirements
check_system_requirements() {
    # Check macOS version
    local macos_version
    macos_version=$(sw_vers -productVersion)
    local min_version="10.15"
    
    if [[ "$(printf '%s\n' "$min_version" "$macos_version" | sort -V | head -n1)" != "$min_version" ]]; then
        print_message "red" "This script requires macOS $min_version or later. You have $macos_version"
        return 1
    fi
    
    # Check available disk space (need at least 10GB)
    local available_space
    available_space=$(df -h / | awk 'NR==2 {print $4}' | sed 's/[^0-9.]//g')
    if (( $(echo "$available_space < 10" | bc -l) )); then
        print_message "red" "Insufficient disk space. Need at least 10GB, have ${available_space}GB"
        return 1
    fi
    
    # Check internet connectivity
    if ! curl -s --connect-timeout 5 "https://api.github.com" >/dev/null; then
        print_message "red" "No internet connectivity"
        return 1
    fi
    
    # Check if running on Apple Silicon or Intel
    local arch
    arch=$(uname -m)
    print_message "blue" "Detected architecture: $arch"
    if [[ "$arch" == "arm64" ]]; then
        print_message "blue" "Running on Apple Silicon"
    else
        print_message "blue" "Running on Intel"
    fi
    
    return 0
}

# Function to verify script dependencies
verify_dependencies() {
    local missing_deps=()
    local dep
    
    for dep in curl git bc; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if (( ${#missing_deps[@]} > 0 )); then
        print_message "red" "Missing required dependencies: ${missing_deps[*]}"
        print_message "yellow" "Please install the missing dependencies and try again"
        return 1
    fi
    
    return 0
}

# Source required files with error handling
source_required_files() {
    local file
    for file in setup_functions.sh setup_config.sh; do
        local filepath="${SCRIPT_DIR}/${file}"
        if [[ ! -f "$filepath" ]]; then
            print_message "red" "Required file not found: $file"
            return 1
        fi
        
        if ! source "$filepath"; then
            print_message "red" "Failed to source $file"
            return 1
        fi
    done
    return 0
}

# Function to parse command line arguments
parse_arguments() {
    local opt OPTIND
    while getopts ":vh" opt; do
        case ${opt} in
            v)
                print_message "blue" "Script version: $SCRIPT_VERSION"
                return 1
                ;;
            h)
                print_message "blue" "Usage: $0 [-v] [-h]"
                print_message "blue" "  -v: Print version"
                print_message "blue" "  -h: Show this help message"
                return 1
                ;;
            \?)
                print_message "red" "Invalid option: -$OPTARG"
                return 1
                ;;
            :)
                print_message "red" "Option -$OPTARG requires an argument"
                return 1
                ;;
        esac
    done
    return 0
}

# Main script execution
main() {
    print_message "blue" "Starting setup (version $SCRIPT_VERSION)"
    
    # Create temporary directory
    mkdir -p "${SCRIPT_DIR}/.tmp"
    
    # Process command line arguments
    if ! parse_arguments "$@"; then
        return $?
    fi
    
    # Check if running as root
    if [[ "$EUID" -eq 0 ]]; then
        print_message "red" "This script should not be run as root"
        return 1
    fi
    
    # Check system requirements
    print_message "blue" "Checking system requirements..."
    if ! check_system_requirements; then
        print_message "red" "System requirements not met"
        return 1
    fi
    
    # Verify dependencies
    print_message "blue" "Verifying dependencies..."
    if ! verify_dependencies; then
        print_message "red" "Missing required dependencies"
        return 1
    fi
    
    # Source required files
    print_message "blue" "Loading required files..."
    if ! source_required_files; then
        print_message "red" "Failed to load required files"
        return 1
    fi
    
    # Run the main setup
    print_message "blue" "Running main setup..."
    if ! setup_environment; then
        print_message "red" "Setup failed"
        return 1
    fi
    
    print_message "green" "Setup completed successfully"
    print_message "yellow" "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    return 0
}

# Run main function with proper error handling
if ! main "$@"; then
    exit 1
fi

exit 0