#!/usr/bin/env zsh

<<COMMENT
-------------------------------------------------
setup.zsh: A macOS configuration setup script

Purpose:
Automates the setup process for a new macOS machine by installing desired Homebrew packages, cask apps, and configuring zsh.

Usage Examples:
./setup.zsh                 : Run the setup
./setup.zsh -v              : Run the setup with verbose output
./setup.zsh -d              : Run a dry run with verbose output
./setup.zsh -s              : Skip updating existing packages
./setup.zsh -h              : Display help message

-------------------------------------------------
COMMENT

# Enforce strict error handling
set -euo pipefail

# Script version
readonly SCRIPT_VERSION="1.5.1"

# Config file path
readonly CONFIG_FILE="./setup_config.sh"

# Function to keep sudo alive
keep_sudo_alive() {
    sudo -v
    while true; do
        sleep 60
        sudo -n true 2>/dev/null || exit
        kill -0 "$$" || exit
    done &>/dev/null &
}

# Call the function at the start of the script
keep_sudo_alive

# Source functions
source "setup_functions.sh"

# Parse arguments
parse_arguments "$@"

# Load config
load_config "$CONFIG_FILE"

# Run main function
main