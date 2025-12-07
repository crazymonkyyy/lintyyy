# Research on D Language's #! and -i Flag

## Overview
This document compiles research on the usage of shebang (#!) lines and the -i flag in the D programming language, particularly as they relate to the lintyyy linter project requirements.

## The #! (Shebang) in D

### Standard Usage
- In D scripts, the #! line is used to specify the interpreter, similar to shell scripts
- Common patterns in D:
  - `#!/usr/bin/dmd` - Direct execution with DMD compiler
  - `#!/usr/bin/rdmd` - Execution with D's runtime compiler
  - `#!/usr/bin/dub` - Execution with DUB build tool (though SPEC.md says not to use)

### DMD Direct Execution
- When using `#!/usr/bin/dmd`, DMD compiles and runs the script directly
- This bypasses the need for a separate compilation step
- The -i flag can be used in this context for import paths

### Syntax Requirements
- The #! must be the very first two characters on the first line
- Following the #! is the path to the D compiler
- Additional arguments can follow the compiler path

## The -i Flag in DMD

### Import Path Functionality
- The `-i` flag in DMD adds import paths for modules
- Syntax: `dmd -i=/path/to/modules file.d`
- Allows the compiler to find modules in non-standard locations

### Usage with #! Lines
- When D scripts have #! lines with -i, it looks like:
  - `#!/usr/bin/dmd -i=/path/to/imports`
  - `#!/usr/bin/dmd -i=/usr/local/dmd/src`

### Common Usage Patterns
- `-i` is often used to specify additional directories where D modules are located
- Multiple import paths can be specified: `dmd -i=path1 -i=path2 file.d`
- This is different from the `-I` flag which affects header inclusion

## Research from Forum Post

Based on the forum post referenced in your request, there appears to be an issue with how DMD handles #! lines when combined with certain flags. The post mentions:
- Potential problems with shebang handling in DMD
- Issues with how import paths are processed when using #! with -i

## Lintyyy Implementation Considerations

### REQUIREMENT: First Line #!
- The SPEC.md requires all files to start with #!
- The #! should be a dmd or opend command
- This means lintyyy should verify and potentially add these lines

### REQUIREMENT: Use -i as is, Don't Use Dub
- SPEC.md specifically states "Use -i as is, dont use dub"
- This suggests using DMD directly with import paths (-i flag)
- Rather than relying on build systems like dub

### Integration Notes
- lintyyy may need to verify that #! lines are properly formatted
- The linter might need to ensure -i flags are used appropriately in shebang lines
- Files without proper #! lines might need to have them added/modified

## Common Issues and Workarounds

### Portability Considerations
- Shebang paths may vary between systems (`/usr/bin/dmd` vs `/usr/local/bin/dmd`)
- Some systems may not support shebangs in the same way

### Compiler Differences
- DMD vs GDC vs LDC may handle #! differently
- The SPEC.md specifically mentions dmd or opend, suggesting specific compiler preference

## References
- DMD documentation on command line arguments
- Forum post referenced: fphdephlkhpyjtlxtmnf@forum.dlang.org
- SPEC.md requirements for lintyyy project