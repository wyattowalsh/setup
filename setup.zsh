#!/usr/bin/env zsh

# Source required modules
SCRIPT_DIR="${0:A:h}"
source "$SCRIPT_DIR/lib/logging.zsh"
source "$SCRIPT_DIR/lib/system.zsh"
source "$SCRIPT_DIR/lib/config.zsh"
source "$SCRIPT_DIR/lib/install.zsh"

# Script settings
declare -i VERBOSE=0
declare -i DRY_RUN=0
declare -i SKIP_UPDATE=0
declare -r CONFIG_FILE="$SCRIPT_DIR/setup.yaml"

# Print welcome message
print_welcome() {
    cat << EOF

${BLUE}${BOLD}🖥️  macOS Development Environment Setup${NC}
${DIM}Automated setup for a productive development environment${NC}

EOF
}

# Print completion message
print_completion() {
    local duration=$1
    cat << EOF

${GREEN}${BOLD}${ROCKET} Setup completed successfully!${NC}
${DIM}Duration: ${duration} seconds${NC}

${BOLD}Next steps:${NC}
${BULLET} Restart your terminal to apply all changes
${BULLET} Run ${ITALIC}p10k configure${NC} to customize your prompt
${BULLET} Check the README for more customization options

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                print_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=1
                CURRENT_LOG_LEVEL=$LOG_DEBUG
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=1
                shift
                ;;
            -e|--enable)
                if [[ -z "$2" ]]; then
                    error "No environment specified for --enable"
                    exit 1
                fi
                enable_environment "$2" "$CONFIG_FILE"
                shift 2
                ;;
            -x|--disable)
                if [[ -z "$2" ]]; then
                    error "No environment specified for --disable"
                    exit 1
                fi
                disable_environment "$2" "$CONFIG_FILE"
                shift 2
                ;;
            -l|--list)
                list_environments "$CONFIG_FILE"
                exit 0
                ;;
            -s|--skip-update)
                SKIP_UPDATE=1
                shift
                ;;
            *)
                error "Unknown option: $1"
                print_help
                exit 1
                ;;
        esac
    done
}

# Setup enabled environments
setup_environments() {
    local environments
    environments=($(get_enabled_environments))
    
    if (( ${#environments[@]} == 0 )); then
        warn "No environments are enabled"
        return 0
    fi
    
    for env in "${environments[@]}"; do
        info "Setting up environment: $env"
        local packages=($(get_environment_packages "$env" "brew"))
        local casks=($(get_environment_packages "$env" "cask"))
        
        if (( ${#packages[@]} > 0 )); then
            install_packages_parallel "brew" "${packages[@]}" || return 1
        fi
        
        if (( ${#casks[@]} > 0 )); then
            install_packages_parallel "cask" "${casks[@]}" || return 1
        fi
    done
    
    return 0
}

# Main setup function
main() {
    local start_time=$SECONDS
    
    # Print welcome message and parse arguments
    print_welcome
    parse_args "$@"
    
    if [[ $DRY_RUN -eq 1 ]]; then
        info "${WARNING} Running in dry-run mode. No changes will be made."
        echo
    fi
    
    # Run system checks
    print_section "System Check" "$GEAR"
    if ! check_system; then
        error "System checks failed. Please resolve the issues and try again."
        return 1
    fi
    
    # Load configuration
    print_section "Configuration" "$GEAR"
    if ! load_config "$CONFIG_FILE"; then
        error "Failed to load configuration"
        return 1
    fi
    
    # Install and update Homebrew
    print_section "Package Manager" "$PACKAGE"
    if ! install_homebrew; then
        error "Failed to install/configure Homebrew"
        return 1
    fi
    
    if ! update_homebrew; then
        warn "Homebrew update failed, continuing with installation"
    fi
    
    # Setup environments
    print_section "Environment Setup" "$TOOLS"
    if ! setup_environments; then
        error "Failed to setup environments"
        return 1
    fi
    
    # Configure shell
    print_section "Shell Configuration" "$GEAR"
    if ! configure_shell; then
        error "Failed to configure shell"
        return 1
    fi
    
    # Print installation summary
    print_section "Installation Summary" "$INFO"
    print_install_summary
    
    # Print completion message
    local duration=$((SECONDS - start_time))
    print_completion $duration
    
    return 0
}

# Run main function with error handling
if ! main "$@"; then
    error "Setup failed"
    exit 1
fi