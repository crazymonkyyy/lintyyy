#!/usr/bin/dmd
/**
 * convert_spaces_to_tabs.d - Simple utility to convert spaces to tabs in D files
 */
import std.stdio;
import std.file;
import std.string;
import std.path;
import std.array;

void convertFileSpacesToTabs(string filePath)
{
    // Read the file content
    string content = cast(string)readText(filePath);
    string[] lines = splitLines(content);
    
    // Convert leading spaces to tabs (assuming 4 spaces per tab)
    for(int i = 0; i < lines.length; i++)
    {
        string line = lines[i];
        if(line.length == 0) continue;  // Skip empty lines
        
        // Count leading spaces
        int spaceCount = 0;
        foreach(c; line)
        {
            if(c == ' ') spaceCount++;
            else break;
        }
        
        if(spaceCount > 0)
        {
            // Convert every 4 spaces to a tab
            int tabCount = spaceCount / 4;
            int remainingSpaces = spaceCount % 4;
            
            string newLine = "";
            for(int j = 0; j < tabCount; j++)
                newLine ~= "\t";
            for(int j = 0; j < remainingSpaces; j++)
                newLine ~= " ";
            
            // Add the rest of the line
            newLine ~= line[spaceCount .. $];
            lines[i] = newLine;
        }
    }
    
    // Write the converted content back to the file
    string newContent = join(lines, "\n");
    writeText(filePath, newContent);
    writeln("Converted spaces to tabs in: ", filePath);
}

void main()
{
    writeln("Converting spaces to tabs in D files...");
    
    // List of files to convert (these are the ones our detection program found)
    string[] filesToConvert = [
        "semiparse/source/semiparse.d",
        "semiparse/test_semiparse.d",
        "semiparse/semiparse_tests.d",
        "semiparse/comprehensive_tests.d",
        "semiparse/fuzz_test.d",
        "semiparse/integration_tests.d",
        "semiparse/libdparse_migrated_tests.d",
        "semiparse/benchmark.d"
    ];
    
    foreach(file; filesToConvert)
    {
        if(exists(file))
        {
            convertFileSpacesToTabs(file);
        }
        else
        {
            writeln("File does not exist: ", file);
        }
    }
    
    writeln("Conversion completed!");
}