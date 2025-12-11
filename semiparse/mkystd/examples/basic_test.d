#!/usr/bin/dmd
/+ dub.sdl:
name "basic_test"
description "Basic test suite for mkystd library"
license "BSL-1.0"
+/
/**
 * Basic test for mkystd library
 * Tests one data structure and a few algorithms
 */
import mkystd;
import mkystd_data_structures_dynamic_array;
import mkystd_algorithms;
import std.stdio;

void main()
{
    writeln("Running basic tests for mkystd library...");
    
    // Test DynamicArray
    testDynamicArray();
    
    // Test Algorithms
    testAlgorithms();
    
    writeln("All basic tests completed successfully!");
}

void testDynamicArray()
{
    writeln("Testing DynamicArray...");
    
    // Create and test basic functionality
    auto arr = DynamicArray!int(1, 2, 3, 4, 5);
    assert(arr.front == 1, "Front should be 1");
    arr.pop;
    assert(arr.front == 2, "Front should be 2 after pop");
    
    // Test length and index
    assert(arr.length == 4, "Length should be 4");
    writeln("DynamicArray basic functionality test passed!");
}

void testAlgorithms()
{
    writeln("Testing Algorithms...");
    
    // Test sum
    auto arr = DynamicArray!int(1, 2, 3, 4, 5);
    auto sumResult = sum(arr);
    assert(sumResult == 15, "Sum should be 15");
    writeln("Sum test passed!");
    
    // Test max
    arr = DynamicArray!int(5, 2, 8, 1, 9, 3);
    auto maxResult = max(arr);
    assert(maxResult == 9, "Max should be 9");
    writeln("Max test passed!");
    
    // Test min
    auto minResult = min(arr);
    assert(minResult == 1, "Min should be 1");
    writeln("Min test passed!");
}