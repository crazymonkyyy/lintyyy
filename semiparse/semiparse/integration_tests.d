#!/usr/bin/dmd
/**
 * integration_tests.d - Integration tests for the semiparse library
 * 
 * Tests complete end-to-end parsing of D code files
 */
import semiparse;
import std.stdio;
import std.array;
import std.file;
import std.string;

void testRealDCodeParsing()
{
    writeln("Testing parsing of realistic D code...");
    
    auto parser = new SemiParser();
    
    // Complex D code sample that includes all construct types
    string realisticCode = q{
module example;

import std.stdio;
import std.algorithm;
import std.range;

enum MAX_ITEMS = 100;
alias StringList = string[];

struct Point
{
    int x;
    int y;
    
    this(int x, int y)
    {
        this.x = x;
        this.y = y;
    }
    
    double distanceTo(Point other)
    {
        return sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y));
    }
}

class Shape
{
protected:
    Point center;
    
public:
    this(Point center)
    {
        this.center = center;
    }
    
    void move(int dx, int dy)
    {
        center.x += dx;
        center.y += dy;
    }
    
    void display() @property
    {
        writeln("Shape at (", center.x, ", ", center.y, ")");
    }
}

template Max(T)
{
    T Max(T a, T b)
    {
        return a > b ? a : b;
    }
}

void processItems()
{
    auto items = [1, 2, 3, 4, 5];
    auto result = items
        .filter!(x => x > 2)
        .map!(x => x * 2)
        .array();
    
    foreach(item; result)
    {
        writeln(item);
    }
}

auto globalVar = 42;
auto calculated = globalVar * 2;

int main()
{
    Point p1 = Point(1, 2);
    Point p2 = Point(4, 6);
    
    writeln("Distance: ", p1.distanceTo(p2));
    
    auto shape = new Shape(p1);
    shape.display();
    
    processItems();
    
    return 0;
}
};
    
    Construct[] constructs = parser.parse(realisticCode);
    
    // Verify we got some constructs
    assertTrue(constructs.length > 0, 
               "Should parse multiple constructs from realistic D code");
    
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
    
    writeln("  Found ", constructs.length, " total constructs");
    writeln("    Small definitions: ", smallDefs);
    writeln("    Block statement headers: ", blockHeaders);
    writeln("    Statements: ", statements);
    
    assertTrue(smallDefs > 0, "Should find small definitions in realistic D code");
    assertTrue(blockHeaders > 0, "Should find block statement headers in realistic D code");
    assertTrue(statements > 0, "Should find statements in realistic D code");
    
    writeln("  PASS: Realistic D code parsed successfully");
}

void testErrorDetectionInComplexCode()
{
    writeln("\nTesting error detection in complex code...");
    
    auto parser = new SemiParser();
    
    // Code with intentional errors
    string codeWithErrors = q{
module example;

import std.stdio
int x = "unclosed string

struct Point {
    int x y;  // Missing comma
}

void foo() {
    auto result = someFunc(;
}
};

    Construct[] constructs = parser.parse(codeWithErrors);
    auto errors = parser.getErrors();
    
    // Check that errors were detected
    size_t errorCount = 0;
    foreach(error; errors) {
        if(error != ErrorMode.none) errorCount++;
    }
    
    assertTrue(errorCount > 0, 
               "Should detect errors in problematic code");
    
    writeln("  Found ", errorCount, " errors in problematic code");
    writeln("  PASS: Errors detected appropriately in complex code");
}

void testLineNumberAccuracy()
{
    writeln("\nTesting line number accuracy...");
    
    auto parser = new SemiParser();
    
    string multiLineCode = q{
import std.stdio;
void foo()
{
    writeln("hello");
}
auto x = 42;
};
    
    Construct[] constructs = parser.parse(multiLineCode);
    
    // Check that line numbers are reasonable
    bool lineNumbersValid = true;
    foreach(construct; constructs) {
        if(construct.lineStart > construct.lineEnd) {
            lineNumbersValid = false;
            break;
        }
        // Since line numbers start from 0, all should be less than total lines
        if(construct.lineStart >= 10 || construct.lineEnd >= 10) {  // Estimated max lines
            lineNumbersValid = false;
            break;
        }
    }
    
    assertTrue(lineNumbersValid, 
               "Line numbers should be consistent and within bounds");
    
    writeln("  PASS: Line numbers are accurate");
}

void testParsingConsistency()
{
    writeln("\nTesting parsing consistency...");
    
    auto parser1 = new SemiParser();
    auto parser2 = new SemiParser();
    
    string testCode = q{
import std.stdio;
struct Test { int x; }
void func() { }
auto y = 100;
};
    
    // Parse the same code with two different parsers
    Construct[] constructs1 = parser1.parse(testCode);
    Construct[] constructs2 = parser2.parse(testCode);
    
    // Results should be identical
    assertTrue(constructs1.length == constructs2.length,
               "Consistent number of constructs should be found");
    
    for(size_t i = 0; i < constructs1.length && i < constructs2.length; i++) {
        assertTrue(constructs1[i].type == constructs2[i].type,
                   "Construct types should be consistent across parses");
    }
    
    writeln("  PASS: Parsing is consistent across multiple instances");
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
    writeln("Running integration tests for semiparse...");
    
    testRealDCodeParsing();
    testErrorDetectionInComplexCode();
    testLineNumberAccuracy();
    testParsingConsistency();
    
    writeln("\nAll integration tests completed!");
}