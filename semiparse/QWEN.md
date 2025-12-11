# Qwen Code Instructions for SemiParse DLang Linter Project

## Project Overview
This project is a component of "lintyyy", a lazy linter for the D programming language. Specifically, "semiparse" refers to a semi-parsing layer that enables basic parsing without requiring a complete D language parser. The semi-parser is designed to detect formatting issues and code-style violations while maintaining efficiency.

## Project Architecture
The project is organized as a nested hierarchy:

- Main project: lintyyy (the overall linter initiative)
- Sub-project: semiparse (the semi-parsing layer)
- Child project: mkystd (custom standard library for monkyyy's preferences)

## Key Components

### 1. Semiparse (Main Component)
The semi-parse system is designed to parse D code at a high level without full syntactic analysis. It recognizes three major categories of D constructs:

- Small definitions: `import std;`, `enum foo=3;`, `alias bar=int;`
- Block statement headers: `struct nullable(T){`, `void foo(T)(T a){`
- Statements: `helloworld.writeln;`

This semi-parser should handle ugly or malformed code gracefully by incrementally increasing error reporting, while avoiding crashes on any valid or invalid D code.

### 2. mkystd (Child Project)
The mkystd component is a custom standard library for D tailored to monkyyy's preferences. Rather than using the standard Phobos library, mkystd implements data structures and algorithms using monkyyy's preferred ranges API.

The ranges API follows a 3-function interface pattern:
- `front`: gets the current element
- `pop`: moves to the next element
- `empty`: checks if iteration is complete

Additionally, the custom API includes optional functions:
- `.index`: returns a numeric value for constant-time access
- `.length`: returns the number of elements
- `.reverse`: reverses the range in place
- `.delete`: marks an element for deletion
- `.append`: adds an element at the current position
- `.resolve`: finalizes pending operations

The project aims to implement 7 data structures and the 30 most commonly used algorithms according to monkyyy's requirements.

## Relationship Between Projects
Communication flows downhill from parent to child projects. Parent agents should only add tests and requests, following a test-driven development approach. Each child project has its own REQUESTS.md file where parent requests are noted in the format `[ ] please fix foo`.

## Organizational Structure
The overall plan involves creating three nested projects with agents working in parallel. The directory structure reflects this hierarchy with mkystd nested within semiparse, which is part of the broader lintyyy initiative.

## Implementation Notes
- The linter should modify files to enforce standards
- The semi-parser should be resilient and not crash on any input code
- All code should follow monkyyy's specific formatting preferences
- Unit tests from libdparse should be referenced for robust parsing