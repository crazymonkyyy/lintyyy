# Lint Operation Pattern for Metaprogramming

## Core Function Pattern
```d
LintReport function_name(char[] content);
```

This pattern enables metaprogramming over lint operations by providing a consistent interface that can be applied to all simple lint tests and individual lint operations.

## Functions Following This Pattern

### 1. Whitespace Enforcement (Tabs over Spaces)
```d
LintReport enforceTabs(char[] content);
```
- Converts leading spaces to tabs in indentation
- Implements SPEC.md requirement: "tabs over spaces (MUST)"

### 2. Private Keyword Removal
```d
LintReport removePrivateKeywords(char[] content);
```
- Removes all `private` keywords from the code
- Implements SPEC.md requirement: "`private` MUST NOT exist in code base"

### 3. Immutable/Const Warning Generator
```d
LintReport detectImmutableConst(char[] content);
```
- Detects `immutable` and `const` keywords but doesn't remove them
- Implements SPEC.md requirement: "`immutable`, `const` SHOULD NOT be"

### 4. Import Normalization
```d
LintReport normalizeImports(char[] content);
```
- Converts `import std.*` patterns to specific imports
- Implements SPEC.md requirement: "if import std.* is called it SHOULD be just whatever at the top"

### 5. Section Break Addition
```d
LintReport addSectionBreaks(char[] content);
```
- Adds `//---` comments between code sections
- Implements SPEC.md requirement: "`//---` SHOULD break up sections"

### 6. Comment Standardization
```d
LintReport standardizeComments(char[] content);
```
- Validates comments follow SPEC.md standards
- Implements SPEC.md requirement: "comments MUST be ddoc or `//BAD:` or have a ';'"

### 7. Shebang Verification
```d
LintReport verifyShebang(char[] content);
```
- Verifies the first line is #! with dmd/opend command
- Implements SPEC.md requirement: "the first line of all files MUST be #!"

## Metaprogramming Applications

### 1. Batch Processing
```d
LintReport[] allLintOps(char[] content) {
    alias lintOps = [
        &enforceTabs,
        &removePrivateKeywords,
        &detectImmutableConst,
        &normalizeImports
    ];
    
    LintReport[] results;
    foreach(op; lintOps) {
        results ~= op(content);
    }
    return results;
}
```

### 2. Conditional Application
```d
LintReport conditionalLint(char[] content, bool[] enabledOps) {
    alias allOps = [
        &enforceTabs,
        &removePrivateKeywords,
        &detectImmutableConst,
        &normalizeImports
    ];
    
    LintReport finalReport;
    foreach(i, op; allOps) {
        if (enabledOps[i]) {
            auto result = op(content);
            finalReport = combineReports(finalReport, result);
        }
    }
    return finalReport;
}
```

### 3. Testing Framework
```d
unittest {
    char[] testContent = "private int x;";
    auto result = removePrivateKeywords(testContent);
    assert(result.result == LintResult.Fixes);
    assert(cast(string)testContent == "int x;");
}
```

## Implementation Consistency

All functions following this pattern:
1. Take a mutable `char[] content` as input
2. Return a `LintReport` with appropriate result level
3. Modify content in-place for MUST rules, generate warnings for SHOULD rules
4. Follow a consistent error handling approach
5. Preserve code functionality while applying changes

## SPEC.md Implementation Strategy

This pattern enables implementation of all SPEC.md requirements through simple, testable functions:

- **MUST rules**: Implemented as functions that modify content directly
- **SHOULD rules**: Implemented as functions that generate warnings without modification
- **Composable**: Functions can be run individually or in combination
- **Testable**: Each function can be unit tested with clear input/output expectations
- **Extensible**: New SPEC.md requirements can be implemented as additional functions following the same pattern

This consistent interface enables the development of sophisticated linting workflows while maintaining the active modification requirement from SPEC.md.