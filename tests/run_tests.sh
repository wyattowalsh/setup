#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC2296,SC2299,SC2300,SC2301,SC2128,SC2034,SC2154

# Set strict error handling
setopt ERR_EXIT NO_UNSET PIPE_FAIL

# Colors for test output (disable if not in terminal)
if [[ -t 1 ]]; then
    typeset -r GREEN='\033[0;32m'
    typeset -r RED='\033[0;31m'
    typeset -r YELLOW='\033[1;33m'
    typeset -r BLUE='\033[0;34m'
    typeset -r NC='\033[0m'
else
    typeset -r GREEN=''
    typeset -r RED=''
    typeset -r YELLOW=''
    typeset -r BLUE=''
    typeset -r NC=''
fi

# Test results tracking
typeset -i TOTAL_TESTS=0
typeset -i PASSED_TESTS=0
typeset -i FAILED_TESTS=0
typeset -i SKIPPED_TESTS=0
typeset -a FAILED_TESTS_LIST=()
typeset -a SKIPPED_TESTS_LIST=()

# GitHub Actions specific settings
typeset -r IS_GITHUB_ACTIONS="${GITHUB_ACTIONS:-false}"
typeset -r GITHUB_STEP_SUMMARY="${GITHUB_STEP_SUMMARY:-}"

# Print test suite header
print_header() {
    printf '%s\n' "----------------------------------------"
    printf '%s\n' "🧪 Running Setup Script Test Suite"
    if [[ "$IS_GITHUB_ACTIONS" == "true" ]]; then
        printf '%s\n' "Running in GitHub Actions environment"
    fi
    printf '%s\n' "----------------------------------------"
}

# Print test results summary
print_results() {
    printf '%s\n' "----------------------------------------"
    printf '%s\n' "📊 Test Results Summary"
    printf '%s\n' "----------------------------------------"
    printf 'Total Tests: %d\n' "$TOTAL_TESTS"
    printf '%bPassed: %d%b\n' "${GREEN}" "$PASSED_TESTS" "${NC}"
    printf '%bFailed: %d%b\n' "${RED}" "$FAILED_TESTS" "${NC}"
    printf '%bSkipped: %d%b\n' "${YELLOW}" "$SKIPPED_TESTS" "${NC}"
    
    if (( FAILED_TESTS > 0 )); then
        printf '\n%bFailed Tests:%b\n' "${RED}" "${NC}"
        printf '%s\n' "${FAILED_TESTS_LIST[@]}" | sed 's/^/  /'
    fi
    
    if (( SKIPPED_TESTS > 0 )); then
        printf '\n%bSkipped Tests:%b\n' "${YELLOW}" "${NC}"
        printf '%s\n' "${SKIPPED_TESTS_LIST[@]}" | sed 's/^/  /'
    fi
    
    printf '%s\n' "----------------------------------------"
    
    # Write results to GitHub Actions step summary if available
    if [[ -n "$GITHUB_STEP_SUMMARY" ]]; then
        {
            echo "## Test Results Summary"
            echo "| Category | Count |"
            echo "|----------|-------|"
            echo "| Total | $TOTAL_TESTS |"
            echo "| ✅ Passed | $PASSED_TESTS |"
            echo "| ❌ Failed | $FAILED_TESTS |"
            echo "| ⚠️ Skipped | $SKIPPED_TESTS |"
            
            if (( FAILED_TESTS > 0 )); then
                echo -e "\n### Failed Tests"
                printf '%s\n' "${FAILED_TESTS_LIST[@]}" | sed 's/^/- /'
            fi
            
            if (( SKIPPED_TESTS > 0 )); then
                echo -e "\n### Skipped Tests"
                printf '%s\n' "${SKIPPED_TESTS_LIST[@]}" | sed 's/^/- /'
            fi
        } >> "$GITHUB_STEP_SUMMARY"
    fi
}

# Run a test suite
run_test_suite() {
    local suite_path="$1"
    local suite_name="$2"
    
    printf '%b🔍 Running %s tests...%b\n' "${BLUE}" "$suite_name" "${NC}"
    
    # Check if directory exists
    if [[ ! -d "$suite_path" ]]; then
        printf '%b⚠️ Warning: Test suite directory %s not found%b\n' "${YELLOW}" "$suite_path" "${NC}"
        return 0
    fi
    
    # Find all test files
    # shellcheck disable=SC2296
    local test_files=("$suite_path"/*_test.sh(N))
    if (( ${#test_files} == 0 )); then
        printf '%b⚠️ Warning: No test files found in %s%b\n' "${YELLOW}" "$suite_path" "${NC}"
        return 0
    fi
    
    local test_file test_output start_time end_time duration
    for test_file in "${test_files[@]}"; do
        if [[ ! -x "$test_file" ]]; then
            printf '%b⚠️ Warning: %s is not executable, skipping%b\n' "${YELLOW}" "$test_file" "${NC}"
            (( SKIPPED_TESTS++ ))
            SKIPPED_TESTS_LIST+=("$(basename "$test_file"): Not executable")
            continue
        fi
        
        printf '  Running %s...\n' "$(basename "$test_file")"
        
        # Time the test execution
        start_time=$SECONDS
        if test_output=$(zsh "$test_file" 2>&1); then
            end_time=$SECONDS
            duration=$((end_time - start_time))
            (( PASSED_TESTS++ ))
            printf '%b✓ Test passed%b (took %ds)\n' "${GREEN}" "${NC}" "$duration"
            
            # Log to GitHub Actions
            if [[ "$IS_GITHUB_ACTIONS" == "true" ]]; then
                echo "::debug::Test passed: $(basename "$test_file") (${duration}s)"
            fi
        else
            end_time=$SECONDS
            duration=$((end_time - start_time))
            (( FAILED_TESTS++ ))
            FAILED_TESTS_LIST+=("$(basename "$test_file"): $test_output")
            printf '%b✗ Test failed%b (took %ds)\n' "${RED}" "${NC}" "$duration"
            printf '%s\n' "$test_output" | sed 's/^/    /'
            
            # Log to GitHub Actions
            if [[ "$IS_GITHUB_ACTIONS" == "true" ]]; then
                echo "::error::Test failed: $(basename "$test_file") (${duration}s)"
                echo "::group::Error Details"
                echo "$test_output"
                echo "::endgroup::"
            fi
        fi
        (( TOTAL_TESTS++ ))
    done
    printf '\n'
}

# Cleanup function
cleanup() {
    local exit_code=$?
    if [[ -n "${TEST_WORKSPACE:-}" && -d "$TEST_WORKSPACE" ]]; then
        rm -rf "$TEST_WORKSPACE"
    fi
    exit "$exit_code"
}

# Main function
main() {
    # Set up cleanup trap
    trap cleanup EXIT INT TERM
    
    # Set up error handling
    trap 'echo "::error::Command failed: $BASH_COMMAND"' ERR
    
    print_header
    
    # Run all test suites
    local test_dir="${0:h}"
    run_test_suite "$test_dir/unit" "Unit"
    run_test_suite "$test_dir/integration" "Integration"
    run_test_suite "$test_dir/system" "System"
    
    print_results
    
    # Exit with failure if any tests failed
    return $(( FAILED_TESTS > 0 ))
}

# Run main function
if ! main "$@"; then
    exit 1
fi 