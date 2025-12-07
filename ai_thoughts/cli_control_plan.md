# CLI Control Scheme Implementation Plan

## Overview
Design and implement a comprehensive CLI interface that provides users with appropriate control over linter behavior while maintaining strict SPEC.md compliance.

## Core CLI Flags to Implement

### File Processing Control
- `-f, --files` - Specify files to process (file paths, globs, or directories)
- `-r, --recursive` - Process directories recursively 
- `--include <pattern>` - Only process files matching pattern
- `--exclude <pattern>` - Skip files matching pattern

### Output Control
- `-v, --verbose` - Verbose output with detailed information
- `-q, --quiet` - Suppress non-error output
- `-o, --output <file>` - Write output to specified file
- `--report-format <format>` - Output format (text, json, csv)

### Operation Control (while keeping rules enabled)
- `--dry-run` - Show what changes would be made without applying them
- `--check` - Check only, don't modify files (warnings only)
- `--diff` - Show changes in diff format
- `--max-errors <n>` - Stop after n errors
- `--progress` - Show progress bar when processing large directories

### Reporting Control
- `--show-stats` - Show statistics about code quality metrics
- `--summary` - Print summary of violations at the end
- `--error-on-warning` - Return error code for warnings too
- `--suggest-fixes` - Show suggested fixes alongside violations

## Implementation Approach

### Phase 1: Core Structure
- Implement flag parsing using a proper argument parser
- Create configuration struct to hold all CLI options
- Update main function to handle new flags
- Ensure all SPEC.md rules remain active

### Phase 2: File Processing Controls
- Implement file discovery with include/exclude patterns
- Add recursive directory processing
- Create file filtering logic

### Phase 3: Output Controls
- Implement different output formats
- Add verbosity levels
- Create structured output options

### Phase 4: Operation Controls
- Implement dry-run mode
- Add progress indicators
- Create diff-style output

## Architecture Considerations

### Configuration Layer
Create a centralized configuration system that handles:
- CLI arguments
- Potential future config file settings
- Default values for all options

### Reporting Layer
Separate the reporting/output logic from rule enforcement to allow different presentation formats without affecting rule execution.

### File Processing Layer
Abstract the file discovery and filtering logic to support different selection criteria while maintaining rule application.

## Safety Measures
- Maintain SPEC.md compliance regardless of CLI options
- Ensure no option can disable rule enforcement
- Validate arguments to prevent unsafe operations
- Provide clear error messages for invalid combinations

## Testing Strategy
- Unit tests for argument parsing
- Integration tests for different CLI flag combinations
- Verify rules remain active under all flag configurations
- Test file filtering and selection logic

## Backwards Compatibility
- Maintain current basic functionality
- Ensure existing usage patterns still work
- Add new functionality as enhancements, not replacements