# libdparse: D Source Code Parser Library

## What is libdparse?

libdparse is a library for lexing and parsing D source code - it's a complete D language parser that allows programs to accurately understand D source code structure. It's used by Dscanner for accurate AST (Abstract Syntax Tree) generation.

## Complexity and Size
- Total lines of code: ~30,337 lines
- Purpose: Lexing and parsing D source code accurately
- Used by: Dscanner, DCD (D Code Daemon), and other D tooling

## Key Features
- Complete D language parser that handles all valid D syntax
- AST generation for accurate code analysis
- Visitor pattern implementation for traversing code structure
- Handles complex D features: templates, mixins, UFCS, etc.
- Provides source location information (line numbers, columns)
- Grammar-based parsing for accuracy

## Architecture
- `lexer.d`: Tokenizes D source code
- `parser.d`: Builds AST from tokens
- `ast.d`: Defines AST node structures
- `entities.d`: Representation of D language entities
- `astprinter.d`: Utilities for printing AST
- `formatter.d`: Code formatting utilities

## How Dscanner Uses libdparse
Dscanner leverages libdparse to:
- Parse D source files into accurate ASTs
- Navigate code structure to identify specific elements
- Locate specific constructs (variables, functions, classes, etc.)
- Perform accurate analysis without being fooled by comments, strings, etc.
- Get precise line/column information for error reporting

## Comparison with lintyyy Approach
- **libdparse**: Proper D language parsing with AST (30k+ lines)
- **lintyyy**: Simple pattern matching and string replacement (~1k lines)
- **Accuracy**: libdparse won't confuse "private" in strings/comments with actual private keywords
- **Complexity**: libdparse is significantly more complex but more accurate

## Impact on Analysis Quality
Using libdparse allows Dscanner to:
- Distinguish between keywords in code vs. in string literals
- Understand scoping and context accurately
- Provide precise line/column locations
- Avoid false positives/negatives common in regex-based tools
- Handle complex D syntax correctly

## Potential Value for lintyyy
While lintyyy currently uses string replacement, integrating libdparse could:
- Dramatically improve accuracy (no more removing "private" from string literals)
- Enable more sophisticated analysis
- Provide precise location reporting
- Handle all D language constructs properly
- But would significantly increase complexity from ~1k lines to ~30k+ lines plus dependencies