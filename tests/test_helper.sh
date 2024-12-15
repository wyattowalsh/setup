#!/usr/bin/env bash

# Set strict error handling
set -euo pipefail

# Test environment setup
export TEST_MODE=true
export TEST_WORKSPACE="$(mktemp -d)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Testing utilities
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    
    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓ PASS${NC} - $message"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} - $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}✓ PASS${NC} - $message"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} - $message"
        echo "  Expected to find: $needle"
        echo "  In: $haystack"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-}"
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓ PASS${NC} - $message"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} - $message"
        echo "  File does not exist: $file"
        return 1
    fi
}

assert_directory_exists() {
    local directory="$1"
    local message="${2:-}"
    
    if [[ -d "$directory" ]]; then
        echo -e "${GREEN}✓ PASS${NC} - $message"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} - $message"
        echo "  Directory does not exist: $directory"
        return 1
    fi
}

setup_test_environment() {
    # Create temporary test workspace
    mkdir -p "$TEST_WORKSPACE"
    cp -r ../* "$TEST_WORKSPACE/"
    cd "$TEST_WORKSPACE"
    
    # Mock system commands
    mock_command() {
        local cmd="$1"
        local response="$2"
        echo "echo \"$response\"" > "$TEST_WORKSPACE/bin/$cmd"
        chmod +x "$TEST_WORKSPACE/bin/$cmd"
    }
    
    # Add mock bin to PATH
    mkdir -p "$TEST_WORKSPACE/bin"
    export PATH="$TEST_WORKSPACE/bin:$PATH"
    
    # Mock common commands
    mock_command "sw_vers" "12.0.0"
    mock_command "uname" "Darwin"
}

teardown_test_environment() {
    # Clean up test workspace
    rm -rf "$TEST_WORKSPACE"
}

# Run before each test
setup() {
    setup_test_environment
}

# Run after each test
teardown() {
    teardown_test_environment
}

# Mock Homebrew for testing
mock_homebrew() {
    # Create mock brew command
    cat > "$TEST_WORKSPACE/bin/brew" << 'EOF'
#!/bin/bash
case "$1" in
    "--prefix")
        echo "/opt/homebrew"
        ;;
    "list")
        echo "installed-package-1"
        echo "installed-package-2"
        ;;
    "search")
        echo "found-package-1"
        echo "found-package-2"
        ;;
    *)
        echo "brew $*"
        ;;
esac
EOF
    chmod +x "$TEST_WORKSPACE/bin/brew"
}

# Mock system commands that require sudo
mock_sudo_commands() {
    # Create mock sudo command
    cat > "$TEST_WORKSPACE/bin/sudo" << 'EOF'
#!/bin/bash
if [[ "$1" == "-v" ]]; then
    exit 0
fi
echo "sudo $*"
EOF
    chmod +x "$TEST_WORKSPACE/bin/sudo"
}

# Run a command and capture its output
run_command() {
    local output
    local exit_code
    
    output=$("$@" 2>&1) || exit_code=$?
    echo "$output"
    return ${exit_code:-0}
} 