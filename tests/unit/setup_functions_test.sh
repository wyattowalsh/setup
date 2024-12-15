#!/usr/bin/env bash

# Source test helper
source "$(dirname "$0")/../test_helper.sh"

# Source the functions to test
source "./setup_functions.sh"

test_check_macos_compatibility() {
    echo "Testing check_macos_compatibility..."
    
    # Test successful case
    mock_command "sw_vers" "12.0.0"
    mock_command "uname" "Darwin"
    output=$(check_macos_compatibility)
    assert_contains "$output" "Detected macOS version: 12.0.0" "Should detect correct macOS version"
    
    # Test non-Darwin OS
    mock_command "uname" "Linux"
    if output=$(check_macos_compatibility 2>&1); then
        echo "Should fail on non-Darwin OS"
        return 1
    fi
    assert_contains "$output" "This script is intended for macOS only" "Should show correct error for non-Darwin OS"
    
    # Test old macOS version
    mock_command "uname" "Darwin"
    mock_command "sw_vers" "10.14.0"
    if output=$(check_macos_compatibility 2>&1); then
        echo "Should fail on old macOS version"
        return 1
    fi
    assert_contains "$output" "This script requires at least macOS 10.15" "Should show correct error for old macOS"
}

test_check_user_privileges() {
    echo "Testing check_user_privileges..."
    
    # Test non-root user
    EUID=1000
    output=$(check_user_privileges)
    assert_equals "" "$output" "Should succeed silently for non-root user"
    
    # Test root user
    EUID=0
    if output=$(check_user_privileges 2>&1); then
        echo "Should fail for root user"
        return 1
    fi
    assert_contains "$output" "This script should not be run as root" "Should show correct error for root user"
}

test_check_dependencies() {
    echo "Testing check_dependencies..."
    
    # Test all dependencies available
    mock_command "curl" "curl 7.79.1"
    mock_command "git" "git version 2.33.0"
    mock_command "jq" "jq-1.6"
    
    output=$(check_dependencies)
    assert_equals "" "$output" "Should succeed silently when all dependencies are available"
    
    # Test missing dependency
    rm "$TEST_WORKSPACE/bin/jq"
    output=$(check_dependencies 2>&1) || true
    assert_contains "$output" "Dependency jq is missing" "Should detect missing dependency"
}

test_install_or_upgrade_brew_item() {
    echo "Testing install_or_upgrade_brew_item..."
    
    # Mock brew command
    mock_homebrew
    
    # Test installing new formula
    output=$(install_or_upgrade_brew_item "new-package" "formula")
    assert_contains "$output" "Installing formula: new-package" "Should show installing message for new formula"
    
    # Test upgrading existing formula
    output=$(install_or_upgrade_brew_item "installed-package-1" "formula")
    assert_contains "$output" "Formula installed-package-1 is already installed via Homebrew" "Should detect existing formula"
    
    # Test installing new cask
    output=$(install_or_upgrade_brew_item "new-cask" "cask")
    assert_contains "$output" "Installing cask: new-cask" "Should show installing message for new cask"
}

test_append_shell_configs_to_zshrc() {
    echo "Testing append_shell_configs_to_zshrc..."
    
    # Create test .zshrc
    echo "# Existing config" > "$HOME/.zshrc"
    
    # Test appending new config
    SHELL_CONFIGS=("test_config_1" "test_config_2")
    append_shell_configs_to_zshrc
    
    # Verify configs were appended
    zshrc_content=$(cat "$HOME/.zshrc")
    assert_contains "$zshrc_content" "test_config_1" "Should append first config"
    assert_contains "$zshrc_content" "test_config_2" "Should append second config"
    
    # Test not duplicating existing config
    append_shell_configs_to_zshrc
    
    # Count occurrences of test configs
    occurrences=$(grep -c "test_config_1" "$HOME/.zshrc")
    assert_equals "1" "$occurrences" "Should not duplicate existing configs"
}

# Run all tests
main() {
    test_check_macos_compatibility
    test_check_user_privileges
    test_check_dependencies
    test_install_or_upgrade_brew_item
    test_append_shell_configs_to_zshrc
}

main 