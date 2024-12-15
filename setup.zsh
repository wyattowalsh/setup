#!/usr/bin/env zsh

# Terminal colors and styles
typeset -r BOLD='\033[1m'
typeset -r DIM='\033[2m'
typeset -r ITALIC='\033[3m'
typeset -r UNDERLINE='\033[4m'
typeset -r RED='\033[0;31m'
typeset -r GREEN='\033[0;32m'
typeset -r YELLOW='\033[0;33m'
typeset -r BLUE='\033[0;34m'
typeset -r MAGENTA='\033[0;35m'
typeset -r CYAN='\033[0;36m'
typeset -r WHITE='\033[0;37m'
typeset -r NC='\033[0m'

# Unicode symbols for better formatting
typeset -r CHECK_MARK="✓"
typeset -r CROSS_MARK="✗"
typeset -r ARROW="→"
typeset -r BULLET="•"
typeset -r GEAR="⚙️"
typeset -r PACKAGE="📦"
typeset -r TOOLS="🛠"
typeset -r ROCKET="🚀"
typeset -r WARNING="⚠️"
typeset -r INFO="ℹ️"

# Progress spinner frames
typeset -a SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# Verbose mode flag
typeset -i VERBOSE=0

# Dry run mode flag
typeset -i DRY_RUN=0

# Log levels
typeset -r LOG_DEBUG=0
typeset -r LOG_INFO=1
typeset -r LOG_WARN=2
typeset -r LOG_ERROR=3

# Current log level
typeset -i CURRENT_LOG_LEVEL=$LOG_INFO

# Print a formatted header
print_header() {
    local text="$1"
    local width=60
    local padding=$(( (width - ${#text}) / 2 ))
    
    echo
    printf '%s\n' "${BLUE}${BOLD}${UNDERLINE}%${width}s${NC}" " "
    printf '%s\n' "${BLUE}${BOLD}%$((padding))s%s%$((width - padding - ${#text}))s${NC}" " " "$text" " "
    printf '%s\n' "${BLUE}${BOLD}${UNDERLINE}%${width}s${NC}" " "
    echo
}

# Print a section header
print_section() {
    local text="$1"
    local symbol="${2:-$BULLET}"
    echo
    printf '%s\n' "${CYAN}${BOLD}$symbol %s${NC}" "$text"
    echo
}

# Print a task status
print_task() {
    local text="$1"
    local status="$2"
    local color="$3"
    printf '%s %s\n' "${color}${status}${NC}" "$text"
}

# Show a spinner while running a command
show_spinner() {
    local pid=$1
    local message="$2"
    local i=0
    
    tput civis # Hide cursor
    while kill -0 $pid 2>/dev/null; do
        local frame="${SPINNER_FRAMES[$((i % ${#SPINNER_FRAMES[@]} + 1))]}"
        printf '\r%s %s %s' "${BLUE}${frame}${NC}" "$message" "${DIM}...${NC}"
        i=$((i + 1))
        sleep 0.1
    done
    tput cnorm # Show cursor
    printf '\r'
}

# Log a message with a specific level
log() {
    local level=$1
    local message="$2"
    local symbol="$3"
    
    if (( level >= CURRENT_LOG_LEVEL )); then
        case $level in
            $LOG_DEBUG)
                [[ $VERBOSE -eq 1 ]] && printf '%s\n' "${DIM}${symbol} %s${NC}" "$message"
                ;;
            $LOG_INFO)
                printf '%s\n' "${symbol} %s" "$message"
                ;;
            $LOG_WARN)
                printf '%s\n' "${YELLOW}${symbol} %s${NC}" "$message"
                ;;
            $LOG_ERROR)
                printf '%s\n' "${RED}${symbol} %s${NC}" "$message"
                ;;
        esac
    fi
}

# Log debug message
debug() { log $LOG_DEBUG "$1" "$INFO" }

# Log info message
info() { log $LOG_INFO "$1" "$INFO" }

# Log warning message
warn() { log $LOG_WARN "$1" "$WARNING" }

# Log error message
error() { log $LOG_ERROR "$1" "$CROSS_MARK" }

# Show success message
success() { print_task "$1" "$CHECK_MARK" "$GREEN" }

# Show progress message
progress() {
    local message="$1"
    local temp_file=$(mktemp)
    
    # Start the command in background
    eval "$2" > "$temp_file" 2>&1 &
    local pid=$!
    
    # Show spinner while command runs
    show_spinner $pid "$message"
    
    # Check if command succeeded
    wait $pid
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        success "$message"
        [[ $VERBOSE -eq 1 ]] && cat "$temp_file"
    else
        error "$message"
        cat "$temp_file"
    fi
    
    rm -f "$temp_file"
    return $exit_code
}

# Print help message
print_help() {
    cat << EOF
${BOLD}Usage:${NC} ./setup.zsh [options]

${BOLD}Options:${NC}
  ${BLUE}-h, --help${NC}         Show this help message
  ${BLUE}-v, --verbose${NC}      Enable verbose output
  ${BLUE}-d, --dry-run${NC}      Show what would be done without making changes
  ${BLUE}-e, --enable${NC}       Enable specific environment (can be used multiple times)
  ${BLUE}-x, --disable${NC}      Disable specific environment (can be used multiple times)
  ${BLUE}-l, --list${NC}         List available environments
  ${BLUE}-s, --skip-update${NC}  Skip updating existing packages

${BOLD}Examples:${NC}
  ${DIM}# Run setup with default settings${NC}
  ./setup.zsh

  ${DIM}# Enable specific environments${NC}
  ./setup.zsh -e python -e node

  ${DIM}# Run in verbose mode${NC}
  ./setup.zsh -v

  ${DIM}# Show what would be done${NC}
  ./setup.zsh -d

EOF
}

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
                enable_environment "$2"
                shift 2
                ;;
            -x|--disable)
                disable_environment "$2"
                shift 2
                ;;
            -l|--list)
                list_environments
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

# Main function
main() {
    local start_time=$SECONDS
    
    print_welcome
    parse_args "$@"
    
    if [[ $DRY_RUN -eq 1 ]]; then
        info "${WARNING} Running in dry-run mode. No changes will be made."
        echo
    fi
    
    print_section "System Check" "$GEAR"
    progress "Checking system compatibility" "check_macos_compatibility"
    progress "Checking user privileges" "check_user_privileges"
    progress "Checking dependencies" "check_dependencies"
    
    print_section "Package Manager" "$PACKAGE"
    progress "Installing/updating Homebrew" "install_or_update_homebrew"
    
    print_section "Environment Setup" "$TOOLS"
    setup_enabled_environments
    
    print_section "Shell Configuration" "$GEAR"
    progress "Installing Oh My Zsh" "install_oh_my_zsh"
    progress "Installing Powerlevel10k theme" "install_powerlevel10k"
    progress "Configuring shell" "configure_shell"
    
    local duration=$((SECONDS - start_time))
    print_completion $duration
}

# Run main function
main "$@"