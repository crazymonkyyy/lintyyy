# Comprehensive Synthesis: lintyyy DLang Linter Project

## Project Overview
lintyyy is a linter for the D programming language specifically designed to enforce the rules and requirements outlined in SPEC.md. The linter actively modifies files to ensure compliance with coding standards and conventions.

## Core Requirements from SPEC.md

### File Format Requirements
- The first line of all files MUST be `#!`
- `#!` SHOULD be a `dmd` or `opend` command
- Use `-i` (import path) flag as is, don't use dub

### Shebang (#!) Requirements
- The `#!` must be the very first two characters on the first line
- Following the #! is the path to the D compiler (dmd or opend)
- Common patterns: `#!/usr/bin/dmd` or `#!/usr/bin/opend`
- Additional arguments can follow the compiler path, including the -i flag for import paths

### -i Flag Usage
- The `-i` flag in DMD adds import paths for modules
- Syntax: `dmd -i=/path/to/modules file.d`
- SPEC.md specifically states "Use -i as is, dont use dub", suggesting using DMD directly with import paths rather than build systems like dub

### Code Standards Enforcement
- **Whitespace**: Tabs over spaces (MUST), conceptual spacing (SHOULD)
- **Keywords**: `private` MUST NOT exist in codebase, `immutable`/`const` SHOULD NOT be used
- **Imports**: SHOULD be at the top, `std.*` imports should be simplified
- **Sections**: Use `//---` to break up sections (types/constants, functions, main, unittests)
- **Comments**: Only for temp code or apologies, with specific keywords ("BAD", "HACK", "RANT")
- **UDA Handling**: User-defined attributes should be kept to a minimum and be functional
- **Code Duplication**: All files MUST NOT be line by line identical, and files SHOULD NOT be extremely similar

### Core Functionality
- MUST actively modify the file (not just warn)
- SHOULD provide warnings, consider permissive tests

## Architecture Plan

### Core Architecture Components
- File parser/tokenizer to read D source files
- Syntax tree visitor to analyze code structure
- Rule engine to implement SPEC.md requirements
- File editor/writer to actively modify files
- Command-line interface for execution

### Module Structure
- Main entry point that processes command-line arguments
- File processor module that handles individual files
- Rule checker module that implements each SPEC requirement
- File writer module that applies modifications
- Configuration module for linter settings

### Processing Pipeline
- Read D source file
- Parse into tokens/AST
- Apply rule checks
- Generate warnings for SHOULD requirements
- Apply modifications for MUST requirements
- Write back to file

## Implementation Plan

### Phase 1: Project Setup and Structure
- Create project directory structure
- Set up build system (likely make-based since no dub)
- Define core data structures for AST representation
- Create basic file I/O utilities
- Implement #! verification function
- Create shebang addition/modification function
- Verify proper #! format (#!/usr/bin/dmd or #!/usr/bin/opend)
- Create regex or pattern matching for #! validation
- Validate #! is at the very beginning of the file (first two characters)
- Check for valid dmd/opend paths after #!
- Handle optional arguments after the interpreter path (like -i flags)
- Test validation on various valid #! formats
- Test rejection of invalid #! formats

### Phase 2: File Parsing and Reading
- Implement D source file parser
- Create tokenizer for D syntax
- Handle file encoding detection
- Implement error recovery for malformed files

### Phase 3: Rule Implementation - Whitespace
- Implement tab detection and validation
- Create space-to-tab conversion function
- Detect multiple closing braces on separate lines

### Phase 4: Rule Implementation - Keywords
- Implement 'private' keyword detector
- Create function to remove 'private' keyword
- Implement 'immutable'/'const' detector for warnings

### Phase 5: Rule Implementation - Imports
- Detect 'import std.*' patterns
- Create import normalization function
- Ensure imports are at the top of files

### Phase 6: Rule Implementation - Section Breaks
- Identify code sections (types, functions, main, unittests)
- Implement section break insertion

### Phase 7: Rule Implementation - Comments
- Detect non-ddoc comments
- Identify BAD/HACK/RANT comments
- Validate comments with ';' or function calls

### Phase 8: Rule Implementation - Duplication Detection
- Create file comparison algorithm
- Detect line-by-line identical files
- Identify highly similar files

### Phase 9: File Modification Engine
- Create safe file modification functions
- Implement temporary file creation
- Add backup file functionality (optional)
- Ensure atomic file operations

### Phase 10: CLI Integration
- Integrate CLI interface with core functionality
- Implement argument parsing
- Add file/directory traversal logic
- Connect all flags to functionality

### Phase 11: UDA Handling
- Implement UDA detection
- Distinguish between functional and non-functional udas

### Phase 12: File Header Requirements
- Implement shebang detection
- Add shebang verification ('#!/usr/bin/dmd' or '#!/usr/bin/opend')

### Phase 13: Integration Testing
- Create comprehensive test files combining multiple rules
- Test error handling and edge cases
- Performance testing with large files

### Phase 14: Performance and Optimization
- Profile performance bottlenecks
- Optimize critical code paths
- Add caching for repeated operations

### Phase 15: Documentation and Final Testing
- Complete inline documentation
- Create user documentation
- Run complete test suite
- Perform final validation against SPEC.md

## CLI Interface

### Command Format
```
lintyyy [options] [files... | directories...]
```

### Core Flags
- `-h, --help` - Display help information about the linter
- `-c, --check` - Check for violations without modifying files (default behavior)
- `-n, --dry-run` - Show what would be changed without making modifications (outputs to stdout)
- `--stdin` - Read from standard input
- `--no-fix` - Disable automatic fixing of violations (fixing enabled by default per SPEC.md requirement)
- `--no-warnings` - Hide warnings for SHOULD rules (warnings shown by default)
- `--max-lines <n>` - Stop processing after n lines of code

### Exit Codes
- `0` : Success, no violations found
- `1` : Success, violations found and fixed (for MUST rules) or warnings issued (for SHOULD rules)
- `2` : Error during processing (parsing error, file I/O issues, etc.)

### Examples
- `lintyyy src/` - Lint all files in src directory
- `lintyyy --no-fix file.d` - Check file without fixing violations
- `lintyyy -n file.d` - Show what changes would be made to file
- `lintyyy --stdin < file.d` - Lint from standard input

## Test Files Strategy

### Phase 1 Tests
- [test_file_1.d] - Basic file with correct shebang
- [test_file_2.d] - File without shebang to test rejection
- [test_file_3.d] - File with invalid shebang to test rejection
- [shebang_test_1.d] - File with #!/usr/bin/dmd
- [shebang_test_2.d] - File with #!/usr/bin/opend
- [shebang_test_3.d] - File with incorrect shebang format
- [shebang_test_4.d] - File with #!/usr/bin/dmd -i flag combination

### Phase 2 Tests
- [parse_test_1.d] - Valid D file with various syntax constructs
- [parse_test_2.d] - File with syntax errors to test error recovery
- [parse_test_3.d] - Minimal valid D file
- [parse_test_4.d] - Complex D file with classes, functions, imports

### Phase 3 Tests
- [whitespace_test_1.d] - File with spaces instead of tabs
- [whitespace_test_2.d] - File with correct tab indentation
- [whitespace_test_3.d] - File with multiple consecutive closing braces
- [whitespace_test_4.d] - Mixed indentation to test correction

### Phase 4 Tests
- [keyword_test_1.d] - File with 'private' members
- [keyword_test_2.d] - File with 'immutable' variables
- [keyword_test_3.d] - File with 'const' functions
- [keyword_test_4.d] - File without restricted keywords

### Phase 5 Tests
- [import_test_1.d] - File with 'import std.stdio : writeln'
- [import_test_2.d] - File with 'import std.*' pattern
- [import_test_3.d] - File with correctly normalized imports
- [import_test_4.d] - File with imports scattered throughout

### Phase 6 Tests
- [section_test_1.d] - File without section breaks
- [section_test_2.d] - File with proper section breaks
- [section_test_3.d] - Complex file with multiple sections
- [section_test_4.d] - File with inconsistent section organization

### Phase 7 Tests
- [comment_test_1.d] - File with invalid comments
- [comment_test_2.d] - File with proper ddoc comments
- [comment_test_3.d] - File with BAD/HACK/RANT comments
- [comment_test_4.d] - File with comments containing ';' or function calls

### Phase 8 Tests
- [duplication_test_1.d] - First file for duplication check
- [duplication_test_2.d] - Identical to duplication_test_1.d
- [duplication_test_3.d] - Similar but not identical to duplication_test_1.d
- [duplication_test_4.d] - Completely different file

### Phase 9 Tests
- [modify_test_1.d] - File to test in-place modification
- [modify_test_2.d] - File to test modification with backup
- [modify_test_3.d] - Large file to test modification performance

### Phase 10 Tests
- [cli_test_1.d] - File for basic CLI testing
- [cli_test_2.d] - File for dry-run testing
- [cli_test_3.d] - File for fix/no-fix testing

### Phase 11 Tests
- [uda_test_1.d] - File with functional udas
- [uda_test_2.d] - File with non-functional udas
- [uda_test_3.d] - File without udas

### Phase 12 Tests
- [header_test_1.d] - File with correct dmd shebang
- [header_test_2.d] - File with correct opend shebang
- [header_test_3.d] - File without shebang
- [header_test_4.d] - File with invalid shebang

### Phase 13 Tests
- [integration_test_1.d] - File with multiple SPEC.md violations
- [integration_test_2.d] - Large complex file with various constructs
- [integration_test_3.d] - Edge case file with unusual syntax
- [integration_test_4.d] - Valid file that should remain unchanged

### Phase 14 Tests
- [perf_test_1.d] - Large file for performance testing
- [perf_test_2.d] - Medium file for baseline performance
- [perf_test_3.d] - Complex file with many violations

### Phase 15 Tests
- [final_test_1.d] - Complete compliance test file
- [final_test_2.d] - Regression test file
- [final_test_3.d] - Edge case validation file

## D Language Specific Research

### Shebang Usage in D
- In D scripts, the #! line is used to specify the interpreter, similar to shell scripts
- When using `#!/usr/bin/dmd`, DMD compiles and runs the script directly
- This bypasses the need for a separate compilation step
- The -i flag can be used in this context for import paths

### Import Path Functionality
- The `-i` flag in DMD adds import paths for modules
- Multiple import paths can be specified: `dmd -i=path1 -i=path2 file.d`
- This is different from the `-I` flag which affects header inclusion