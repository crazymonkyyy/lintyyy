# Semi-Parser Testing Framework

## Overview
This directory contains the testing framework for the semiparse library, designed to validate the semi-parsing functionality against various D code constructs.

## Testing Approach
The semi-parser takes a "lazy" approach to parsing D code, identifying three main categories of constructs:
1. Small definitions: `import std;` `enum foo=3;` `alias bar=int;`
2. Block statement headers: `struct nullable(T){` `void foo(T)(T a){`
3. Statements: `helloworld.writeln;`

Rather than performing a complete parse like libdparse (30k+ lines), this approach aims to detect "gross ugliness" while being less complex.

## Test Structure
- `/libdparse_tests/` - Contains test files from libdparse project adapted for semi-parsing
- `semiparse_tests.d` - Main test suite that runs comprehensive unit tests
- `test_semiparse.d` - Example usage and integration test

## Testing Loop
The testing loop follows this process:
1. Load D code from test files
2. Parse with semi-parser to identify constructs
3. Validate that constructs are correctly categorized
4. Check for proper error detection in malformed code
5. Verify performance and memory usage constraints

## Test Categories

### 1. Unit Tests
- Individual function testing (isSmallDefinition, isBlockStatementHeader, isStatement)
- Edge case validation
- Error detection accuracy

### 2. Integration Tests
- Complete file parsing
- Cross-construct validation
- Performance checks

### 3. Regression Tests
- Previously problematic D code patterns
- Template parsing challenges (from libdparse issues)
- Error recovery validation

## Running Tests

To run the complete test suite:
```
dmd semiparse_tests.d source/semiparse.d && ./semiparse_tests
```

To run a basic functionality test:
```
dmd test_semiparse.d source/semiparse.d && ./test_semiparse
```

To run libdparse validation tests:
```
dmd libdparse_validation_tests.d source/semiparse.d && ./libdparse_validation_tests
```

To run the comprehensive testing loop:
```
./comprehensive_test_loop.sh
```

## Libdparse Test Integration

The system includes test files from libdparse to validate against known D parsing challenges:

- `helloworld.d` - Basic "Hello World" program
- `expressions.d` - Complex expression syntax
- `templates.d` - Template definition and usage
- `classes.d` - Class and interface definitions
- `enums.d` - Various enum constructs

## Testing for Common D Parsing Challenges

### Template Parsing (Issue #0042, #0158, #0171, etc.)
- Complex template syntax with constraints
- Template specializations
- Variadic templates

### Expression Parsing
- Operator precedence and associativity
- Mixed expressions with function calls and array accesses
- Cast and type construction expressions

### Error Recovery
- Detecting malformed constructs
- Precise error location reporting
- Continuing parsing after errors

## Quality Metrics
- Parsing accuracy (percentage of constructs correctly identified)
- Error detection rate (percentage of malformed code identified)
- Performance (parsing speed vs. file size)
- Memory efficiency (memory usage vs. file size)