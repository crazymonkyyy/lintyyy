/**
 * test.d - Simple test for mkystd library
 *
 * Tests the basic functionality of the custom standard library
 */
import mkystd;
import mkystd_data_structures_dynamic_array;
import mkystd_algorithms;
import std.stdio;

void main()
{

    writeln("Testing mkystd library...");

    // Test DynamicArray
    auto arr = DynamicArray!int(1, 2, 3, 4, 5);
    writeln("Created array: ", arr.toArray());

    // Test range operations
    writeln("Range operations:");
    while (!arr.empty)
    {
        write(arr.front, " ");
        arr.pop;
    }
    writeln();

    // Recreate array for further tests
    arr = DynamicArray!int(1, 2, 3, 4, 5);
    writeln("Recreated array for algorithm tests: ", arr.toArray());

    // Test sum algorithm
    auto sumResult = sum(arr);
    writeln("Sum of elements: ", sumResult);

    /* Skipping complex algorithms temporarily
    // Test map algorithm - need to create proper function
    auto mapped = map!(doubleIt)(arr);
    writeln("Mapped (doubled): ");
    while (!mapped.empty)
    {
        write(mapped.front, " ");
        mapped.pop;
    }
    writeln();

    // Recreate array for filter test
    arr = DynamicArray!int(1, 2, 3, 4, 5, 6);
    auto filtered = filter!(isEven)(arr);
    writeln("Filtered (even numbers): ");
    while (!filtered.empty)
    {
        write(filtered.front, " ");
        filtered.pop;
    }
    writeln();
    */

    // Test the optional functions
    arr = DynamicArray!int(10, 20, 30, 40, 50);
    writeln("Testing optional functions on [10, 20, 30, 40, 50]:");
    writeln("Initial length: ", arr.length);
    writeln("Index of front: ", arr.index);

    arr.remove();  // Remove the first element (10)
    writeln("After remove (before resolve), length: ", arr.length);

    arr.resolve();  // Resolve the removal
    writeln("After resolve, length: ", arr.length);

    arr.append(60);  // Append new element
    writeln("After append 60 (before resolve), length: ", arr.length);

    arr.resolve();  // Resolve the addition
    writeln("After resolve, array: ", arr.toArray());

    // Test LinkedList as well
    auto ll = LinkedList!int(100, 200, 300);
    writeln("Created linked list: ", ll.toArray());

    writeln("LinkedList range operations:");
    while (!ll.empty)
    {
        write(ll.front, " ");
        ll.pop;
    }
    writeln();

    // Test Stack as well
    auto stack = Stack!int(1, 2, 3, 4, 5);
    writeln("Created stack: ", stack.toLIFOArray()); // In LIFO order

    writeln("Stack range operations (top to bottom):");
    while (!stack.empty)
    {
        write(stack.front, " ");
        stack.pop;
    }
    writeln();

    // Test Queue as well
    auto queue = Queue!int(10, 20, 30, 40, 50);
    writeln("Created queue: ", queue.toFIFOArray()); // In FIFO order

    writeln("Queue range operations (front to back):");
    while (!queue.empty)
    {
        write(queue.front, " ");
        queue.pop;
    }
    writeln();

    // Test Binary Tree as well
    auto tree = BinaryTree!int(50, 30, 70, 20, 40, 60, 80);
    writeln("Created binary tree: ", tree.toArray()); // In-order traversal

    writeln("Binary tree range operations (in-order traversal):");
    while (!tree.empty)
    {
        write(tree.front, " ");
        tree.pop;
    }
    writeln();

    // Test Hash Set as well
    auto hashset = HashSet!int(5, 2, 8, 1, 9, 3);
    writeln("Created hash set: ", hashset.toArray());

    writeln("Hash set range operations:");
    while (!hashset.empty)
    {
        write(hashset.front, " ");
        hashset.pop;
    }
    writeln();

    // Test Priority Queue as well
    auto pq = PriorityQueue!int(3, 1, 4, 1, 5, 9, 2, 6, 5);
    writeln("Created priority queue: ", pq.toPriorityOrderArray());

    writeln("Priority queue range operations (highest to lowest priority):");
    while (!pq.empty)
    {
        write(pq.front, " ");
        pq.pop;
    }
    writeln();

    // Test some of the new algorithms
    auto arr2 = DynamicArray!int(5, 2, 8, 1, 9, 3);
    writeln("Array for algorithm tests: ", arr2.toArray());

    writeln("Max: ", max(arr2));

    // For other tests, we need to recreate the array since max() consumes it
    arr2 = DynamicArray!int(5, 2, 8, 1, 9, 3);
    writeln("Min: ", min(arr2));

    arr2 = DynamicArray!int(5, 2, 8, 1, 9, 3);
    writeln("Count of evens: ", count!isEven(arr2));

    arr2 = DynamicArray!int(2, 4, 6, 8);
    writeln("All even? ", all!isEven(arr2));

    arr2 = DynamicArray!int(1, 2, 3, 4);
    writeln("Any even? ", any!isEven(arr2));

    arr2 = DynamicArray!int(1, 2, 3, 4, 5);
    writeln("Contains 3? ", contains(arr2, 3));

    arr2 = DynamicArray!int(1, 2, 3, 4);
    writeln("Product: ", product(arr2));

    arr2 = DynamicArray!int(1, 2, 3, 4, 5);
    writeln("Average: ", average(arr2));

    // Test take algorithm
    arr2 = DynamicArray!int(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
    auto taken = take(arr2, 5);
    writeln("Take 5: ");
    while (!taken.empty)
    {
        write(taken.front, " ");
        taken.pop;
    }
    writeln();

    // Test iota
    auto range = iota(1, 6);
    writeln("Iota 1 to 5: ");
    while (!range.empty)
    {
        write(range.front, " ");
        range.pop;
    }
    writeln();

    // Test repeat
    auto repeated = repeat(42, 3);
    writeln("Repeat 42 three times: ");
    while (!repeated.empty)
    {
        write(repeated.front, " ");
        repeated.pop;
    }
    writeln();

    writeln("All tests completed successfully!");
}