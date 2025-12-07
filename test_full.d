#!/usr/bin/dmd
int x = 5;
	int y = 10;  // This has spaces for indentation

import std.stdio : writeln;  // This should be normalized
import std.*; // This should be normalized

// Invalid comment - this should generate a warning
/// This is a ddoc comment - this is valid

int main() {
	writeln("Hello, world!");  // Main function
	return 0;
}