#!/usr/bin/dmd
/**
 * benchmark.d - Performance and accuracy benchmarks for semiparse
 * 
 * Measures parsing speed, memory usage, and accuracy metrics
 */
import semiparse;
import std.stdio;
import std.array;
import std.datetime;
import std.random;
import std.string;

void generateTestCode(out string code, int lineCount = 100)
{
    code = "module benchmark_test;\n\n";
    
    // Add imports
    code ~= "import std.stdio;\nimport std.algorithm;\nimport std.range;\n\n";
    
    // Add some enum definitions
    code ~= "enum MAX_VALUE = 1000;\n";
    code ~= "enum MIN_VALUE = 1;\n\n";
    
    // Add some aliases
    code ~= "alias IntList = int[];\n";
    code ~= "alias StringMap = string[int];\n\n";
    
    // Add a struct
    code ~= "struct Point {\n    int x;\n    int y;\n}\n\n";
    
    // Generate variable declarations
    for (int i = 0; i < 10; i++) {
        code ~= "auto var" ~ to!string(i) ~ " = " ~ to!string(uniform(1, 100)) ~ ";\n";
    }
    code ~= "\n";
    
    // Generate functions
    for (int i = 0; i < 5; i++) {
        code ~= "void func" ~ to!string(i) ~ "() {\n";
        code ~= "    writeln(\"Function " ~ to!string(i) ~ "\");\n";
        code ~= "    auto temp = var" ~ to!string(uniform(0, 10)) ~ ";\n";
        code ~= "}\n\n";
    }
    
    // Add template
    code ~= "template Max(T) {\n    T max(T a, T b) { return a > b ? a : b; }\n}\n\n";
    
    // Add remaining lines as statements
    for (int i = 10; i < lineCount - 30; i++) {  // Leave some room for other content
        if (i % 3 == 0) {
            // Assignment statements
            code ~= "var" ~ to!string(uniform(0, 10)) ~ " = " ~ to!string(uniform(1, 50)) ~ ";\n";
        } else if (i % 3 == 1) {
            // Function calls
            code ~= "func" ~ to!string(uniform(0, 5)) ~ "();\n";
        } else {
            // Other statements
            code ~= "writeln(\"Line " ~ to!string(i) ~ "\");\n";
        }
    }
}

void measurePerformance()
{
    writeln("Measuring performance...");
    
    string testCode;
    generateTestCode(testCode, 500);  // 500-line test file
    
    auto parser = new SemiParser();
    
    // Measure parsing time
    StopWatch sw;
    sw.start();
    
    Construct[] constructs = parser.parse(testCode);
    
    sw.stop();
    auto parsingTime = sw.peek();
    
    writeln("  Test code size: ", testCode.length, " characters");
    writeln("  Number of lines: ", testCode.count("\n"));
    writeln("  Number of constructs found: ", constructs.length);
    writeln("  Parsing time: ", parsingTime.total!"msecs", " ms");
    
    // Calculate speed in lines per second
    double linesPerSecond = (cast(double)testCode.count("\n")) / (cast(double)parsingTime.total!"secs");
    writeln("  Parsing speed: ", linesPerSecond, " lines/sec");
    
    // Calculate speed in characters per second
    double charsPerSecond = (cast(double)testCode.length) / (cast(double)parsingTime.total!"secs");
    writeln("  Parsing speed: ", charsPerSecond, " chars/sec");
}

void testAccuracyWithKnownCode()
{
    writeln("\nTesting accuracy with known code constructs...");
    
    auto parser = new SemiParser();
    
    string knownCode = q{
module test_accuracy;

import std.stdio;
import std.algorithm;
import std.range;

enum MAX_ITEMS = 100;
enum Status { Active, Inactive }

alias IntList = int[];
alias ProcessFunc = void delegate(int);

struct Point {
    int x;
    int y;
}

class Shape {
protected:
    Point center;
public:
    this(Point c) { center = c; }
    void move(int dx, int dy) { center.x += dx; center.y += dy; }
}

template Max(T) {
    T max(T a, T b) { return a > b ? a : b; }
}

void simpleFunc() {
    writeln("Simple function");
}

int calculate(int a, int b) {
    return a + b;
}

void processItems(IntList items) {
    foreach(item; items) {
        writeln(item);
    }
}

auto var1 = 42;
auto var2 = "hello";
int globalValue = 100;
};

    Construct[] constructs = parser.parse(knownCode);
    
    // Count expected construct types
    int expectedSmallDefs = 5;  // import x2, enum x1, alias x2
    int expectedBlockHeaders = 6;  // struct x1, class x1, template x1, function x3
    int expectedStatements = 3;  // auto var1, auto var2, int globalValue
    
    int actualSmallDefs = 0, actualBlockHeaders = 0, actualStatements = 0;
    foreach(c; constructs) {
        switch(c.type) {
            case ConstructType.smallDefinition:
                actualSmallDefs++;
                break;
            case ConstructType.blockStatementHeader:
                actualBlockHeaders++;
                break;
            case ConstructType.statement:
                actualStatements++;
                break;
        }
    }
    
    writeln("  Expected: ", expectedSmallDefs, " small defs, ", 
            expectedBlockHeaders, " block headers, ", expectedStatements, " statements");
    writeln("  Actual:   ", actualSmallDefs, " small defs, ", 
            actualBlockHeaders, " block headers, ", actualStatements, " statements");
    
    // Accuracy calculation - not exact match but a reasonable approximation
    double smallDefAccuracy = (cast(double)min(expectedSmallDefs, actualSmallDefs)) / cast(double)max(expectedSmallDefs, actualSmallDefs);
    double blockHeaderAccuracy = (cast(double)min(expectedBlockHeaders, actualBlockHeaders)) / cast(double)max(expectedBlockHeaders, actualBlockHeaders);
    double statementAccuracy = (cast(double)min(expectedStatements, actualStatements)) / cast(double)max(expectedStatements, actualStatements);
    
    writeln("  Small Definition Accuracy: ", smallDefAccuracy * 100, "%");
    writeln("  Block Header Accuracy: ", blockHeaderAccuracy * 100, "%");
    writeln("  Statement Accuracy: ", statementAccuracy * 100, "%");
    
    double overallAccuracy = (smallDefAccuracy + blockHeaderAccuracy + statementAccuracy) / 3.0 * 100;
    writeln("  Overall Accuracy: ", overallAccuracy, "%");
    
    assertTrue(overallAccuracy >= 70.0, 
               "Overall accuracy should be at least 70%");
}

void testRobustnessWithVaryingSizes()
{
    writeln("\nTesting robustness with varying code sizes...");
    
    int[] sizes = [50, 100, 500, 1000, 2000];
    auto parser = new SemiParser();
    
    foreach(size; sizes) {
        string testCode;
        generateTestCode(testCode, size);
        
        auto startTime = Clock.currSystemTick();
        
        try {
            Construct[] constructs = parser.parse(testCode);
            
            auto endTime = Clock.currSystemTick();
            auto timeTaken = (endTime - startTime);
            
            writeln("    Size ", size, " lines: ", constructs.length, 
                    " constructs in ", timeTaken, " ticks");
        } catch (Exception e) {
            writeln("    Size ", size, " lines: FAILED - ", e.msg);
        }
    }
}

// Helper function to create a simple assertion mechanism
void assertTrue(bool condition, string message) {
    if (!condition) {
        writeln("FAIL: ", message);
        assert(false, message);
    }
    writeln("PASS: ", message);
}

// Helper functions for calculations
int min(int a, int b) {
    return a < b ? a : b;
}

int max(int a, int b) {
    return a > b ? a : b;
}

void main()
{
    writeln("Running performance and accuracy benchmarks for semiparse...");
    
    measurePerformance();
    testAccuracyWithKnownCode();
    testRobustnessWithVaryingSizes();
    
    writeln("\nAll benchmarks completed!");
}