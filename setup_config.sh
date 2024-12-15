#!/bin/bash
# This script is intended to be sourced by zsh but maintains sh compatibility for linting

###################################################
# Configuration settings for setup.zsh
#
# Define package groups and their configurations for macOS setup.
###################################################

# Group configuration
# Set to true to enable, false to disable
declare -A GROUP_ENABLED
GROUP_ENABLED=(
    ["core"]="true"              # Core development tools and utilities
    ["python"]="true"           # Python development environment
    ["java"]="true"            # Java development environment
    ["ruby"]="true"            # Ruby development environment
    ["node"]="true"            # Node.js development environment
    ["docker"]="true"          # Container development environment
    ["r_stats"]="true"         # R statistical computing environment
    ["web"]="true"             # Web development tools
    ["data_science"]="true"    # Data science and analysis tools
    ["writing"]="true"         # Documentation and writing tools
    ["media"]="true"           # Media and entertainment
    ["system"]="true"          # System utilities and enhancements
    ["fonts"]="true"           # Development and system fonts
)

# Define package groups
declare -A PACKAGE_GROUPS
PACKAGE_GROUPS=(
    ["core"]="gcc git gh make tree wget zsh zsh-completions visual-studio-code github"

    ["python"]="pyenv poetry miniconda jupyter-notebook-ql sphinx-doc"

    ["java"]="java graphviz"

    ["ruby"]="rbenv ruby-build"

    ["node"]="nvm watchman"

    ["docker"]="docker docker-completion docker-compose"

    ["r_stats"]="r"

    ["web"]="google-chrome responsively quicklook-csv qlmarkdown webpquicklook"

    ["data_science"]="db-browser-for-sqlite jupyter-notebook-ql"

    ["writing"]="mark-text notion obsidian zotero"

    ["media"]="iina spotify"

    ["system"]="glance google-drive logi-options+ slack speedtest-cli unar"

    ["fonts"]="font-sf-pro font-sf-compact font-sf-mono font-new-york font-fira-code font-montserrat font-fontawesome font-awesome-terminal-fonts font-academicons font-devicons font-foundation-icons font-material-design-icons-webfont font-material-icons font-mynaui-icons font-simple-line-icons"
)

# Function to get all enabled packages
get_enabled_packages() {
    local enabled_packages=""
    local IFS=$'\n'
    for group in "${!GROUP_ENABLED[@]}"; do
        if [ "${GROUP_ENABLED[$group]}" = "true" ]; then
            enabled_packages="${enabled_packages} ${PACKAGE_GROUPS[$group]}"
        fi
    done
    echo "${enabled_packages# }"
}

# Set PACKAGES array based on enabled groups
PACKAGES=($(get_enabled_packages))

# Shell configurations
SHELL_CONFIGS=(
    # Initialize Homebrew and set HOMEBREW_PREFIX
    'if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi'
    'export HOMEBREW_PREFIX="$(brew --prefix)"'

    # Ensure Homebrew bin is in PATH
    'export PATH="$HOMEBREW_PREFIX/bin:$PATH"'

    # Add GNU Make tools to PATH
    'export PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"'

    # Initialize pyenv
    'export PYENV_ROOT="$HOME/.pyenv"'
    'export PATH="$PYENV_ROOT/bin:$PATH"'
    'if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
    fi'

    # Initialize rbenv
    'export PATH="$HOME/.rbenv/bin:$PATH"'
    'if command -v rbenv 1>/dev/null 2>&1; then
        eval "$(rbenv init - zsh)"
    fi'

    # Set up NVM
    'export NVM_DIR="$HOME/.nvm"'
    '[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && . "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"'

    # Add other necessary paths
    'export PATH="$HOMEBREW_PREFIX/opt/sphinx-doc/bin:$PATH"'
    'export PATH="$HOMEBREW_PREFIX/opt/openjdk/bin:$PATH"'
    'export PATH="$HOMEBREW_PREFIX/opt/curl/bin:$PATH"'
    'export PATH="$HOMEBREW_PREFIX/opt/qt@5/bin:$PATH"'

    # Compiler flags
    'export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/openjdk/include -I$HOMEBREW_PREFIX/opt/curl/include -I$HOMEBREW_PREFIX/opt/qt@5/include"'
    'export LDFLAGS="-L$HOMEBREW_PREFIX/opt/curl/lib -L$HOMEBREW_PREFIX/opt/qt@5/lib"'
    'export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/curl/lib/pkgconfig:$HOMEBREW_PREFIX/opt/qt@5/lib/pkgconfig"'

    # Add custom Zsh function path
    'fpath+=~/.zfunc'

    # Aliases
    'alias c="clear"'

    # Source Powerlevel10k theme
    'if [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme" ]; then
        source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k/powerlevel10k.zsh-theme"
    fi'

    # Load Powerlevel10k configuration if it exists
    '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh'
)