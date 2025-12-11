# Updated Integration Plan for Lintyyy, Semiparse, and Mkystd

## Phase 1: Implement Partial Linter Using Semi-Parser

- [x] Analyze current semi-parser capabilities
- [x] Create non-destructive partial linter (`partial_linter.d`)
- [x] Implement easiest rules using semi-parser constructs
- [x] Ensure linter stays under 300 lines of code
- [x] Test linter on existing D files in the project

## Phase 2: Establish Communication Pathways

- [ ] Create/update REQUESTS.md files in each project to follow downhill communication model
- [ ] Update ORG-CHART.md in each project to clearly define roles and responsibilities
- [ ] Define interfaces between projects: lintyyy uses semiparse for parsing, semiparse uses mkystd for data structures

## Phase 3: Integrate mkystd with semiparse

- [ ] Modify semiparse to use mkystd instead of Phobos for range operations
- [ ] Update semiparse imports to use mkystd modules instead of std.*
- [ ] Ensure all semiparse data structures implement the mkystd ranges API with required functions (front, pop, empty) and optional functions (index, length, reverse, remove, append, resolve)

## Phase 4: Enhance Partial Linter

- [ ] Replace current std-based string functions with mkystd equivalents when available
- [ ] Extend linter functionality as semiparse and mkystd improve
- [ ] Add more sophisticated rule checking using semiparse's construct recognition

## Phase 5: Integrate semiparse with lintyyy

- [ ] Modify main lintyyy to incorporate semiparse-based analysis
- [ ] Replace current lint operations with semiparse-based analysis where beneficial
- [ ] Allow semiparse to identify code constructs according to SPEC.md (small definitions, block statement headers, statements)

## Phase 6: Update Build System

- [ ] Create a unified build process that compiles all three projects together
- [ ] Ensure lintyyy can be linked with semiparse and mkystd
- [ ] Update Makefiles or build scripts to handle the dependency chain

## Phase 7: Implement Cross-Project Testing

- [ ] Create integration tests that verify the connection between all three components
- [ ] Ensure all existing tests still pass after integration
- [ ] Add tests that cover the use of mkystd ranges in semiparse and lintyyy

## Phase 8: Update Project Documentation

- [ ] Document the integrated workflow in SPEC.md files
- [ ] Update README or add INTEGRATION.md to explain how the three projects work together
- [ ] Ensure all coding standards from SPEC.md are properly enforced across all levels