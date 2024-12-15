#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC2296,SC2299,SC2300,SC2301,SC2128,SC2034,SC2154

source "${0:A:h}/../test_helper.sh"

# Test environment setup and configuration
test_environment_setup() {
    # Create test YAML configuration
    local yaml_content='
packages:
  brew:
    - git
    - zsh
  cask:
    - visual-studio-code
environments:
  dev:
    enabled: true
    packages:
      - git
      - zsh
'
    local test_yaml="$TEST_WORKSPACE/setup.yaml"
    echo "$yaml_content" > "$test_yaml"
    
    # Test environment setup
    local result
    result=$(setup_environment "dev" "$test_yaml")
    assert_equals 0 $? "Environment setup should succeed"
    assert_contains "$result" "Setting up dev environment" "Should show setup message"
}

# Test package installation workflow
test_package_installation() {
    mock_homebrew
    mock_sudo_commands
    
    # Test brew package installation workflow
    local result
    result=$(install_packages "brew" "git zsh wget")
    assert_equals 0 $? "Brew package installation workflow should succeed"
    assert_contains "$result" "Installing packages" "Should show installation message"
    
    # Test cask package installation workflow
    result=$(install_packages "cask" "visual-studio-code iterm2")
    assert_equals 0 $? "Cask package installation workflow should succeed"
    assert_contains "$result" "Installing casks" "Should show cask installation message"
}

# Test shell configuration
test_shell_configuration() {
    # Test Oh My Zsh installation
    local result
    result=$(configure_shell)
    assert_equals 0 $? "Shell configuration should succeed"
    assert_file_exists "$HOME/.zshrc" "Should create .zshrc"
    assert_directory_exists "$HOME/.oh-my-zsh" "Should install Oh My Zsh"
    
    # Test theme installation
    result=$(install_shell_theme)
    assert_equals 0 $? "Theme installation should succeed"
    assert_directory_exists "$HOME/.oh-my-zsh/custom/themes" "Should create themes directory"
}

# Test environment group management
test_environment_groups() {
    # Create test configuration
    local yaml_content='
environments:
  dev:
    enabled: true
    packages:
      - git
      - zsh
  data:
    enabled: false
    packages:
      - python
      - r
'
    local test_yaml="$TEST_WORKSPACE/setup.yaml"
    echo "$yaml_content" > "$test_yaml"
    
    # Test enabling environment
    local result
    result=$(enable_environment "data" "$test_yaml")
    assert_equals 0 $? "Environment enabling should succeed"
    
    # Test disabling environment
    result=$(disable_environment "dev" "$test_yaml")
    assert_equals 0 $? "Environment disabling should succeed"
    
    # Verify changes
    local config
    config=$(cat "$test_yaml")
    assert_contains "$config" "data:\n    enabled: true" "Should enable data environment"
    assert_contains "$config" "dev:\n    enabled: false" "Should disable dev environment"
}

# Test error handling and recovery
test_error_handling() {
    # Test package installation failure recovery
    mock_homebrew
    chmod -x "$TEST_WORKSPACE/bin/brew"
    
    local result
    result=$(install_packages "brew" "git" 2>&1) || true
    assert_contains "$result" "ERROR" "Should log error on installation failure"
    assert_contains "$result" "Attempting to recover" "Should attempt recovery"
    
    # Test configuration error handling
    echo "invalid: yaml: content:" > "$TEST_WORKSPACE/setup.yaml"
    result=$(setup_environment "dev" "$TEST_WORKSPACE/setup.yaml" 2>&1) || true
    assert_contains "$result" "ERROR" "Should log error on invalid configuration"
}

# Test parallel operations
test_parallel_operations() {
    mock_homebrew
    
    # Test parallel package installation
    local result
    result=$(parallel_install_packages "git zsh wget" "brew")
    assert_equals 0 $? "Parallel installation should succeed"
    
    # Test parallel environment setup
    local yaml_content='
environments:
  dev:
    enabled: true
    packages:
      - git
  data:
    enabled: true
    packages:
      - python
'
    echo "$yaml_content" > "$TEST_WORKSPACE/setup.yaml"
    
    result=$(parallel_setup_environments "$TEST_WORKSPACE/setup.yaml")
    assert_equals 0 $? "Parallel environment setup should succeed"
}

# Run all tests
run_tests() {
    # Setup test environment
    setup
    
    # Run individual test functions
    test_environment_setup
    test_package_installation
    test_shell_configuration
    test_environment_groups
    test_error_handling
    test_parallel_operations
    
    # Cleanup test environment
    teardown
}

# Execute tests
run_tests