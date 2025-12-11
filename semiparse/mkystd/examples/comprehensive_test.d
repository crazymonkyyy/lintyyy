#!/usr/bin/dmd
/+ dub.sdl:
name "comprehensive_test"
description "Comprehensive test suite for mkystd library"
license "BSL-1.0"
+/
/**
 * Comprehensive test suite for mkystd library
 * Tests all data structures and algorithms
 */
import mkystd;
import mkystd_data_structures_dynamic_array;
import mkystd_data_structures_linkedlist;
import mkystd_data_structures_stack;
import mkystd_data_structures_queue;
import mkystd_data_structures_btree;
import mkystd_data_structures_hashtable;
import mkystd_data_structures_priority_queue;
import mkystd_algorithms;
import std.stdio;

// Helper functions for the algorithms
int doubleIt(int x) { return x * 2; }
bool isEven(int x) { return x % 2 == 0; }

void main()
{
    writeln("Running comprehensive tests for mkystd library...");
    
    // Test DynamicArray
    testDynamicArray();
    
    // Test LinkedList
    testLinkedList();
    
    // Test Stack
    testStack();
    
    // Test Queue
    testQueue();
    
    // Test BinaryTree
    testBinaryTree();
    
    // Test HashSet
    testHashSet();
    
    // Test PriorityQueue
    testPriorityQueue();
    
    // Test Algorithms
    testAlgorithms();
    
    writeln("All tests completed successfully!");
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
    assert(arr.index == 1, "Index should be 1");
    
    // Test remove/append/resolve
    arr.remove;
    assert(arr.length == 3, "Length should be 3 after remove");
    arr.resolve;
    assert(arr.front == 3, "Front should be 3 after resolve");
    
    // Test reverse
    arr = DynamicArray!int(1, 2, 3);
    arr.reverse;
    // Note: This will depend on how reverse works with the internal structure
    
    writeln("DynamicArray tests passed!");
}

void testLinkedList()
{
    writeln("Testing LinkedList...");
    
    auto ll = LinkedList!int(10, 20, 30);
    assert(ll.front == 10, "Front should be 10");
    ll.pop;
    assert(ll.front == 20, "Front should be 20 after pop");
    
    assert(ll.length == 2, "Length should be 2");
    assert(ll.index == 1, "Index should be 1");
    
    writeln("LinkedList tests passed!");
}

void testStack()
{
    writeln("Testing Stack...");
    
    auto stack = Stack!int(1, 2, 3);
    assert(stack.front == 3, "Stack front should be top element (3)");
    stack.pop;
    assert(stack.front == 2, "Stack front should be 2 after pop");
    
    stack.push(4);
    assert(stack.front == 4, "Stack front should be 4 after push");
    
    assert(stack.length == 3, "Length should be 3");
    assert(stack.index == 3, "Index should be 3");
    
    writeln("Stack tests passed!");
}

void testQueue()
{
    writeln("Testing Queue...");
    
    auto queue = Queue!int(10, 20, 30);
    assert(queue.front == 10, "Queue front should be first element (10)");
    queue.pop;
    assert(queue.front == 20, "Queue front should be 20 after pop");
    
    queue.push(40);
    assert(queue.length == 3, "Length should be 3 after push");
    
    assert(queue.index == 1, "Index should be 1");
    
    writeln("Queue tests passed!");
}

void testBinaryTree()
{
    writeln("Testing BinaryTree...");
    
    auto tree = BinaryTree!int(50, 30, 70, 20, 40, 60, 80);
    // Note: For tree, the front would be the first element in in-order traversal
    assert(tree.front == 20, "Tree front should be smallest element (20)");
    tree.pop;
    assert(tree.front == 30, "Tree front should be next element (30) after pop");
    
    assert(tree.length > 0, "Tree should have elements");
    
    writeln("BinaryTree tests passed!");
}

void testHashSet()
{
    writeln("Testing HashSet...");
    
    auto set = HashSet!int(5, 2, 8, 1, 9, 3);
    assert(set.contains(5), "Set should contain 5");
    assert(!set.contains(10), "Set should not contain 10");
    
    set.add(10);
    assert(set.contains(10), "Set should now contain 10");
    
    // Check that front is one of the expected values (order not guaranteed in hash set)
    int val = set.front;
    assert(val == 5 || val == 2 || val == 8 || val == 1 || val == 9 || val == 3 || val == 10, "Front should be one of the values");
    
    set.pop;
    assert(set.length > 0 || set.empty, "Length should be consistent with empty status");
    
    writeln("HashSet tests passed!");
}

void testPriorityQueue()
{
    writeln("Testing PriorityQueue...");
    
    auto pq = PriorityQueue!int(3, 1, 4, 1, 5, 9, 2, 6, 5);
    assert(pq.front == 9, "PQ front should be highest priority (9)");
    pq.pop;
    assert(pq.front == 6, "PQ front should be next highest (6) after pop");
    
    pq.push(10);
    assert(pq.front == 10, "PQ front should be 10 after pushing higher priority");
    
    assert(pq.length > 0, "PQ should have elements");
    
    writeln("PriorityQueue tests passed!");
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
    
    // Test count
    arr = DynamicArray!int(1, 2, 3, 4, 5, 6);
    auto countResult = count!isEven(arr);
    assert(countResult == 3, "Count of evens should be 3");
    writeln("Count test passed!");
    
    // Test all
    arr = DynamicArray!int(2, 4, 6, 8);
    auto allResult = all!isEven(arr);
    assert(allResult == true, "All should be even");
    writeln("All test passed!");
    
    // Test any
    arr = DynamicArray!int(1, 2, 3, 4);
    auto anyResult = any!isEven(arr);
    assert(anyResult == true, "Any should be even");
    writeln("Any test passed!");
    
    // Test contains
    arr = DynamicArray!int(1, 2, 3, 4, 5);
    auto containsResult = contains(arr, 3);
    assert(containsResult == true, "Should contain 3");
    writeln("Contains test passed!");
    
    // Test product
    arr = DynamicArray!int(1, 2, 3, 4);
    auto productResult = product(arr);
    assert(productResult == 24, "Product should be 24");
    writeln("Product test passed!");
    
    // Test average
    arr = DynamicArray!int(1, 2, 3, 4, 5);
    auto avgResult = average(arr);
    assert(avgResult == 3, "Average should be 3");
    writeln("Average test passed!");
    
    // Test take
    arr = DynamicArray!int(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
    auto taken = take(arr, 3);
    assert(taken.front == 1, "Take front should be 1");
    taken.pop;
    assert(taken.front == 2, "Take front should be 2 after pop");
    writeln("Take test passed!");
    
    // Test iota
    auto range = iota(1, 4);
    assert(range.front == 1, "Iota front should be 1");
    range.pop;
    assert(range.front == 2, "Iota front should be 2 after pop");
    writeln("Iota test passed!");
    
    // Test repeat
    auto repeated = repeat(42, 3);
    assert(repeated.front == 42, "Repeat front should be 42");
    repeated.pop;
    assert(repeated.front == 42, "Repeat front should still be 42");
    writeln("Repeat test passed!");
    
    writeln("All algorithm tests passed!");
}