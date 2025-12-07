module lint.rules_tests;

import lint.core;
import lint.rules;
import lint.abandons;
import std.stdio;
import std.algorithm : canFind;

// Comprehensive unit tests for all rule implementations
unittest {
    // Test 1: Private keyword removal - basic case
    char[] testContent1 = "private int x;".dup;
    auto result1 = removePrivateKeywords(testContent1);
    assert(result1.result == LintResult.Fixes, "Should detect private keyword removal");
    assert(cast(string)testContent1 == "int x;", "Should remove private keyword");
    writeln("Test 1 passed: Basic private keyword removal");

    // Test 2: Private keyword removal - multiple occurrences
    char[] testContent2 = `private int x;
private void func() {}`.dup;
    auto result2 = removePrivateKeywords(testContent2);
    assert(result2.result == LintResult.Fixes, "Should detect multiple private keywords");
    assert(cast(string)testContent2 == `int x;
void func() {}`, "Should remove multiple private keywords");
    writeln("Test 2 passed: Multiple private keyword removal");

    // Test 3: Private keyword removal - no private keyword
    char[] testContent3 = "int x;".dup;
    auto result3 = removePrivateKeywords(testContent3);
    assert(result3.result == LintResult.Success, "Should return success when no private found");
    writeln("Test 3 passed: No private keyword case");

    // Test 4: Tab enforcement - basic case
    char[] testContent4 = "    int x = 5;".dup;
    auto result4 = enforceTabs(testContent4);
    assert(result4.result == LintResult.Fixes, "Should detect space to tab conversion");
    assert(cast(string)testContent4 == "\tint x = 5;", "Should convert leading spaces to tab");
    writeln("Test 4 passed: Basic tab enforcement");

    // Test 5: Tab enforcement - multiple indentations
    char[] testContent5 = `    int x = 5;
        int y = 10;`.dup;
    auto result5 = enforceTabs(testContent5);
    assert(result5.result == LintResult.Fixes, "Should detect multiple indentations");
    assert(cast(string)testContent5 == `\tint x = 5;
\t\tint y = 10;`, "Should convert multiple space indentations");
    writeln("Test 5 passed: Multiple indentation conversion");

    // Test 6: Tab enforcement - no spaces to convert
    char[] testContent6 = "\tint x = 5;".dup;
    auto result6 = enforceTabs(testContent6);
    assert(result6.result == LintResult.Success, "Should return success when no conversion needed");
    writeln("Test 6 passed: No conversion needed case");

    // Test 7: Immutable detection - should return warning
    char[] testContent7 = "immutable int x;".dup;
    auto result7 = detectImmutableConst(testContent7);
    assert(result7.result == LintResult.Warnings, "Should detect immutable keyword");
    writeln("Test 7 passed: Immutable keyword detection");

    // Test 8: Const detection - should return warning
    char[] testContent8 = "const int x;".dup;
    auto result8 = detectImmutableConst(testContent8);
    assert(result8.result == LintResult.Warnings, "Should detect const keyword");
    writeln("Test 8 passed: Const keyword detection");

    // Test 9: Both immutable and const detection
    char[] testContent9 = `immutable int x;
const int y;`.dup;
    auto result9 = detectImmutableConst(testContent9);
    assert(result9.result == LintResult.Warnings, "Should detect both immutable and const");
    assert(result9.messages.length >= 1, "Should have warning messages");
    writeln("Test 9 passed: Both immutable and const detection");

    // Test 10: No immutable/const - should return success
    char[] testContent10 = "int x;".dup;
    auto result10 = detectImmutableConst(testContent10);
    assert(result10.result == LintResult.Success, "Should return success when no immutable/const found");
    writeln("Test 10 passed: No immutable/const case");

    // Test 11: Multi-line mixin detection
    char[] testContent11 = `mixin(
  "int x = 5;"
);`.dup;
    auto result11 = detectAbandons(testContent11);
    assert(result11.result == LintResult.Warnings, "Should detect multi-line mixin");
    assert(result11.messages[0].canFind("multi-line"), "Should mention multi-line mixin in message");
    writeln("Test 11 passed: Multi-line mixin detection");

    // Test 12: Escaped string mixin detection
    char[] testContent12 = `mixin(q{int x = 5;});`.dup;
    auto result12 = detectAbandons(testContent12);
    assert(result12.result == LintResult.Warnings, "Should detect escaped string mixin");
    assert(result12.messages[0].canFind("escaped string"), "Should mention escaped string mixin in message");
    writeln("Test 12 passed: Escaped string mixin detection");

    // Test 13: Single-line mixin should not trigger warning
    char[] testContent13 = `mixin("int x = 5;");`.dup;
    auto result13 = detectAbandons(testContent13);
    assert(result13.result == LintResult.Success, "Single-line mixin should not trigger warning");
    writeln("Test 13 passed: Single-line mixin no warning");

    // Test 14: Plain content should return success
    char[] testContent14 = `int x = 5;
void main() {}`.dup;
    auto result14 = detectAbandons(testContent14);
    assert(result14.result == LintResult.Success, "Plain content should return success");
    writeln("Test 14 passed: Plain content success");

    writeln("All rule tests passed successfully!");
}