#!/usr/bin/dmd
/**
 * mkystd_data_structures_priority_queue - Priority queue implementation with ranges API
 *
 * Implements monkyyy's ranges API with the required optional functions
 */
module mkystd_data_structures_priority_queue;

import mkystd.range;  // Simplified import path

//---
// Types and Constants
//---

/**
 * PriorityQueue - A priority queue (max-heap) data structure implementing monkyyy's ranges API
 * When used as a range, it iterates from highest priority to lowest
 */
struct PriorityQueue(T)
{
	T[] _heap;  // Array representation of the heap
	bool[] _removalFlags; // Tracks removed elements
	bool _needsResolve = false;

	// Constructor
	this(T[] initialValues...)
	{
		_heap = new T[initialValues.length];
		_removalFlags = new bool[initialValues.length];

		// Copy values and build the heap
		for(size_t i = 0; i < initialValues.length; i++)
		{
			_heap[i] = initialValues[i];
		}

		// Build heap property
		for(size_t i = initialValues.length / 2; i > 0; i--)
		{
			heapifyDown(i - 1);
		}

		_needsResolve = true;
	}

	// Helper to maintain heap property downward
	void heapifyDown(size_t index)
	{
		size_t largest = index;
		size_t left = 2 * index + 1;
		size_t right = 2 * index + 2;

		// Find the largest among root, left child and right child
		if (left < _heap.length && _heap[left] > _heap[largest] && !_removalFlags[left])
		{
			largest = left;
		}

		if (right < _heap.length && _heap[right] > _heap[largest] && !_removalFlags[right])
		{
			largest = right;
		}

		// If largest is not root, swap and continue heapifying
		if (largest != index)
		{
			T temp = _heap[index];
			_heap[index] = _heap[largest];
			_heap[largest] = temp;

			bool flagTemp = _removalFlags[index];
			_removalFlags[index] = _removalFlags[largest];
			_removalFlags[largest] = flagTemp;

			heapifyDown(largest);
		}
	}

	// Helper to maintain heap property upward
	void heapifyUp(size_t index)
	{
		if (index == 0) return;

		size_t parent = (index - 1) / 2;

		if (_heap[index] > _heap[parent] && !_removalFlags[parent])
		{
			// Swap
			T temp = _heap[index];
			_heap[index] = _heap[parent];
			_heap[parent] = temp;

			bool flagTemp = _removalFlags[index];
			_removalFlags[index] = _removalFlags[parent];
			_removalFlags[parent] = flagTemp;

			heapifyUp(parent);
		}
	}

	// Helper to find the highest priority non-removed element
	size_t findHighestPriorityIndex()
	{
		size_t highestIdx = _heap.length;
		T highestValue;
		bool first = true;

		for(size_t i = 0; i < _heap.length; i++)
		{
			if (!_removalFlags[i])
			{
				if (first || _heap[i] > highestValue)
				{
					highestValue = _heap[i];
					highestIdx = i;
					first = false;
				}
			}
		}

		return highestIdx;
	}

	// Core range functions - the highest priority element is the front
	ref T front() @property
	{
		if (empty())
			assert(0, "Accessing empty priority queue");

		size_t idx = findHighestPriorityIndex();
		if (idx >= _heap.length)
			assert(0, "Accessing empty priority queue after removals");

		return _heap[idx];
	}

	void pop()
	{
		if (empty())
			assert(0, "Popping empty priority queue");

		// Instead of removing the element (which would break heap structure),
		// we mark the highest priority element as removed
		size_t idx = findHighestPriorityIndex();
		if (idx < _heap.length)
		{
			_removalFlags[idx] = true;
			_needsResolve = true;
		}
	}

	bool empty() @property
	{
		// Check if all elements are removed
		for(size_t i = 0; i < _heap.length; i++)
		{
			if (!_removalFlags[i])
				return false;
		}
		return true;
	}

	// Optional functions as specified
	size_t index()
	{
		// Return the index of the current highest priority element
		return findHighestPriorityIndex();
	}

	size_t length() @property
	{
		if (!_needsResolve)
		{
			// Count non-removed elements
			size_t count = 0;
			for(size_t i = 0; i < _heap.length; i++)
			{
				if (!_removalFlags[i])
					count++;
			}
			return count;
		}
		else
		{
			// Count non-removed elements
			size_t count = 0;
			for(size_t i = 0; i < _heap.length; i++)
			{
				if (!_removalFlags[i])
					count++;
			}
			return count;
		}
	}

	PriorityQueue reverse()
	{
		// For a priority queue, reversing might mean changing from max-heap to min-heap
		// or changing the order of extraction. Here we'll just reverse the heap array
		// and rebuild the heap structure (which would still maintain the heap property)

		// Actually, let's just reverse the array representation of the heap
		size_t len = _heap.length;
		for(size_t i = 0; i < len / 2; i++)
		{
			T temp = _heap[i];
			bool flagTemp = _removalFlags[i];

			_heap[i] = _heap[len - 1 - i];
			_removalFlags[i] = _removalFlags[len - 1 - i];

			_heap[len - 1 - i] = temp;
			_removalFlags[len - 1 - i] = flagTemp;
		}

		// Rebuild heap
		for(size_t i = len / 2; i > 0; i--)
		{
			heapifyDown(i - 1);
		}

		_needsResolve = true;

		return this;
	}

	void remove()
	{
		if (empty())
			assert(0, "Removing from empty priority queue");

		// Mark the highest priority element for removal
		size_t idx = findHighestPriorityIndex();
		if (idx < _heap.length)
		{
			_removalFlags[idx] = true;
			_needsResolve = true;
		}
	}

	void append(T value)  // Add a value to the priority queue (push)
	{
		// Add to the end of the array
		_heap ~= value;
		_removalFlags ~= false;  // New element is not removed

		// Restore heap property by moving up
		heapifyUp(_heap.length - 1);

		_needsResolve = true;
	}

	void resolve()
	{
		if (!_needsResolve) return;

		T[] newHeap;
		bool[] newRemovalFlags;

		// Copy only non-removed elements to the new heap
		for(size_t i = 0; i < _heap.length; i++) {
			if (!_removalFlags[i]) {
				newHeap ~= _heap[i];
				newRemovalFlags ~= false;
			}
		}

		_heap = newHeap;
		_removalFlags = newRemovalFlags;

		// Rebuild the heap property
		for(size_t i = _heap.length / 2; i > 0; i--)
		{
			heapifyDown(i - 1);
		}

		_needsResolve = false;
	}

	// Priority queue specific methods
	void push(T value)
	{
		append(value);
	}

	T top()
	{
		return front;
	}

	// Convert to array (doesn't maintain heap order necessarily)
	T[] toArray()
	{
		resolve(); // Ensure we have a clean array
		return _heap.dup;
	}

	// Get elements in priority order (highest first)
	T[] toPriorityOrderArray()
	{
		resolve();
		// Create a copy of the heap as it would be extracted (highest first)
		T[] result;
		bool[] tempFlags = _removalFlags.dup;

		// Simulate extraction of all elements
		for(size_t count = 0; count < _heap.length; count++)
		{
			size_t highestIdx = findHighestPriorityIndexWithFlags(tempFlags);
			if (highestIdx < _heap.length)
			{
				result ~= _heap[highestIdx];
				tempFlags[highestIdx] = true;  // Mark as "extracted"
			}
		}

		return result;
	}

	// Helper to find highest priority with a temporary flag array
	size_t findHighestPriorityIndexWithFlags(bool[] flags)
	{
		size_t highestIdx = _heap.length;
		T highestValue;
		bool first = true;

		for(size_t i = 0; i < _heap.length; i++)
		{
			if (!flags[i])
			{
				if (first || _heap[i] > highestValue)
				{
					highestValue = _heap[i];
					highestIdx = i;
					first = false;
				}
			}
		}

		return highestIdx;
	}
}