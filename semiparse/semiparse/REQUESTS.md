# REQUESTS.md

This file documents requests for changes to the semiparse project based on the style guide violations discovered by the parent project.

## Style Guide Violations

[ ] **Shebang requirement**: The file must start with `#!/usr/bin/dmd` but it doesn't have this requirement implemented.

[ ] **Private keyword removal**: The project uses `private` keyword in the SemiParser class, but SPEC.md requires that "private MUST NOT exist in codebase". The file contains instances like `private string[] lines;` and `private ErrorMode[] errors;`.

[ ] **Whitespace violations**: The codebase uses spaces for indentation instead of tabs. SPEC.md requires "MUST BE tabs over spaces".

[ ] **Missing section breaks**: The project doesn't use `//---` to break up sections as required by SPEC.md. Sections should include types/constants, functions, main, and unittests.

[ ] **Import normalization**: The project uses full std library paths (like `import std.array : appender;`) instead of simplified versions as required by SPEC.md.