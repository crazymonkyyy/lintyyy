# Lintyyy: Custom DLang Linter Design Document

## Overview
This document outlines the design of lintyyy, a specialized linter for the D programming language that strictly enforces the requirements specified in SPEC.md. This linter is designed specifically to meet your personal requirements as outlined in SPEC.md.

## Design Philosophy

### Active Modification vs Passive Reporting
- Unlike traditional linters that only report issues, lintyyy MUST actively modify files
- The linter is designed to ensure compliance with SPEC.md requirements automatically
- Passive reporting is secondary to active enforcement for MUST requirements

### Strict Rule Enforcement
- MUST requirements from SPEC.md are enforced with automatic corrections
- SHOULD requirements generate warnings but don't modify files by default
- The design prioritizes SPEC.md compliance over general best practices

## Architecture Design

### Core Components

#### 1. File Processing Engine
- **Input Validation**: Verifies each file starts with #! and uses dmd/opend
- **Content Parser**: Tokenizes D source code without full compilation
- **Output Writer**: Modifies files in-place while preserving non-targeted content

#### 2. Rule Enforcement Engine
- **Mandatory Rule Processor**: Handles MUST requirements with automatic fixes
- **Advisory Rule Processor**: Handles SHOULD requirements with warnings
- **Rule Priority System**: Ensures MUST rules take precedence over SHOULD rules

#### 3. Compliance Validator
- **SPEC.md Requirements Checker**: Validates all SPEC.md rules are properly implemented
- **Permissive Testing System**: Aligns with SPEC.md's "consider permissive tests" requirement

## Rule Implementation Design

### File Header Requirements (#!)
```
Design:
- Preprocessor checks first line for #! pattern
- Validates #! is followed by dmd or opend command
- Automatically adds #!/usr/bin/dmd if missing
- Preserves additional arguments like -i flags
```

### Whitespace Rules (Tabs vs Spaces)
```
Design:
- Scans for lines with leading space indentation
- Converts leading spaces to equivalent tab characters
- Maintains relative indentation levels
- Implements "conceptual spacing" as defined in SPEC.md
```

### Keyword Enforcement (private, immutable, const)
```
Design:
- private removal: AST traversal to locate and remove 'private' keyword
- immutable/const detection: Flag occurrences with warning
- UDA handling: Distinguish functional vs non-functional attributes
```

### Import Normalization
```
Design:
- Identifies 'import std.*' patterns
- Replaces with specific import statements
- Ensures imports are at top of file
```

### Section Break Implementation
```
Design:
- Analyzes code structure to identify sections
- Inserts '//---' comments between logical sections
- Recognizes: types/constants, functions, main, unittests
```

### Comment Standardization
```
Design:
- Validates all comments follow ddoc format or special rules
- Identifies BAD, HACK, RANT comments for easy grepping
- Verifies other comments have ';' or function calls for detection
```

### Code Duplication Detection
```
Design:
- File comparison algorithm to detect line-by-line identical files
- Similarity detection for highly similar files
- Implementation prevents identical file content across project
```

## Design Features Specific to Requirements

### Active File Modification Design
```
Implementation:
- Use temporary file approach for safety
- Atomic file operations to prevent corruption
- Backup creation option for safety
- Direct modification of file content that violates MUST rules
```

### Permissive Testing Approach
```
Design:
- Testing framework that focuses on core functionality rather than strict behavior
- Allow flexibility in implementation details while maintaining SPEC.md compliance
- Test that SHOULD rules are detectable even if not enforced
```

### DMD Integration Design
```
Implementation:
- No dub dependency as specified in SPEC.md
- Direct integration with DMD's -i flag functionality
- Support for #!/usr/bin/dmd and #!/usr/bin/opend formats
- Compatibility with DMD import paths
```

## Processing Flow

### 1. Input Validation
- Verify file has proper #! line
- Skip files that don't meet basic requirements
- Validate D language syntax (minimal parsing)

### 2. Rule Analysis
- Check all SPEC.md requirements against source
- Distinguish between MUST and SHOULD violations
- Generate action plan for modifications

### 3. Active Modification
- Apply automatic fixes for MUST violations
- Preserve existing code structure where possible
- Log changes made for verification

### 4. Warning Generation
- Report SHOULD violations that weren't fixed
- Provide clear messages about SPEC.md requirements
- Allow suppression of warnings if needed

### 5. Output Generation
- Write modified file back to disk
- Maintain original file permissions
- Provide optional backup of original file

## Configuration Design

### Built-in Configuration
- No external configuration file needed for basic operation
- All SPEC.md requirements are enforced by default
- Compliance with SPEC.md is mandatory, not configurable

### Optional Configuration
- File exclusion patterns
- Backup behavior (enable/disable)
- Output verbosity levels
- Testing/permissive mode toggles

## Extensibility Considerations

### Future Rule Addition
- Plugin system for additional rules (while maintaining SPEC.md compliance)
- Easy addition of new MUST or SHOULD requirements
- Rule inheritance and grouping capabilities

### Performance Optimization
- Caching mechanisms for repeated runs
- Parallel processing capabilities
- Incremental analysis features

## Testing Design

### Unit Testing
- Individual rule validation
- Parser/tokenizer verification
- File modification safety tests

### Integration Testing
- Full SPEC.md compliance verification
- Real-world D code testing
- Edge case and malformed input handling

### Regression Testing
- Ensure new features don't break existing SPEC.md compliance
- Maintain active modification functionality
- Validate warning systems work correctly