#!/bin/bash
# test_loop.sh - Testing loop for semiparse

echo "Starting semiparse testing loop..."

# Build the semiparse library
echo "Building semiparse..."
dmd -c source/semiparse.d
if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Running unit tests..."
dmd semiparse_tests.d source/semiparse.d
if [ $? -eq 0 ]; then
    echo "Running semiparse_tests..."
    ./semiparse_tests
    if [ $? -eq 0 ]; then
        echo "Unit tests PASSED"
    else
        echo "Unit tests FAILED"
        exit 1
    fi
else
    echo "Compilation of tests failed!"
    exit 1
fi

echo "Running integration test..."
dmd test_semiparse.d source/semiparse.d
if [ $? -eq 0 ]; then
    echo "Running integration test..."
    ./test_semiparse
    if [ $? -eq 0 ]; then
        echo "Integration test PASSED"
    else
        echo "Integration test FAILED"
        exit 1
    fi
else
    echo "Compilation of integration test failed!"
    exit 1
fi

echo "All tests completed successfully!"