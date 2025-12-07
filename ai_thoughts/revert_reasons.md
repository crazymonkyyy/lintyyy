# Why the Linter Revert Happened

## Root Cause
The linter experienced a critical failure due to an overly simplistic approach to source code modification. The `removePrivateKeywords` function used naive string replacement instead of proper D language tokenization, causing:

1. **Semantic confusion**: The function couldn't distinguish between actual D keywords and text within string literals
2. **Content corruption**: During replacement operations, the character array manipulation caused severe file corruption
3. **Unsafe modifications**: Text patterns were replaced without considering D language syntax context

## Specific Issue
The function was using simple string matching:
```d
if (line.canFind("private ")) { line = line.replace("private ", ""); }
```

This would incorrectly match and replace "private" in contexts like:
- String literals: `string s = "This is private";`
- Comments: `// This is a private method`
- Variable names: `privateData` (if it started with "private")

## Impact of the Issue
- Files were being corrupted beyond recognition during processing
- Valid code was being mangled, not just keywords removed
- The linter was failing its core purpose of safely enforcing SPEC.md requirements

## Lessons Learned
- Language-aware source modification requires proper parsing/tokenization
- Simple text replacement is insufficient for code modification
- Context awareness (strings vs comments vs code) is essential
- Safety mechanisms are needed to prevent content corruption

## What This Means for the Project
The current linter functions work for some rules (tabs, abandons, etc.) but the core keyword removal functionality is fundamentally broken. A more robust approach to source code analysis is required.