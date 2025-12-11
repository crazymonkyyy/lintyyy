# Testing Plan for Semi-Parser Agent

## Overview
This document outlines the testing strategy and implementation plan for the semiparse agent. The agent needs to build robust testing to handle the complex nature of parsing D code, similar to libdparse but with a simpler "semi-parsing" approach.

## Testing Loop Implementation

### 1. Unit Testing Framework
- Implement comprehensive unit tests for each parsing function
- Test each `is*` function individually (isSmallDefinition, isBlockStatementHeader, isStatement)
- Test helper functions like `findBlockStatementEnd`, `handleUnrecognized`, `countUnescaped`
- Create test cases for edge conditions and malformed code

### 2. Integration Testing
- Test end-to-end parsing of complete D files
- Validate Construct type detection accuracy
- Test error detection functionality
- Verify line number accuracy in results

### 3. Regression Testing Loop
- Create a repository of D files with known parsing requirements
- Run tests continuously to ensure parsing accuracy doesn't degrade
- Track parsing accuracy metrics over time
- Add new test cases when parsing issues are discovered

### 4. Fuzz Testing
- Generate random D-like code to test parser robustness
- Ensure parser doesn't crash on malformed input
- Test boundary conditions and unusual syntax patterns

## Libdparse Tests Migration Plan

### 1. Extract Test Cases from Libdparse
- Copy libdparse test files that focus on parsing functionality
- Identify tests that validate specific D language constructs
- Extract unit tests for different parsing scenarios
- Include tests for error recovery and diagnostics

### 2. Adapt Tests for Semi-Parsing Approach
- Modify tests to match semiparse's construct types (smallDefinition, blockStatementHeader, statement)
- Adjust expectations to match semi-parsing rather than full AST generation
- Focus on construct identification rather than detailed AST structure

### 3. Integrate with Existing Test Structure
- Add libdparse-derived tests to semiparse_tests.d
- Organize tests by construct type categories
- Maintain compatibility with current test runner

## Handling Previous Problems

### Problem 1: Incomplete Parsing of Complex D Features
- **Solution**: Create extensive test suite for template parsing
- **Test Focus**: templates.d, issue0042.d (octal templates), crazy1.d patterns
- **Verification**: Ensure semi-parser at least identifies template regions

### Problem 2: Operator Precedence and Expression Parsing
- **Solution**: Add expression-focused test cases
- **Test Focus**: expressions.d, switch_condition.d, while_condition.d
- **Verification**: Ensure statements are properly identified even with complex expressions

### Problem 3: Function and Method Parsing Complexity
- **Solution**: Create function declaration test suite
- **Test Focus**: shortenedMethod.d, function_declarations.d
- **Verification**: Ensure function headers are correctly classified as blockStatementHeaders

### Problem 4: Error Recovery and Diagnostics
- **Solution**: Implement comprehensive error detection tests
- **Test Focus**: fail_files directory from libdparse
- **Verification**: Ensure the semi-parser detects malformed constructs with appropriate ErrorMode

### Problem 5: Enum and Aggregate Parsing
- **Solution**: Add enum-specific test cases
- **Test Focus**: issue0095.d, enums.d
- **Verification**: Ensure enum constructs are identified correctly

## Testing Strategy for Semi-Parsing Approach

### Construct Type Accuracy Testing
- **Small Definition Tests**: Validate import, enum, alias, variable declarations are correctly identified
- **Block Header Tests**: Ensure class, struct, function, unittest headers are detected
- **Statement Tests**: Verify expression statements, assignments, and method calls are recognized

### Error Mode Testing
- **Minor Format Issue**: Test lines longer than 120 chars, missing semicolons
- **Suspicious Construct**: Test unclosed strings, unusual operator sequences
- **Severe Malformation**: Test unbalanced parentheses, braces, brackets
- **Potential Security Risk**: Test nested mixins or other potentially risky constructs

### Performance Testing
- **Large File Testing**: Process files similar to those in libdparse test suite
- **Complex Template Testing**: Validate performance on complex template scenarios
- **Memory Usage**: Monitor memory consumption during parsing

## Implementation Steps

### Step 1: Set up Test Infrastructure
```
- Create test harness based on current semiparse_tests.d
- Add helper functions for comparing parsing results
- Implement test case runner with pass/fail reporting
```

### Step 2: Migrate Libdparse Tests
```
- Identify relevant test cases from libdparse
- Convert them to use semi-parser construct types
- Add to semiparse test suite
```

### Step 3: Implement New Test Categories
```
- Create test files for each construct type
- Add edge case tests
- Include tests for error detection
```

### Step 4: Establish Continuous Testing Loop
```
- Automate test execution
- Set up performance benchmarks
- Implement regression test tracking
```

## Quality Assurance Process

### Parsing Accuracy Validation
- Compare semiparse results with libdparse on the same code
- Track accuracy metrics (percentage of constructs correctly identified)
- Monitor false positive/negative rates

### Robustness Validation
- Test parser against all valid D syntax from language specification
- Validate parser doesn't crash on malformed input
- Ensure parser handles all libdparse test cases gracefully

### Performance Validation
- Benchmark parsing speed against libdparse
- Monitor memory usage on large files
- Verify acceptable performance for linting use case