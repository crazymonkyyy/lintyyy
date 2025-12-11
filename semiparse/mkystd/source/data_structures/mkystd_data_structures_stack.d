#!/usr/bin/dmd
/**
 * mkystd_data_structures_stack - Stack implementation with ranges API
 *
 * Implements monkyyy's ranges API with the required optional functions
 */
module mkystd_data_structures_stack;

import mkystd.range;  // Simplified import path

//---
// Types and Constants
//---

/**
 * Stack - A stack (LIFO) data structure implementing monkyyy's ranges API
 * When used as a range, it iterates from top to bottom (LIFO order)
 */
struct Stack(T)
{
	T[] _data;
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
		if (_data.length == 0)
			assert(0, "Accessing empty stack");

		// Find the topmost non-removed element
		for(int i = cast(int)(_data.length - 1); i >= 0; i--)
		{
			if (!_removalFlags[i])
				return _data[i];
		}

		assert(0, "Accessing empty stack after removals");
	}

	void pop()
	{
		if (_data.length == 0)
			assert(0, "Popping empty stack");

		// Mark the top element for removal instead of removing it
		// Actual removal happens during resolve()
		for(int i = cast(int)(_data.length - 1); i >= 0; i--)
		{
			if (!_removalFlags[i])
			{
				_removalFlags[i] = true;
				_needsResolve = true;
				return;
			}
		}

		assert(0, "Popping empty stack after removals");
	}

	bool empty() @property
	{
		if (_data.length == 0) return true;

		// Check if all elements are removed
		foreach(flag; _removalFlags)
		{
			if (!flag) return false;
		}
		return true;
	}

	// Optional functions as specified
	size_t index()
	{
		// Return the index of the current front element
		for(int i = cast(int)(_data.length - 1); i >= 0; i--)
		{
			if (!_removalFlags[i])
				return i;
		}
		return _data.length; // If empty, return past-the-end index
	}

	size_t length() @property
	{
		if (!_needsResolve) {
			// Count non-removed elements
			size_t count = 0;
			foreach(flag; _removalFlags) {
				if (!flag) count++;
			}
			return count;
		} else {
			// If resolve is needed, count non-removed elements
			size_t count = 0;
			foreach(flag; _removalFlags) {
				if (!flag) count++;
			}
			return count;
		}
	}

	Stack reverse()
	{
		// Reverse the stack data in place
		size_t len = _data.length;
		for(size_t i = 0; i < len / 2; i++)
		{
			// Swap elements
			T temp = _data[i];
			_data[i] = _data[len - 1 - i];
			_data[len - 1 - i] = temp;

			// Swap removal flags
			bool tempFlag = _removalFlags[i];
			_removalFlags[i] = _removalFlags[len - 1 - i];
			_removalFlags[len - 1 - i] = tempFlag;
		}

		_needsResolve = true;
		return this;
	}

	void remove()
	{
		if (_data.length == 0)
			assert(0, "Removing from empty stack");

		// Mark the top element for removal
		for(int i = cast(int)(_data.length - 1); i >= 0; i--)
		{
			if (!_removalFlags[i])
			{
				_removalFlags[i] = true;
				_needsResolve = true;
				return;
			}
		}

		assert(0, "Removing from empty stack after removals");
	}

	void append(T value)
	{
		// Add to the top of the stack
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
		for(size_t i = 0; i < _data.length; i++) {
			if (!_removalFlags[i]) {
				newData ~= _data[i];
				newRemovalFlags ~= false;
			}
		}

		_data = newData;
		_removalFlags = newRemovalFlags;
		_needsResolve = false;
	}
    
    // Stack-specific methods
    void push(T value)
    {
        append(value);
    }
    
    T top()
    {
        return front;
    }
    
    // Helper functions
    T opIndex(size_t idx)
    {
        resolve();  // Ensure array is in clean state
        
        if (idx >= _data.length) 
            assert(0, "Index out of bounds");
        
        return _data[_data.length - 1 - idx]; // Access from top
    }
    
    void opIndexAssign(T value, size_t idx)
    {
        resolve();  // Ensure array is in clean state
        
        if (idx >= _data.length) 
            assert(0, "Index out of bounds");
        
        _data[_data.length - 1 - idx] = value; // Access from top
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
    
    // Get the stack data in LIFO order
    T[] toLIFOArray()
    {
        resolve();
        T[] result;
        foreach_reverse(item; _data) {
            result ~= item;
        }
        return result;
    }
}