#!/bin/bash
# Cortado test runner - runs each test file in isolation

echo "=== CORTADO TEST RUNNER ==="
echo "Running tests with fixed module loading..."
echo

TOTAL_PASS=0
TOTAL_FAIL=0
FAILED_TESTS=""

# Run a single test file and capture results
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .lisp)
    
    echo -n "Running $test_name... "
    
    # Run test and capture output
    local output=$(cargo run --release --quiet -- "$test_file" 2>&1)
    local exit_code=$?
    
    # Check for explicit test failures in output
    if echo "$output" | grep -q "✗ FAIL"; then
        echo "FAILED"
        echo "$output" | grep "✗ FAIL" | sed 's/^/  /'
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
        FAILED_TESTS="$FAILED_TESTS\n- $test_name"
    elif [ $exit_code -ne 0 ]; then
        echo "ERROR"
        echo "  Exit code: $exit_code"
        echo "$output" | tail -5 | sed 's/^/  /'
        TOTAL_FAIL=$((TOTAL_FAIL + 1))
        FAILED_TESTS="$FAILED_TESTS\n- $test_name (error)"
    else
        echo "PASSED"
        TOTAL_PASS=$((TOTAL_PASS + 1))
    fi
}

# Create test wrapper that loads test framework
create_test_wrapper() {
    local test_file=$1
    local wrapper_file="${test_file%.lisp}-wrapped.lisp"
    
    cat > "$wrapper_file" << 'EOF'
;; Test wrapper - loads test framework before running test
(require [test :as t])

;; Reset test stats
(t/reset-test-stats)

EOF
    
    # Append the actual test content
    cat "$test_file" >> "$wrapper_file"
    
    # Add summary at end
    echo "" >> "$wrapper_file"
    echo "(print \"Test summary:\" (t/test-summary))" >> "$wrapper_file"
    
    echo "$wrapper_file"
}

# Run all test files
for test_file in test/*.lisp; do
    if [ -f "$test_file" ]; then
        # Create wrapped version
        wrapper=$(create_test_wrapper "$test_file")
        
        # Run the wrapped test
        run_test "$wrapper"
        
        # Clean up wrapper
        rm -f "$wrapper"
    fi
done

echo
echo "=== TEST SUMMARY ==="
echo "Total: $TOTAL_PASS passed, $TOTAL_FAIL failed"

if [ $TOTAL_FAIL -gt 0 ]; then
    echo -e "\nFailed tests:$FAILED_TESTS"
    exit 1
else
    echo "All tests passed!"
    exit 0
fi