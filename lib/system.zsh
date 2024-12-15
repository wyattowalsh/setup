#!/usr/bin/env zsh

# System compatibility and checks module

# Source logging module
source "${0:A:h}/logging.zsh"

# System requirements
declare -r MIN_MACOS_VERSION="11.0"  # Big Sur minimum
declare -r MIN_RAM_GB=4
declare -r MIN_DISK_GB=20

# Check macOS version
check_macos_version() {
    local current_version
    current_version=$(sw_vers -productVersion)
    debug "Current macOS version: $current_version"
    
    if ! version_compare "$current_version" "$MIN_MACOS_VERSION"; then
        error "macOS version $current_version is not supported. Minimum required: $MIN_MACOS_VERSION"
        return 1
    fi
    return 0
}

# Compare version strings
version_compare() {
    local version1="$1"
    local version2="$2"
    
    # Convert versions to comparable numbers
    local v1=$(echo "$version1" | sed 's/[^0-9.]//g' | cut -d. -f1,2)
    local v2=$(echo "$version2" | sed 's/[^0-9.]//g' | cut -d. -f1,2)
    
    if (( $(echo "$v1 >= $v2" | bc -l) )); then
        return 0
    fi
    return 1
}

# Check system resources
check_system_resources() {
    # Check RAM
    local total_ram_gb
    total_ram_gb=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    debug "Total RAM: ${total_ram_gb}GB"
    
    if (( total_ram_gb < MIN_RAM_GB )); then
        error "Insufficient RAM. Required: ${MIN_RAM_GB}GB, Available: ${total_ram_gb}GB"
        return 1
    fi
    
    # Check disk space
    local free_disk_gb
    free_disk_gb=$(df -g / | awk 'NR==2 {print $4}')
    debug "Free disk space: ${free_disk_gb}GB"
    
    if (( free_disk_gb < MIN_DISK_GB )); then
        error "Insufficient disk space. Required: ${MIN_DISK_GB}GB, Available: ${free_disk_gb}GB"
        return 1
    fi
    
    return 0
}

# Check network connectivity with timeout
check_network() {
    local timeout="${1:-10}"
    local test_urls=(
        "https://github.com"
        "https://brew.sh"
        "https://raw.githubusercontent.com"
    )
    
    for url in "${test_urls[@]}"; do
        debug "Testing connectivity to $url"
        if curl --connect-timeout "$timeout" -Is "$url" >/dev/null 2>&1; then
            return 0
        fi
    done
    
    error "No network connectivity. Please check your internet connection"
    return 1
}

# Check for required permissions
check_permissions() {
    # Check if we can sudo
    if ! sudo -n true 2>/dev/null; then
        warn "Administrative privileges will be required for some operations"
        if ! sudo -v; then
            error "Failed to obtain administrative privileges"
            return 1
        fi
    fi
    
    # Keep sudo alive
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
    
    return 0
}

# Check development tools
check_dev_tools() {
    # Check for Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        info "Installing Xcode Command Line Tools..."
        if ! xcode-select --install; then
            error "Failed to install Xcode Command Line Tools"
            return 1
        fi
        # Wait for installation to complete
        until xcode-select -p &>/dev/null; do
            sleep 5
        done
    fi
    
    # Verify git installation
    if ! command -v git &>/dev/null; then
        error "Git is not installed"
        return 1
    fi
    
    return 0
}

# Comprehensive system check
check_system() {
    local checks=(
        "check_macos_version"
        "check_system_resources"
        "check_network"
        "check_permissions"
        "check_dev_tools"
    )
    
    local failed=false
    
    for check in "${checks[@]}"; do
        info "Running $check..."
        if ! "$check"; then
            failed=true
            warn "Check failed: $check"
        fi
    done
    
    if $failed; then
        error "System checks failed"
        return 1
    fi
    
    success "All system checks passed"
    return 0
}

# Export functions
export -f check_macos_version version_compare check_system_resources
export -f check_network check_permissions check_dev_tools check_system 