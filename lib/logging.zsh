#!/usr/bin/env zsh

# Terminal formatting utilities for beautiful CLI output

# Color codes
typeset -rA COLORS=(
    [reset]='\033[0m'
    [bold]='\033[1m'
    [dim]='\033[2m'
    [italic]='\033[3m'
    [underline]='\033[4m'
    [blink]='\033[5m'
    [reverse]='\033[7m'
    [hidden]='\033[8m'
    [black]='\033[30m'
    [red]='\033[31m'
    [green]='\033[32m'
    [yellow]='\033[33m'
    [blue]='\033[34m'
    [magenta]='\033[35m'
    [cyan]='\033[36m'
    [white]='\033[37m'
    [bg_black]='\033[40m'
    [bg_red]='\033[41m'
    [bg_green]='\033[42m'
    [bg_yellow]='\033[43m'
    [bg_blue]='\033[44m'
    [bg_magenta]='\033[45m'
    [bg_cyan]='\033[46m'
    [bg_white]='\033[47m'
)

# Unicode symbols
typeset -rA SYMBOLS=(
    [check]='✓'
    [cross]='✗'
    [dot]='•'
    [arrow]='→'
    [star]='★'
    [warning]='⚠️'
    [info]='ℹ️'
    [error]='❌'
    [success]='✅'
    [pending]='⏳'
    [gear]='⚙️'
    [package]='📦'
    [tools]='🛠'
    [rocket]='🚀'
    [folder]='📁'
    [file]='📄'
    [link]='🔗'
    [clock]='🕐'
)

# Progress bar settings
typeset -r PROGRESS_WIDTH=40
typeset -r PROGRESS_FILLED='█'
typeset -r PROGRESS_EMPTY='░'

# Spinner frames for loading animations
typeset -ra SPINNER_FRAMES=(
    '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏'
)

# Format text with color and style
format() {
    local text="$1"
    shift
    
    local formatted="$text"
    local code
    
    for code in "$@"; do
        if [[ -n "${COLORS[$code]}" ]]; then
            formatted="${COLORS[$code]}${formatted}${COLORS[reset]}"
        fi
    done
    
    echo -n "$formatted"
}

# Print a horizontal rule
hr() {
    local char="${1:-─}"
    local width="${2:-$(tput cols)}"
    printf '%*s\n' "$width" | tr ' ' "$char"
}

# Print centered text
center() {
    local text="$1"
    local width="${2:-$(tput cols)}"
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%${padding}s%s%${padding}s\n" "" "$text" ""
}

# Print a box around text
box() {
    local text="$1"
    local padding="${2:-1}"
    local width=$(( ${#text} + padding * 2 ))
    
    # Top border
    printf '╭%*s╮\n' "$width" | tr ' ' '─'
    
    # Text with padding
    printf '│%*s%s%*s│\n' "$padding" "" "$text" "$padding" ""
    
    # Bottom border
    printf '╰%*s╯\n' "$width" | tr ' ' '─'
}

# Show a progress bar
progress_bar() {
    local current="$1"
    local total="$2"
    local text="${3:-}"
    
    local percentage=$(( current * 100 / total ))
    local filled=$(( percentage * PROGRESS_WIDTH / 100 ))
    local empty=$(( PROGRESS_WIDTH - filled ))
    
    printf '\r%s [%s%s] %d%%' \
        "$text" \
        "$(printf '%*s' "$filled" | tr ' ' "$PROGRESS_FILLED")" \
        "$(printf '%*s' "$empty" | tr ' ' "$PROGRESS_EMPTY")" \
        "$percentage"
    
    [[ $current -eq $total ]] && echo
}

# Show a spinner
spinner() {
    local pid="$1"
    local text="${2:-Loading}"
    local frame=0
    
    tput civis # Hide cursor
    
    while kill -0 "$pid" 2>/dev/null; do
        printf '\r%s %s' "${SPINNER_FRAMES[frame + 1]}" "$text"
        frame=$(( (frame + 1) % ${#SPINNER_FRAMES[@]} ))
        sleep 0.1
    done
    
    tput cnorm # Show cursor
    printf '\r'
}

# Print a heading
heading() {
    local text="$1"
    local level="${2:-1}"
    local symbol="${3:-${SYMBOLS[star]}}"
    
    echo
    case $level in
        1)
            format "$symbol $text" bold underline
            hr
            ;;
        2)
            format "$symbol $text" bold
            ;;
        *)
            format "$text" bold
            ;;
    esac
    echo
}

# Print a list item
list_item() {
    local text="$1"
    local symbol="${2:-${SYMBOLS[dot]}}"
    local indent="${3:-2}"
    
    printf "%${indent}s%s %s\n" "" "$symbol" "$text"
}

# Print a success message
success() {
    local text="$1"
    format "${SYMBOLS[success]} $text\n" green
}

# Print an error message
error() {
    local text="$1"
    format "${SYMBOLS[error]} $text\n" red bold >&2
}

# Print a warning message
warning() {
    local text="$1"
    format "${SYMBOLS[warning]} $text\n" yellow
}

# Print an info message
info() {
    local text="$1"
    format "${SYMBOLS[info]} $text\n" blue
}

# Print a debug message
debug() {
    [[ -n "$DEBUG" ]] && format "${SYMBOLS[gear]} $1\n" dim
}

# Print a table
table() {
    local -a headers=("${(@)1}")
    local -a rows=("${(@)2}")
    local separator="${3:-|}"
    
    # Calculate column widths
    local -a widths=()
    local col header row
    for col in {1..${#headers}}; do
        local max_width=${#headers[col]}
        for row in "${rows[@]}"; do
            (( ${#row[col]} > max_width )) && max_width=${#row[col]}
        done
        widths+=($max_width)
    done
    
    # Print headers
    local header_line=""
    for col in {1..${#headers}}; do
        printf "%s %*s " "$separator" "-${widths[col]}" "${headers[col]}"
        header_line+=$(printf "%*s" "$((widths[col] + 2))" | tr ' ' '-')
        header_line+="$separator"
    done
    echo "$separator"
    
    # Print separator
    echo "$header_line"
    
    # Print rows
    for row in "${rows[@]}"; do
        for col in {1..${#row}}; do
            printf "%s %*s " "$separator" "-${widths[col]}" "${row[col]}"
        done
        echo "$separator"
    done
}

# Print a keyboard shortcut
key() {
    local key="$1"
    format " $key " reverse
}

# Print a command example
cmd() {
    local command="$1"
    format "$ $command" dim
}

# Print a file path
path() {
    local path="$1"
    local type="${2:-file}"
    local symbol="${SYMBOLS[$type]}"
    format "$symbol $path" underline
}

# Export functions
typeset -fx format hr center box progress_bar spinner heading
typeset -fx list_item success error warning info debug
typeset -fx table key cmd path 