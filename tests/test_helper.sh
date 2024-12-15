#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC2296,SC2299,SC2300,SC2301,SC2128,SC2034

# Set strict error handling
setopt ERR_EXIT NO_UNSET PIPE_FAIL

# Get repository root directory
REPO_ROOT="${0:A:h:h}"

# Test environment setup
export TEST_MODE=true
export TEST_WORKSPACE="$(mktemp -d)"
export TEST_HOME="$TEST_WORKSPACE/home"

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

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-}"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        echo -e "${GREEN}✓ PASS${NC} - $message"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} - $message"
        echo "  Expected not to find: $needle"
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
    # Create test workspace and home directory
    mkdir -p "$TEST_WORKSPACE" "$TEST_HOME"
    
    # Set HOME to test home directory
    export HOME="$TEST_HOME"
    
    # Copy repository files to test workspace
    cp -R "$REPO_ROOT"/* "$TEST_WORKSPACE/"
    cd "$TEST_WORKSPACE" || exit 1
    
    # Create mock bin directory and add to PATH
    mkdir -p "$TEST_WORKSPACE/bin"
    export PATH="$TEST_WORKSPACE/bin:$PATH"
    
    # Create mock command function
    mock_command() {
        local cmd="$1"
        local response="$2"
        local bin_dir="$TEST_WORKSPACE/bin"
        echo "#!/usr/bin/env zsh" > "$bin_dir/$cmd"
        echo "echo \"$response\"" >> "$bin_dir/$cmd"
        chmod +x "$bin_dir/$cmd"
    }
    
    # Mock common commands
    mock_command "sw_vers" "12.0.0"
    mock_command "uname" "Darwin"
    
    # Create necessary dot files
    touch "$HOME/.zshrc"
    mkdir -p "$HOME/.oh-my-zsh/custom/themes"
}

teardown_test_environment() {
    # Clean up test workspace
    if [[ -d "$TEST_WORKSPACE" ]]; then
        rm -rf "$TEST_WORKSPACE"
    fi
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
    cat > "$TEST_WORKSPACE/bin/brew" << 'EOF'
#!/usr/bin/env zsh
case "$1" in
    "--prefix")
        echo "/opt/homebrew"
        ;;
    "list")
        if [[ "$2" == "--cask" ]]; then
            echo "installed-cask-1"
            echo "installed-cask-2"
        else
            echo "installed-package-1"
            echo "installed-package-2"
        fi
        ;;
    "search")
        echo "found-package-1"
        echo "found-package-2"
        ;;
    "outdated")
        if [[ "$2" == "--cask" ]]; then
            echo "outdated-cask-1"
            echo "outdated-cask-2"
        else
            echo "outdated-package-1"
            echo "outdated-package-2"
        fi
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
    cat > "$TEST_WORKSPACE/bin/sudo" << 'EOF'
#!/usr/bin/env zsh
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
    local exit_code=0
    
    output=$("$@" 2>&1) || exit_code=$?
    echo "$output"
    return $exit_code
}

# Export functions for use in test files
typeset -fx assert_equals assert_contains assert_not_contains
typeset -fx assert_file_exists assert_directory_exists
typeset -fx setup teardown mock_command mock_homebrew mock_sudo_commands run_command 