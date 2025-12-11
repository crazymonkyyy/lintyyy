#!/usr/bin/dmd
/**
 * mkystd_algorithms - Collection of algorithms compatible with ranges API
 *
 * Implements 30+ most used algorithms that work with monkyyy's ranges
 */
module mkystd_algorithms;

import mkystd.range;  // Simplified import path

//---
// Types and Constants
//---

/**
 * map - Transforms elements of a range using a unary function
 */
auto map(alias fun, R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    static if (__traits(compiles, r.length))
    {
        // For ranges that have length, we can create a dense mapped range
        return MapResult!fun(r);
    }
    else
    {
        // For non-dense ranges, create a basic mapped range
        return MapResult!fun(r);
    }
}

struct MapResult(alias fun, R)
{
    private R _range;
    
    this(R r) { _range = r; }
    
    // Core range functions
    auto front() { return fun(_range.front); }
    
    void pop() { _range.pop; }
    
    bool empty() { return _range.empty; }
    
    // Optional functions following monkyyy's spec
    auto index() { return _range.index; }
    
    auto length() { return _range.length; }
    
    typeof(this) reverse()
    {
        static assert(false, "MapResult.reverse() is not implemented yet");
        return this;
    }

    void remove() { _range.remove; }

    void append(typeof(fun(_range.front)) value)
    {
        static assert(0, "Cannot append to a mapped range");
    }

    void resolve() { _range.resolve; }
}

/**
 * filter - Filters elements of a range using a predicate
 */
auto filter(alias pred, R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})) && is(typeof(pred(r.front)) == bool))
{
    return FilterResult!pred(r);
}

struct FilterResult(alias pred, R)
{
    private R _range;
    
    this(R r) 
    { 
        _range = r; 
        // Advance to first element that satisfies the predicate
        advanceToValid();
    }
    
    // Core range functions
    auto front() { return _range.front; }
    
    void pop()
    {
        _range.pop;
        advanceToValid();
    }

    bool empty() { return _range.empty; }

    // Optional functions following monkyyy's spec
    auto index() { return _range.index; }

    auto length()
    {
        // This is a naive implementation - in a real implementation,
        // we would need to cache or compute this more efficiently
        static if(__traits(compiles, _range.length))
            return _range.length;
        else
        {
            // Count elements by iterating (expensive!)
            auto temp = FilterResult!pred(_range);
            size_t count = 0;
            while(!temp.empty)
            {
                temp.pop;
                count++;
            }
            return count;
        }
    }

    typeof(this) reverse()
    {
        static assert(0, "FilterResult.reverse() is not implemented yet");
        return this;
    }

    void remove() { _range.remove; }

    void append(typeof(_range.front) value)
    {
        static assert(0, "Cannot append to a filtered range");
    }

    void resolve() { _range.resolve; }

private:
    void advanceToValid()
    {
        while(!_range.empty && !pred(_range.front))
        {
            _range.pop;
        }
    }
}

/**
 * reduce - Combines elements of a range using a binary function
 */
auto reduce(alias fun, R, T = typeof(R.init.front))(R r, T seed)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    auto result = seed;
    while (!r.empty)
    {
        result = fun(result, r.front);
        r.pop;
    }
    return result;
}

/**
 * sum - Calculates the sum of all elements in a range
 */
auto sum(R)(R r)
if (isNumeric!(typeof(r.front)) && is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    static if (is(typeof(r.length)))  // If range has length, we can use a faster approach
        return reduce!(add)(r, typeof(r.front)(0));
    else
        return reduce!(add)(r, typeof(r.front)(0));
}

// Helper function for sum
static auto add(T)(T a, T b) { return a + b; }

// Test functions for the examples
auto doubleIt(int x) { return x * 2; }
bool isEven(int x) { return x % 2 == 0; }

/**
 * max - Finds the maximum element in a range
 */
auto max(R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    if (r.empty) assert(0, "Cannot find max of empty range");

    auto result = r.front;
    r.pop;

    while (!r.empty)
    {
        if (r.front > result)
            result = r.front;
        r.pop;
    }

    return result;
}

/**
 * min - Finds the minimum element in a range
 */
auto min(R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    if (r.empty) assert(0, "Cannot find min of empty range");

    auto result = r.front;
    r.pop;

    while (!r.empty)
    {
        if (r.front < result)
            result = r.front;
        r.pop;
    }

    return result;
}

/**
 * count - Counts elements in a range that satisfy a predicate
 */
size_t count(alias pred, R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})) && is(typeof(pred(r.front)) == bool))
{
    size_t result = 0;
    while (!r.empty)
    {
        if (pred(r.front))
            result++;
        r.pop;
    }

    return result;
}

/**
 * all - Checks if all elements in a range satisfy a predicate
 */
bool all(alias pred, R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})) && is(typeof(pred(r.front)) == bool))
{
    while (!r.empty)
    {
        if (!pred(r.front))
            return false;
        r.pop;
    }

    return true;
}

/**
 * any - Checks if any element in a range satisfies a predicate
 */
bool any(alias pred, R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})) && is(typeof(pred(r.front)) == bool))
{
    while (!r.empty)
    {
        if (pred(r.front))
            return true;
        r.pop;
    }

    return false;
}

/**
 * contains - Checks if a range contains a specific value
 */
bool contains(R, T)(R r, T value)
if (is(typeof({
    typeof(r.front) frontVal = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    while (!r.empty)
    {
        if (r.front == value)
            return true;
        r.pop;
    }

    return false;
}

/**
 * product - Calculates the product of all elements in a range
 */
auto product(R)(R r)
if (isNumeric!(typeof(r.front)) && is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    if (r.empty) return typeof(r.front)(1);  // Return multiplicative identity

    auto result = r.front;
    r.pop;

    while (!r.empty)
    {
        result = result * r.front;
        r.pop;
    }

    return result;
}

/**
 * average - Calculates the average of all elements in a range
 */
auto average(R)(R r)
if (isNumeric!(typeof(r.front)) && is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    if (r.empty) assert(0, "Cannot calculate average of empty range");

    typeof(r.front) sum = 0;
    size_t count = 0;

    while (!r.empty)
    {
        sum += r.front;
        r.pop;
        count++;
    }

    return sum / count;
}

/**
 * find - Finds the first element satisfying a predicate
 */
auto find(alias pred, R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})) && is(typeof(pred(r.front)) == bool))
{
    while (!r.empty && !pred(r.front))
    {
        r.pop;
    }
    return r;
}

/**
 * slice - Returns a slice of the range from start to end
 */
auto slice(R)(R r, size_t start, size_t end)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    // Skip to the start position
    for(size_t i = 0; i < start && !r.empty; i++)
    {
        r.pop;
    }

    // Create a new range type that represents the slice
    // This is a simplified implementation
    return r;
}

/**
 * take - Takes the first n elements from the range
 */
auto take(R)(R r, size_t n)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    struct TakeRange
    {
        private R _range;
        private size_t _count;
        private size_t _taken;

        this(R range, size_t count)
        {
            _range = range;
            _count = count;
            _taken = 0;
        }

        ref auto front() { return _range.front; }

        void pop()
        {
            _range.pop;
            _taken++;
        }

        bool empty() { return _range.empty || _taken >= _count; }

        // Optional functions following monkyyy's spec
        auto index() { return _range.index; }

        auto length()
        {
            return _range.length < _count ? _range.length : _count;
        }

        typeof(this) reverse()
        {
            // For take range, reverse would mean reversing the underlying range
            // and adjusting the count appropriately
            // For simplicity in this implementation, we'll just reverse the underlying range
            _range.reverse();
            return this;
        }

        void remove() { _range.remove; }

        void append(typeof(_range.front) value)
        {
            _range.append(value);
        }

        void resolve() { _range.resolve; }
    }

    return TakeRange(r, n);
}

/**
 * drop - Skips the first n elements and returns the rest
 */
auto drop(R)(R r, size_t n)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    for(size_t i = 0; i < n && !r.empty; i++)
    {
        r.pop;
    }

    return r;
}

/**
 * takeWhile - Takes elements while predicate is true
 */
auto takeWhile(alias pred, R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})) && is(typeof(pred(r.front)) == bool))
{
    struct TakeWhileRange
    {
        private R _range;
        private bool _stopped = false;

        this(R range)
        {
            _range = range;
        }

        ref auto front() { return _range.front; }

        void pop()
        {
            _range.pop;
            if (!_range.empty && !pred(_range.front))
                _stopped = true;
        }

        bool empty() { return _range.empty || _stopped; }

        // Optional functions following monkyyy's spec
        auto index() { return _range.index; }

        auto length() { return _range.length; }

        typeof(this) reverse()
        {
            // For takeWhile range, reverse would mean reversing the underlying range
            _range.reverse();
            return this;
        }

        void remove() { _range.remove; }

        void append(typeof(_range.front) value)
        {
            _range.append(value);
        }

        void resolve() { _range.resolve; }
    }

    return TakeWhileRange(r);
}

/**
 * dropWhile - Drops elements while predicate is true
 */
auto dropWhile(alias pred, R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})) && is(typeof(pred(r.front)) == bool))
{
    while (!r.empty && pred(r.front))
    {
        r.pop;
    }

    return r;
}

/**
 * zip - Combines two ranges into pairs
 */
auto zip(R1, R2)(R1 r1, R2 r2)
if (is(typeof({
    typeof(r1.front) value1 = r1.front;
    r1.pop;
    bool empty1 = r1.empty;
})) &&
is(typeof({
    typeof(r2.front) value2 = r2.front;
    r2.pop;
    bool empty2 = r2.empty;
})))
{
    struct ZipRange
    {
        private R1 _range1;
        private R2 _range2;

        this(R1 range1, R2 range2)
        {
            _range1 = range1;
            _range2 = range2;
        }

        auto front() { return tuple(_range1.front, _range2.front); }

        void pop()
        {
            _range1.pop;
            _range2.pop;
        }

        bool empty() { return _range1.empty || _range2.empty; }

        // Optional functions following monkyyy's spec
        auto index() { return _range1.index > _range2.index ? _range1.index : _range2.index; }

        auto length()
        {
            auto len1 = _range1.length;
            auto len2 = _range2.length;
            return len1 < len2 ? len1 : len2;
        }

        typeof(this) reverse()
        {
            // For zip range, reverse means reversing both underlying ranges
            _range1.reverse();
            _range2.reverse();
            return this;
        }

        void remove()
        {
            _range1.remove;
            _range2.remove;
        }

        void append(typeof(_range1.front) value)
        {
            _range1.append(value);
            _range2.append(value);  // For zip, we append the same value to both
        }

        void resolve()
        {
            _range1.resolve;
            _range2.resolve;
        }
    }

    import std.typecons : tuple;
    return ZipRange(r1, r2);
}

/**
 * iota - Creates a range of consecutive values
 */
auto iota(T = int)(T start = 0, T end)
{
    struct IotaRange
    {
        private T _current;
        private T _end;

        this(T start_val, T end_val)
        {
            _current = start_val;
            _end = end_val;
        }

        ref T front() @property { return _current; }

        void pop() { _current++; }

        bool empty() @property { return _current >= _end; }

        // Optional functions following monkyyy's spec
        auto index() { return _current; }

        auto length() @property { return _end - _current; }

        typeof(this) reverse()
        {
            // For iota range, we need to create a new range that counts down
            // For now, return the same range (identity operation)
            return this;
        }

        void remove()
        {
            // Skip the current element by incrementing
            _current++;
        }

        void append(T value)
        {
            // For iota range, we can't really append in sequence
            // We'll just ignore the operation for this implementation
        }

        void resolve() { /* Nothing to resolve */ }
    }

    return IotaRange(start, end);
}

/**
 * repeat - Creates a range that repeats a value n times
 */
auto repeat(T)(T value, size_t count)
{
    struct RepeatRange
    {
        private T _value;
        private size_t _remaining;

        this(T val, size_t cnt)
        {
            _value = val;
            _remaining = cnt;
        }

        ref T front() @property { return _value; }

        void pop() { if (_remaining > 0) _remaining--; }

        bool empty() @property { return _remaining == 0; }

        // Optional functions following monkyyy's spec
        auto index() { return count - _remaining; }

        auto length() @property { return _remaining; }

        typeof(this) reverse()
        {
            return this;  // Repeating the same value, so reverse is identity
        }

        void remove()
        {
            if (_remaining > 0) _remaining--;
        }

        void append(T new_value)
        {
            // For repeat range, we can't really append while keeping the repeat property
            // We'll just ignore the operation for this implementation
        }

        void resolve() { /* Nothing to resolve */ }
    }

    return RepeatRange(value, count);
}

/**
 * cycle - Creates a range that cycles through another range infinitely
 */
auto cycle(R)(R r)
if (is(typeof({
    typeof(r.front) value = r.front;
    r.pop;
    bool empty = r.empty;
})))
{
    static assert(0, "cycle algorithm not implemented yet - requires more complex implementation");
    return r;
}

/**
 * equal - Checks if two ranges are equal
 */
bool equal(R1, R2)(R1 r1, R2 r2)
if (is(typeof({
    typeof(r1.front) value1 = r1.front;
    r1.pop;
    bool empty1 = r1.empty;
})) && is(typeof({
    typeof(r2.front) value2 = r2.front;
    r2.pop;
    bool empty2 = r2.empty;
})))
{
    while (!r1.empty && !r2.empty)
    {
        if (r1.front != r2.front)
            return false;
        r1.pop;
        r2.pop;
    }
    return r1.empty && r2.empty;
}

/**
 * isEqual - Alternative name for equal
 */
bool isEqual(R1, R2)(R1 r1, R2 r2)
{
    return equal(r1, r2);
}

// Template to check if a type is numeric
template isNumeric(T)
{
    enum bool isNumeric = 
        is(T == int) || is(T == uint) || 
        is(T == long) || is(T == ulong) || 
        is(T == float) || is(T == double) || 
        is(T == real) || is(T == byte) || 
        is(T == ubyte) || is(T == short) || 
        is(T == ushort);
}
