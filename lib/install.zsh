#!/usr/bin/env zsh

# Package installation module

# Source required modules
source "${0:A:h}/logging.zsh"
source "${0:A:h}/system.zsh"

# Installation settings
declare -r MAX_RETRIES=3
declare -r RETRY_DELAY=5
declare -r PARALLEL_JOBS=$(( $(sysctl -n hw.ncpu) / 2 ))
declare -r INSTALL_TIMEOUT=300

# Package installation status tracking
declare -A INSTALLED_PACKAGES
declare -A FAILED_PACKAGES
declare -A SKIPPED_PACKAGES

# Initialize Homebrew environment
init_homebrew() {
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        error "Homebrew not found in expected locations"
        return 1
    fi
    return 0
}

# Install Homebrew with retry mechanism
install_homebrew() {
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        local retries=$MAX_RETRIES
        local wait_time=$RETRY_DELAY
        
        while (( retries > 0 )); do
            if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                init_homebrew
                success "Homebrew installed successfully"
                return 0
            fi
            
            retries=$((retries - 1))
            if (( retries > 0 )); then
                warn "Homebrew installation failed. Retrying in $wait_time seconds..."
                sleep "$wait_time"
                wait_time=$((wait_time * 2))
            fi
        done
        
        error "Failed to install Homebrew after multiple attempts"
        return 1
    else
        success "Homebrew is already installed"
        init_homebrew
        return 0
    fi
}

# Update Homebrew and upgrade existing packages
update_homebrew() {
    if [[ "${SKIP_UPDATE:-false}" == "true" ]]; then
        info "Skipping Homebrew update"
        return 0
    fi
    
    info "Updating Homebrew..."
    if ! brew update; then
        warn "Homebrew update failed, continuing with installation"
    fi
    
    info "Upgrading existing packages..."
    if ! brew upgrade; then
        warn "Some packages failed to upgrade, continuing with installation"
    fi
    
    return 0
}

# Install a single package with retry mechanism
install_package() {
    local package="$1"
    local type="${2:-brew}"
    local retries=$MAX_RETRIES
    
    # Skip if already installed
    if brew list "$package" &>/dev/null; then
        SKIPPED_PACKAGES[$package]="Already installed"
        debug "Package $package is already installed"
        return 0
    fi
    
    info "Installing $package..."
    while (( retries > 0 )); do
        local output
        case "$type" in
            brew)
                output=$(brew install "$package" 2>&1)
                ;;
            cask)
                output=$(brew install --cask "$package" 2>&1)
                ;;
            *)
                error "Unknown package type: $type"
                return 1
                ;;
        esac
        
        if [[ $? -eq 0 ]]; then
            INSTALLED_PACKAGES[$package]="$type"
            success "Installed $package successfully"
            return 0
        fi
        
        retries=$((retries - 1))
        if (( retries > 0 )); then
            warn "Failed to install $package. Retrying in $RETRY_DELAY seconds..."
            warn "Error: $output"
            sleep "$RETRY_DELAY"
        fi
    done
    
    FAILED_PACKAGES[$package]="$output"
    error "Failed to install $package after $MAX_RETRIES attempts"
    error "Last error: $output"
    return 1
}

# Install packages in parallel
install_packages_parallel() {
    local type="$1"
    shift
    local packages=("$@")
    
    if (( ${#packages[@]} == 0 )); then
        debug "No packages to install for type: $type"
        return 0
    fi
    
    info "Installing ${#packages[@]} $type packages with $PARALLEL_JOBS parallel jobs..."
    
    # Create a temporary directory for status files
    local temp_dir
    temp_dir=$(mktemp -d) || {
        error "Failed to create temporary directory"
        return 1
    }
    
    # Install packages in parallel
    if command -v parallel &>/dev/null; then
        printf '%s\n' "${packages[@]}" | \
            parallel --jobs "$PARALLEL_JOBS" --keep-order \
            "install_package {} $type > '$temp_dir/{}.log' 2>&1"
    else
        printf '%s\n' "${packages[@]}" | \
            xargs -n 1 -P "$PARALLEL_JOBS" -I {} \
            zsh -c "install_package {} $type > '$temp_dir/{}.log' 2>&1"
    fi
    
    # Process logs
    for package in "${packages[@]}"; do
        if [[ -f "$temp_dir/$package.log" ]]; then
            cat "$temp_dir/$package.log"
        fi
    done
    
    # Cleanup
    rm -rf "$temp_dir"
    
    # Check for failures
    if (( ${#FAILED_PACKAGES[@]} > 0 )); then
        error "The following packages failed to install:"
        for package in "${!FAILED_PACKAGES[@]}"; do
            error "  - $package: ${FAILED_PACKAGES[$package]}"
        done
        return 1
    fi
    
    success "All $type packages installed successfully"
    return 0
}

# Print installation summary
print_install_summary() {
    info "Installation Summary:"
    
    if (( ${#INSTALLED_PACKAGES[@]} > 0 )); then
        success "Installed Packages:"
        for package in "${!INSTALLED_PACKAGES[@]}"; do
            success "  - $package (${INSTALLED_PACKAGES[$package]})"
        done
    fi
    
    if (( ${#SKIPPED_PACKAGES[@]} > 0 )); then
        info "Skipped Packages:"
        for package in "${!SKIPPED_PACKAGES[@]}"; do
            info "  - $package (${SKIPPED_PACKAGES[$package]})"
        done
    fi
    
    if (( ${#FAILED_PACKAGES[@]} > 0 )); then
        error "Failed Packages:"
        for package in "${!FAILED_PACKAGES[@]}"; do
            error "  - $package"
            error "    Error: ${FAILED_PACKAGES[$package]}"
        done
    fi
}

# Export functions
export -f init_homebrew install_homebrew update_homebrew
export -f install_package install_packages_parallel print_install_summary 