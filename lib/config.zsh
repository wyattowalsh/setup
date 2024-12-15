#!/usr/bin/env zsh

# Configuration management for setup script

# Source logging module
source "${0:A:h}/logging.zsh"

# Default configuration file
typeset -r DEFAULT_CONFIG="setup.yaml"

# Environment states
typeset -A ENVIRONMENTS

# Package lists
typeset -A BREW_PACKAGES
typeset -A CASK_PACKAGES
typeset -A NPM_PACKAGES
typeset -A PIP_PACKAGES

# Load YAML configuration
load_config() {
    local config_file="${1:-$DEFAULT_CONFIG}"
    
    if [[ ! -f "$config_file" ]]; then
        error "Configuration file not found: $config_file"
        return 1
    }
    
    debug "Loading configuration from $config_file"
    
    # Parse YAML using yq
    if ! command -v yq >/dev/null; then
        error "yq is required for YAML parsing"
        return 1
    }
    
    # Load environments
    while IFS= read -r line; do
        local env_name="$(echo "$line" | cut -d' ' -f1)"
        local enabled="$(echo "$line" | cut -d' ' -f2)"
        ENVIRONMENTS[$env_name]="$enabled"
    done < <(yq e '.environments | to_entries | .[] | .key + " " + (.value.enabled | @text)' "$config_file")
    
    # Load package lists
    load_package_list "$config_file" "brew" BREW_PACKAGES
    load_package_list "$config_file" "cask" CASK_PACKAGES
    load_package_list "$config_file" "npm" NPM_PACKAGES
    load_package_list "$config_file" "pip" PIP_PACKAGES
    
    debug "Configuration loaded successfully"
    return 0
}

# Load package list from configuration
load_package_list() {
    local config_file="$1"
    local type="$2"
    local -n packages="$3"
    
    while IFS= read -r line; do
        local env_name="$(echo "$line" | cut -d' ' -f1)"
        local package="$(echo "$line" | cut -d' ' -f2)"
        packages[$package]="$env_name"
    done < <(yq e ".environments.*.packages[] | select(. == \"*.$type.*\") | parent | parent | parent | key + \" \" + ." "$config_file" 2>/dev/null)
}

# Enable an environment
enable_environment() {
    local env_name="$1"
    local config_file="${2:-$DEFAULT_CONFIG}"
    
    if [[ ! -f "$config_file" ]]; then
        error "Configuration file not found: $config_file"
        return 1
    }
    
    if ! yq e ".environments.$env_name" "$config_file" >/dev/null 2>&1; then
        error "Environment not found: $env_name"
        return 1
    }
    
    debug "Enabling environment: $env_name"
    yq e -i ".environments.$env_name.enabled = true" "$config_file"
    ENVIRONMENTS[$env_name]="true"
    
    success "Enabled environment: $env_name"
    return 0
}

# Disable an environment
disable_environment() {
    local env_name="$1"
    local config_file="${2:-$DEFAULT_CONFIG}"
    
    if [[ ! -f "$config_file" ]]; then
        error "Configuration file not found: $config_file"
        return 1
    }
    
    if ! yq e ".environments.$env_name" "$config_file" >/dev/null 2>&1; then
        error "Environment not found: $env_name"
        return 1
    }
    
    debug "Disabling environment: $env_name"
    yq e -i ".environments.$env_name.enabled = false" "$config_file"
    ENVIRONMENTS[$env_name]="false"
    
    success "Disabled environment: $env_name"
    return 0
}

# List available environments
list_environments() {
    local config_file="${1:-$DEFAULT_CONFIG}"
    
    if [[ ! -f "$config_file" ]]; then
        error "Configuration file not found: $config_file"
        return 1
    }
    
    heading "Available Environments" 1 "$SYMBOLS[folder]"
    
    local -a headers=("Environment" "Status" "Packages")
    local -a rows=()
    
    while IFS= read -r line; do
        local env_name="$(echo "$line" | cut -d' ' -f1)"
        local enabled="$(echo "$line" | cut -d' ' -f2)"
        local packages="$(yq e ".environments.$env_name.packages | length" "$config_file")"
        
        local status_symbol
        if [[ "$enabled" == "true" ]]; then
            status_symbol="${SYMBOLS[success]}"
        else
            status_symbol="${SYMBOLS[pending]}"
        fi
        
        rows+=("$env_name" "$status_symbol" "$packages")
    done < <(yq e '.environments | to_entries | .[] | .key + " " + (.value.enabled | @text)' "$config_file")
    
    table headers rows
    echo
    
    info "Use ${BOLD}-e${NC} to enable or ${BOLD}-x${NC} to disable environments"
    return 0
}

# Get enabled environments
get_enabled_environments() {
    local -a enabled=()
    local env
    for env in "${(k)ENVIRONMENTS[@]}"; do
        [[ "${ENVIRONMENTS[$env]}" == "true" ]] && enabled+=("$env")
    done
    echo "${enabled[@]}"
}

# Get packages for environment
get_environment_packages() {
    local env_name="$1"
    local type="$2"
    local config_file="${3:-$DEFAULT_CONFIG}"
    
    yq e ".environments.$env_name.packages[] | select(. == \"*.$type.*\")" "$config_file" 2>/dev/null
}

# Validate configuration
validate_config() {
    local config_file="${1:-$DEFAULT_CONFIG}"
    
    if [[ ! -f "$config_file" ]]; then
        error "Configuration file not found: $config_file"
        return 1
    }
    
    debug "Validating configuration: $config_file"
    
    # Check basic YAML syntax
    if ! yq e '.' "$config_file" >/dev/null 2>&1; then
        error "Invalid YAML syntax in configuration file"
        return 1
    }
    
    # Check required sections
    if ! yq e '.environments' "$config_file" >/dev/null 2>&1; then
        error "Missing required section: environments"
        return 1
    }
    
    # Validate environment structure
    while IFS= read -r env; do
        if ! yq e ".environments.$env.enabled" "$config_file" >/dev/null 2>&1; then
            error "Missing 'enabled' field in environment: $env"
            return 1
        fi
        
        if ! yq e ".environments.$env.packages" "$config_file" >/dev/null 2>&1; then
            error "Missing 'packages' field in environment: $env"
            return 1
        fi
    done < <(yq e '.environments | keys | .[]' "$config_file")
    
    success "Configuration validation passed"
    return 0
}

# Export functions
typeset -fx load_config load_package_list enable_environment disable_environment
typeset -fx list_environments get_enabled_environments get_environment_packages
typeset -fx validate_config 