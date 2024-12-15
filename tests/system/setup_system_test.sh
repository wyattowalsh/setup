#!/usr/bin/env bash

# Source test helper
source "$(dirname "$0")/../test_helper.sh"

test_full_installation() {
    echo "Testing full installation process..."
    
    # Create test environment
    mkdir -p "$TEST_WORKSPACE/test_install"
    cd "$TEST_WORKSPACE/test_install"
    
    # Copy all setup files
    cp -r ../setup.zsh ../setup_config.sh ../setup_functions.sh ./
    
    # Mock system commands
    mock_homebrew
    mock_sudo_commands
    mock_command "sw_vers" "12.0.0"
    mock_command "uname" "Darwin"
    mock_command "curl" "curl 7.79.1"
    mock_command "git" "git version 2.33.0"
    
    # Run setup script with various flags
    echo "Testing with default options..."
    output=$(./setup.zsh)
    assert_contains "$output" "Running setup.zsh version" "Should show version info"
    
    echo "Testing with verbose mode..."
    output=$(./setup.zsh -v)
    assert_contains "$output" "[debug]" "Should show debug output in verbose mode"
    
    echo "Testing with dry run mode..."
    output=$(./setup.zsh -d)
    assert_contains "$output" "[DRY-RUN]" "Should indicate dry run mode"
    
    echo "Testing with specific environment..."
    output=$(./setup.zsh -e python)
    assert_contains "$output" "python" "Should install Python environment"
}

test_error_handling() {
    echo "Testing error handling..."
    
    # Test invalid option
    output=$(./setup.zsh -z 2>&1) || true
    assert_contains "$output" "Invalid option" "Should handle invalid options"
    
    # Test invalid environment
    output=$(./setup.zsh -e invalid_env 2>&1) || true
    assert_contains "$output" "Unknown package group" "Should handle invalid environments"
    
    # Test running as root
    EUID=0
    output=$(./setup.zsh 2>&1) || true
    assert_contains "$output" "should not be run as root" "Should prevent running as root"
}

test_idempotency() {
    echo "Testing idempotent installation..."
    
    # Run setup twice
    ./setup.zsh -e core > /dev/null
    output=$(./setup.zsh -e core)
    
    # Verify no duplicate installations
    assert_contains "$output" "already installed" "Should detect existing installations"
    
    # Check .zshrc for duplicates
    if [[ -f "$HOME/.zshrc" ]]; then
        duplicates=$(grep -c "HOMEBREW_PREFIX" "$HOME/.zshrc")
        assert_equals "1" "$duplicates" "Should not duplicate shell configurations"
    fi
}

test_environment_isolation() {
    echo "Testing environment isolation..."
    
    # Test Python environment
    output=$(./setup.zsh -e python)
    assert_contains "$output" "pyenv" "Should install Python version manager"
    assert_not_contains "$output" "java" "Should not install Java packages"
    
    # Test Java environment
    output=$(./setup.zsh -e java)
    assert_contains "$output" "java" "Should install Java"
    assert_not_contains "$output" "pyenv" "Should not install Python packages"
}

test_cleanup() {
    echo "Testing cleanup on failure..."
    
    # Simulate failure during installation
    mock_command "brew" "exit 1"
    
    # Run setup and capture output
    output=$(./setup.zsh 2>&1) || true
    
    # Verify error handling and cleanup
    assert_contains "$output" "error" "Should show error message"
    assert_not_contains "$(ps aux)" "brew" "Should not leave hanging processes"
}

# Additional assertion for system tests
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

# Run all tests
main() {
    test_full_installation
    test_error_handling
    test_idempotency
    test_environment_isolation
    test_cleanup
}

main 