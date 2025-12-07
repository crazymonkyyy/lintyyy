# lintyyy CLI Interface

## Command Format
```
lintyyy [options] [files... | directories...]
```

## Core Flags
- `-h, --help` - Display help information about the linter
- `-c, --check` - Check for violations without modifying files (default behavior)
- `-n, --dry-run` - Show what would be changed without making modifications (outputs to stdout)
- `--stdin` - Read from standard input
- `--no-fix` - Disable automatic fixing of violations (fixing enabled by default per SPEC.md requirement)
- `--no-warnings` - Hide warnings for SHOULD rules (warnings shown by default)
- `--max-lines <n>` - Stop processing after n lines of code

## Exit Codes
- `0` : Success, no violations found
- `1` : Success, violations found and fixed (for MUST rules) or warnings issued (for SHOULD rules)
- `2` : Error during processing (parsing error, file I/O issues, etc.)

## Examples
- `lintyyy src/` - Lint all files in src directory
- `lintyyy --no-fix file.d` - Check file without fixing violations
- `lintyyy -n file.d` - Show what changes would be made to file
- `lintyyy --stdin < file.d` - Lint from standard input