#!/usr/bin/env zsh

# Configuration management for setup script

# Source logging module
source "${0:A:h}/logging.zsh"

# Default configuration file
declare -r DEFAULT_CONFIG="setup.yaml"

# Package lists by group
declare -A PACKAGE_GROUPS

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
    
    # Load package groups
    while IFS= read -r group; do
        local packages=($(yq e ".groups.$group.packages[]" "$config_file" 2>/dev/null))
        if (( ${#packages[@]} > 0 )); then
            PACKAGE_GROUPS[$group]="${packages[*]}"
            debug "Loaded ${#packages[@]} packages for group: $group"
        fi
    done < <(yq e '.groups | keys | .[]' "$config_file" 2>/dev/null)
    
    # Validate we loaded something
    if (( ${#PACKAGE_GROUPS[@]} == 0 )); then
        error "No valid package groups found in configuration"
        return 1
    fi
    
    debug "Configuration loaded successfully"
    debug "Found ${#PACKAGE_GROUPS[@]} package groups"
    return 0
}

# Get all configured groups
get_configured_groups() {
    echo "${(k)PACKAGE_GROUPS[@]}"
}

# Get packages for a group
get_group_packages() {
    local group_name="$1"
    local type="$2"
    local -a packages=()
    
    # If group exists, filter packages by type
    if [[ -n "${PACKAGE_GROUPS[$group_name]}" ]]; then
        local all_packages=(${=PACKAGE_GROUPS[$group_name]})
        for package in "${all_packages[@]}"; do
            # Match package type based on common patterns
            case "$type" in
                brew)
                    # Exclude cask packages and font packages
                    if [[ "$package" != *".cask"* && "$package" != "font-"* ]]; then
                        packages+=("$package")
                    fi
                    ;;
                cask)
                    # Include .cask packages and font packages
                    if [[ "$package" == *".cask"* || "$package" == "font-"* ]]; then
                        packages+=("$package")
                    fi
                    ;;
                npm)
                    # Include npm packages
                    if [[ "$package" == "npm:"* ]]; then
                        packages+=("${package#npm:}")
                    fi
                    ;;
                pip)
                    # Include pip packages
                    if [[ "$package" == "pip:"* ]]; then
                        packages+=("${package#pip:}")
                    fi
                    ;;
            esac
        done
    fi
    
    echo "${packages[@]}"
}

# Validate configuration
validate_config() {
    local config_file="${1:-$DEFAULT_CONFIG}"
    
    if [[ ! -f "$config_file" ]]; then
        error "Configuration file not found: $config_file"
        return 1
    }
    
    # Basic YAML syntax check
    if ! yq e '.' "$config_file" >/dev/null 2>&1; then
        error "Invalid YAML syntax in configuration file"
        return 1
    }
    
    # Check for groups section
    if ! yq e '.groups' "$config_file" >/dev/null 2>&1; then
        error "Missing required section: groups"
        return 1
    }
    
    # Validate each group has packages
    local invalid_groups=()
    while IFS= read -r group; do
        if ! yq e ".groups.$group.packages" "$config_file" >/dev/null 2>&1; then
            invalid_groups+=("$group")
        fi
    done < <(yq e '.groups | keys | .[]' "$config_file")
    
    if (( ${#invalid_groups[@]} > 0 )); then
        warn "The following groups are missing package lists:"
        printf '%s\n' "${invalid_groups[@]}" | sed 's/^/  - /'
    fi
    
    return 0
}

# Export functions
export -f load_config get_configured_groups get_group_packages validate_config