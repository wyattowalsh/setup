#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC2296,SC2299,SC2300,SC2301,SC2128,SC2034,SC2154

source "${0:A:h}/../test_helper.sh"

# Test YAML parsing functions
test_parse_yaml() {
    local yaml_content='
packages:
  brew:
    - git
    - zsh
  cask:
    - visual-studio-code
    - iterm2
environments:
  dev:
    enabled: true
    packages:
      - git
      - zsh
'
    local test_yaml="$TEST_WORKSPACE/test.yaml"
    echo "$yaml_content" > "$test_yaml"
    
    # Test YAML parsing
    local result
    result=$(parse_yaml "$test_yaml")
    assert_contains "$result" "packages_brew_1=git" "YAML parser should handle nested arrays"
    assert_contains "$result" "environments_dev_enabled=true" "YAML parser should handle boolean values"
}

# Test environment validation functions
test_validate_environment() {
    # Test valid environment
    local result
    result=$(validate_environment "dev")
    assert_equals 0 $? "Valid environment should pass validation"
    
    # Test invalid environment
    result=$(validate_environment "nonexistent")
    assert_equals 1 $? "Invalid environment should fail validation"
}

# Test package installation functions
test_install_package() {
    mock_homebrew
    
    # Test brew package installation
    local result
    result=$(install_package "git" "brew")
    assert_equals 0 $? "Brew package installation should succeed"
    assert_contains "$result" "brew install git" "Should attempt to install brew package"
    
    # Test cask package installation
    result=$(install_package "visual-studio-code" "cask")
    assert_equals 0 $? "Cask package installation should succeed"
    assert_contains "$result" "brew install --cask visual-studio-code" "Should attempt to install cask package"
}

# Test parallel installation functions
test_parallel_install() {
    mock_homebrew
    
    # Test parallel brew installation
    local packages=("git" "zsh" "wget")
    local result
    result=$(parallel_install_packages "$packages" "brew")
    assert_equals 0 $? "Parallel brew installation should succeed"
    
    # Test parallel cask installation
    local casks=("visual-studio-code" "iterm2")
    result=$(parallel_install_packages "$casks" "cask")
    assert_equals 0 $? "Parallel cask installation should succeed"
}

# Test error handling functions
test_error_handling() {
    # Test error logging
    local result
    result=$(log_error "Test error message")
    assert_contains "$result" "ERROR" "Error logging should include ERROR prefix"
    assert_contains "$result" "Test error message" "Error logging should include message"
    
    # Test error recovery
    result=$(handle_error "test_function" "Test error")
    assert_contains "$result" "Attempting to recover" "Error handler should attempt recovery"
}

# Test configuration validation
test_validate_config() {
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
'
    local test_yaml="$TEST_WORKSPACE/test.yaml"
    echo "$yaml_content" > "$test_yaml"
    
    # Test valid configuration
    local result
    result=$(validate_config "$test_yaml")
    assert_equals 0 $? "Valid configuration should pass validation"
    
    # Test invalid configuration
    echo "invalid: yaml: content:" > "$test_yaml"
    result=$(validate_config "$test_yaml")
    assert_equals 1 $? "Invalid configuration should fail validation"
}

# Run all tests
run_tests() {
    # Setup test environment
    setup
    
    # Run individual test functions
    test_parse_yaml
    test_validate_environment
    test_install_package
    test_parallel_install
    test_error_handling
    test_validate_config
    
    # Cleanup test environment
    teardown
}

# Execute tests
run_tests