module lint.abandons;

import lint.core;
import std.algorithm : canFind, startsWith;
import std.array : split, join;

// Detect abandoned constructs (multi-line mixins, quines, etc.) - these get warnings
@Rule("DetectAbandons", "Detects abandoned constructs like multi-line mixins")
LintReport detectAbandons(char[] content) {
    string original = cast(string)content;
    auto lines = original.split("\n");
    bool hasMultiLineMixin = false;
    bool hasEscapedStringMixin = false;

    // Track if we're inside a potential multi-line mixin
    bool inMixin = false;
    int openParensCount = 0;

    foreach(i, line; lines) {
        // Check for single-line mixin with escaped strings first
        if (line.canFind("mixin(") && (line.canFind(`q{`) || line.canFind(`r"`))) {
            hasEscapedStringMixin = true;
            continue;
        }

        // Check for start of mixin (could be multi-line)
        if (line.canFind("mixin(")) {
            inMixin = true;

            // Count opening parentheses
            foreach(c; line) {
                if (c == '(') openParensCount++;
                if (c == ')') openParensCount--;
            }

            // If all parentheses closed in one line, it's single-line
            if (openParensCount <= 0) {
                inMixin = false;
                openParensCount = 0;
            }
        } else if (inMixin) {
            // Still in a multi-line mixin - check for closing paren
            foreach(c; line) {
                if (c == '(') openParensCount++;
                if (c == ')') openParensCount--;
            }

            if (openParensCount <= 0) {
                inMixin = false;
                hasMultiLineMixin = true;  // Found a multi-line mixin
                openParensCount = 0;
            }
        }
    }

    // Also check for quine-like patterns (self-referencing code)
    bool hasPossibleQuine = original.canFind("typeof(this)") && original.canFind("__traits");
    size_t quineLine = 0;
    if (hasPossibleQuine) {
        for(size_t i = 0; i < lines.length; i++) {
            if (lines[i].canFind("typeof(this)") && lines[i].canFind("__traits")) {
                quineLine = i + 1;
                break;
            }
        }
    }

    bool hasStringofFile = (original.canFind("stringof") && original.canFind("__FILE__"));
    size_t stringofLine = 0;
    if (hasStringofFile) {
        for(size_t i = 0; i < lines.length; i++) {
            if (lines[i].canFind("stringof") && lines[i].canFind("__FILE__")) {
                stringofLine = i + 1;
                break;
            }
        }
    }

    Message[] messages;

    if (hasMultiLineMixin && hasEscapedStringMixin) {
        messages ~= Message("Found multi-line mixin and escaped string mixin - abandoning analysis", 1); // Would need more sophisticated tracking
    } else if (hasMultiLineMixin) {
        messages ~= Message("Found multi-line mixin - abandoning analysis", 1); // Would need more sophisticated tracking
    } else if (hasEscapedStringMixin) {
        messages ~= Message("Found escaped string mixin - abandoning analysis", 1); // Would need more sophisticated tracking
    }

    if (hasPossibleQuine && quineLine > 0) {
        messages ~= Message("Found possible self-referencing code pattern", quineLine);
    }
    if (hasStringofFile && stringofLine > 0) {
        messages ~= Message("Found possible self-referencing code pattern", stringofLine);
    }

    if (messages.length > 0) {
        return LintReport(LintResult.Warnings, messages);
    }

    return LintReport(LintResult.Success, []);
}

unittest {
    // Test multi-line mixin detection
    char[] testContent1 = `mixin(`
                        ~ `  "int x = 5;" `
                        ~ `);`.dup;
    auto result1 = detectAbandons(testContent1);
    assert(result1.result == LintResult.Warnings);
    assert(result1.messages[0].startsWith("Found multi-line mixin"));
    
    // Test escaped string mixin detection
    char[] testContent2 = `mixin(q{int x = 5;});`.dup;
    auto result2 = detectAbandons(testContent2);
    assert(result2.result == LintResult.Warnings);
    assert(result2.messages[0].startsWith("Found escaped string mixin"));
    
    // Test single-line mixin should not trigger
    char[] testContent3 = `mixin("int x = 5;");`.dup;
    auto result3 = detectAbandons(testContent3);
    assert(result3.result == LintResult.Success);
    
    // Test success case
    char[] testContent4 = `int x = 5;`.dup;
    auto result4 = detectAbandons(testContent4);
    assert(result4.result == LintResult.Success);
}