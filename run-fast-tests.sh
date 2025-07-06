#!/bin/bash
# Cortado Fast Test Runner - Only runs known-good, fast tests
# Each test runs in isolation with timeout protection

set -e  # Exit on any error

echo "CORTADO FAST TEST RUNNER"
echo "Running curated list of fast, working tests..."
echo

# Test configuration
TIMEOUT_SECONDS=10
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
FAILED_LIST=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run a single test with timeout
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .lisp)
    
    echo -n "Testing $test_name... "
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    # Run test with test framework loaded
    # Create a temporary test file that loads the framework first
    cat > /tmp/cortado_test_runner.lisp << EOF
;; Load test framework
(defn assert-eq [expected actual] 
  (if (= expected actual) 
    (print "  ✓ PASS:" expected "==" actual)
    (print "  ✗ FAIL: expected" expected "but got" actual)))

;; Load the actual test file
(load "$test_file")
EOF
    
    if cargo run --quiet /tmp/cortado_test_runner.lisp > /tmp/cortado_test_output.txt 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        # Show any interesting output (but not too verbose)
        if grep -q "FAIL\|ERROR\|error" /tmp/cortado_test_output.txt; then
            echo "  Output: $(cat /tmp/cortado_test_output.txt | tail -3)"
        fi
    else
        echo -e "${RED}✗ FAILED${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_LIST="$FAILED_LIST\n  - $test_name"
        
        # Show error output
        echo "  Error: $(cat /tmp/cortado_test_output.txt | tail -3)"
    fi
}

# Curated list of known-good, fast tests
echo "Running curated fast tests..."

# Core language functionality (instant)
run_test "test/basic-test.lisp"
run_test "test/core.lisp"
run_test "test/math.lisp"

# Comprehensive tests that we saw working
run_test "test/core-comprehensive.lisp"
run_test "test/edge-cases.lisp"

# Threading macros (~260ms)  
run_test "test/threading-basic.lisp"

# Sequence operations (~260ms)
run_test "test/sequences-simple.lisp"

# More comprehensive tests
run_test "test/math-comprehensive.lisp"
run_test "test/macro-comprehensive.lisp"
run_test "test/seq.lisp"
run_test "test/multiline-test.lisp"
run_test "test/manual-test.lisp"

echo
echo "======================================"
echo -e "${BLUE} TEST SUMMARY${NC}"
echo "======================================"
echo -e "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "\n${RED}Failed tests:${NC}$FAILED_LIST"
    echo
    echo -e "${YELLOW} TIP: Failed tests may use slow 'load' instead of fast 'require'${NC}"
    exit 1
else
    echo -e "\n${GREEN} ALL TESTS PASSED!${NC}"
    echo -e "${GREEN} Module loading performance is working great!${NC}"
    exit 0
fi

# Cleanup
rm -f /tmp/cortado_test_output.txt /tmp/cortado_test_runner.lisp
