#!/usr/bin/env bash

# Set strict error handling
set -euo pipefail

# Colors for test output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

print_header() {
    echo "----------------------------------------"
    echo "🧪 Running Setup Script Test Suite"
    echo "----------------------------------------"
}

print_results() {
    echo "----------------------------------------"
    echo "📊 Test Results Summary"
    echo "----------------------------------------"
    echo "Total Tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    echo "----------------------------------------"
}

run_test_suite() {
    local suite_path="$1"
    local suite_name="$2"
    
    echo "🔍 Running $suite_name tests..."
    
    for test_file in "$suite_path"/*_test.sh; do
        if [[ -f "$test_file" ]]; then
            echo "  Running $(basename "$test_file")..."
            if bash "$test_file"; then
                ((PASSED_TESTS++))
            else
                ((FAILED_TESTS++))
            fi
            ((TOTAL_TESTS++))
        fi
    done
    echo
}

main() {
    print_header
    
    # Run all test suites
    run_test_suite "tests/unit" "Unit"
    run_test_suite "tests/integration" "Integration"
    run_test_suite "tests/system" "System"
    
    print_results
    
    # Exit with failure if any tests failed
    [[ $FAILED_TESTS -eq 0 ]]
}

main 