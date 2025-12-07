# Qwen Code Instructions for DLang Linter Project

## Project Overview
This is a linter for the D programming language (DLang). The project specifications are documented in SPEC.md and define rules and requirements for DLang code analysis and enforcement of specific coding standards.

## Project Purpose
- A linter tool specifically designed for the D programming language
- Enforces specific coding standards and conventions as outlined in the SPEC.md
- Actively modifies files to enforce standards (MUST actively modify the file)

## Key Requirements from SPEC.md

### Running the Linter
- The first line of all files MUST be `#!`
- `#!` SHOULD be a `dmd` or `opend` command
- Use `-i` as is, don't use `dub`

### Coding Standards Enforced
- **Whitespace**: Tabs over spaces (MUST), conceptual spacing (SHOULD)
- **Keywords**: `private` MUST NOT exist in codebase, `immutable`/`const` SHOULD NOT be used
- **Imports**: SHOULD be at the top, `std.*` imports should be simplified
- **Sections**: Use `//---` to break up sections (types/constants, functions, main, unittests)
- **Comments**: Only for temp code or apologies, with specific keywords ("BAD", "HACK", "RANT")

### Code Deduplication
- Files MUST NOT be line-by-line identical
- Files SHOULD NOT be extremely similar

## Development Approach
- This is a research project for "monkyyy" (github research: "crazymonkyyy")
- Focus on warning capabilities with permissive tests (SHOULD warning)
- Implementation should follow the strict requirements in SPEC.md

## Building and Running
- Specific build instructions are not provided in the current SPEC.md
- Linter should work with DMD compiler directly using `-i` flag
- TODO: Add specific build and execution commands when project structure is established

## Development Conventions
- Follow the coding standards that the linter enforces
- Use tabs instead of spaces
- Avoid private keyword usage
- Structure code with proper section breaks using `//---`
- Use appropriate commenting style with "BAD", "HACK", or "RANT" when necessary