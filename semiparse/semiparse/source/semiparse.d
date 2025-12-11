/**
 * semiparse - Semi-parsing module for D code
 *
 * This module implements a semi-parsing system that can detect D code structures
 * without performing a full parse. It identifies three main categories of D constructs:
 * 1. Small definitions: import std; enum foo=3; alias bar=int;
 * 2. Block statement headers: struct nullable(T){ void foo(T)(T a){
 * 3. Statements: helloworld.writeln;
 */
module semiparse;

import std.array : appender;
import std.range : take, drop, front, empty;
import std.algorithm : find, canFind, filter, map, count;
import std.string : split, strip, join;
import std.regex : regex, match;
import std.conv : to;
import std.format : format;

//---
/// Types and Constants
//---

/// Enum to represent different types of D code constructs
enum ConstructType 
{
    smallDefinition,    // import std; enum foo=3; alias bar=int;
    blockStatementHeader, // struct nullable(T){ void foo(T)(T a){
    statement          // helloworld.writeln;
}

/// Represents a parsed construct from the semi-parser
struct Construct
{
    ConstructType type;
    string content;
    size_t lineStart;
    size_t lineEnd;
}

/// Enum to represent different error modes for malformed code
enum ErrorMode
{
    none,
    minorFormatIssue,
    suspiciousConstruct,
    severeMalformation,
    potentialSecurityRisk
}

/// Range functions will be provided by mkystd child agent
// These functions will follow monkyyy's custom ranges API
// [ ] Please implement these functions in mkystd: startsWith, endsWith, indexOf
// After mkystd implements these functions, they will be imported as needed
// without using dub package management

//---
/// Types and Constants
//---

/// Main class for the semi-parser
class SemiParser
{
    string[] lines;
    ErrorMode[] errors;
    
    /**
     * Parse a D source code file and return an array of recognized constructs
     */
    public Construct[] parse(string sourceCode)
    {
        lines = sourceCode.split("\n");
        errors = new ErrorMode[lines.length];
        foreach(i, ref err; errors) { err = ErrorMode.none; }
        
        Construct[] constructs;
        
        // Process each line separately for now
        for(size_t i = 0; i < lines.length; i++)
        {
            auto trimmedLine = lines[i].strip();
            
            if(trimmedLine.length == 0 || trimmedLine.length >= 2 && trimmedLine[0] == '/' && trimmedLine[1] == '/')
                continue;
                
            // Determine the type of construct and add to results
            if(isSmallDefinition(trimmedLine))
            {
                constructs ~= Construct(ConstructType.smallDefinition, trimmedLine, i, i);
            }
            else if(isBlockStatementHeader(trimmedLine))
            {
                // Find the end of this block header (might span multiple lines)
                size_t endLine = findBlockStatementEnd(i);
                string fullContent = join(lines[i..endLine+1], "\n");
                constructs ~= Construct(ConstructType.blockStatementHeader, fullContent, i, endLine);
                i = endLine; // Skip processed lines
            }
            else if(isStatement(trimmedLine))
            {
                constructs ~= Construct(ConstructType.statement, trimmedLine, i, i);
            }
            else
            {
                // Not a recognized construct, but mark if there are formatting issues
                handleUnrecognized(trimmedLine, i);
            }
        }
        
        return constructs;
    }
    
    private bool isSmallDefinition(string line)
    {
        // Check for import declarations (with potential aliases)
        import std.algorithm : canFind;
        if(line.length >= 6 && line[0..6] == "import" && line.canFind(";"))
            return true;

        // Check for enum assignments (simple check)
        static immutable enumPattern = regex(r"^enum\s+\w+\s*=\s*[^;]+;$");
        if(match(line, enumPattern))
            return true;

        // Check for complex enum blocks
        static immutable enumBlockPattern = regex(r"^enum\s+\w+\s*\{");
        if(match(line, enumBlockPattern))
            return true;

        // Check for alias declarations (simple check)
        import std.string : indexOf;
        if(line.length >= 5 && line[0..5] == "alias" && line.canFind("=") && line.canFind(";"))
            return true;

        // Check for variable declarations with assignment
        if(line.canFind("=") && line.canFind(";") &&
           !line.canFind("import") && !line.canFind("enum") && !line.canFind("alias"))
            return true;

        // Check for const/immutable declarations
        if((line.length >= 5 && line[0..5] == "const" ||
            line.length >= 9 && line[0..9] == "immutable") &&
           line.canFind("=") && line.canFind(";"))
            return true;

        // Check for manifest constants (simple check)
        if(line.canFind("=") && line.canFind(";") && !line.canFind("import") &&
           !line.canFind("enum") && !line.canFind("alias") && !line.canFind("const"))
            return true;

        return false;
    }
    
    private bool isBlockStatementHeader(string line)
    {
        import std.algorithm : canFind;

        // Check for common D block headers: class, struct, union, interface, etc.
        static immutable blockHeaders = [
            "class ", "struct ", "union ", "interface ",
            "enum ", "template ", "unittest ",
            "version(", "debug ",
            "extern(C) ", "extern(D) ", "extern(C++) ",
            "static ", "final ", "abstract "
        ];

        foreach(header; blockHeaders)
        {
            if(line.length >= header.length && line[0..header.length] == header)
                return true;
        }

        // Check for function-like patterns (return type followed by identifier and params)
        // Simplified: look for a pattern with parentheses that's not an import or enum
        if(line.canFind("(") && line.canFind(")") &&
           !(line.length >= 7 && line[0..7] == "import ") && !(line.length >= 4 && line[0..4] == "enum "))
        {
            return true;
        }

        // Check for property-style function declarations
        if(line.canFind("@property"))
            return true;

        // Check for constructor/destructor
        bool isConstructor = (line.length >= 5 && line[0..5] == "this(") ||
                            (line.length >= 6 && line[0..6] == "~this(");
        if(isConstructor && line.canFind("{"))
            return true;

        // Check for operator overloading - simplified check
        if(line.canFind("op") && line.canFind("(") && line.canFind(")"))
            return true;

        // Check for aggregate initialization patterns
        if(line.canFind("=") && line.canFind("{"))
            return true;

        return false;
    }
    
    private bool isStatement(string line)
    {
        import std.algorithm : canFind;

        // Check if line ends with semicolon
        if(line.length > 0 && line[$-1] == ';')
        {
            // Exclude small definitions and block headers (already handled)
            auto stripped = line.strip();
            if(!isSmallDefinition(line) && !(stripped.length > 0 && stripped[$-1] == '{'))
            {
                // Additional check: ensure it's not a continuation of a multi-line construct
                bool isContinuation = false;
                if (stripped.length >= 4 && stripped[0..4] == "else") isContinuation = true;
                else if (stripped.length >= 5 && stripped[0..5] == "catch") isContinuation = true;
                else if (stripped.length >= 7 && stripped[0..7] == "finally") isContinuation = true;

                if (!isContinuation)
                {
                    return true;
                }
            }
        }

        // Assignment statements without explicit type declaration
        static immutable assignmentPattern = regex(r"^\s*[a-zA-Z_]\w*(\[\w\d]*)?(\s*\.\s*[a-zA-Z_]\w*)*\s*[\+\-\*/%&|^]?=\s*.*;$");
        if(match(line, assignmentPattern))
            return true;

        // Function calls
        static immutable funcCallPattern = regex(r"^\s*[a-zA-Z_]\w*\s*\([^)]*\)\s*;?$");
        if(match(line, funcCallPattern) && line.canFind("("))
        {
            // Ensure it's not a function declaration
            if(!isBlockStatementHeader(line))
                return true;
        }

        // Method chaining
        static immutable chainPattern = regex(r"^\s*[a-zA-Z_]\w*(\s*\.\s*[a-zA-Z_]\w*)+\s*;?$");
        if(match(line, chainPattern) && line.canFind("."))
            return true;

        // Expression statements
        static immutable exprPattern = regex(r"^\s*[a-zA-Z_]\w*\s+.*;$");
        if(match(line, exprPattern))
        {
            // Exclude cases that are more likely to be declarations
            if(!line.canFind("=") || (line.length >= 6 && line[0..6] == "assert"))
                return true;
        }

        return false;
    }
    
    private size_t findBlockStatementEnd(size_t startLine)
    {
        import std.algorithm : canFind;

        // Find where the block statement header ends (typically at opening brace)
        for(size_t i = startLine; i < lines.length; i++)
        {
            if(lines[i].canFind("{"))
                return i;
        }

        // If no opening brace found, return the start line
        return startLine;
    }
    
    private void handleUnrecognized(string line, size_t lineNumber)
    {
        import std.algorithm : canFind;
        auto trimmedLine = line.strip();

        // Check for potential formatting issues
        if(trimmedLine.canFind("/*") && !trimmedLine.canFind("*/"))
        {
            errors[lineNumber] = ErrorMode.minorFormatIssue;
        }
        else if(countUnescaped(trimmedLine, '"') % 2 != 0)  // Unclosed string
        {
            errors[lineNumber] = ErrorMode.suspiciousConstruct;
        }
        else if(countUnescaped(trimmedLine, '\'') % 2 != 0)  // Unclosed character literal
        {
            errors[lineNumber] = ErrorMode.suspiciousConstruct;
        }
        else if(trimmedLine.length > 120)  // Very long line
        {
            errors[lineNumber] = ErrorMode.minorFormatIssue;
        }
        else if(trimmedLine.canFind("^^")) // Potential exponentiation confusion
        {
            errors[lineNumber] = ErrorMode.suspiciousConstruct;
        }
        else if(trimmedLine.canFind(">>>")) // Unusual operator sequence
        {
            errors[lineNumber] = ErrorMode.suspiciousConstruct;
        }
        else if(countChar(trimmedLine, '(') != countChar(trimmedLine, ')')) // Unbalanced parentheses
        {
            errors[lineNumber] = ErrorMode.severeMalformation;
        }
        else if(countChar(trimmedLine, '{') != countChar(trimmedLine, '}')) // Unbalanced braces
        {
            errors[lineNumber] = ErrorMode.severeMalformation;
        }
        else if(countChar(trimmedLine, '[') != countChar(trimmedLine, ']')) // Unbalanced brackets
        {
            errors[lineNumber] = ErrorMode.severeMalformation;
        }
        else if(trimmedLine.length >= 6 && trimmedLine[0..6] == "import" && !(trimmedLine.length > 0 && trimmedLine[$-1] == ';')) // Missing semicolon in import
        {
            errors[lineNumber] = ErrorMode.minorFormatIssue;
        }
        else if(trimmedLine.length >= 5 && trimmedLine[0..5] == "mixin" && trimmedLine.canFind("template") && !trimmedLine.canFind("{"))
        {
            errors[lineNumber] = ErrorMode.potentialSecurityRisk; // Nested mixins could be risky
        }
        // Check for unusual nesting levels or potential multiline issues
        else if(countCharStr(trimmedLine, "/*") > 1) // Multiple opening comments in one line
        {
            errors[lineNumber] = ErrorMode.severeMalformation;
        }
    }

    private size_t countChar(string str, char c)
    {
        size_t count = 0;
        foreach(ch; str) {
            if(ch == c) count++;
        }
        return count;
    }

    private size_t countCharStr(string str, string substr)
    {
        if (substr.length == 0 || str.length < substr.length) return 0;
        size_t count = 0;
        size_t pos = 0;

        while (pos <= str.length - substr.length) {
            if (str[pos..pos+substr.length] == substr) {
                count++;
                pos += substr.length;
            } else {
                pos++;
            }
        }
        return count;
    }

    private size_t countUnescaped(string str, char c)
    {
        size_t count = 0;
        bool escaped = false;

        foreach(ch; str)
        {
            if(escaped)
            {
                escaped = false;
                continue;
            }

            if(ch == '\\')
            {
                escaped = true;
                continue;
            }

            if(ch == c)
            {
                count++;
            }
        }

        return count;
    }
    
    /**
     * Returns the accumulated errors detected during parsing
     */
    public ErrorMode[] getErrors()
    {
        return errors;
    }
}

//---
/// Functions
//---

// [All the range function requirements would go here once implemented by mkystd]
// [Functions like startsWith, endsWith, indexOf, countUnescaped, etc.]

//---
/// Unittests
//---

unittest
{
    // Basic functionality tests would go here once range functions are available
    // from the mkystd library
    import std.stdio;

    writeln("SemiParser unittests need mkystd range functions to be fully implemented");
}