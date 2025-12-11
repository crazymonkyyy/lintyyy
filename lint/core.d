module lint.core;

enum LintResult {
    Success = 0,    // No violations found
    Warnings = 1,   // SHOULD violations found (warnings generated)
    Fixes = 2       // MUST violations found and fixed
}

LintResult max(LintResult a, LintResult b) {
    int intA = cast(int)a;
    int intB = cast(int)b;
    int result = (intA > intB) ? intA : intB;
    return cast(LintResult)result;
}

// UDA to mark rule functions for metaprogramming
struct Rule {
    string name;
    string description;
    this(string name, string description) {
        this.name = name;
        this.description = description;
    }
}

struct Message {
    string content;     // The warning or fix notification message
    size_t lineNumber;  // Line number where the issue was found

    // Define equality operator for use in collections
    bool opEquals(const ref Message other) const pure nothrow @safe {
        return this.content == other.content && this.lineNumber == other.lineNumber;
    }
}

struct LintReport {
    LintResult result;
    Message[] messages;  // Warnings and fix notifications with line numbers
}

LintReport combineReports(LintReport a, LintReport b) {
    LintReport result;
    result.result = max(a.result, b.result);
    result.messages = a.messages ~ b.messages;
    return result;
}

unittest {
    // Test max(Success, Warnings) == Warnings
    assert(max(LintResult.Success, LintResult.Warnings) == LintResult.Warnings);
    
    // Test max(Warnings, Success) == Warnings
    assert(max(LintResult.Warnings, LintResult.Success) == LintResult.Warnings);
    
    // Test max(Fixes, Warnings) == Fixes
    assert(max(LintResult.Fixes, LintResult.Warnings) == LintResult.Fixes);
    
    // Test max(Warnings, Fixes) == Fixes
    assert(max(LintResult.Warnings, LintResult.Fixes) == LintResult.Fixes);
    
    // Test identity cases
    assert(max(LintResult.Success, LintResult.Success) == LintResult.Success);
    assert(max(LintResult.Warnings, LintResult.Warnings) == LintResult.Warnings);
    assert(max(LintResult.Fixes, LintResult.Fixes) == LintResult.Fixes);
}