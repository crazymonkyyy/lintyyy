# DEDUPLICATION SYSTEM IMPLEMENTATION PLAN

## Overview
The deduplication system is the most complex remaining component of the lintyyy linter. Based on the SPEC.md requirements and existing design documents, this system must detect and handle duplicate code across the entire project.

## SPEC.md Requirements
- "all files in the project MUST NOT be line by line identical"
- "all file in the project SHOULD NOT be extremely similar"

## Implementation Strategy

### 1. Design Approach
Following the design in code_block_deduplication_design.md, the system will:
- Run as a separate phase since it requires global project knowledge
- Use the function signature: `ErrorCode dedup(char[] activefile, string path)`
- Have access to information about the entire project's code blocks
- Identify and modify duplicate blocks to make them unique

### 2. Implementation Architecture
```
1. Project-wide scan to identify all code blocks
2. Normalization of code blocks to remove superficial differences
3. Comparison of normalized blocks to identify duplicates
4. Modification of duplicate blocks to make them unique
5. Preservation of functionality while introducing differences
```

### 3. Block Identification
The system needs to identify logical code blocks:
- Function/method bodies
- Loop bodies (foreach, for, while)
- Conditional blocks (if/else, switch)
- Anonymous code blocks
- Template instantiations that generate code

### 4. Normalization Process
To properly compare code blocks, normalize:
- Variable names (standardize to generic names)
- Comments (remove or standardize)
- Whitespace (standardize)
- Equivalent expressions (a + b vs b + a when commutative)

### 5. Modification Strategies
When identical blocks are found, apply modifications such as:
- Different variable names in one copy
- Equivalent but different expressions
- Unique comments explaining context
- Harmless code variations that don't affect logic

### 6. Integration with Existing System
- Run this phase after other linting operations
- May require multiple passes since modifications can create new blocks
- Ensure modifications don't violate other SPEC.md rules

## Technical Implementation Steps

### Step 1: Create the dedup function structure
```d
enum ErrorCode {
    Success,
    Error,
    NoDuplicatesFound
}

ErrorCode dedup(char[] activefile, string path) {
    // Implementation will go here
}
```

### Step 2: Implement code block identification
- Parse D source to identify logical code blocks
- Store blocks with their locations and content
- Create normalized representations for comparison

### Step 3: Implement comparison algorithm
- Hash-based quick comparison for potential matches
- Detailed comparison for potential duplicates
- Fuzzy comparison for "extremely similar" blocks

### Step 4: Implement modification strategies
- Safe modifications that preserve functionality
- Techniques to make blocks unique without breaking code

### Step 5: Integrate with global project analysis
- Share information across files
- Track all code blocks across the project
- Maintain thread-safe access if processing in parallel