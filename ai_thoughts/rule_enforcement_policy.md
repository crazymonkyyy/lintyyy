# Updated Documentation: Rule Enforcement Policy

## Core Principle
The lintyyy linter must balance strict SPEC.md compliance with practical bootstrapping needs. While the end goal is full compliance, the linter must support gradual migration of existing codebases.

## Rationale for Selective Enforcement
1. **Bootstrapping Reality**: Existing codebases need gradual migration to SPEC.md compliance
2. **Practical Adoption**: Allowing control during transition eases adoption
3. **Selective Application**: Different rules may be enabled gradually as codebase improves
4. **Developer Productivity**: Overly strict enforcement can block development during migration

## New Policy Approach
- Core functionality remains (all SPEC.md requirements are available)
- Some rules may be selectively disabled during migration phases
- Default behavior enforces all rules for new development
- Configuration options allow temporary rule disabling during bootstrapping

## Implementation Approach
- Use configuration files to control rule sets
- Allow per-file or per-directory rule exemptions
- Provide annotation-based suppression (e.g., `//lintyyy:ignore`)
- Support "warning only" mode for gradual migration

## Balanced Implementation Philosophy
The linter should enforce standards automatically where possible but allow flexibility during bootstrapping and gradual migration to full SPEC.md compliance.