Im working a linter but lazy parsing isnt working: this will be next step up in complexity but not a real parser still

d has roughly 3 types of sensable formating + {}'s primitives: 

small definations: `import std;`  `enum foo=3;`  `alias bar=int;` 

block statement header: `struct nullable(T){`  `void foo(T)(T a){` 

statement: `helloworld.writeln;` that are owned by a block header 

so im imagine a semi-parser that trys to detects gross uglyiness such as a string thats multiple lines long, nested mixins to "give up" on, but otherwise returns these primitives as strings
 
file path turn into a range of pair(enum of error modes,sumtype of peusdo primitives)

"Semi-parsing" should be correct on any reasonable style of code, but feel free to fail on ugly code, this should be heavily tested.

It should be able to read all code without crashing, but gradually increase error mode for awful code.

`libdparse` has unit tests, steal them; all code MUST not cause a crash
