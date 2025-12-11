#!/usr/bin/dmd
/**
 * mkystd_data_structures_dynamic_array - Dynamic array implementation with ranges API
 *
 * Implements monkyyy's ranges API with the required optional functions
 */
module mkystd_data_structures_dynamic_array;

import mkystd.range;  // Simplified import path

//---
// Types and Constants
//---

/**
 * DynamicArray - A dynamic array implementing monkyyy's ranges API
 */
struct DynamicArray(T)
{
	T[] _data;
	size_t _startIdx = 0;  // For efficient popping from front
	bool[] _removalFlags; // Tracks removed elements
	bool _needsResolve = false;

	// Constructors
	this(T[] initialValues...)
	{
		_data = initialValues.dup;
		_removalFlags = new bool[_data.length];
	}

	// Core range functions
	ref T front() @property
	{
		if (_startIdx >= _data.length)
			assert(false, "Accessing empty range");

		// Skip removed elements
		size_t i = _startIdx;
		while (i < _data.length && _removalFlags[i]) {
			i++;
		}

		if (i >= _data.length)
			assert(false, "Accessing empty range after removals");

		return _data[i];
	}

	void pop()
	{
		if (_startIdx >= _data.length)
			assert(false, "Popping empty range");

		// Mark current front as removed instead of actually removing it
		// Actual removal happens during resolve()
		size_t i = _startIdx;
		while (i < _data.length && _removalFlags[i]) {
			i++;
		}

		if (i >= _data.length)
			assert(false, "Popping empty range after removals");

		_removalFlags[i] = true;
		_needsResolve = true;
		_startIdx = i + 1;  // Move past the removed element
	}

	bool empty() @property
	{
		if (_startIdx >= _data.length) return true;

		// Check if remaining elements are all removed
		for(size_t i = _startIdx; i < _data.length; i++) {
			if (!_removalFlags[i]) return false;
		}
		return true;
	}

	// Optional functions as specified
	size_t index()
	{
		// Return position that allows O(1) access to current front
		// For now, just return the start index
		return _startIdx;
	}

	size_t length() @property
	{
		if (!_needsResolve) {
			// Count non-removed elements
			size_t count = 0;
			for(size_t i = _startIdx; i < _data.length; i++) {
				if (!_removalFlags[i]) count++;
			}
			return count;
		} else {
			// If resolve is needed, return the apparent length
			// Actual resolution hasn't happened yet
			size_t count = 0;
			for(size_t i = _startIdx; i < _data.length; i++) {
				if (!_removalFlags[i]) count++;
			}
			return count;
		}
	}

	DynamicArray reverse()
	{
		// Actually reverse the data
		T[] newData = _data.dup;
		_removalFlags = _removalFlags.dup;

		// Reverse both data and removal flags together
		size_t left = 0;
		size_t right = newData.length - 1;

		while (left < right) {
			// Swap elements
			T temp = newData[left];
			newData[left] = newData[right];
			newData[right] = temp;

			// Swap removal flags
			bool tempFlag = _removalFlags[left];
			_removalFlags[left] = _removalFlags[right];
			_removalFlags[right] = tempFlag;

			left++;
			right--;
		}

		_data = newData;
		_needsResolve = true;

		// The start index also needs to be adjusted
		_startIdx = _data.length - _startIdx - 1;

		return this;
	}

	void remove()
	{
		// Mark current element for removal
		if (_startIdx >= _data.length)
			assert(false, "Removing from empty range");

		size_t i = _startIdx;
		while (i < _data.length && _removalFlags[i]) {
			i++;
		}

		if (i >= _data.length)
			assert(false, "Removing from empty range after removals");

		_removalFlags[i] = true;
		_needsResolve = true;
	}

	void append(T value)
	{
		// Append to the end of the data array
		_data ~= value;
		_removalFlags ~= false;  // New elements are not removed
		_needsResolve = true;
	}

	void resolve()
	{
		if (!_needsResolve) return;

		T[] newData;
		bool[] newRemovalFlags;

		// Copy only non-removed elements to the new array
		for(size_t i = _startIdx; i < _data.length; i++) {
			if (!_removalFlags[i]) {
				newData ~= _data[i];
				newRemovalFlags ~= false;
			}
		}

		_data = newData;
		_removalFlags = newRemovalFlags;
		_startIdx = 0;
		_needsResolve = false;
	}

	// Helper functions
	T opIndex(size_t idx)
	{
		resolve();  // Ensure array is in clean state

		if (idx >= _data.length)
			assert(false, "Index out of bounds");

		return _data[idx];
	}

	void opIndexAssign(T value, size_t idx)
	{
		resolve();  // Ensure array is in clean state

		if (idx >= _data.length)
			assert(false, "Index out of bounds");

		_data[idx] = value;
	}

	size_t opDollar()  // Property for length
	{
		return length;
	}

	// Convert to plain array
	T[] toArray()
	{
		resolve();
		return _data.dup;
	}
}