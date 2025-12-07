module lint.operations;

import lint.core;

// Function pattern that allows for metaprogramming over lint operations
alias LintOp = LintReport function(char[] content);

// Dummy function that follows the pattern but only returns success
LintReport dummyOp(char[] content) {
    return LintReport(LintResult.Success, []);
}

unittest {
    char[] content = "int x = 5;".dup;
    auto result = dummyOp(content);
    assert(result.result == LintResult.Success);
    assert(result.messages.length == 0);
}