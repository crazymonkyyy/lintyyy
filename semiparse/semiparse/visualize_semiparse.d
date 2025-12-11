#!/usr/bin/dmd
/**
 * visualize_semiparse.d - Tool to visualize semiparse output with colored output and | for breaks
 */
import semiparse;
import std.stdio;
import std.array;
import std.string;
import std.file;

void main(string[] args)
{
    if (args.length < 2) {
        writeln("Usage: ", args[0], " <source_file.d>");
        writeln("Visualizes semiparse output with colored output and | for breaks");
        return;
    }

    string fileName = args[1];
    
    try {
        string sourceCode = cast(string)readText(fileName);
        auto parser = new SemiParser();
        Construct[] constructs = parser.parse(sourceCode);
        auto errors = parser.getErrors();
        
        writeln("Semiparse Visualization for: ", fileName);
        writeln("===========================================");
        
        string[] lines = splitLines(sourceCode);
        size_t lineIdx = 0;
        
        foreach(i, line; lines)
        {
            // Show line number and error status
            string errorIndicator = (i < errors.length && errors[i] != ErrorMode.none) 
                ? getErrorColor(errors[i]) ~ " [ERROR]" ~ resetColor() 
                : "";
                
            writefln("%3d: %s%s", i+1, line, errorIndicator);
            
            // Show construct breaks after relevant lines
            foreach(construct; constructs)
            {
                if(construct.lineStart == i || construct.lineEnd == i) {
                    // Print break with appropriate color based on construct type
                    string typeColor = getColorForConstructType(construct.type);
                    string typeName = getConstructTypeName(construct.type);
                    
                    writeln(typeColor, "|--- ", typeName, " (", construct.lineStart+1, "-", construct.lineEnd+1, "): ", construct.content, resetColor());
                }
            }
        }
        
        writeln("===========================================");
        writeln("Summary:");
        writeln("  Total constructs found: ", constructs.length);
        
        int smallDefs = 0, blockHeaders = 0, statements = 0;
        foreach(c; constructs) {
            final switch(c.type) {
                case ConstructType.smallDefinition: smallDefs++; break;
                case ConstructType.blockStatementHeader: blockHeaders++; break;
                case ConstructType.statement: statements++; break;
            }
        }
        
        writeln("  Small definitions: ", smallDefs);
        writeln("  Block headers: ", blockHeaders);
        writeln("  Statements: ", statements);
        
        size_t errorCount = 0;
        foreach(error; errors) {
            if(error != ErrorMode.none) errorCount++;
        }
        writeln("  Lines with errors: ", errorCount);
        
    } catch (Exception e) {
        writeln("Error processing file: ", e.msg);
    }
}

string getColorForConstructType(ConstructType type) {
    final switch(type) {
        case ConstructType.smallDefinition:
            return "\x1b[33m";  // Yellow
        case ConstructType.blockStatementHeader:
            return "\x1b[34m";  // Blue
        case ConstructType.statement:
            return "\x1b[32m";  // Green
    }
    return resetColor();
}

string getErrorColor(ErrorMode errorMode) {
    final switch(errorMode) {
        case ErrorMode.none:
            return resetColor();
        case ErrorMode.minorFormatIssue:
            return "\x1b[35m";  // Magenta
        case ErrorMode.suspiciousConstruct:
            return "\x1b[31m";  // Red
        case ErrorMode.severeMalformation:
            return "\x1b[31m\x1b[1m";  // Bold Red
        case ErrorMode.potentialSecurityRisk:
            return "\x1b[31m\x1b[1m";  // Bold Red
    }
}

string getConstructTypeName(ConstructType type) {
    final switch(type) {
        case ConstructType.smallDefinition:
            return "SMALL_DEF";
        case ConstructType.blockStatementHeader:
            return "BLOCK_HDR";
        case ConstructType.statement:
            return "STATEMENT";
    }
    return "UNKNOWN";
}

string resetColor() {
    return "\x1b[0m";
}