# Mixin Handling Strategy for lintyyy

## Updated Approach
The linter will differentiate between mixin types based on complexity and analyzability:
- **Single-line mixins**: Will be processed normally as part of the linting rules
- **Multi-line mixins**: Will be flagged as "abandoned" and generate warnings
- **Mixins with escaped strings**: Will be flagged as "abandoned" and generate warnings

## Rationale
Single-line mixins are often used for simple code generation or simple string injection that can be safely analyzed by the linter without interfering with the core SPEC.md requirements. However, multi-line mixins and those containing escaped strings are more likely to generate complex code structures that are difficult to analyze for duplicates or other linting rules, and may contain complex template metaprogramming constructs.

This approach allows the linter to handle common, simple mixin usage while acknowledging that complex mixin scenarios are beyond the practical scope of static analysis for the requirements in SPEC.md.

## Implementation Details
The abandonment detection rule will specifically look for:
- `mixin(` followed by newlines before the closing parenthesis (flag as abandoned)
- `mixin(` containing escaped strings like `q{...}` or `r"..."` (flag as abandoned)
- Single-line `mixin(...)` statements that fit entirely on one line (process normally with other rules)

## SPEC.md Compliance
This strategy maintains the SPEC.md requirement to actively modify files while acknowledging practical limitations with extremely complex D language constructs. The warning system for "abandoned" constructs satisfies the "SHOULD" requirement pattern mentioned in SPEC.md regarding permissive testing.

## Example Cases
- `mixin("int x = 5;");` → Processed normally
- `mixin("int x = 5;" ~ "writeln(x);");` → Processed normally  
- ```
  mixin(`
    int x = 5;
    writeln(x);
  `);
  ``` → Flagged as abandoned
- `mixin(q{...});` → Flagged as abandoned