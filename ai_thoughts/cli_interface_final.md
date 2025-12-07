# lintyyy CLI Interface

## Command Format
```
lintyyy [options] [files... | directories...]
```

## Core Flags
- `-h, --help` - Display help information about the linter
- ~~`-c, --check` - Check for violations without modifying files (default behavior)~~ (DEPRECATED: Rules are always enforced per new policy)
- `-n, --dry-run` - Show what would be changed without making modifications (outputs to stdout)
- `--stdin` - Read from standard input
- ~~`--no-fix` - Disable automatic fixing of violations (fixing enabled by default per SPEC.md requirement)~~ (DEPRECATED: All fixes are mandatory per new policy)
- ~~`--no-warnings` - Hide warnings for SHOULD rules (warnings shown by default)~~ (DEPRECATED: All warnings are shown per new policy)
- `--max-lines <n>` - Stop processing after n lines of code
- `--max-errors <n>` - Stop after n errors
- `-v, --verbose` - Verbose output with detailed information
- `-q, --quiet` - Suppress non-error output
- `--diff` - Show changes in diff format

## Exit Codes
- `0` : Success, no violations found
- `1` : Success, violations found and fixed (for MUST rules) or warnings issued (for SHOULD rules)
- `2` : Error during processing (parsing error, file I/O issues, etc.)

## Examples
- `lintyyy src/` - Lint all files in src directory
- `lintyyy -n file.d` - Show what changes would be made to file
- `lintyyy --stdin < file.d` - Lint from standard input
- `lintyyy --diff src/` - Show changes in diff format
- `lintyyy --verbose --max-errors 10 src/` - Verbose output with error limit

## Policy Note
The linter supports configurable rule enforcement for practical bootstrapping. While default behavior enforces all SPEC.md requirements, configuration options allow selective rule control during migration phases.