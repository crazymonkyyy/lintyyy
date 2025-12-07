void main() {
    import lint.rules;
    import std.stdio;
    
    // Test private keyword removal
    char[] testContent = "private int x = 5;\n    int y = 10;".dup;
    writeln("Original: ", cast(string)testContent);
    
    auto result = removePrivateKeywords(testContent);
    writeln("After private removal: ", cast(string)testContent);
    writeln("Result: ", result.result);
    
    auto result2 = enforceTabs(testContent);
    writeln("After tab enforcement: ", cast(string)testContent);
    writeln("Result: ", result2.result); 
}