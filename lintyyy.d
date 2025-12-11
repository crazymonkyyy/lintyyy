#!/usr/bin/dmd
import std.stdio;
import std.file;
import std.array;
import std.string;

import lint.core;
import lint.operations;
import lint.rules;
import lint.abandons;
import lint.utils;

int main(string[] args) {
    bool dryRun = false;
    bool noFix = false;
    bool readStdin = false;

    // Parse flags first
    size_t i = 1;
    for (; i < args.length; i++) {
        string arg = args[i];
        if (arg == "-n" || arg == "--dry-run") {
            dryRun = true;
        } else if (arg == "--no-fix") {
            noFix = true;
        } else if (arg == "--stdin") {
            readStdin = true;
        } else {
            break; // First non-flag argument is treated as a file
        }
    }

    if (i >= args.length && !readStdin) {
        writeln("Usage: lintyyy [options] <file1> [file2] ...");
        writeln("Options:");
        writeln("  -n, --dry-run    Show changes without applying them");
        writeln("  --no-fix         Don't apply fixes (warnings only)");
        writeln("  --stdin          Read from standard input");
        return 1;
    }

    // Process each file argument
    for (size_t j = i; j < args.length; j++) {
        string arg = args[j];

        // Read the file
        auto fileContent = cast(char[])read(arg);
        if (fileContent.length == 0) {
            writeln("Warning: Could not read file ", arg);
            continue;
        }

        // Process the file (create a copy that can be modified)
        char[] content = fileContent.dup;
        char[] originalContent = fileContent.dup; // Keep original for comparison

        // For no-fix mode, we still want to detect what WOULD be fixed, so we need to process
        // but potentially revert the modifications afterward
        LintReport result;
        if (noFix) {
            // Process but capture what would be changed without applying permanently
            result = processFile(content, arg);
            // Restore original content to not apply fixes
            content[] = originalContent[];
        } else {
            // Process normally
            result = processFile(content, arg);
        }

        // Show results
        writeln("Processing ", arg, ": ", result.result);
        foreach (msg; result.messages) {
            writeln("  - Line ", msg.lineNumber, ": ", msg.content);
        }

        // Apply changes only if not in dry-run and not in no-fix mode
        if (!dryRun && !noFix) {
            std.file.write(arg, content);
        } else if (dryRun) {
            writeln("Dry run - changes would be:");
            string origStr = cast(string)originalContent;
            string newStr = cast(string)content;
            if (origStr != newStr) {
                writeln("  File would be modified");
            } else {
                writeln("  File would remain unchanged");
            }
        }
    }

    // Handle stdin option separately
    if (readStdin) {
        string inputContent = readln().chomp();
        char[] buffer = inputContent.dup;
        auto result = processFile(buffer, "stdin");

        writeln("Processing stdin: ", result.result);
        foreach (msg; result.messages) {
            writeln("  - ", msg);
        }

        if (!dryRun && !noFix) {
            writeln(cast(string)buffer);
        } else if (dryRun) {
            writeln("Dry run - content would be processed");
        }
    }

    return 0;
}

LintReport processFile(char[] content, string filename) {
    // Apply all lint operations in sequence
    LintReport finalReport;

    // Apply individual rules that make fixes (content will be modified during analysis)
    finalReport = combineReports(finalReport, enforceShebang(content));
    finalReport = combineReports(finalReport, removePrivateKeywords(content));
    finalReport = combineReports(finalReport, enforceTabs(content));
    finalReport = combineReports(finalReport, normalizeImports(content));
    finalReport = combineReports(finalReport, addSectionBreaks(content));

    // Always run warning-only rules
    finalReport = combineReports(finalReport, detectImmutableConst(content));
    finalReport = combineReports(finalReport, standardizeComments(content));
    finalReport = combineReports(finalReport, detectAbandons(content));

    return finalReport;
}