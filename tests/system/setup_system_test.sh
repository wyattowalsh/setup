#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC2296,SC2299,SC2300,SC2301,SC2128,SC2034,SC2154

source "${0:A:h}/../test_helper.sh"

# Test complete system setup with default configuration
test_default_setup() {
    # Create default YAML configuration
    local yaml_content='
packages:
  brew:
    - git
    - zsh
  cask:
    - visual-studio-code
environments:
  core:
    enabled: true
    packages:
      - git
      - zsh
'
    local test_yaml="$TEST_WORKSPACE/setup.yaml"
    echo "$yaml_content" > "$test_yaml"
    
    # Run complete setup
    local result
    result=$(./setup.zsh)
    assert_equals 0 $? "Default setup should succeed"
    assert_contains "$result" "Setting up core environment" "Should setup core environment"
    
    # Verify installations
    assert_directory_exists "$HOME/.oh-my-zsh" "Should install Oh My Zsh"
    assert_file_exists "$HOME/.zshrc" "Should create .zshrc"
}

# Test environment-specific setup
test_environment_specific_setup() {
    # Create test configuration with multiple environments
    local yaml_content='
environments:
  dev:
    enabled: false
    packages:
      - git
      - zsh
  data:
    enabled: false
    packages:
      - python
      - r
  web:
    enabled: false
    packages:
      - node
      - yarn
'
    local test_yaml="$TEST_WORKSPACE/setup.yaml"
    echo "$yaml_content" > "$test_yaml"
    
    # Test enabling specific environment
    local result
    result=$(./setup.zsh -e dev)
    assert_equals 0 $? "Environment-specific setup should succeed"
    assert_contains "$result" "Enabling dev environment" "Should enable dev environment"
    
    # Verify only dev environment was set up
    local config
    config=$(cat "$test_yaml")
    assert_contains "$config" "dev:\n    enabled: true" "Should enable dev environment"
    assert_contains "$config" "data:\n    enabled: false" "Should not enable data environment"
}

# Test parallel installation performance
test_parallel_installation() {
    # Create configuration with many packages
    local yaml_content='
packages:
  brew:
    - git
    - zsh
    - wget
    - curl
    - jq
  cask:
    - visual-studio-code
    - iterm2
    - firefox
environments:
  dev:
    enabled: true
    packages:
      - git
      - zsh
      - wget
'
    local test_yaml="$TEST_WORKSPACE/setup.yaml"
    echo "$yaml_content" > "$test_yaml"
    
    # Time parallel installation
    local start_time end_time duration
    start_time=$(date +%s)
    ./setup.zsh
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    # Verify reasonable completion time (under 5 minutes)
    assert_equals 0 $((duration < 300)) "Parallel installation should complete in reasonable time"
}

# Test error recovery and resilience
test_error_recovery() {
    # Create invalid configuration
    echo "invalid: yaml: content:" > "$TEST_WORKSPACE/setup.yaml"
    
    # Test setup with invalid configuration
    local result
    result=$(./setup.zsh 2>&1) || true
    assert_contains "$result" "ERROR" "Should log error for invalid configuration"
    assert_contains "$result" "Attempting to recover" "Should attempt recovery"
    
    # Test recovery by creating valid configuration
    local yaml_content='
packages:
  brew:
    - git
environments:
  core:
    enabled: true
    packages:
      - git
'
    echo "$yaml_content" > "$TEST_WORKSPACE/setup.yaml"
    
    result=$(./setup.zsh)
    assert_equals 0 $? "Should recover and complete setup"
}

# Test command line options
test_command_line_options() {
    # Test help option
    local result
    result=$(./setup.zsh -h)
    assert_contains "$result" "Usage:" "Should show usage information"
    
    # Test list environments option
    result=$(./setup.zsh -l)
    assert_contains "$result" "Available environments:" "Should list available environments"
    
    # Test verbose output
    result=$(./setup.zsh -v)
    assert_contains "$result" "DEBUG:" "Should show verbose output"
    
    # Test dry run
    result=$(./setup.zsh -d)
    assert_contains "$result" "[DRY-RUN]" "Should indicate dry run mode"
}

# Test system integration
test_system_integration() {
    # Test shell integration
    local result
    result=$(./setup.zsh)
    assert_equals 0 $? "System setup should succeed"
    
    # Verify shell configuration
    assert_file_exists "$HOME/.zshrc" "Should create shell configuration"
    local zshrc_content
    zshrc_content=$(cat "$HOME/.zshrc")
    assert_contains "$zshrc_content" "oh-my-zsh" "Should configure Oh My Zsh"
    assert_contains "$zshrc_content" "plugins=" "Should configure shell plugins"
    
    # Verify Homebrew integration
    assert_contains "$(command -v brew)" "brew" "Should have Homebrew in PATH"
}

# Run all tests
run_tests() {
    # Setup test environment
    setup
    
    # Run individual test functions
    test_default_setup
    test_environment_specific_setup
    test_parallel_installation
    test_error_recovery
    test_command_line_options
    test_system_integration
    
    # Cleanup test environment
    teardown
}

# Execute tests
run_tests