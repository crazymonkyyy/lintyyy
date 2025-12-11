#!/usr/bin/dmd
/**
 * libdparse_migrated_tests.d - Tests migrated from libdparse for semiparse
 * 
 * These tests have been adapted from libdparse to work with semiparse's
 * semi-parsing approach, focusing on construct identification rather than
 * full AST generation.
 */
import semiparse;
import std.stdio;
import std.array;

void testTemplateParsing()
{
    writeln("Testing template parsing (migrated from libdparse)...");
    
    auto parser = new SemiParser();
    
    // Template with function
    string templateCode = q{
template Foo(T)
{
    T bar(T x) { return x + 1; }
}
};
    
    Construct[] constructs = parser.parse(templateCode);
    int templateHeaders = 0;
    foreach(c; constructs) {
        if(c.content.indexOf("template") != -1) {
            templateHeaders++;
        }
    }
    
    assertTrue(templateHeaders > 0, 
               "Template constructs should be identified");
    
    writeln("  PASS: Template parsing works");
}

void testExpressionParsing()
{
    writeln("\nTesting expression parsing (migrated from libdparse)...");
    
    auto parser = new SemiParser();
    
    // Complex expressions
    string expressionCode = q{
void testExpressions()
{
    auto a = 1 + 2 * 3;
    auto b = (a > 5) ? a : 0;
    auto c = func(a, b, a + b);
    bool flag = a > b && b < c || c == a;
}
};
    
    Construct[] constructs = parser.parse(expressionCode);
    
    // Should identify the function header
    int functionHeaders = 0;
    foreach(c; constructs) {
        if(c.content.indexOf("void testExpressions") != -1 || 
           c.content.indexOf("testExpressions()") != -1) {
            functionHeaders++;
        }
    }
    
    assertTrue(functionHeaders > 0, 
               "Function with complex expressions should be identified as block header");
    
    writeln("  PASS: Expression parsing works");
}

void testEnumParsing()
{
    writeln("\nTesting enum parsing (migrated from libdparse)...");
    
    auto parser = new SemiParser();
    
    // Different enum styles
    string enumCode = q{
enum SimpleEnum { A, B, C }
enum ComplexEnum
{
    Value1 = 1,
    Value2 = 2,
    Value3
}
};
    
    Construct[] constructs = parser.parse(enumCode);
    
    int enumHeaders = 0;
    foreach(c; constructs) {
        if(c.content.indexOf("enum") != -1) {
            enumHeaders++;
        }
    }
    
    assertTrue(enumHeaders >= 2, 
               "Both enum declarations should be identified");
    
    writeln("  PASS: Enum parsing works");
}

void testFunctionDeclarationParsing()
{
    writeln("\nTesting function declaration parsing (migrated from libdparse)...");
    
    auto parser = new SemiParser();
    
    // Various function declaration styles
    string funcCode = q{
int add(int a, int b) { return a + b; }
auto multiply(auto a, auto b) { return a * b; }
void printValue(int val) { writeln(val); }
int delegate(int) callback;
int function(int) funcPtr;
};
    
    Construct[] constructs = parser.parse(funcCode);
    
    // Should identify function headers
    int functionHeaders = 0;
    foreach(c; constructs) {
        if(c.type == ConstructType.blockStatementHeader) {
            functionHeaders++;
        }
    }
    
    assertTrue(functionHeaders >= 3, 
               "Function declarations should be identified as block headers");
    
    writeln("  PASS: Function declaration parsing works");
}

void testClassAndStructParsing()
{
    writeln("\nTesting class and struct parsing (migrated from libdparse)...");
    
    auto parser = new SemiParser();
    
    string classStructCode = q{
struct Point
{
    int x;
    int y;
}

class Shape
{
private:
    int id;
public:
    this() { id = 0; }
    void draw();
}
};
    
    Construct[] constructs = parser.parse(classStructCode);
    
    int blockHeaders = 0;
    foreach(c; constructs) {
        if(c.type == ConstructType.blockStatementHeader) {
            blockHeaders++;
        }
    }
    
    assertTrue(blockHeaders >= 2, 
               "Struct and class declarations should be identified as block headers");
    
    writeln("  PASS: Class and struct parsing works");
}

void testOperatorOverloading()
{
    writeln("\nTesting operator overloading (migrated from libdparse)...");
    
    auto parser = new SemiParser();
    
    string operatorCode = q{
struct Vec2
{
    int x, y;
    
    Vec2 opBinary(string op)(Vec2 other)
    {
        static if(op == "add")
            return Vec2(x + other.x, y + other.y);
        else
            return Vec2(0, 0);
    }
}
};
    
    Construct[] constructs = parser.parse(operatorCode);
    
    // Check that the struct is identified
    int blockHeaders = 0;
    foreach(c; constructs) {
        if(c.type == ConstructType.blockStatementHeader && c.content.indexOf("struct") != -1) {
            blockHeaders++;
        }
    }
    
    assertTrue(blockHeaders >= 1, 
               "Struct with operators should be identified as block header");
    
    writeln("  PASS: Operator overloading parsing works");
}

// Helper function to create a simple assertion mechanism
void assertTrue(bool condition, string message) {
    if (!condition) {
        writeln("FAIL: ", message);
        assert(false, message);
    }
    writeln("PASS: ", message);
}

void main()
{
    writeln("Running libdparse-migrated tests for semiparse...");
    
    testTemplateParsing();
    testExpressionParsing();
    testEnumParsing();
    testFunctionDeclarationParsing();
    testClassAndStructParsing();
    testOperatorOverloading();
    
    writeln("\nAll libdparse-migrated tests completed!");
}