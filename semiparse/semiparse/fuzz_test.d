#!/usr/bin/dmd
/**
 * fuzz_test.d - Fuzz testing for the semiparse library
 * 
 * Tests parser robustness with random/malformed D-like code
 */
import semiparse;
import std.stdio;
import std.random;
import std.array;
import std.string;

void generateRandomCode(out string code, int length = 100)
{
    code = "";
    string chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 \t\n;:{}()[]+-*/=.<>!&|";
    
    for (int i = 0; i < length; i++) {
        code ~= chars[uniform(0, chars.length)];
    }
}

void testValidDConstructs()
{
    writeln("Testing valid D constructs...");
    
    string[] validConstructs = [
        "import std.stdio;",
        "enum MAX_VALUE = 100;",
        "alias MyInt = int;",
        "auto x = 42;",
        "struct Point { int x; int y; }",
        "class Shape { }",
        "void foo() { }",
        "int add(int a, int b) { return a + b; }",
        "x = 5;",
        "funcCall();",
        "writeln(\"hello\");"
    ];
    
    auto parser = new SemiParser();
    
    foreach(construct; validConstructs) {
        try {
            Construct[] result = parser.parse(construct);
            writeln("  PASS: Parsed '", construct, "' successfully");
        } catch (Exception e) {
            writeln("  FAIL: Failed to parse '", construct, "' - ", e.msg);
        }
    }
}

void testInvalidConstructs()
{
    writeln("\nTesting invalid/malformed constructs...");
    
    string[] invalidConstructs = [
        "import std.stdio  // Missing semicolon",
        "int x = \"unclosed string",
        "enum {  // Unclosed enum",
        "void foo(  // Unmatched parenthesis",
        "struct Point { int x; int y;  // Unmatched brace",
        "x = ;  // Incomplete assignment",
        "if (x > 5  // Unmatched parenthesis",
        "for (int i = 0; i < 10; i++  // Unmatched parenthesis", 
        "auto x = {  // Incomplete initialization",
        "class Shape  // Missing opening brace",
    ];
    
    auto parser = new SemiParser();
    
    foreach(construct; invalidConstructs) {
        try {
            Construct[] result = parser.parse(construct);
            auto errors = parser.getErrors();
            
            // Check if errors were detected
            bool hasErrors = false;
            foreach(error; errors) {
                if(error != ErrorMode.none) {
                    hasErrors = true;
                    break;
                }
            }
            
            if (hasErrors) {
                writeln("  PASS: Malformed '", construct, "' correctly flagged with errors");
            } else {
                writeln("  INFO: Malformed '", construct, "' parsed without errors (may be acceptable)");
            }
        } catch (Exception e) {
            writeln("  FAIL: Exception thrown for '", construct, "' - ", e.msg);
        }
    }
}

void testRandomFuzz()
{
    writeln("\nTesting random fuzz inputs...");
    
    auto parser = new SemiParser();
    int testCount = 50;
    
    for (int i = 0; i < testCount; i++) {
        string randomCode;
        generateRandomCode(randomCode, uniform(20, 200));
        
        try {
            Construct[] result = parser.parse(randomCode);
            writeln("  PASS: Random code (", randomCode.length, " chars) parsed without crashing");
        } catch (Exception e) {
            writeln("  FAIL: Random code caused exception - ", e.msg);
            writeln("  Code: ", randomCode);
        }
    }
}

void main()
{
    writeln("Running fuzz tests for semiparse...");
    
    testValidDConstructs();
    testInvalidConstructs();
    testRandomFuzz();
    
    writeln("\nFuzz testing completed!");
}