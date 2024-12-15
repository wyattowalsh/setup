#!/usr/bin/env zsh

###################################################
# Utility functions and core logic for setup.zsh
###################################################

# Enforce strict error handling
setopt ERR_EXIT NO_UNSET PIPE_FAIL

# Set Internal Field Separator
IFS=$'\n\t'

# Ensure VERBOSE has a default value
VERBOSE=${VERBOSE:-false}

# Modified error handling function
handle_error() {
    local exit_code="$?"
    local error_info="${funcfiletrace[1]:-}"
    local error_file="${error_info%%:*}"
    local error_line="${error_info##*:}"
    local last_command="${funcstack[1]:-}"
    log "An error occurred in function '${last_command:-main}' at ${error_file:-unknown}:$error_line. Exit code: $exit_code." "warning"
    # Do not exit the script; continue execution
}

# Trap errors and handle them
trap 'handle_error' ERR

# Logging function with levels and colors
log() {
    local message="$1"
    local level="${2:-info}"
    local color_code

    case "$level" in
        debug)   color_code="34" ;; # Blue
        info)    color_code="32" ;; # Green
        warning) color_code="33" ;; # Yellow
        error)   color_code="31" ;; # Red
        *)       color_code="0"  ;; # Default
    esac

    if $VERBOSE || [[ "$level" != "debug" ]]; then
        printf "\e[%sm[%s][%s] %s\e[0m\n" "$color_code" "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$message"
    fi
}

# Check if a given command exists in the system
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if an application exists in the /Applications directory
app_exists() {
    local app_name="$1"

    # Ensure the app name is not empty
    if [ -z "$app_name" ]; then
        log "Error: app_exists function called with an empty app name." "error"
        return 1
    fi

    # Check for both "AppName.app" and "AppName"
    if [ -d "/Applications/$app_name.app" ] || [ -d "/Applications/$app_name" ]; then
        return 0  # App exists
    else
        return 1  # App does not exist
    fi
}

# Get application names from a cask (using jq for JSON parsing)
get_cask_app_name() {
    local cask_name="$1"
    brew info --cask --json=v2 "$cask_name" 2>/dev/null | jq -r '
        .casks[0].artifacts[] |
        if type=="object" then
            .app[]?
        elif type=="array" and .[0]=="app" then
            .[1]
        else
            empty
        end
    '
}

# Check if a cask is installed via Homebrew
cask_installed() {
    local cask_name="$1"
    brew list --cask "$cask_name" &>/dev/null
}

# New function to list available package groups
list_package_groups() {
    log "Available package groups:"
    for group in "${!GROUP_ENABLED[@]}"; do
        local status="disabled"
        [[ "${GROUP_ENABLED[$group]}" == "true" ]] && status="enabled"
        log "  - $group ($status)" "info"
        if $VERBOSE; then
            local packages=($=PACKAGE_GROUPS[$group])
            for package in "${packages[@]}"; do
                log "    • $package" "debug"
            done
        fi
    done
}

# Enhanced parse_arguments function to handle group management
parse_arguments() {
    VERBOSE=false
    DRY_RUN=false
    SKIP_UPDATES=false
    LIST_GROUPS=false
    ENABLE_GROUP=""
    DISABLE_GROUP=""

    while getopts ":vdshlg:e:d:" opt; do
        case $opt in
            v) VERBOSE=true ;;
            d) DRY_RUN=true; VERBOSE=true ;;
            s) SKIP_UPDATES=true ;;
            l) LIST_GROUPS=true ;;
            e) ENABLE_GROUP="$OPTARG" ;;
            x) DISABLE_GROUP="$OPTARG" ;;
            h)
                print_usage
                exit 0
                ;;
            \?)
                log "Invalid option: -$OPTARG" "error"
                print_usage
                exit 1
                ;;
        esac
    done

    # Handle group management if requested
    if [[ -n "$ENABLE_GROUP" ]]; then
        if [[ -n "${GROUP_ENABLED[$ENABLE_GROUP]}" ]]; then
            GROUP_ENABLED[$ENABLE_GROUP]=true
            log "Enabled package group: $ENABLE_GROUP" "info"
        else
            log "Unknown package group: $ENABLE_GROUP" "error"
            list_package_groups
            exit 1
        fi
    fi

    if [[ -n "$DISABLE_GROUP" ]]; then
        if [[ -n "${GROUP_ENABLED[$DISABLE_GROUP]}" ]]; then
            GROUP_ENABLED[$DISABLE_GROUP]=false
            log "Disabled package group: $DISABLE_GROUP" "info"
        else
            log "Unknown package group: $DISABLE_GROUP" "error"
            list_package_groups
            exit 1
        fi
    fi

    if $LIST_GROUPS; then
        list_package_groups
        exit 0
    fi
}

# Enhanced print_usage function with group management options
print_usage() {
    echo "Usage: ./setup.zsh [options]"
    echo "Options:"
    echo "  -v           : Enable verbose output"
    echo "  -d           : Dry run mode (no changes made)"
    echo "  -s           : Skip updating existing packages"
    echo "  -l           : List available package groups"
    echo "  -e GROUP     : Enable a specific package group"
    echo "  -x GROUP     : Disable a specific package group"
    echo "  -h           : Display this help message"
    echo
    echo "Available package groups:"
    for group in "${!GROUP_ENABLED[@]}"; do
        echo "  - $group"
    done
}

# Load the configuration file
load_config() {
    local config_file="$1"
    if [[ ! -f "$config_file" ]]; then
        log "Configuration file not found: $config_file. Exiting." "error"
        exit 1
    else
        source "$config_file"
    fi
}

# Verify the script is being run on macOS
check_macos_compatibility() {
    if [[ "$(uname)" != "Darwin" ]]; then
        log "This script is intended for macOS only." "error"
        exit 1
    fi

    local macos_version
    macos_version=$(sw_vers -productVersion)
    log "Detected macOS version: $macos_version"

    local min_version="10.15"
    if [[ "$(echo -e "$macos_version\n$min_version" | sort -V | head -n1)" != "$min_version" ]]; then
        log "This script requires at least macOS $min_version. Detected version is $macos_version." "error"
        exit 1
    fi
}

# Check if the script is run as root (should not be)
check_user_privileges() {
    if [[ "$EUID" -eq 0 ]]; then
        log "This script should not be run as root. Please run as a regular user with sudo privileges when necessary." "error"
        exit 1
    fi
}

# Verify all dependencies are installed
check_dependencies() {
    local dependencies=("curl" "git" "jq")

    for dep in "${dependencies[@]}"; do
        if ! command_exists "$dep"; then
            log "Dependency $dep is missing."
            if [[ "$dep" == "git" ]]; then
                log "Attempting to install $dep via Xcode Command Line Tools..."
                if ! $DRY_RUN; then
                    xcode-select --install || true
                    until command_exists git; do
                        sleep 5
                    done
                else
                    log "[DRY-RUN] Would install $dep via Xcode Command Line Tools"
                fi
            elif [[ "$dep" == "jq" ]]; then
                log "Installing $dep via Homebrew..."
                if ! $DRY_RUN; then
                    brew install jq || {
                        log "Failed to install $dep. Please check your network connection." "error"
                        exit 1
                    }
                else
                    log "[DRY-RUN] Would install $dep via Homebrew"
                fi
            else
                log "Please install $dep and rerun the script." "error"
                exit 1
            fi
        fi
    done
}

# Check network connectivity
check_network_connectivity() {
    if ! ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
        log "Network connectivity is required for this script. Please check your connection." "error"
        exit 1
    fi
}

# Install or upgrade a Homebrew formula or cask
install_or_upgrade_brew_item() {
    local item="$1"
    local is_cask="$2"  # "cask" or "formula"

    if [[ "$is_cask" == "cask" ]]; then
        if cask_installed "$item"; then
            log "Cask $item is already installed via Homebrew."
            if ! $SKIP_UPDATES; then
                if brew outdated --cask --quiet "$item" &>/dev/null; then
                    log "Cask $item is outdated. Upgrading..."
                    if ! $DRY_RUN; then
                        brew upgrade --cask "$item" || brew reinstall --cask "$item" || {
                            log "Failed to upgrade cask $item. Continuing to next item." "warning"
                        }
                    else
                        log "[DRY-RUN] Would upgrade/reinstall cask $item"
                    fi
                else
                    log "Cask $item is up-to-date."
                fi
            else
                log "Skipping update for cask $item due to --skip-updates flag."
            fi
        else
            log "Installing cask: $item..."
            if ! $DRY_RUN; then
                brew install --cask "$item" || {
                    log "Failed to install cask $item. Continuing to next item." "warning"
                }
            else
                log "[DRY-RUN] Would install cask $item"
            fi
        fi
    else
        # Handle formula installations
        if brew list --formula --versions "$item" &>/dev/null; then
            if ! $SKIP_UPDATES; then
                if brew outdated --quiet "$item" &>/dev/null; then
                    log "Formula $item is outdated. Upgrading..."
                    if ! $DRY_RUN; then
                        brew upgrade "$item" || brew reinstall "$item" || {
                            log "Failed to upgrade formula $item. Continuing to next item." "warning"
                        }
                    else
                        log "[DRY-RUN] Would upgrade/reinstall formula $item"
                    fi
                else
                    log "Formula $item is up-to-date."
                fi
            else
                log "Skipping update for formula $item due to --skip-updates flag."
            fi
        else
            log "Installing formula: $item..."
            if ! $DRY_RUN; then
                brew install "$item" || {
                    log "Failed to install formula $item. Continuing to next item." "warning"
                }
            else
                log "[DRY-RUN] Would install formula $item"
            fi
        fi
    fi
}

# Enhanced install_brew_items function to handle groups
install_brew_items() {
    log "Installing Homebrew packages based on enabled groups..."
    
    # Get all enabled packages
    local packages=($(get_enabled_packages))
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log "No packages to install - all groups are disabled." "warning"
        return
    }
    
    # Install each package
    for pkg in "${packages[@]}"; do
        # Determine if it's a cask or formula
        if [[ "$pkg" == font-* || -n "$(brew search --casks "^${pkg}$" 2>/dev/null)" ]]; then
            install_or_upgrade_brew_item "$pkg" "cask"
        else
            install_or_upgrade_brew_item "$pkg" "formula"
        fi
    done
}

# Installs Xcode Command Line Tools
install_xcode() {
    if ! xcode-select --print-path &> /dev/null; then
        log "Xcode Command Line Tools are not installed. Installing..."
        if ! $DRY_RUN; then
            xcode-select --install || true
            until xcode-select --print-path &> /dev/null; do
                sleep 5
            done
        else
            log "[DRY-RUN] Would install Xcode Command Line Tools"
        fi
    else
        log "Xcode Command Line Tools are already installed."
    fi
}

# Installs Homebrew on macOS if not present
install_or_update_homebrew() {
    if ! command_exists brew; then
        log "Homebrew is not installed. Installing..."
        if ! $DRY_RUN; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
                log "Homebrew installation failed. Please ensure you have sudo privileges." "error"
                exit 1
            }
            eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)"
        else
            log "[DRY-RUN] Would install Homebrew"
        fi
    else
        if ! $SKIP_UPDATES; then
            log "Updating Homebrew to the latest version..."
            if ! $DRY_RUN; then
                brew update
            else
                log "[DRY-RUN] Would update Homebrew"
            fi
        else
            log "Skipping Homebrew update due to --skip-updates flag."
        fi
    fi
    HOMEBREW_PREFIX="$(brew --prefix)"
}

# Installs Oh My Zsh shell framework
install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "Oh My Zsh is not installed. Installing..."
        if ! $DRY_RUN; then
            RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
                log "Failed to install Oh My Zsh. Please check your network connection." "error"
                exit 1
            }
        else
            log "[DRY-RUN] Would install Oh My Zsh"
        fi
    else
        log "Oh My Zsh is already installed."
    fi
}

# Installs Powerlevel10k Zsh theme
install_powerlevel10k() {
    local theme_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ ! -d "$theme_dir" ]]; then
        log "Powerlevel10k theme is not installed. Installing..."
        if ! $DRY_RUN; then
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir" || {
                log "Failed to clone Powerlevel10k repository. Please check your network connection." "error"
                exit 1
            }
        else
            log "[DRY-RUN] Would install Powerlevel10k theme"
        fi
    else
        log "Powerlevel10k theme is already installed."
    fi
}

# Appends additional shell configurations to .zshrc
append_shell_configs_to_zshrc() {
    local zshrc="$HOME/.zshrc"
    local backup_zshrc="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"

    if [[ -f "$zshrc" && ! -f "$backup_zshrc" ]]; then
        log "Backing up existing .zshrc to $backup_zshrc"
        if ! $DRY_RUN; then
            cp "$zshrc" "$backup_zshrc"
        else
            log "[DRY-RUN] Would backup $zshrc to $backup_zshrc"
        fi
    fi

    for config in "${SHELL_CONFIGS[@]}"; do
        if ! grep -Fqx "$config" "$zshrc" 2> /dev/null; then
            log "Appending configuration to .zshrc: $config"
            if ! $DRY_RUN; then
                echo "$config" >> "$zshrc"
            else
                log "[DRY-RUN] Would append configuration to .zshrc: $config"
            fi
        else
            log "Configuration already present in .zshrc: $config"
        fi
    done
}

# Ensures that Zsh is set as the default shell
check_default_shell() {
    local zsh_path
    zsh_path=$(command -v zsh)
    if [[ "$SHELL" != "$zsh_path" ]]; then
        log "Changing default shell to Zsh..."
        if ! $DRY_RUN; then
            if ! grep -Fxq "$zsh_path" /etc/shells; then
                echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null || {
                    log "Failed to add $zsh_path to /etc/shells. Please ensure you have sudo privileges." "error"
                    exit 1
                }
            fi
            chsh -s "$zsh_path" || {
                log "Failed to change the default shell. Please ensure you have the necessary permissions." "error"
                exit 1
            }
        else
            log "[DRY-RUN] Would change default shell to Zsh"
        fi
    else
        log "Zsh is already set as the default shell."
    fi
}

# Enhanced main function to handle group management
main() {
    log "Running setup.zsh version $SCRIPT_VERSION" "info"
    
    # If no specific actions are requested, show current group status
    if [[ $# -eq 0 ]]; then
        list_package_groups
    fi
    
    check_macos_compatibility
    check_user_privileges
    check_network_connectivity
    check_dependencies
    install_xcode
    install_or_update_homebrew
    install_brew_items
    install_oh_my_zsh
    install_powerlevel10k
    append_shell_configs_to_zshrc
    check_default_shell
    
    log "Setup completed successfully." "info"
    log "Please restart your terminal or source your .zshrc to apply changes."
}