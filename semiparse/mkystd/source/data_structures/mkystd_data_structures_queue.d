#!/usr/bin/dmd
/**
 * mkystd_data_structures_queue - Queue implementation with ranges API
 *
 * Implements monkyyy's ranges API with the required optional functions
 */
module mkystd_data_structures_queue;

import mkystd.range;  // Simplified import path

//---
// Types and Constants
//---

/**
 * Queue - A queue (FIFO) data structure implementing monkyyy's ranges API
 * When used as a range, it iterates from front to back (FIFO order)
 */
struct Queue(T)
{
	T[] _data;
	size_t _frontIdx = 0;  // Index of the front element
	size_t _size = 0;      // Current number of elements in the queue
	bool[] _removalFlags; // Tracks removed elements
	bool _needsResolve = false;

	// Constructors
	this(T[] initialValues...)
	{
		_data = initialValues.dup;
		_size = _data.length;
		_removalFlags = new bool[_data.length];
	}

	// Core range functions
	ref T front() @property
	{
		if (empty())
			assert(0, "Accessing empty queue");

		// Find the frontmost non-removed element
		for(size_t i = _frontIdx; i < _frontIdx + _size && i < _data.length; i++)
		{
			if (!_removalFlags[i])
				return _data[i];
		}

		assert(0, "Accessing empty queue after removals");
	}

	void pop()
	{
		if (empty())
			assert(0, "Popping empty queue");

		// Mark the front element for removal instead of removing it
		// Actual removal happens during resolve()
		for(size_t i = _frontIdx; i < _frontIdx + _size && i < _data.length; i++)
		{
			if (!_removalFlags[i])
			{
				_removalFlags[i] = true;
				_needsResolve = true;

				// Update the front index to the next non-removed element
				_frontIdx = i + 1;
				return;
			}
		}

		assert(0, "Popping empty queue after removals");
	}

	bool empty() @property
	{
		if (_size == 0) return true;

		// Check if all elements from frontIdx to frontIdx+size are removed
		for(size_t i = _frontIdx; i < _frontIdx + _size && i < _data.length; i++)
		{
			if (!_removalFlags[i]) return false;
		}
		return true;
	}

	// Optional functions as specified
	size_t index()
	{
		// Return the index of the current front element
		for(size_t i = _frontIdx; i < _frontIdx + _size && i < _data.length; i++)
		{
			if (!_removalFlags[i])
				return i;
		}
		return _frontIdx + _size; // If empty, return past-the-end index
	}

	size_t length() @property
	{
		if (!_needsResolve) {
			// Count non-removed elements from frontIdx to frontIdx+size
			size_t count = 0;
			for(size_t i = _frontIdx; i < _frontIdx + _size && i < _data.length; i++) {
				if (!_removalFlags[i]) count++;
			}
			return count;
		} else {
			// If resolve is needed, count non-removed elements
			size_t count = 0;
			for(size_t i = _frontIdx; i < _frontIdx + _size && i < _data.length; i++) {
				if (!_removalFlags[i]) count++;
			}
			return count;
		}
	}

	Queue reverse()
	{
		// Create a new reversed queue by copying non-removed elements in reverse order
		T[] tempData;

		// Collect non-removed elements in reverse order
		for(size_t i = _frontIdx + _size - 1; i >= _frontIdx && i < _data.length; i--)
		{
			if (!_removalFlags[i])
			{
				tempData ~= _data[i];
			}
		}

		// Clear the current queue and populate with reversed data
		_data = tempData;
		_frontIdx = 0;
		_size = _data.length;
		_removalFlags = new bool[_data.length]; // All elements are now non-removed
		_needsResolve = true;

		return this;
	}

	void remove()
	{
		if (empty())
			assert(0, "Removing from empty queue");

		// Mark the front element for removal
		for(size_t i = _frontIdx; i < _frontIdx + _size && i < _data.length; i++)
		{
			if (!_removalFlags[i])
			{
				_removalFlags[i] = true;
				_needsResolve = true;
				return;
			}
		}

		assert(0, "Removing from empty queue after removals");
	}

	void append(T value)
	{
		// Add to the back of the queue
		if (_frontIdx + _size >= _data.length)
		{
			// Need to expand the array
			_data ~= value;
			_removalFlags ~= false;
		}
		else
		{
			// There's space, so just add to the end
			_data[_frontIdx + _size] = value;
			if (_removalFlags.length <= _frontIdx + _size)
			{
				_removalFlags ~= false;
			}
			else
			{
				_removalFlags[_frontIdx + _size] = false;
			}
		}
		_size++;
		_needsResolve = true;
	}

	void resolve()
	{
		if (!_needsResolve) return;

		T[] newData;
		bool[] newRemovalFlags;

		// Copy only non-removed elements to the new array
		for(size_t i = _frontIdx; i < _frontIdx + _size && i < _data.length; i++) {
			if (!_removalFlags[i]) {
				newData ~= _data[i];
				newRemovalFlags ~= false;
			}
		}

		_data = newData;
		_removalFlags = newRemovalFlags;
		_frontIdx = 0;
		_size = _data.length;
		_needsResolve = false;
	}
    
    // Queue-specific methods
    void push(T value)  // Same as append for a queue (enqueue at back)
    {
        append(value);
    }
    
    T peek()
    {
        return front;
    }
    
    // Helper functions
    T opIndex(size_t idx)
    {
        resolve();  // Ensure array is in clean state
        
        if (idx >= _size) 
            assert(0, "Index out of bounds");
        
        return _data[idx];
    }
    
    void opIndexAssign(T value, size_t idx)
    {
        resolve();  // Ensure array is in clean state
        
        if (idx >= _size) 
            assert(0, "Index out of bounds");
        
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
    
    // Get the queue data in FIFO order
    T[] toFIFOArray()
    {
        resolve();
        return _data.dup;
    }
}