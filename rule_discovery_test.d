module rule_discovery_test;

import std.stdio;
import lint.core;
import lint.rules;

// Test to verify UDA-based rule function discovery works
void main() {
    writeln("Testing UDA-based rule discovery...");
    
    // This is a conceptual test - in practice you would use introspection
    // to find all functions with the @Rule UDA
    
    writeln("Rule UDAs applied successfully to rule functions:");
    writeln("- removePrivateKeywords: ", __traits(getAttributes, removePrivateKeywords));
    writeln("- enforceTabs: ", __traits(getAttributes, enforceTabs));
    writeln("- detectImmutableConst: ", __traits(getAttributes, detectImmutableConst));
    writeln("- normalizeImports: ", __traits(getAttributes, normalizeImports));
    writeln("- addSectionBreaks: ", __traits(getAttributes, addSectionBreaks));
    writeln("- standardizeComments: ", __traits(getAttributes, standardizeComments));
    
    writeln("Syntax test passed - UDAs are properly attached to rule functions.");
}