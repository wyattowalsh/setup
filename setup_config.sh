#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC2296,SC2299,SC2300,SC2301

###################################################
# Configuration settings for setup.zsh
#
# Load package groups and configurations from setup.yaml
###################################################

# Initialize associative arrays
declare -A GROUP_ENABLED
declare -A PACKAGE_GROUPS
declare -A GROUP_DESCRIPTIONS
declare -a SHELL_CONFIGS

# Function to validate YAML structure
validate_yaml() {
    local yaml_file="$1"
    local required_keys=("groups" "shell_configs")
    local key

    # Check file exists and is readable
    if [[ ! -f "$yaml_file" || ! -r "$yaml_file" ]]; then
        print_message "red" "Error: YAML file '$yaml_file' does not exist or is not readable"
        return 1
    fi

    # Check for required top-level keys
    for key in "${required_keys[@]}"; do
        if ! yq eval "has(\"$key\")" "$yaml_file" | grep -q "true"; then
            print_message "red" "Error: Missing required key '$key' in YAML file"
            return 1
        fi
    done

    # Validate groups structure
    local groups
    if ! mapfile -t groups < <(yq eval '.groups | keys | .[]' "$yaml_file"); then
        print_message "red" "Error: Failed to read groups from YAML file"
        return 1
    fi
    
    if (( ${#groups[@]} == 0 )); then
        print_message "red" "Error: No package groups defined in YAML file"
        return 1
    fi
    
    local required_group_fields=("enabled" "packages" "description")
    for group in "${groups[@]}"; do
        for field in "${required_group_fields[@]}"; do
            if ! yq eval ".groups.${group} | has(\"$field\")" "$yaml_file" | grep -q "true"; then
                print_message "red" "Error: Group '$group' missing required field '$field'"
                return 1
            fi
        done
        
        # Validate packages array is not empty
        local package_count
        package_count=$(yq eval ".groups.${group}.packages | length" "$yaml_file")
        if (( package_count == 0 )); then
            print_message "red" "Error: Group '$group' has no packages defined"
            return 1
        fi
    done

    # Validate shell_configs structure
    local config_count
    config_count=$(yq eval '.shell_configs | keys | length' "$yaml_file")
    if (( config_count == 0 )); then
        print_message "yellow" "Warning: No shell configurations defined in YAML file"
    fi

    return 0
}

# Function to load YAML configuration with validation and error handling
load_yaml_config() {
    local yaml_file="${1:-setup.yaml}"
    
    # Check yq installation
    if ! command -v yq &> /dev/null; then
        if ! command -v brew &> /dev/null; then
            print_message "red" "Error: Homebrew is required to install yq"
            return 1
        fi
        print_message "blue" "Installing yq for YAML parsing..."
        if ! brew install yq; then
            print_message "red" "Error: Failed to install yq"
            return 1
        fi
    fi

    # Validate YAML structure
    print_message "blue" "Validating YAML configuration..."
    if ! validate_yaml "$yaml_file"; then
        return 1
    fi

    # Load group configurations with error handling
    print_message "blue" "Loading package groups..."
    local group enabled packages description
    while IFS= read -r group; do
        # Get group status
        if ! enabled=$(yq eval ".groups.${group}.enabled" "$yaml_file"); then
            print_message "red" "Error: Failed to read enabled status for group '$group'"
            return 1
        fi
        GROUP_ENABLED[$group]="$enabled"
        
        # Get group description
        if ! description=$(yq eval ".groups.${group}.description" "$yaml_file"); then
            print_message "yellow" "Warning: Failed to read description for group '$group'"
            description="No description available"
        fi
        GROUP_DESCRIPTIONS[$group]="$description"
        
        # Read packages as an array and join with spaces
        if ! packages=$(yq eval ".groups.${group}.packages[]" "$yaml_file" | tr '\n' ' '); then
            print_message "red" "Error: Failed to read packages for group '$group'"
            return 1
        fi
        PACKAGE_GROUPS[$group]="${packages% }" # Remove trailing space
        
        # Log group loading
        if [[ "${GROUP_ENABLED[$group]}" == "true" ]]; then
            print_message "green" "Loaded group '$group' (enabled): $description"
            print_message "blue" "  Packages: ${packages% }"
        else
            print_message "yellow" "Loaded group '$group' (disabled): $description"
        fi
    done < <(yq eval '.groups | keys | .[]' "$yaml_file")

    # Load shell configurations with error handling
    print_message "blue" "Loading shell configurations..."
    local config_sections section config
    if ! mapfile -t config_sections < <(yq eval '.shell_configs | keys | .[]' "$yaml_file"); then
        print_message "red" "Error: Failed to read shell configuration sections"
        return 1
    fi
    
    for section in "${config_sections[@]}"; do
        print_message "blue" "Loading configuration section: $section"
        local config_count=0
        while IFS= read -r config; do
            if [[ -n "$config" ]]; then
                SHELL_CONFIGS+=("$config")
                ((config_count++))
            fi
        done < <(yq eval ".shell_configs.${section}[]" "$yaml_file")
        print_message "green" "  Loaded $config_count configurations from section '$section'"
    done

    # Validate we have at least one enabled group
    local enabled_count=0
    for group in "${!GROUP_ENABLED[@]}"; do
        if [[ "${GROUP_ENABLED[$group]}" == "true" ]]; then
            ((enabled_count++))
        fi
    done

    if (( enabled_count == 0 )); then
        print_message "yellow" "Warning: No package groups are enabled"
    else
        print_message "green" "Successfully loaded $enabled_count enabled package groups"
    fi

    print_message "green" "Configuration loaded successfully"
    return 0
}

# Function to get all enabled packages with validation
get_enabled_packages() {
    local enabled_packages=""
    local group
    
    # Validate GROUP_ENABLED is populated
    if (( ${#GROUP_ENABLED[@]} == 0 )); then
        print_message "red" "Error: No groups defined in configuration"
        return 1
    fi
    
    # Get packages from enabled groups
    local enabled_count=0
    local package_count=0
    # shellcheck disable=SC2296
    for group in ${(k)GROUP_ENABLED}; do
        if [[ "${GROUP_ENABLED[$group]}" == "true" ]]; then
            ((enabled_count++))
            if [[ -z "${PACKAGE_GROUPS[$group]}" ]]; then
                print_message "yellow" "Warning: No packages defined for enabled group '$group'"
                continue
            fi
            enabled_packages+=" ${PACKAGE_GROUPS[$group]}"
            # Count packages in this group
            package_count+=$(echo "${PACKAGE_GROUPS[$group]}" | wc -w)
        fi
    done
    
    # Validate we have packages to install
    if [[ -z "${enabled_packages# }" ]]; then
        if (( enabled_count > 0 )); then
            print_message "red" "Error: Enabled groups contain no packages"
        else
            print_message "yellow" "Warning: No packages selected for installation"
        fi
        return 1
    fi
    
    print_message "green" "Found $package_count packages in $enabled_count enabled groups"
    
    # Remove leading space and return
    echo "${enabled_packages# }"
}

# Load configuration from YAML file with error handling
YAML_CONFIG="${SCRIPT_DIR:-$PWD}/setup.yaml"
if ! load_yaml_config "$YAML_CONFIG"; then
    print_message "red" "Failed to load configuration from $YAML_CONFIG"
    exit 1
fi

# Set PACKAGES array based on enabled groups
# shellcheck disable=SC2206,SC2296
if ! PACKAGES=(${(f)$(get_enabled_packages)}); then
    print_message "red" "Failed to process enabled packages"
    exit 1
fi

# Final validation
if (( ${#PACKAGES[@]} == 0 )); then
    print_message "yellow" "Warning: No packages selected for installation"
fi

# Log configuration summary
print_message "blue" "Configuration Summary:"
print_message "blue" "  Total Groups: ${#GROUP_ENABLED[@]}"
print_message "blue" "  Enabled Groups: $(print_r "${GROUP_ENABLED[@]}" | grep -c true)"
print_message "blue" "  Total Packages: ${#PACKAGES[@]}"
print_message "blue" "  Shell Configs: ${#SHELL_CONFIGS[@]}"