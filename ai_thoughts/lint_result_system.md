# LintResult System and Private Keyword Removal

## LintResult Enum Definition

```d
enum LintResult {
    Success = 0,    // No violations found
    Warnings = 1,   // SHOULD violations found (warnings generated)
    Fixes = 2       // MUST violations found and fixed
}
```

### Enumeration Values
- `Success (0)`: No SPEC.md violations detected
- `Warnings (1)`: SHOULD violations detected and reported as warnings
- `Fixes (2)`: MUST violations detected and actively modified in code

### Max Operation Behavior
The LintResult enum implements a max operation with the following rules:
- `max(Success, Warnings) == Warnings` (warnings take precedence over success)
- `max(Warnings, Success) == Warnings` (commutative property)
- `max(Fixes, Warnings) == Fixes` (active modifications take precedence over warnings)
- `max(Warnings, Fixes) == Fixes` (commutative property)
- `max(X, X) == X` (identity property)

This hierarchy ensures that more severe result types (those requiring action) take precedence when combining multiple results.

## Private Keyword Removal Function

### Function Signature
```d
LintReport removePrivateKeywords(char[] content);
```

### Parameters
- `content`: A mutable character array containing the D source code to process

### Return Value
- `LintReport`: A structure containing:
  - `LintResult result`: The severity of the linter result (Success, Warnings, or Fixes)
  - `string[] messages`: An array of messages describing changes or warnings

### Purpose
This function implements the SPEC.md requirement that `private` MUST NOT exist in the codebase. It actively modifies the source code by removing the `private` keyword from any declarations, as this is a MUST rule requiring active modification.

### Implementation Notes
- This function operates on the content in-place, modifying the char[] directly
- It identifies `private` keywords in all contexts (class members, variables, functions, etc.)
- For each `private` keyword found, it removes the keyword and adjusts spacing appropriately
- Returns a LintReport with LintResult.Fixes if private keywords were removed, LintResult.Success otherwise

### Example Transformation
Input: `private int value;`
Output: `int value;`

Input: `class MyClass { private void method(); }`
Output: `class MyClass { void method(); }`

### Error Handling
The function should handle malformed input gracefully and ensure that removing the `private` keyword doesn't introduce syntax errors in the source code.