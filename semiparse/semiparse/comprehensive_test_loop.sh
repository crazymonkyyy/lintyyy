#!/bin/bash
# comprehensive_test_loop.sh - Comprehensive testing loop for semiparse

echo "Starting comprehensive semiparse testing loop..."

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
        # Continue anyway to run other tests
    fi
else
    echo "Compilation of tests failed!"
    # Continue anyway to run other tests
fi

echo ""
echo "Running integration test..."
dmd test_semiparse.d source/semiparse.d
if [ $? -eq 0 ]; then
    echo "Running integration test..."
    ./test_semiparse
    if [ $? -eq 0 ]; then
        echo "Integration test PASSED"
    else
        echo "Integration test FAILED"
    fi
else
    echo "Compilation of integration test failed!"
fi

echo ""
echo "Running libdparse validation tests..."
dmd libdparse_validation_tests.d source/semiparse.d
if [ $? -eq 0 ]; then
    echo "Running libdparse validation..."
    ./libdparse_validation_tests
    if [ $? -eq 0 ]; then
        echo "Libdparse validation tests PASSED"
    else
        echo "Libdparse validation tests FAILED"
    fi
else
    echo "Compilation of libdparse validation tests failed!"
fi

echo ""
echo "Testing loop completed!"