#!/usr/bin/dmd
/**
 * mkystd_range - Range interface with monkyyy's specifications
 *
 * Defines the core range interface with required functions and optional functions
 */
module mkystd_range;

//---
// Types and Constants
//---

/**
 * Interface for ranges in the mkystd library
 *
 * Core required functions: front, pop, empty
 * Optional functions: index, length, reverse, remove, append, resolve
 */
interface IRange(T)
{
	// Core required functions
	ref T front();
	void pop();
	bool empty();

	// Optional functions as specified in the requirements
	size_t index();      // returns something numbery that can be passed to a data structure to access the current front in const time
	size_t length();     // returns the length of the range
	typeof(this) reverse();  // mutates the range and returns itself
	void remove();     // marks the element for removal (doesn't change front/length if resolve is defined until resolve() is called)
	void append(T value);   // adds element (doesn't change front/length if resolve is defined until resolve() is called)
	void resolve();    // finalizes remove and append operations
}

//---
// Functions
//---

/**
 * Template to check if a type implements the IRange interface
 */
template isIRange(T)
{
	enum bool isIRange =
		is(typeof((T t) {
			t.front();
			t.pop();
			t.empty();
			t.index();
			t.length();
			t.reverse();
			t.remove();
			t.append(T.init);
			t.resolve();
		}));
}