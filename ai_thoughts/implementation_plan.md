# lintyyy Implementation Plan

## Phase 1: Project Setup and Structure
- [ ] Create project directory structure
- [ ] Set up build system (likely make-based since no dub)
- [ ] Define core data structures for AST representation
- [ ] Create basic file I/O utilities
- [ ] Implement #! verification function
- [ ] Create shebang addition/modification function
- [ ] Verify proper #! format (#!/usr/bin/dmd or #!/usr/bin/opend)
- [ ] [test_file_1.d] - Basic file with correct shebang
- [ ] [test_file_2.d] - File without shebang to test rejection
- [ ] [test_file_3.d] - File with invalid shebang to test rejection
- [ ] [shebang_test_1.d] - File with #!/usr/bin/dmd
- [ ] [shebang_test_2.d] - File with #!/usr/bin/opend
- [ ] [shebang_test_3.d] - File with incorrect shebang format
- [ ] [shebang_test_4.d] - File with #!/usr/bin/dmd -i flag combination

## Phase 2: File Parsing and Reading
- [ ] Implement D source file parser
- [ ] Create tokenizer for D syntax
- [ ] Handle file encoding detection
- [ ] Implement error recovery for malformed files
- [ ] [parse_test_1.d] - Valid D file with various syntax constructs
- [ ] [parse_test_2.d] - File with syntax errors to test error recovery
- [ ] [parse_test_3.d] - Minimal valid D file
- [ ] [parse_test_4.d] - Complex D file with classes, functions, imports

## Phase 3: Rule Implementation - Whitespace
- [ ] Implement tab detection and validation
- [ ] Create space-to-tab conversion function
- [ ] Detect multiple closing braces on separate lines
- [ ] [whitespace_test_1.d] - File with spaces instead of tabs
- [ ] [whitespace_test_2.d] - File with correct tab indentation
- [ ] [whitespace_test_3.d] - File with multiple consecutive closing braces
- [ ] [whitespace_test_4.d] - Mixed indentation to test correction

## Phase 4: Rule Implementation - Keywords
- [ ] Implement 'private' keyword detector
- [ ] Create function to remove 'private' keyword
- [ ] Implement 'immutable'/'const' detector for warnings
- [ ] [keyword_test_1.d] - File with 'private' members
- [ ] [keyword_test_2.d] - File with 'immutable' variables
- [ ] [keyword_test_3.d] - File with 'const' functions
- [ ] [keyword_test_4.d] - File without restricted keywords

## Phase 5: Rule Implementation - Imports
- [ ] Detect 'import std.*' patterns
- [ ] Create import normalization function
- [ ] Ensure imports are at the top of files
- [ ] [import_test_1.d] - File with 'import std.stdio : writeln'
- [ ] [import_test_2.d] - File with 'import std.*' pattern
- [ ] [import_test_3.d] - File with correctly normalized imports
- [ ] [import_test_4.d] - File with imports scattered throughout

## Phase 6: Rule Implementation - Section Breaks
- [ ] Identify code sections (types, functions, main, unittests)
- [ ] Implement section break insertion
- [ ] [section_test_1.d] - File without section breaks
- [ ] [section_test_2.d] - File with proper section breaks
- [ ] [section_test_3.d] - Complex file with multiple sections
- [ ] [section_test_4.d] - File with inconsistent section organization

## Phase 7: Rule Implementation - Comments
- [ ] Detect non-ddoc comments
- [ ] Identify BAD/HACK/RANT comments
- [ ] Validate comments with ';' or function calls
- [ ] [comment_test_1.d] - File with invalid comments
- [ ] [comment_test_2.d] - File with proper ddoc comments
- [ ] [comment_test_3.d] - File with BAD/HACK/RANT comments
- [ ] [comment_test_4.d] - File with comments containing ';' or function calls

## Phase 8: Rule Implementation - Duplication Detection
- [ ] Create file comparison algorithm
- [ ] Detect line-by-line identical files
- [ ] Identify highly similar files
- [ ] [duplication_test_1.d] - First file for duplication check
- [ ] [duplication_test_2.d] - Identical to duplication_test_1.d
- [ ] [duplication_test_3.d] - Similar but not identical to duplication_test_1.d
- [ ] [duplication_test_4.d] - Completely different file

## Phase 9: File Modification Engine
- [ ] Create safe file modification functions
- [ ] Implement temporary file creation
- [ ] Add backup file functionality (optional)
- [ ] Ensure atomic file operations
- [ ] [modify_test_1.d] - File to test in-place modification
- [ ] [modify_test_2.d] - File to test modification with backup
- [ ] [modify_test_3.d] - Large file to test modification performance

## Phase 10: CLI Integration
- [ ] Integrate CLI interface with core functionality
- [ ] Implement argument parsing
- [ ] Add file/directory traversal logic
- [ ] Connect all flags to functionality
- [ ] [cli_test_1.d] - File for basic CLI testing
- [ ] [cli_test_2.d] - File for dry-run testing
- [ ] [cli_test_3.d] - File for fix/no-fix testing

## Phase 11: UDA Handling
- [ ] Implement UDA detection
- [ ] Distinguish between functional and non-functional udas
- [ ] [uda_test_1.d] - File with functional udas
- [ ] [uda_test_2.d] - File with non-functional udas
- [ ] [uda_test_3.d] - File without udas

## Phase 12: File Header Requirements
- [ ] Implement shebang detection
- [ ] Add shebang verification ('#!/usr/bin/dmd' or '#!/usr/bin/opend')
- [ ] [header_test_1.d] - File with correct dmd shebang
- [ ] [header_test_2.d] - File with correct opend shebang
- [ ] [header_test_3.d] - File without shebang
- [ ] [header_test_4.d] - File with invalid shebang

## Phase 13: Integration Testing
- [ ] Create comprehensive test files combining multiple rules
- [ ] Test error handling and edge cases
- [ ] Performance testing with large files
- [ ] [integration_test_1.d] - File with multiple SPEC.md violations
- [ ] [integration_test_2.d] - Large complex file with various constructs
- [ ] [integration_test_3.d] - Edge case file with unusual syntax
- [ ] [integration_test_4.d] - Valid file that should remain unchanged

## Phase 14: Performance and Optimization
- [ ] Profile performance bottlenecks
- [ ] Optimize critical code paths
- [ ] Add caching for repeated operations
- [ ] [perf_test_1.d] - Large file for performance testing
- [ ] [perf_test_2.d] - Medium file for baseline performance
- [ ] [perf_test_3.d] - Complex file with many violations

## Phase 15: Documentation and Final Testing
- [ ] Complete inline documentation
- [ ] Create user documentation
- [ ] Run complete test suite
- [ ] Perform final validation against SPEC.md
- [ ] [final_test_1.d] - Complete compliance test file
- [ ] [final_test_2.d] - Regression test file
- [ ] [final_test_3.d] - Edge case validation file