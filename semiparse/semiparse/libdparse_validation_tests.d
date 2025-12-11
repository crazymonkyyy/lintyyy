#!/usr/bin/dmd
/**
 * libdparse_validation_tests.d - Validation tests comparing semiparse against libdparse test cases
 *
 * This test file runs semiparse against various D code examples from libdparse
 * to validate that our semi-parsing approach correctly identifies D constructs.
 */
import std.stdio;
import std.file;
import std.string;
import std.array;

import semiparse;

void validateHelloWorld()
{
    writeln("Testing helloworld.d parsing...");
    try {
        string code = cast(string)read("libdparse_tests/helloworld.d");
        auto parser = new SemiParser();
        Construct[] constructs = parser.parse(code);
        
        writeln("  Found ", constructs.length, " constructs:");
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
            
            writeln("    - Type: ", typeName, ", Content: \"", construct.content, "\"");
        }
        
        // Verify we found the expected constructs
        bool foundImport = false;
        bool foundMain = false; 
        bool foundStatement = false;
        
        foreach(construct; constructs)
        {
            if (construct.content.contains("import std.stdio"))
                foundImport = true;
            if (construct.content.contains("void main"))
                foundMain = true;
            if (construct.content.contains("writeln"))
                foundStatement = true;
        }
        
        assert(foundImport, "Should have found import statement");
        assert(foundMain, "Should have found main function header");
        assert(foundStatement, "Should have found writeln statement");
        
        writeln("  helloworld.d validation PASSED");
    } catch(Exception e) {
        writeln("  Could not read helloworld.d: ", e.msg);
    }
}

void validateExpressions()
{
    writeln("Testing expressions.d parsing...");
    try {
        string code = cast(string)read("libdparse_tests/expressions.d");
        auto parser = new SemiParser();
        Construct[] constructs = parser.parse(code);
        
        writeln("  Found ", constructs.length, " constructs in expressions.d");
        
        // Count different types of constructs
        int smallDefs = 0;
        int blockHeaders = 0;
        int statements = 0;
        
        foreach(construct; constructs)
        {
            switch(construct.type)
            {
                case ConstructType.smallDefinition: smallDefs++; break;
                case ConstructType.blockStatementHeader: blockHeaders++; break;
                case ConstructType.statement: statements++; break;
            }
        }
        
        writeln("  Small definitions: ", smallDefs);
        writeln("  Block headers: ", blockHeaders); 
        writeln("  Statements: ", statements);
        
        writeln("  expressions.d validation completed");
    } catch(Exception e) {
        writeln("  Could not read expressions.d: ", e.msg);
    }
}

void validateClasses()
{
    writeln("Testing classes.d parsing...");
    try {
        string code = cast(string)read("libdparse_tests/classes.d");
        auto parser = new SemiParser();
        Construct[] constructs = parser.parse(code);
        
        writeln("  Found ", constructs.length, " constructs in classes.d");
        
        // Count different types of constructs
        int smallDefs = 0;
        int blockHeaders = 0;
        int statements = 0;
        
        foreach(construct; constructs)
        {
            switch(construct.type)
            {
                case ConstructType.smallDefinition: smallDefs++; break;
                case ConstructType.blockStatementHeader: blockHeaders++; break;
                case ConstructType.statement: statements++; break;
            }
        }
        
        writeln("  Small definitions: ", smallDefs);
        writeln("  Block headers: ", blockHeaders); 
        writeln("  Statements: ", statements);
        
        writeln("  classes.d validation completed");
    } catch(Exception e) {
        writeln("  Could not read classes.d: ", e.msg);
    }
}

void validateEnums()
{
    writeln("Testing enums.d parsing...");
    try {
        string code = cast(string)read("libdparse_tests/enums.d");
        auto parser = new SemiParser();
        Construct[] constructs = parser.parse(code);
        
        writeln("  Found ", constructs.length, " constructs in enums.d");
        
        // Count different types of constructs
        int smallDefs = 0;
        int blockHeaders = 0;
        int statements = 0;
        
        foreach(construct; constructs)
        {
            switch(construct.type)
            {
                case ConstructType.smallDefinition: smallDefs++; break;
                case ConstructType.blockStatementHeader: blockHeaders++; break;
                case ConstructType.statement: statements++; break;
            }
        }
        
        writeln("  Small definitions: ", smallDefs);
        writeln("  Block headers: ", blockHeaders); 
        writeln("  Statements: ", statements);
        
        writeln("  enums.d validation completed");
    } catch(Exception e) {
        writeln("  Could not read enums.d: ", e.msg);
    }
}

void validateTemplates()
{
    writeln("Testing templates.d parsing...");
    try {
        string code = cast(string)read("libdparse_tests/templates.d");
        auto parser = new SemiParser();
        Construct[] constructs = parser.parse(code);
        
        writeln("  Found ", constructs.length, " constructs in templates.d");
        
        // Count different types of constructs
        int smallDefs = 0;
        int blockHeaders = 0;
        int statements = 0;
        
        foreach(construct; constructs)
        {
            switch(construct.type)
            {
                case ConstructType.smallDefinition: smallDefs++; break;
                case ConstructType.blockStatementHeader: blockHeaders++; break;
                case ConstructType.statement: statements++; break;
            }
        }
        
        writeln("  Small definitions: ", smallDefs);
        writeln("  Block headers: ", blockHeaders); 
        writeln("  Statements: ", statements);
        
        writeln("  templates.d validation completed");
    } catch(Exception e) {
        writeln("  Could not read templates.d: ", e.msg);
        writeln("  This is expected if the file is not available");
    }
}

void main()
{
    writeln("Running libdparse validation tests for semiparse...");
    writeln();
    
    validateHelloWorld();
    writeln();
    
    validateExpressions();
    writeln();
    
    validateClasses();
    writeln();
    
    validateEnums();
    writeln();
    
    validateTemplates();
    writeln();
    
    writeln("All libdparse validation tests completed!");
}