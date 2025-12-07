linter for dlang
for monkyyy, research me "crazymonkyyy" on github

MUST: actively modify the file
SHOULD: warning, consider permissive tests

running:
the first line of all files MUST be #!
#! SHOULD be a dmd or opend command
Use -i as is, dont use dub

whitespace:
MUST BE tabs over spaces
spaceing SHOULD be conceptual
several lines of `}` are silly

imports:
SHOULD be at the top of the file
if import std.* is called it SHOULD be just whatever at the top

antiwork keywords:
private MUST NOT exist in code base
immutable, const SHOULD NOT be
udas should be kept to a minimum and be functional

sections:
`//---` SHOULD break up sections; possible sections inlucde

	- types and constants
	- functions
	- main
	- unittests

	Admit fault:
	comments are for two things, temp code, saying sorry for failure
	saying sorry should be easily grepable with the following keywords
	"BAD" "HACK" "RANT"
	all comments MUST be ddoc or `//BAD:` or have a ';' or function call (detectable with '.' or '()'s)

Code deduping:
all files in the project MUST NOT be line by line identical, and yes im saying that with MUST intentionally with deleting it
all file in the project SHOULD NOT be extremely similar
