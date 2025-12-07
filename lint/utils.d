module lint.utils;

import lint.core;
import std.array : split, join;
import std.algorithm : startsWith;
import std.string : strip;

// Utility function to combine multiple lint reports
LintReport combineReports(LintReport[] reports) {
    LintReport result;
    result.result = LintResult.Success;
    result.messages = [];

    foreach(report; reports) {
        result.result = max(result.result, report.result);
        result.messages ~= report.messages;
    }

    return result;
}

// Utility function to check if content starts with shebang
bool hasShebang(char[] content) {
    string str = cast(string)content;
    auto lines = str.split("\n");

    if (lines.length == 0) return false;

    string firstLine = lines[0].strip();
    return firstLine.startsWith("#!");
}

// Utility function to add shebang if missing
bool ensureShebang(char[] content) {
    if (hasShebang(content)) {
        return false; // Already has shebang
    }

    string newContent = "#!/usr/bin/dmd\n" ~ cast(string)content;
    content[] = newContent[];
    return true;
}

unittest {
    // Test hasShebang
    char[] content1 = "#!/usr/bin/dmd\nint x;".dup;
    assert(hasShebang(content1));

    char[] content2 = "int x;".dup;
    assert(!hasShebang(content2));

    // Test ensureShebang
    char[] content3 = "int x;".dup;
    bool modified = ensureShebang(content3);
    assert(modified);
    assert((cast(string)content3).startsWith("#!/usr/bin/dmd"));

    char[] content4 = "#!/usr/bin/dmd\nint x;".dup;
    bool notModified = !ensureShebang(content4);
    assert(notModified);
}