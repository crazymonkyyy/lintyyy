#!/usr/bin/dmd
import std.stdio;
import std.file;
import std.array;
import std.string;
import std.algorithm;

void main(string[] args) {
    if (args.length < 2) {
        writeln("Usage: debug_shebang <filename>");
        return;
    }

    string filename = args[1];
    auto content = cast(char[])read(filename);

    writeln("File content (first 100 chars):");
    writeln(cast(string)content[0..min(100, content.length)]);
    writeln();

    string contentStr = cast(string)content;
    auto lines = contentStr.split("\n");
    writeln("First line: ", lines[0]);
    writeln("First line starts with #!?", startsWith(lines[0], "#!"));
    writeln("First line contains dmd?", canFind(lines[0], "dmd"));
    writeln("First line contains opend?", canFind(lines[0], "opend"));
}