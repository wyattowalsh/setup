#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC2296,SC2299,SC2300,SC2301

###################################################
# Functions for setup.zsh
###################################################

# Set error handling
setopt ERR_EXIT
setopt PIPE_FAIL
setopt NO_UNSET

# Set default values
: "${PARALLEL_JOBS:=4}"
: "${INSTALL_TIMEOUT:=300}"
: "${NETWORK_TIMEOUT:=30}"

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print a message with color and timestamp
print_message() {
    local color="$1"
    local message="$2"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    
    case "$color" in
        "red") printf "\033[0;31m[%s] %s\033[0m\n" "$timestamp" "$message" ;;
        "green") printf "\033[0;32m[%s] %s\033[0m\n" "$timestamp" "$message" ;;
        "yellow") printf "\033[0;33m[%s] %s\033[0m\n" "$timestamp" "$message" ;;
        "blue") printf "\033[0;34m[%s] %s\033[0m\n" "$timestamp" "$message" ;;
        *) printf "[%s] %s\n" "$timestamp" "$message" ;;
    esac
}

# Check network connectivity
check_network() {
    local timeout="${1:-$NETWORK_TIMEOUT}"
    if ! curl -s --connect-timeout "$timeout" "https://api.github.com" >/dev/null; then
        print_message "red" "No network connectivity. Please check your connection."
        return 1
    fi
    return 0
}

# Install Homebrew with retry mechanism
install_homebrew() {
    if ! command_exists brew; then
        print_message "blue" "Installing Homebrew..."
        local retries=3
        local wait_time=5
        
        while (( retries > 0 )); do
            if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                # Initialize Homebrew environment
                if [[ -x /opt/homebrew/bin/brew ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                elif [[ -x /usr/local/bin/brew ]]; then
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
                print_message "green" "Homebrew installed successfully"
                return 0
            fi
            
            retries=$((retries - 1))
            if (( retries > 0 )); then
                print_message "yellow" "Homebrew installation failed. Retrying in $wait_time seconds..."
                sleep "$wait_time"
                wait_time=$((wait_time * 2))
            fi
        done
        
        print_message "red" "Failed to install Homebrew after multiple attempts"
        return 1
    else
        print_message "green" "Homebrew is already installed"
        return 0
    fi
}

# Install yq with retry mechanism
install_yq() {
    if ! command_exists yq; then
        print_message "blue" "Installing yq for YAML parsing..."
        local retries=3
        while (( retries > 0 )); do
            if brew install yq; then
                print_message "green" "yq installed successfully"
                return 0
            fi
            retries=$((retries - 1))
            (( retries > 0 )) && sleep 5
        done
        print_message "red" "Failed to install yq"
        return 1
    else
        print_message "green" "yq is already installed"
        return 0
    fi
}

# Install Oh My Zsh with better error handling
install_oh_my_zsh() {
    local omz_dir="$HOME/.oh-my-zsh"
    if [[ ! -d "$omz_dir" ]]; then
        print_message "blue" "Installing Oh My Zsh..."
        if ! check_network; then
            return 1
        fi
        
        # Backup existing zsh configuration
        if [[ -f "$HOME/.zshrc" ]]; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
        fi
        
        # Install Oh My Zsh
        if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
            print_message "red" "Failed to install Oh My Zsh"
            return 1
        fi
        
        print_message "green" "Oh My Zsh installed successfully"
    else
        print_message "green" "Oh My Zsh is already installed"
    fi
    return 0
}

# Install Powerlevel10k with better error handling
install_powerlevel10k() {
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ ! -d "$p10k_dir" ]]; then
        print_message "blue" "Installing Powerlevel10k theme..."
        if ! check_network; then
            return 1
        fi
        
        if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"; then
            print_message "red" "Failed to install Powerlevel10k"
            return 1
        fi
        
        print_message "green" "Powerlevel10k installed successfully"
    else
        print_message "green" "Powerlevel10k is already installed"
    fi
    return 0
}

# Parallel package installation helper
install_package_parallel() {
    local package="$1"
    local success=false
    local output
    
    if ! brew list "$package" &>/dev/null; then
        print_message "blue" "Installing $package..."
        
        # Try installing as a formula first
        if output=$(brew install "$package" 2>&1); then
            success=true
        # If formula fails, try as a cask
        elif output=$(brew install --cask "$package" 2>&1); then
            success=true
        fi
        
        if ! $success; then
            print_message "red" "Failed to install $package: ${output}"
            echo "$package" >> "$FAILED_PACKAGES_FILE"
        else
            print_message "green" "$package installed successfully"
        fi
    else
        print_message "green" "$package is already installed"
    fi
}

# Enhanced package installation with parallelization
install_packages() {
    print_message "blue" "Installing packages from enabled groups..."
    
    # Create temporary directory for parallel installation
    local temp_dir
    temp_dir=$(mktemp -d) || {
        print_message "red" "Failed to create temporary directory"
        return 1
    }
    
    # Set up temporary files
    export FAILED_PACKAGES_FILE="$temp_dir/failed_packages"
    touch "$FAILED_PACKAGES_FILE"
    
    # Update Homebrew and upgrade existing packages
    print_message "blue" "Updating Homebrew..."
    if ! brew update; then
        print_message "yellow" "Homebrew update failed, continuing with installation"
    fi
    
    print_message "blue" "Upgrading existing packages..."
    if ! brew upgrade; then
        print_message "yellow" "Some packages failed to upgrade, continuing with installation"
    fi

    # Install packages in parallel
    local all_packages=()
    # shellcheck disable=SC2296
    for group in ${(k)GROUP_ENABLED}; do
        if [[ "${GROUP_ENABLED[$group]}" == "true" ]]; then
            print_message "yellow" "Processing group: $group"
            # shellcheck disable=SC2296
            all_packages+=("${=PACKAGE_GROUPS[$group]}")
        fi
    done
    
    if (( ${#all_packages[@]} > 0 )); then
        print_message "blue" "Installing ${#all_packages[@]} packages with $PARALLEL_JOBS parallel jobs..."
        
        # Use GNU Parallel if available, otherwise fallback to xargs
        if command_exists parallel; then
            printf '%s\n' "${all_packages[@]}" | \
                parallel --jobs "$PARALLEL_JOBS" --keep-order \
                "install_package_parallel {}"
        else
            printf '%s\n' "${all_packages[@]}" | \
                xargs -n 1 -P "$PARALLEL_JOBS" -I {} \
                zsh -c 'install_package_parallel "$@"' _ {}
        fi
    fi

    # Clean up
    brew cleanup

    # Check for failures
    local failed_packages=()
    if [[ -f "$FAILED_PACKAGES_FILE" ]]; then
        mapfile -t failed_packages < "$FAILED_PACKAGES_FILE"
    fi
    
    # Clean up temporary directory
    rm -rf "$temp_dir"

    if (( ${#failed_packages[@]} > 0 )); then
        print_message "red" "The following packages failed to install:"
        printf '%s\n' "${failed_packages[@]}"
        return 1
    fi

    print_message "green" "All packages installed successfully"
    return 0
}

# Enhanced shell configuration
configure_shell() {
    print_message "blue" "Configuring shell environment..."

    local zshrc="$HOME/.zshrc"
    local temp_file
    temp_file=$(mktemp) || {
        print_message "red" "Failed to create temporary file"
        return 1
    }

    # Create .zshrc if it doesn't exist
    touch "$zshrc" || {
        print_message "red" "Failed to create/touch .zshrc"
        rm -f "$temp_file"
        return 1
    }

    # Backup existing configuration
    if [[ -f "$zshrc" ]]; then
        cp "$zshrc" "$zshrc.backup.$(date +%Y%m%d%H%M%S)" || {
            print_message "red" "Failed to backup existing .zshrc"
            rm -f "$temp_file"
            return 1
        }
    fi

    # Add shell configurations from YAML
    print_message "blue" "Adding shell configurations..."
    
    {
        echo "# Generated by setup.zsh"
        echo "# Do not edit this section manually"
        echo
        printf '%s\n' "${SHELL_CONFIGS[@]}"
        echo "# End of generated configurations"
    } > "$temp_file" || {
        print_message "red" "Failed to write configurations to temporary file"
        rm -f "$temp_file"
        return 1
    }

    # Check if configurations already exist in .zshrc
    if grep -q "# Generated by setup.zsh" "$zshrc"; then
        # Replace existing configurations
        sed -i.bak '/# Generated by setup.zsh/,/# End of generated configurations/d' "$zshrc" || {
            print_message "red" "Failed to remove existing configurations"
            rm -f "$temp_file"
            return 1
        }
    fi

    # Add new configurations
    cat "$temp_file" >> "$zshrc" || {
        print_message "red" "Failed to append configurations to .zshrc"
        rm -f "$temp_file"
        return 1
    }

    # Clean up
    rm -f "$temp_file"

    print_message "green" "Shell environment configured successfully"
    
    # Create zsh functions directory if it doesn't exist
    mkdir -p "$HOME/.zfunc" || {
        print_message "red" "Failed to create .zfunc directory"
        return 1
    }
    
    return 0
}

# Enhanced main setup function with better error handling and cleanup
setup_environment() {
    print_message "blue" "Starting environment setup..."
    
    # Check network connectivity first
    if ! check_network; then
        return 1
    fi
    
    # Create trap for cleanup
    trap 'print_message "red" "Setup interrupted. Cleaning up..."; rm -rf "$temp_dir" 2>/dev/null' INT TERM EXIT
    
    # Install core dependencies
    local step_failed=false
    
    install_homebrew || step_failed=true
    if $step_failed; then
        print_message "red" "Failed to install/configure Homebrew"
        return 1
    fi
    
    install_yq || step_failed=true
    if $step_failed; then
        print_message "red" "Failed to install yq"
        return 1
    fi
    
    install_oh_my_zsh || step_failed=true
    if $step_failed; then
        print_message "red" "Failed to install Oh My Zsh"
        return 1
    fi
    
    install_powerlevel10k || step_failed=true
    if $step_failed; then
        print_message "red" "Failed to install Powerlevel10k"
        return 1
    fi
    
    # Install packages from enabled groups
    install_packages || step_failed=true
    if $step_failed; then
        print_message "red" "Some packages failed to install"
        return 1
    fi
    
    # Configure shell environment
    configure_shell || step_failed=true
    if $step_failed; then
        print_message "red" "Failed to configure shell environment"
        return 1
    fi
    
    # Remove trap and clean up
    trap - INT TERM EXIT
    
    print_message "green" "Environment setup completed successfully"
    print_message "yellow" "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    return 0
}