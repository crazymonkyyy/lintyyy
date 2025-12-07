# DLang Linter Planning Notes

## Project Overview
This is a linter for the D programming language (DLang). The project specifications are documented in SPEC.md and define rules and requirements for DLang code analysis and enforcement of specific coding standards.

## Key Requirements from SPEC.md

### Running the Linter
- The first line of all files MUST be `#!`
- `#!` SHOULD be a `dmd` or `opend` command
- Use `-i` as is, don't use `dub`

### Shebang (#!) Requirements
- The `#!` must be the very first two characters on the first line
- Following the #! is the path to the D compiler (dmd or opend)
- Common patterns: `#!/usr/bin/dmd` or `#!/usr/bin/opend`
- Additional arguments can follow the compiler path, including the -i flag for import paths
- lintyyy should verify and potentially add/modify these lines to comply with requirements

### -i Flag Usage
- The `-i` flag in DMD adds import paths for modules
- Syntax: `dmd -i=/path/to/modules file.d`
- SPEC.md specifically states "Use -i as is, dont use dub", suggesting using DMD directly with import paths
- Rather than relying on build systems like dub
- Multiple import paths can be specified: `dmd -i=path1 -i=path2 file.d`

### Coding Standards Enforced
- **Whitespace**: Tabs over spaces (MUST), conceptual spacing (SHOULD)
- **Keywords**: `private` MUST NOT exist in codebase, `immutable`/`const` SHOULD NOT be used
- **Imports**: SHOULD be at the top, `std.*` imports should be simplified
- **Sections**: Use `//---` to break up sections (types/constants, functions, main, unittests)
- **Comments**: Only for temp code or apologies, with specific keywords ("BAD", "HACK", "RANT")

### Code Deduplication
- Files MUST NOT be line-by-line identical
- Files SHOULD NOT be extremely similar

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

### Implementation Language
- Since this is a D linter and the SPEC.md mentions using DMD compiler, implementation might be in D itself
- Alternative: Implementation in common systems language (Go, Rust, C++) for better performance

### Processing Pipeline
- Read D source file
- Parse into tokens/AST
- Apply rules checking
- Generate warnings for SHOULD requirements
- Apply modifications for MUST requirements
- Write back to file

## Implementation Approaches for Each Rule

### File Header Rule
- Implementation: Check first line of file for `#!` pattern
- Action: If not present, add `#!/usr/bin/dmd` or similar as first line

### Whitespace Rule (Tabs over Spaces)
- Implementation: Token scanner that identifies space indentation
- Action: Replace leading spaces with tabs based on indentation level

### Private Keyword Rule
- Implementation: AST traversal to identify `private` keyword declarations
- Action: Remove `private` keyword and replace with default/package access

### Immutable/Const Rule
- Implementation: AST traversal to identify `immutable` or `const` usage
- Action: For SHOULD NOT cases, generate warnings; for stronger enforcement as needed

### Import Rule
- Implementation: Identify `import std.*` patterns
- Action: Replace with more specific imports like `import std.algorithm.iteration`

### Section Break Rule
- Implementation: Analyze code structure and logical blocks
- Action: Insert `//---` comments between sections as appropriate

### UDA Rule
- Implementation: Identify user-defined attributes
- Action: Flag non-functional udas; allow functional ones

### Comment Standardization
- Implementation: Analyze comment patterns
- Action: Ensure all comments follow ddoc format, `//BAD:`, or contain `;` or function calls

### Duplicate Code Detection
- Implementation: File comparison algorithm to detect identical content
- Action: Flag or modify to introduce differences

## File Modification Functionality Plan

### File Reading
- Read D source files with proper encoding handling
- Preserve original formatting where not modified

### In-Place Modification Strategy
- Use temporary file approach to safely modify content
- Or use in-memory editing with write-back to original file
- Ensure file permissions are preserved

### Modification Safety
- Create backups of original files before modification (optional)
- Validate syntax after modifications to prevent breaking code
- Atomic file operations to prevent corruption

### Selective Modification
- Only modify content that violates MUST rules
- For SHOULD rules, provide warnings but don't modify unless explicitly configured
- Allow configuration for different rule enforcement levels

### File Processing Pipeline
- Parse file content into tokens/lines
- Apply rule checks
- Collect modifications to make
- Apply modifications to original content
- Write modified content back to file

## DMD Compiler Integration

### DMD Integration Points
- The linter should NOT use dub (as specified in SPEC.md)
- Should work with DMD directly using -i flag
- May leverage DMD's parsing capabilities or have its own parser

### Implementation Considerations
- Could be written in D and compiled with DMD
- Could parse D code using a dedicated D parser library
- Would need to understand D syntax without relying on dub build system

### CLI Integration
- Use DMD's -i flag for in-place editing as mentioned in SPEC.md
- Follow the pattern of using DMD directly rather than build tools
- The #!/usr/bin/dmd pattern suggests linter files should be executable

## Testing Strategy

### Unit Testing
- Test individual rule checkers with simple input/output cases
- Test parser/tokenizer with various D syntax patterns
- Test file modification functions in isolation

### Integration Testing
- Test complete linter execution on sample D files
- Verify that MUST rules are enforced (files are modified)
- Verify that SHOULD rules generate warnings appropriately

### Regression Testing
- Maintain a suite of test files that represent various D coding patterns
- Ensure linter doesn't break valid code during modification
- Test edge cases and unusual file structures

### Testing for Each Rule
- File header: Test files with/without #!/dmd headers
- Whitespace: Test files with spaces vs tabs, verify conversion
- Private keyword: Test files with private members and verify removal
- Immutable/const: Test detection and warning generation
- Imports: Test std.* normalization
- Section breaks: Test section identification and commenting
- UDA handling: Test functional vs non-functional udas
- Comment standardization: Test various comment formats
- Duplicate detection: Test between similar files

### Permissive Tests
- As specified in SPEC.md, tests should be permissive
- Focus on validation rather than overly strict behavior
- Allow for the "SHOULD" vs "MUST" distinction in testing

## Test Files Structure

### Test directory structure:
- `/tests/file_header/`
- `/tests/whitespace/`
- `/tests/keywords/`
- `/tests/imports/`
- `/tests/sections/`
- `/tests/comments/`
- `/tests/duplication/`
- `/tests/integration/`

### Test file naming convention:
- `{rule_name}_positive.d` - Files that violate rules and should be modified
- `{rule_name}_negative.d` - Files that comply with rules and should remain unchanged
- `{rule_name}_warning.d` - Files that trigger SHOULD warnings but not modifications

### Test case examples:
- `private_keyword_positive.d` - Contains `private` keyword to be removed
- `whitespace_positive.d` - Uses spaces instead of tabs to be converted
- `imports_positive.d` - Contains `import std.*` to be normalized
- `comments_positive.d` - Contains invalid comments to be standardized

### Integration test files:
- Complex D files combining multiple rules
- Edge cases and boundary conditions
- Files that should remain unchanged when already compliant