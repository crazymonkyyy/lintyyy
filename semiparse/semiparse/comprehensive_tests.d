#!/usr/bin/dmd
/**
 * comprehensive_tests.d - Comprehensive tests for the semiparse library
 * 
 * Implements the testing plan outlined in TESTING_PLAN.md
 */
import semiparse;
import std.stdio;
import std.array;
import std.uni;

// Helper function to create a simple assertion mechanism
void assertTrue(bool condition, string message) {
    if (!condition) {
        writeln("FAIL: ", message);
        assert(false, message);
    }
    writeln("PASS: ", message);
}

void testSmallDefinitionDetection()
{
    writeln("\n--- Testing Small Definition Detection ---");
    
    auto parser = new SemiParser();
    
    // Test import declarations
    assertTrue(parser.isSmallDefinition("import std.stdio;"), 
               "Simple import should be detected as small definition");
    assertTrue(parser.isSmallDefinition("import std.stdio : writeln;"), 
               "Aliased import should be detected as small definition");
    
    // Test enum assignments
    assertTrue(parser.isSmallDefinition("enum MAX_VALUE = 100;"), 
               "Enum assignment should be detected as small definition");
    
    // Test alias declarations
    assertTrue(parser.isSmallDefinition("alias MyInt = int;"), 
               "Alias declaration should be detected as small definition");
    
    // Test variable assignments
    assertTrue(parser.isSmallDefinition("auto x = 42;"), 
               "Auto variable assignment should be detected as small definition");
    assertTrue(parser.isSmallDefinition("int y = 100;"), 
               "Typed variable assignment should be detected as small definition");
    
    // Test non-small definitions (should return false)
    assertTrue(!parser.isSmallDefinition("struct Point { int x; int y; }"), 
               "Struct should not be detected as small definition");
    assertTrue(!parser.isSmallDefinition("void foo() { }"), 
               "Function should not be detected as small definition");
    assertTrue(!parser.isSmallDefinition("x = 5;"), 
               "Assignment statement should not be detected as small definition");
}

void testBlockStatementHeaderDetection()
{
    writeln("\n--- Testing Block Statement Header Detection ---");
    
    auto parser = new SemiParser();
    
    // Test class declarations
    assertTrue(parser.isBlockStatementHeader("class Shape {"), 
               "Class declaration should be detected as block statement header");
    
    // Test struct declarations
    assertTrue(parser.isBlockStatementHeader("struct Point {"), 
               "Struct declaration should be detected as block statement header");
    
    // Test function declarations
    assertTrue(parser.isBlockStatementHeader("void printPoint(Point p) {"), 
               "Function declaration should be detected as block statement header");
    assertTrue(parser.isBlockStatementHeader("int add(int a, int b) {"), 
               "Typed function declaration should be detected as block statement header");
    
    // Test template declarations
    assertTrue(parser.isBlockStatementHeader("template Foo(T) {"), 
               "Template declaration should be detected as block statement header");
    
    // Test unittest blocks
    assertTrue(parser.isBlockStatementHeader("unittest {"), 
               "Unittest block should be detected as block statement header");
    
    // Test non-block headers (should return false)
    assertTrue(!parser.isBlockStatementHeader("import std.stdio;"), 
               "Import should not be detected as block statement header");
    assertTrue(!parser.isBlockStatementHeader("enum MAX_VALUE = 100;"), 
               "Enum assignment should not be detected as block statement header");
    assertTrue(!parser.isBlockStatementHeader("x = 5;"), 
               "Assignment statement should not be detected as block statement header");
}

void testStatementDetection()
{
    writeln("\n--- Testing Statement Detection ---");
    
    auto parser = new SemiParser();
    
    // Test assignment statements
    assertTrue(parser.isStatement("x = 5;"), 
               "Assignment statement should be detected as statement");
    assertTrue(parser.isStatement("obj.field = value;"), 
               "Field assignment should be detected as statement");
    
    // Test function calls
    assertTrue(parser.isStatement("funcCall();"), 
               "Function call should be detected as statement");
    assertTrue(parser.isStatement("writeln(\"hello\");"), 
               "Method call should be detected as statement");
    
    // Test method chaining
    assertTrue(parser.isStatement("obj.method().chain().call();"), 
               "Method chaining should be detected as statement");
    
    // Test writeln calls
    assertTrue(parser.isStatement("someVar.writeln;"), 
               "writeln call should be detected as statement");
    
    // Test non-statements (should return false)
    assertTrue(!parser.isStatement("import std.stdio;"), 
               "Import should not be detected as statement");
    assertTrue(!parser.isStatement("enum MAX_VALUE = 100;"), 
               "Enum assignment should not be detected as statement");
    assertTrue(!parser.isStatement("void foo() {"), 
               "Function declaration should not be detected as statement");
}

void testErrorHandling()
{
    writeln("\n--- Testing Error Handling ---");
    
    auto parser = new SemiParser();
    
    // Test error detection in handleUnrecognized
    // This is harder to test directly, so we'll test via the parse function
    
    // Create a parser and test with problematic code
    string codeWithErrors = q{
import std.stdio  // Missing semicolon - should be caught as minor format issue
int x = "unclosed string;  // Unclosed string - should be caught as suspicious construct
};
    
    Construct[] constructs = parser.parse(codeWithErrors);
    auto errors = parser.getErrors();
    
    // Check that some errors were detected
    size_t errorCount = 0;
    foreach(error; errors) {
        if(error != ErrorMode.none) errorCount++;
    }
    
    assertTrue(errorCount > 0, 
               "Errors should be detected in malformed code");
    
    writeln("Note: Specific error mode detection requires range functions from mkystd");
}

void testConstructClassification()
{
    writeln("\n--- Testing Construct Classification ---");
    
    auto parser = new SemiParser();
    
    string testCode = q{
import std.stdio;
enum MAX_VALUE = 100;
alias MyInt = int;

struct Point {
    int x;
    int y;
}

void printPoint(Point p) {
    writeln("Point: (", p.x, ",", p.y, ")");
}

auto value = 42;
someFunctionCall();
};
    
    Construct[] constructs = parser.parse(testCode);
    
    // Since we can't directly call the private methods for testing, 
    // we'll verify the overall parsing works
    assertTrue(constructs.length > 0, 
               "Parser should identify at least one construct");
    
    // Count different types of constructs
    int smallDefs = 0, blockHeaders = 0, statements = 0;
    foreach(construct; constructs) {
        switch(construct.type) {
            case ConstructType.smallDefinition:
                smallDefs++;
                break;
            case ConstructType.blockStatementHeader:
                blockHeaders++;
                break;
            case ConstructType.statement:
                statements++;
                break;
        }
    }
    
    assertTrue(smallDefs >= 3, 
               "Should identify at least import, enum, and alias as small definitions");
    assertTrue(blockHeaders >= 2, 
               "Should identify struct and function as block statement headers");
    assertTrue(statements >= 1, 
               "Should identify function call as statement");
}

void testHelperFunctions()
{
    writeln("\n--- Testing Helper Functions (will require mkystd implementation) ---");
    
    // Note: These functions (like countUnescaped) will need to be available
    // via the mkystd library as mentioned in the requirements
    writeln("Helper functions like 'countUnescaped' will be implemented in mkystd");
}

void main()
{
    writeln("Running comprehensive semiparse tests...");
    
    testSmallDefinitionDetection();
    testBlockStatementHeaderDetection();
    testStatementDetection();
    testErrorHandling();
    testConstructClassification();
    testHelperFunctions();
    
    writeln("\nAll comprehensive tests completed!");
}