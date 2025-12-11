/**
 * mkystd_io - Input/output utilities for mkystd
 * 
 * Contains I/O functions compatible with ranges API
 */
module mkystd_io;

import std.stdio;

/**
 * writeln - Outputs range elements separated by commas
 */
void writeln(R)(R range)
if (isInputRange!R)
{
    write(range);
    std.stdio.writeln();
}

/**
 * write - Outputs range elements separated by commas
 */
void write(R)(R range)
if (isInputRange!R)
{
    bool first = true;
    while (!range.empty)
    {
        if (!first) std.stdio.write(", ");
        std.stdio.write(range.front);
        range.pop;
        first = false;
    }
}

/**
 * isInputRange - Checks if a type is an input range
 */
template isInputRange(T)
{
    enum bool isInputRange = 
        is(typeof(
        {
            T r;
            r.front;
            r.pop;
            r.empty;
        }) : bool);
}

/**
 * readln - Reads a line from stdin as a range
 */
auto readln()
{
    return std.stdio.readln();
}