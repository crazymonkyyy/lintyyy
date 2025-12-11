/**
 * mkystd_traits - Trait definitions and utilities for mkystd
 * 
 * Contains utility traits for type introspection and manipulation
 */
module mkystd_traits;

// Import standard D traits for convenience
public import std.traits;

/**
 * isRange - Checks if a type implements range interface
 */
template isRange(T)
{
    static if (is(typeof(
    {
        T r;
        r.front;
        r.pop;
        r.empty;
    })))
        enum isRange = true;
    else
        enum isRange = false;
}

/**
 * hasOptionalFunctions - Checks if a range type has the optional functions
 */
template hasOptionalFunctions(T)
{
    static if (is(typeof(
    {
        T r;
        r.index;
        r.length;
        r.reverse;
        r.remove;
        r.append(r.front);
        r.resolve;
    })))
        enum hasOptionalFunctions = true;
    else
        enum hasOptionalFunctions = false;
}

/**
 * ElementType - Gets the element type of a range
 */
template ElementType(R)
{
    static if (is(R : T[], T))  // Static or dynamic array
        alias ElementType = T;
    else static if (is(R == struct))  // Struct-based range
        alias ElementType = typeof(R.init.front);
    else static if (is(R == class))   // Class-based range
        alias ElementType = typeof(R.init.front);
    else
        static assert(0, "ElementType: unrecognized range type");
}