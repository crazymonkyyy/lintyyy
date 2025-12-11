# REQUESTS.md

This file documents requests for changes to the mkystd project based on the style guide violations discovered by the parent project.

## Style Guide Violations

[ ] **Shebang requirement**: All files in the project must start with `#!/usr/bin/dmd` but none of the files have this requirement implemented yet.

[ ] **Private keyword removal**: The project uses `private` keyword extensively throughout the codebase, but SPEC.md requires that "private MUST NOT exist in codebase". Multiple files contain many instances of the `private` keyword.

[ ] **Whitespace violations**: The codebase uses spaces for indentation instead of tabs. SPEC.md requires "MUST BE tabs over spaces".

[ ] **Missing section breaks**: The project doesn't use `//---` to break up sections as required by SPEC.md. Sections should include types/constants, functions, main, and unittests.

[ ] **Import normalization**: The project uses full std library paths (like `import std.stdio;`) instead of simplified versions as required by SPEC.md.

[ ] **Code duplication**: Need to check for potential duplication between files, as SPEC.md requires "all files in the project MUST NOT be line by line identical".

## Range Functions Requirements for semiparse Module

The semiparse parent module requires specific range functions to be implemented by the mkystd library. These functions should follow the monkyyy custom ranges API as specified in the project documentation.

### Core Range Functions Required (3-function API)
[ ] `front` - returns the current element
[ ] `pop` - advances to next element
[ ] `empty` - checks if iteration is complete

### Optional Range Functions Required (as per SPEC.md)
[ ] `.index` - returns a numeric index that can be passed to a data structure for constant time access to the current front
[ ] `.length` - returns the length of the range
[ ] `.reverse` - mutates the range and returns itself (`.reverse.reverse` is a no-op)
[ ] `.delete` - marks current element for deletion (requires `.resolve` to finalize)
[ ] `.append` - adds element at current position (requires `.resolve` to finalize)
[ ] `.resolve` - finalizes pending delete and append operations

### Specific Range Functions Needed by SemiParser

#### String Range Functions
The semi-parser will need the following string manipulation functions implemented as ranges:

[ ] `indexOf(string str, string substr)` - returns the index of a substring within a string, or -1 if not found
[ ] `startsWith(string str, string prefix)` - checks if a string starts with a prefix
[ ] `endsWith(string str, string suffix)` - checks if a string ends with a suffix
[ ] `countUnescaped(string str, char c)` - counts unescaped occurrences of a character in a string

#### Array/List Range Functions
Additionally, these functions for array/list processing are needed:

[ ] `count(string[] arr, string value)` - counts occurrences of a value in an array
[ ] `find(string[] arr, string value)` - finds the first occurrence of a value in an array
[ ] `filter` - filters elements based on a predicate
[ ] `map` - transforms elements based on a function
[ ] `take` - takes first n elements from a range
[ ] `drop` - drops first n elements from a range

### Implementation Requirements
- All functions should follow the ranges API pattern
- Functions should not crash on any valid or invalid input
- Performance should be optimized for the semi-parsing use case
- Functions should properly handle edge cases and malformed input