#!/usr/bin/dmd
/**
 * test_semiparse.d - Test for semiparse library
 *
 * Tests the basic functionality of the semiparse semi-parsing library
 */
import semiparse;
import std.stdio;
import std.array;

//---
/// Functions
//---

void main()
{
    writeln("Testing semiparse library...");
    
    // Test code with various constructs
    string testCode = q{
import std.stdio;
import std.algorithm;

enum MAX_VALUE = 100;
alias MyInt = int;

struct Point
{
    int x;
    int y;
}

void printPoint(Point p)
{
    writeln("Point: (", p.x, ",", p.y, ")");
}

class Shape
{
    protected double area;
    
    public double getArea()
    {
        return area;
    }
}

auto value = 42;
someFunctionCall();
another.expression.writeln;
};

    auto parser = new SemiParser();
    Construct[] constructs = parser.parse(testCode);
    
    writeln("Found ", constructs.length, " constructs:");
    
    foreach(construct; constructs)
    {
        string typeName;
        switch(construct.type)
        {
            case ConstructType.smallDefinition:
                typeName = "SMALL_DEFINITION";
                break;
            case ConstructType.blockStatementHeader:
                typeName = "BLOCK_HEADER";
                break;
            case ConstructType.statement:
                typeName = "STATEMENT";
                break;
        }
        
        writeln("- Type: ", typeName, ", Line: ", construct.lineStart, "-", construct.lineEnd, 
                ", Content: \"", construct.content, "\"");
    }
    
    auto errors = parser.getErrors();
    size_t errorCount = 0;
    foreach(error; errors) {
        if(error != ErrorMode.none) errorCount++;
    }
    writeln("\nErrors detected: ", errorCount);
    
    writeln("\nTest completed successfully!");
}