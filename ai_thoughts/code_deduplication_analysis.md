# Code Deduplication System Design for lintyyy

## Overview
The SPEC.md requirement "all files in the project MUST NOT be line by line identical, and yes im saying that with MUST intentionally with deleting it" and "all file in the project SHOULD NOT be extremely similar" presents one of the most challenging and complex aspects of the lintyyy linter. This requirement will likely consume a significant portion of implementation effort.

## Understanding the Requirement

### MUST Rule: Line-by-Line Identity
- No two files in the project can be completely identical
- If found, one of the files must be modified to introduce differences
- This is a "MUST" requirement, meaning automatic correction is expected

### SHOULD Rule: Extreme Similarity
- Files SHOULD NOT be extremely similar (but some similarity is allowed)
- This generates warnings but may not require automatic modification
- Subjective definition of "extremely similar" needs algorithmic definition

## Technical Challenges

### 1. File Comparison Complexity
- Need to compare every file against every other file in the project
- Time complexity: O(n²) where n = number of files
- For large projects, this could become a performance bottleneck

### 2. Content Hashing Strategy
- Calculate hash of entire file content for identity detection
- Quick first-pass to identify potentially identical files
- Use cryptographic hash (SHA-256) to ensure uniqueness

### 3. Similarity Detection Algorithm
- Beyond simple identity, need to detect "extremely similar" files
- Possible approaches:
  - Percentage of identical lines
  - Longest common subsequence analysis
  - Abstract Syntax Tree (AST) comparison
  - Normalized content similarity metrics

### 4. Modification Strategy
- When identical files are found, how to introduce differences?
- Options for modification:
  - Add unique comments to each file
  - Add different whitespace patterns
  - Add version-specific code that effectively does nothing
  - Add file-specific metadata

## Implementation Approaches

### Approach 1: File Identity Detection
```
1. Generate hash for each file
2. Group files by hash
3. If any group has multiple files, these are identical
4. Apply modification strategy to all but one file in each group
```

### Approach 2: Similarity Detection
```
1. Compare each file against every other file
2. Calculate similarity metric (e.g., percentage of identical lines)
3. Flag files above similarity threshold (e.g., 90% identical)
4. Generate warning if SHOULD violation detected
```

### Approach 3: AST-Based Comparison (Advanced)
```
1. Parse each file to AST
2. Normalize AST to remove cosmetic differences
3. Compare normalized ASTs
4. More accurate but computationally expensive
```

## Performance Considerations

### Caching
- Cache hashes/metrics to avoid recomputation
- Only recompute when files change
- Store results in .lintyyy_cache directory

### Incremental Analysis
- Only check files that have been modified since last run
- Use file modification times to optimize processing
- Compare against previous run results

### Parallel Processing
- Compare files in parallel threads
- Use thread pool to limit resource usage
- Process large projects more efficiently

## Modification Strategies for Identical Files

### Strategy 1: Unique Comments
```
Add file-specific comments to introduce variation:
- Add timestamp or hash-based comment
- Add file-specific identifier
- Comments must follow SPEC.md comment standards
```

### Strategy 2: Semantic Nullifications
```
Add harmless code that differs between files:
- Different variable names for unused variables
- Different comments in specific locations
- File-specific conditional compilation
```

### Strategy 3: Code Reorganization
```
If semantically possible, reorganize identical code differently:
- Reorder imports differently
- Different function ordering
- Different comment placement
```

## Detection Metrics

### Identity Detection
- Use SHA-256 hash of normalized content
- Normalization removes only whitespace differences that don't affect semantics

### Similarity Detection
- Percentage of identical source lines
- Percentage of identical AST nodes
- Longest common sequence of tokens
- Configurable threshold (e.g., 90% similarity = "extremely similar")

## Implementation Architecture

### FileScan Module
```
- Scans project directory for D source files
- Maintains file metadata (path, size, modification time)
- Provides file list for comparison
```

### IdentityDetector Module
```
- Calculates hashes for all files
- Identifies groups of identical files
- Reports exact duplicates
```

### SimilarityDetector Module
```
- Implements similarity algorithms between file pairs
- Configurable thresholds for what constitutes "extremely similar"
- Provides warning-level output
```

### ModificationEngine Module
```
- Applies changes to resolve identity violations
- Implements file modification strategies
- Ensures changes don't break code functionality
```

## Edge Cases and Considerations

### 1. Large Projects
- For projects with 1000+ files, n² comparisons become expensive
- Need to implement efficient pruning strategies
- Consider only comparing files of similar size initially

### 2. Binary Files
- Ensure D source files (.d extension) are processed
- Skip binary files to avoid processing issues

### 3. Symlinks and Duplicates
- Handle symbolic links appropriately
- Don't count symlinks as separate files if pointing to same content

### 4. Third-Party Code
- Consider whether to exempt third-party libraries
- Or apply rules consistently across entire project directory

### 5. Template-Based Code Generation
- D's template system may generate similar files
- Need to handle programmatic code generation appropriately

## Performance Optimization Strategies

### 1. Size-Based Pruning
- Skip comparison of files with significantly different sizes
- Same-size files still need full comparison

### 2. Early Exit Strategy
- For similarity detection, exit early if threshold exceeded
- Don't calculate exact similarity if clearly below threshold

### 3. Fingerprint-based Pre-filtering
- Use shorter "fingerprints" to quickly eliminate dissimilar files
- Only run full comparison on files that pass fingerprint test

## Potential Issues and Resolution

### Issue 1: False Positives
- Files that are legitimately similar for valid reasons
- Solution: Configurable exceptions, manual override options

### Issue 2: Performance Degradation
- Large projects taking too long to process
- Solution: Incremental updates, caching, parallel processing

### Issue 3: Semantic Modification Risk
- Introducing differences might accidentally affect code meaning
- Solution: Use only comments or truly neutral changes

## Testing Strategy for Duplication Detection

### Unit Tests
- Verify identity detection with known identical files
- Test similarity detection with known similar files
- Test modification strategies on sample files

### Integration Tests
- End-to-end testing on sample projects
- Performance testing on large test projects
- Verification that modifications don't break functionality

## Impact on Overall Architecture

### Integration with Rule Engine
- Duplication detection runs as a separate phase
- Results integrated with overall rule violation reporting
- May require multiple passes over files

### File Processing Order
- Duplication detection may need to occur after other modifications
- Changes made by other linter rules could affect duplication status
- Need to consider ordering of rule application

## Resource Requirements

### Memory Usage
- Need to hold file contents or hashes in memory
- For large projects, may require disk-based processing
- Hash storage scales linearly with file count

### Processing Time
- Primary performance bottleneck for large projects
- May require progress indicators for large operations
- Should be configurable to run as pre-commit hook vs full scan

This duplication detection system will indeed require significant development effort, likely making it the most complex component of the linter, as you predicted.