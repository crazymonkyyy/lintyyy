#!/usr/bin/dmd
/**
 * detect_indentation.d - Example program to detect if a project uses tabs or spaces
 */
import std.stdio;
import std.file;
import std.string;
import std.path;
import std.array;

struct IndentationResult
{
    bool usesTabs;
    bool usesSpaces;
    int tabCount;
    int spaceCount;
    double tabRatio;
    double spaceRatio;
}

IndentationResult analyzeFile(string filePath)
{
    IndentationResult result;
    
    import std.file : exists;

    try
    {
        string content = cast(string)readText(filePath);
        string[] lines = splitLines(content);

        foreach(line; lines)
        {
            // Skip empty lines and lines that don't start with whitespace
            if(line.length == 0 || (line[0] != ' ' && line[0] != '\t'))
                continue;

            // Check for tabs at the beginning of the line
            if(line.startsWith("\t"))
            {
                result.tabCount++;
                result.usesTabs = true;
            }

            // Check for spaces at the beginning of the line
            if(line.startsWith(" "))
            {
                result.spaceCount++;
                result.usesSpaces = true;
            }
        }
        
        int totalIndentLines = result.tabCount + result.spaceCount;
        if(totalIndentLines > 0)
        {
            result.tabRatio = cast(double)result.tabCount / totalIndentLines;
            result.spaceRatio = cast(double)result.spaceCount / totalIndentLines;
        }
    }
    catch(Exception e)
    {
        writeln("Error reading file ", filePath, ": ", e.msg);
    }
    
    return result;
}

IndentationResult analyzeDirectory(string dirPath, string pattern = "*.d")
{
    IndentationResult overallResult;

    // Manually search for .d files in the specific directories we know exist
    string[] directories = [dirPath, dirPath ~ "/semiparse", dirPath ~ "/semiparse/source",
                            dirPath ~ "/mkystd", dirPath ~ "/mkystd/source",
                            dirPath ~ "/mkystd/examples"];

    foreach(dir; directories)
    {
        try
        {
            // Try to read all .d files in the directory
            import std.path : buildPath;

            string[] potentialFiles = [
                dir ~ "/semiparse.d",
                dir ~ "/test_semiparse.d",
                dir ~ "/semiparse_tests.d",
                dir ~ "/comprehensive_tests.d",
                dir ~ "/fuzz_test.d",
                dir ~ "/integration_tests.d",
                dir ~ "/libdparse_migrated_tests.d",
                dir ~ "/benchmark.d"
            ];

            foreach(filePath; potentialFiles)
            {
                if(exists(filePath))
                {
                    IndentationResult fileResult = analyzeFile(filePath);

                    overallResult.tabCount += fileResult.tabCount;
                    overallResult.spaceCount += fileResult.spaceCount;
                    if(fileResult.usesTabs) overallResult.usesTabs = true;
                    if(fileResult.usesSpaces) overallResult.usesSpaces = true;
                }
            }
        }
        catch(Exception e)
        {
            // Continue to next directory if there's an error
        }
    }

    int totalIndentLines = overallResult.tabCount + overallResult.spaceCount;
    if(totalIndentLines > 0)
    {
        overallResult.tabRatio = cast(double)overallResult.tabCount / totalIndentLines;
        overallResult.spaceRatio = cast(double)overallResult.spaceCount / totalIndentLines;
    }

    return overallResult;
}

void main(string[] args)
{
    string projectPath = args.length > 1 ? args[1] : ".";  // Default to current directory
    
    writeln("Analyzing indentation in project: ", projectPath);
    
    IndentationResult result = analyzeDirectory(projectPath);
    
    writeln("Results:");
    writeln("  Uses Tabs: ", result.usesTabs);
    writeln("  Uses Spaces: ", result.usesSpaces);
    writeln("  Tab Count: ", result.tabCount);
    writeln("  Space Count: ", result.spaceCount);
    writeln("  Tab Ratio: ", result.tabRatio * 100, "%");
    writeln("  Space Ratio: ", result.spaceRatio * 100, "%");
    
    if(result.tabCount > result.spaceCount)
    {
        writeln("\nThe project predominantly uses TABS for indentation.");
    }
    else if(result.spaceCount > result.tabCount)
    {
        writeln("\nThe project predominantly uses SPACES for indentation.");
    }
    else if(result.tabCount > 0 && result.spaceCount > 0)
    {
        writeln("\nThe project uses a MIX of tabs and spaces for indentation.");
    }
    else
    {
        writeln("\nThe project does not appear to use indentation in the analyzed files.");
    }
}