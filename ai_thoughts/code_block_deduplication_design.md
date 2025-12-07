# Code Deduplication System Design for lintyyy - Revised

## Clarification: Block-Level Deduplication vs File-Level Identity

The SPEC.md requirement "all files in the project MUST NOT be line by line identical" and "all file in the project SHOULD NOT be extremely similar" is actually about identifying and handling duplicate blocks of code within the project, not just identical files. This is a significantly more complex problem involving:

1. Finding duplicate code blocks within a single file
2. Finding duplicate code blocks across different files
3. Identifying "extremely similar" code blocks (not just identical)
4. Applying changes to ensure no completely identical blocks exist

## Understanding the True Requirement

### Core Problem
- Detect any block of code that appears multiple times in the project
- Block could be a few lines, a function, or any contiguous piece of code
- When identical blocks are found, they must be modified to become unique
- Similar blocks (not identical but very close) should be warned about

### Implications
- This requires parsing and analyzing code structure
- Need to identify code "blocks" (functions, code segments, etc.)
- Comparison must be intelligent enough to recognize semantically equivalent code
- Modification strategy must preserve functionality while introducing differences

## Technical Complexity

### Code Block Identification
- Parse D source code to identify logical code blocks
- Functions, methods, loops, conditional blocks, etc.
- May require full AST construction
- Must account for D-specific features like templates, mixins, etc.

### Intelligent Comparison
- Simple text comparison won't work due to different variable names, whitespace, formatting
- Need to normalize code structure for comparison
- Consider equivalent expressions: `a = b + c` vs `a = c + b` (if commutative)
- Handle different but equivalent control flow structures

### Semantic vs Syntactic Analysis
- Pure syntactic comparison might miss semantically identical blocks
- Fully semantic analysis is very complex in a typed language like D
- Likely need a hybrid approach: normalized syntax with some semantic awareness

## Implementation Architecture

### Separate Deduplication Pass
As you suggested, this requires a separate run from other linting:

```
1. Parse all D files in project to identify code blocks
2. Create normalized representations of each block
3. Compare all blocks against each other
4. Identify identical and highly similar blocks
5. Generate modifications to make identical blocks unique
6. Report similar blocks as warnings
```

### Function Interface Design
```d
enum ErrorCode {
    Success,
    Error,
    NoDuplicatesFound
}

ErrorCode dedup(char[] activefile, string path);
```

This function would:
- Receive the current file content and path
- Have access to information about the entire project's code blocks
- Be responsible for identifying duplicate blocks within the current file
- Apply necessary modifications to eliminate exact duplicates
- Return status of the deduplication operation

## Implementation Strategy for dedup Function

### In-Memory File Access
```d
ErrorCode dedup(char[] activefile, string path) {
    // activefile contains the current file's content in memory
    // path provides context for which file we're processing
    
    // 1. Parse the active file into code blocks
    auto blocks = parseToBlocks(activefile);
    
    // 2. Compare with known blocks from other files
    auto duplicates = findBlockDuplicates(blocks, getAllKnownBlocks());
    
    // 3. Apply modifications to remove exact duplicates
    foreach(dup; duplicates) {
        modifyBlockToBeUnique(dup);
    }
    
    // 4. Update the activefile in place
    updateFileContent(activefile, blocks);
    
    return ErrorCode.Success; // or appropriate status
}
```

### Information Sharing Between Files
- Global registry of known code blocks across all files
- Each call to dedup contributes to this registry
- Blocks are stored in normalized form for comparison
- Thread-safe access if processing files in parallel

## Block Identification Approach

### AST-Based Block Extraction
1. Parse D source to Abstract Syntax Tree
2. Identify "code blocks" as:
   - Function/method bodies
   - Loop bodies (foreach, for, while)
   - Conditional blocks (if/else, switch)
   - Anonymous code blocks within functions
   - Template instantiations that generate code

### Normalization Process
1. Remove/standardize variable names
2. Remove comments
3. Standardize whitespace
4. Convert equivalent expressions to canonical form
5. Maintain structure while removing superficial differences

### Comparison Strategy
1. Quick hash-based comparison of normalized blocks
2. For potential matches, do detailed comparison
3. For "extremely similar", use fuzzy comparison algorithms
4. Track locations of each unique block across the project

## Modification Strategies

### When Identical Blocks Are Found
1. **Identifier Variation**: Add different suffixes to variable names in one copy
2. **Expression Variation**: Use equivalent expressions (`a + b` vs `b + a`)
3. **Structure Variation**: Slightly restructure equivalent control flows
4. **Comment Differentiation**: Add unique comments explaining the specific context
5. **Unused Code**: Add different (but harmless) code that doesn't affect logic

### Example of Modification
```d
// Original duplicate block in file1.d:
int result = calculate(x, y);
if (result > threshold) {
    handleResult(result);
}

// Same block in file2.d needs to be made unique:
int output = calculate(x, y);  // Changed variable name
if (output > threshold) {
    handleResult(output);
}
```

## Performance Considerations

### Memory Usage
- AST for each file can be large
- Storing normalized blocks from all files
- Need to balance memory usage with performance

### Processing Order
- First pass: parse all files and identify blocks
- Second pass: compare blocks and identify duplicates
- Third pass: modify files to eliminate duplicates
- Or: process incrementally but with global registry

### Caching Strategy
- Cache parsed ASTs between runs
- Cache block hashes and comparisons
- Incremental processing for only changed files

## Integration with Overall Linter

### Separate Phase
- Run deduplication as a separate phase before or after other linting
- May need multiple iterations since modifications can create new blocks
- Different error handling and reporting requirements

### Interaction with Other Rules
- Modifications should not violate other SPEC.md rules
- Need to ensure other linter rules still apply after deduplication
- Order of linter phases becomes important

This is indeed a very complex requirement that will require significant development effort, likely forming the core of the linter's sophistication.