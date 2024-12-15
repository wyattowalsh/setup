#!/usr/bin/env zsh

# Configuration management for setup script

# Source logging module
source "${0:A:h}/logging.zsh"

# Default configuration file
declare -r DEFAULT_CONFIG="setup.yaml"

# Environment states
declare -A ENVIRONMENTS

# Package lists
declare -A BREW_PACKAGES
declare -A CASK_PACKAGES
declare -A NPM_PACKAGES
declare -A PIP_PACKAGES

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

# Get enabled environments
get_enabled_environments() {
    local -a enabled=()
    for env in "${(k)ENVIRONMENTS[@]}"; do
        if [[ "${ENVIRONMENTS[$env]}" == "true" ]]; then
            enabled+=("$env")
        fi
    done
    echo "${enabled[@]}"
}

# Get packages for an environment
get_environment_packages() {
    local env_name="$1"
    local type="$2"
    local -a packages=()
    
    for package in "${(k)BREW_PACKAGES[@]}"; do
        if [[ "${BREW_PACKAGES[$package]}" == "$env_name" ]]; then
            packages+=("$package")
        fi
    done
    
    echo "${packages[@]}"
}

# Validate configuration
validate_config() {
    local config_file="${1:-$DEFAULT_CONFIG}"
    
    if [[ ! -f "$config_file" ]]; then
        error "Configuration file not found: $config_file"
        return 1
    }
    
    # Check for required sections
    if ! yq e '.environments' "$config_file" >/dev/null 2>&1; then
        error "Missing required section: environments"
        return 1
    }
    
    # Validate environment structure
    while IFS= read -r env; do
        if ! yq e ".environments.$env.enabled" "$config_file" >/dev/null 2>&1; then
            error "Missing 'enabled' field for environment: $env"
            return 1
        fi
        
        if ! yq e ".environments.$env.packages" "$config_file" >/dev/null 2>&1; then
            error "Missing 'packages' field for environment: $env"
            return 1
        fi
    done < <(yq e '.environments | keys | .[]' "$config_file")
    
    return 0
}

# Export functions
export -f load_config load_package_list get_enabled_environments get_environment_packages validate_config 