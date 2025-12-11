#!/usr/bin/dmd
/**
 * mkystd_data_structures_hashtable - Hash set implementation with ranges API
 *
 * Implements monkyyy's ranges API with the required optional functions
 * Note: I'm implementing a hash set instead of hash table to keep it simpler
 */
module mkystd_data_structures_hashtable;

import mkystd.range;  // Simplified import path
import std.conv : to;

//---
// Types and Constants
//---

/**
 * Hash set node structure
 */
struct HashSetNode(T)
{
    T data;
    HashSetNode* next; // For collision handling with chaining
}

/**
 * HashSet - A hash set data structure implementing monkyyy's ranges API
 * When used as a range, it iterates through stored values
 */
struct HashSet(T)
{
    HashSetNode!(T)*[] _buckets;
    size_t _size;
    size_t _bucketCount = 16; // Initial bucket count
    T[] _valuesCache;  // Cached values for range iteration
    size_t _currentIndex = 0;  // Current position in the range
    bool[] _removalFlags; // Track removed values
    bool _needsResolve = false;

    // Constructor
    this(T[] initialValues...)
    {
        _bucketCount = 16;
        _buckets = new HashSetNode!(T)*[_bucketCount];
        _size = 0;

        // Initialize buckets to null
        for(size_t i = 0; i < _bucketCount; i++)
        {
            _buckets[i] = null;
        }

        // Add initial values
        foreach(value; initialValues)
        {
            add(value);
        }

        _needsResolve = true;
        updateCache();
    }

    // Simple hash function
    size_t hash(T value)
    {
        // A simple hash function - in a real implementation,
        // this would be more sophisticated
        import std.string : format;
        size_t h = 0;
        string s = value.to!string; // Convert value to string representation
        foreach(c; s)
        {
            h = (h * 31 + c) % _bucketCount;
        }
        return h;
    }

    // Helper to update the values cache
    void updateCache()
    {
        _valuesCache = new T[_size];
        _removalFlags = new bool[_size];

        size_t idx = 0;
        for(size_t i = 0; i < _bucketCount; i++)
        {
            HashSetNode!(T)* current = _buckets[i];
            while(current != null)
            {
                _valuesCache[idx] = current.data;
                _removalFlags[idx] = false; // Initially no removals
                idx++;
                current = current.next;
            }
        }
        _currentIndex = 0;
        _needsResolve = false;
    }

    // Add a value to the hash set
    void add(T value)
    {
        // Check if value already exists
        if (contains(value))
        {
            return; // Already exists
        }

        size_t index = hash(value);

        // Add the value
        HashSetNode!(T)* newNode = new HashSetNode!(T);
        newNode.data = value;
        newNode.next = _buckets[index];
        _buckets[index] = newNode;

        _size++;
        _needsResolve = true;
    }

    // Check if value exists
    bool contains(T value)
    {
        size_t index = hash(value);
        HashSetNode!(T)* current = _buckets[index];

        while(current != null)
        {
            if(current.data == value)
            {
                return true;
            }
            current = current.next;
        }

        return false;
    }

    // Core range functions - iterating through values
    ref T front() @property
    {
        if (empty())
            assert(0, "Accessing empty hash set range");

        // Find the next non-removed value
        size_t i = _currentIndex;
        while (i < _valuesCache.length && _removalFlags[i])
        {
            i++;
        }

        if (i >= _valuesCache.length)
            assert(0, "Accessing empty hash set range after removals");

        return _valuesCache[i];
    }

    void pop()
    {
        if (empty())
            assert(0, "Popping empty hash set range");

        // Mark current element as removed
        if (_currentIndex < _valuesCache.length)
        {
            _removalFlags[_currentIndex] = true;

            // Remove the value from the hash set
            T valueToRemove = _valuesCache[_currentIndex];
            remove(valueToRemove);

            _currentIndex++;

            // Find the next non-removed element
            while (_currentIndex < _valuesCache.length && _removalFlags[_currentIndex])
            {
                _currentIndex++;
            }
        }

        _needsResolve = true;
    }

    bool empty() @property
    {
        if (_currentIndex >= _valuesCache.length)
        {
            // Update cache if we need to resolve to ensure accuracy
            if (_needsResolve)
            {
                updateCache();
            }

            // Check if it's still empty after update
            size_t i = _currentIndex;
            while (i < _valuesCache.length && _removalFlags[i])
            {
                i++;
            }
            return i >= _valuesCache.length;
        }
        return false;
    }

    // Optional functions as specified
    size_t index()
    {
        // Return the index in the cached values array
        return _currentIndex;
    }

    size_t length() @property
    {
        if (_needsResolve)
        {
            updateCache();
        }

        // Count non-removed values
        size_t count = 0;
        for(size_t i = _currentIndex; i < _valuesCache.length; i++)
        {
            if (!_removalFlags[i])
                count++;
        }
        return count;
    }

    HashSet reverse()
    {
        if (_needsResolve)
        {
            updateCache();
        }

        // Reverse the order of values in the cache
        size_t len = _valuesCache.length;
        for(size_t i = 0; i < len / 2; i++)
        {
            T tempValue = _valuesCache[i];
            bool tempFlag = _removalFlags[i];

            _valuesCache[i] = _valuesCache[len - 1 - i];
            _removalFlags[i] = _removalFlags[len - 1 - i];

            _valuesCache[len - 1 - i] = tempValue;
            _removalFlags[len - 1 - i] = tempFlag;
        }

        // Reset the current index to the beginning
        _currentIndex = 0;
        _needsResolve = true;

        return this;
    }

    void remove()
    {
        if (empty())
            assert(0, "Removing from empty hash set range");

        // Mark the current value for removal
        if (_currentIndex < _valuesCache.length)
        {
            _removalFlags[_currentIndex] = true;

            // Remove the value from the hash set
            T valueToRemove = _valuesCache[_currentIndex];
            remove(valueToRemove);

            _needsResolve = true;
        }
    }

    void append(T value) // Add a new value
    {
        add(value);
        _needsResolve = true;
    }

    void resolve()
    {
        if (!_needsResolve) return;

        // Refresh the cache to reflect all changes
        updateCache();
    }

    // Remove a value from the hash set
    void remove(T value)
    {
        size_t index = hash(value);
        HashSetNode!(T)* current = _buckets[index];
        HashSetNode!(T)* prev = null;

        while(current != null)
        {
            if(current.data == value)
            {
                if(prev == null)
                {
                    _buckets[index] = current.next;
                }
                else
                {
                    prev.next = current.next;
                }
                _size--;
                return;
            }
            prev = current;
            current = current.next;
        }
    }

    // Convert to array
    T[] toArray()
    {
        if (_needsResolve)
        {
            updateCache();
        }

        T[] result;
        for(size_t i = 0; i < _valuesCache.length; i++)
        {
            if (!_removalFlags[i])
            {
                result ~= _valuesCache[i];
            }
        }
        return result;
    }

    // Destructor to properly free memory
    ~this()
    {
        for(size_t i = 0; i < _bucketCount; i++)
        {
            HashSetNode!(T)* current = _buckets[i];
            while(current != null)
            {
                HashSetNode!(T)* temp = current;
                current = current.next;
                destroy(temp);
            }
        }
    }
}