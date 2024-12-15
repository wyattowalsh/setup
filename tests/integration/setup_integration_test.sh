#!/usr/bin/env bash

# Source test helper
source "$(dirname "$0")/../test_helper.sh"

# Source all script files
source "./setup_config.sh"
source "./setup_functions.sh"

test_homebrew_installation_flow() {
    echo "Testing Homebrew installation flow..."
    
    # Mock commands
    mock_homebrew
    mock_sudo_commands
    
    # Test fresh installation
    rm -f "$TEST_WORKSPACE/bin/brew"
    output=$(install_or_update_homebrew)
    assert_contains "$output" "Homebrew is not installed. Installing..." "Should detect missing Homebrew"
    
    # Test update of existing installation
    mock_homebrew
    output=$(install_or_update_homebrew)
    assert_contains "$output" "Updating Homebrew to the latest version..." "Should update existing Homebrew"
}

test_package_group_installation() {
    echo "Testing package group installation..."
    
    # Enable test groups
    GROUP_ENABLED["test_group"]="true"
    PACKAGE_GROUPS["test_group"]="test-package-1 test-package-2"
    
    # Mock Homebrew
    mock_homebrew
    
    # Test installation
    output=$(install_brew_items)
    assert_contains "$output" "Installing formula: test-package-1" "Should install first package"
    assert_contains "$output" "Installing formula: test-package-2" "Should install second package"
}

test_shell_configuration() {
    echo "Testing shell configuration..."
    
    # Create test home directory and .zshrc
    mkdir -p "$TEST_WORKSPACE/home"
    export HOME="$TEST_WORKSPACE/home"
    touch "$HOME/.zshrc"
    
    # Test Oh My Zsh installation
    output=$(install_oh_my_zsh)
    assert_contains "$output" "Oh My Zsh is not installed. Installing..." "Should detect missing Oh My Zsh"
    
    # Test Powerlevel10k installation
    output=$(install_powerlevel10k)
    assert_contains "$output" "Powerlevel10k theme is not installed. Installing..." "Should detect missing Powerlevel10k"
    
    # Test shell config appending
    SHELL_CONFIGS=("test_config_1" "test_config_2")
    append_shell_configs_to_zshrc
    
    zshrc_content=$(cat "$HOME/.zshrc")
    assert_contains "$zshrc_content" "test_config_1" "Should append shell configs"
    assert_contains "$zshrc_content" "test_config_2" "Should append shell configs"
}

test_environment_setup() {
    echo "Testing complete environment setup..."
    
    # Mock all necessary commands
    mock_homebrew
    mock_sudo_commands
    mock_command "sw_vers" "12.0.0"
    mock_command "uname" "Darwin"
    
    # Create test home directory
    mkdir -p "$TEST_WORKSPACE/home"
    export HOME="$TEST_WORKSPACE/home"
    touch "$HOME/.zshrc"
    
    # Enable test environment
    GROUP_ENABLED["test_env"]="true"
    PACKAGE_GROUPS["test_env"]="test-package"
    
    # Run main setup
    output=$(main)
    
    # Verify all components were installed/configured
    assert_contains "$output" "Running setup.zsh version" "Should show version"
    assert_contains "$output" "Detected macOS version" "Should check macOS compatibility"
    assert_contains "$output" "Installing formula: test-package" "Should install packages"
    assert_file_exists "$HOME/.zshrc" "Should create .zshrc"
}

test_dry_run_mode() {
    echo "Testing dry run mode..."
    
    # Enable dry run mode
    DRY_RUN=true
    
    # Mock commands
    mock_homebrew
    mock_sudo_commands
    
    # Run installation
    output=$(install_brew_items)
    assert_contains "$output" "[DRY-RUN]" "Should indicate dry run mode"
    
    # Verify no actual changes were made
    assert_equals "0" "$(ls -1 /Applications | wc -l)" "Should not install any applications in dry run mode"
}

# Run all tests
main() {
    test_homebrew_installation_flow
    test_package_group_installation
    test_shell_configuration
    test_environment_setup
    test_dry_run_mode
}

main 