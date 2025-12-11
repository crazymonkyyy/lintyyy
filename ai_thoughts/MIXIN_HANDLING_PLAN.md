# MIXIN HANDLING IMPLEMENTATION PLAN

## Overview
Based on the mixin_handling_strategy.md document, implement the strategy to differentiate between mixin types based on complexity and analyzability.

## Strategy Recap
- **Single-line mixins**: Process normally as part of linting rules
- **Multi-line mixins**: Flag as "abandoned" and generate warnings
- **Mixins with escaped strings**: Flag as "abandoned" and generate warnings

## Implementation Approach

### 1. Detection Patterns
The system needs to identify different mixin patterns:

#### Single-line mixins (process normally):
- `mixin("simple code here");`
- `mixin(templateName);`
- Simple expressions that fit on one line

#### Multi-line mixins (flag as abandoned):
- ```
  mixin(`
    complex code
    spanning multiple
    lines
  `);
  ```

#### Escaped string mixins (flag as abandoned):
- `mixin(q{...});`
- `mixin(` `"...");`
- Any mixin containing string literals with complex content

### 2. Detection Algorithm
```d
bool isAbandonedMixin(string line, string[] lines, size_t currentLineIndex) {
    // Look for mixin( pattern
    if (!line.canFind("mixin(")) return false;
    
    // Check if it's a single line mixin
    if (line.canFind(");")) {
        // Even single-line mixins might contain escaped strings
        if (line.canFind("q{") || line.canFind("`") || line.canFind(r"(")) {
            return true;  // Abandoned due to complex content
        }
        return false;  // Normal single-line mixin
    }
    
    // Multi-line mixin - definitely abandoned
    return true;
}
```

### 3. Integration with Existing System
- Add to the abandons.d module
- Generate appropriate warnings for abandoned constructs
- Don't apply other lint rules to abandoned mixin content
- Document that these constructs are "abandoned" to human supervision

### 4. Implementation Steps

#### Step 1: Enhance abandons.d module
- Add mixin detection function
- Distinguish between different mixin types
- Generate appropriate warnings

#### Step 2: Update processFile function
- Call mixin detection as part of the processing pipeline
- Skip other lint rules for abandoned mixin content
- Report abandoned constructs to users

#### Step 3: Testing
- Create test cases for each mixin type
- Verify warnings are generated appropriately
- Ensure normal mixins still get regular linting