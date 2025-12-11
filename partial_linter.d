#!/usr/bin/dmd
/**
*	partial_linter	-	A	non-destructive	linter	using	semi-parse	for	easy	rules
*
*	This	linter	handles	the	easiest	rules	non-destructively	by	using
*	the	semi-parser	to	identify	code	constructs	and	check	for	violations.
*	Max	300	lines	of	code	as	requested.
*/

import	std.stdio;
import	std.file;
import	std.string;
import	std.array;
import	std.algorithm	:	strip;
import	semiparse	:	SemiParser,	ConstructType,	ErrorMode;

//---
//	Types	and	Constants
//---

struct	LintMessage	{
	size_t	line;
	string	message;
	string	severity;	//	"error",	"warning",	or	"info"
}

struct	LintResult	{
	string	filename;
	LintMessage[]	messages;
	bool	hasErrors;
}

//---
//	Functions
//---

LintResult	lintFile(string	filename)	{
	LintResult	result;
	result.filename	=	filename;

	try	{
		string	content	=	cast(string)std.file.read(filename);
		SemiParser	parser	=	new	SemiParser();
		auto	constructs	=	parser.parse(content);
		auto	errors	=	parser.getErrors();

		string[]	lines	=	content.split("\n");

		//	Check	for	shebang	on	first	line
		if	(lines.length	>	0	&&	!lines[0].startsWith("#!"))	{
			result.messages	~=	LintMessage(1,	"File	must	start	with	shebang	#!",	"error");
			result.hasErrors	=	true;
		}

		//	Check	for	access	modifier	keyword	usage
		for	(size_t	i	=	0;	i	<	lines.length;	i++)	{
			//	Skip	comment	lines	that	contain	the	access	modifier	keyword
			//	Manually	trim	leading	and	trailing	whitespace
			size_t	start	=	0;
			while	(start	<	lines[i].length	&&	(lines[i][start]	==	'	'	||	lines[i][start]	==	'\t'	||	lines[i][start]	==	'\n'	||	lines[i][start]	==	'\r'))	{
				start++;
			}
			size_t	end	=	lines[i].length;
			while	(end	>	start	&&	(lines[i][end-1]	==	'	'	||	lines[i][end-1]	==	'\t'	||	lines[i][end-1]	==	'\n'	||	lines[i][end-1]	==	'\r'))	{
				end--;
			}
			auto	line	=	lines[i][start	..	end];
			if	(line.length	>=	2	&&	line[0]	==	'/'	&&	line[1]	==	'/')	continue;	//	Skip	single-line	comments
			if	(line.length	>=	2	&&	line[0]	==	'/'	&&	line[1]	==	'*')	continue;	//	Skip	multi-line	comment	starts
			if	(line.length	>=	2	&&	line[$-2]	==	'*'	&&	line[$-1]	==	'/')	continue;	//	Skip	multi-line	comment	ends

			//	Split	by	spaces	and	check	each	part	for	the	private	keyword
			auto	parts	=	line.split("	");
			foreach(part;	parts)	{
				//	Remove	common	punctuations	from	the	start	and	end	of	the	part
				while	(part.length	>	0	&&	(part[0]	==	'('	||	part[0]	==	'{'	||	part[0]	==	'['	||	part[0]	==	','	||	part[0]	==	';'))	{
					part	=	part[1	..	$];
				}
				while	(part.length	>	0	&&	(part[$-1]	==	')'	||	part[$-1]	==	'}'	||	part[$-1]	==	']'	||	part[$-1]	==	','	||	part[$-1]	==	';'	||	part[$-1]	==	'.'))	{
					part	=	part[0	..	$-1];
				}
				//	Check	if	part	is	exactly	"private"
				if	(part	==	"private")	{
					result.messages	~=	LintMessage(i	+	1,	"Found	'private'	keyword	which	should	not	exist	in	codebase",	"error");
					result.hasErrors	=	true;
					break;	//	Exit	inner	loop	once	we	find	it
				}
			}
		}

		//	Check	for	tab	usage	vs	space	indentation
		for	(size_t	i	=	0;	i	<	lines.length;	i++)	{
			if	(lines[i].length	>	0	&&	lines[i][0]	==	'	')	{
				result.messages	~=	LintMessage(i	+	1,	"Using	spaces	for	indentation	instead	of	tabs",	"error");
				result.hasErrors	=	true;
			}
		}

		//	Check	for	std.*	import	simplification
		for	(size_t	i	=	0;	i	<	lines.length;	i++)	{
			if	(lines[i].indexOf("import	std.")	!=	-1	&&
				lines[i].indexOf("std.stdio")	!=	-1)	{
				result.messages	~=	LintMessage(i	+	1,	"Consider	simplifying	'std.stdio'	import",	"warning");
			}
		}

		//	Check	for	error	modes	from	semiparse
		for	(size_t	i	=	0;	i	<	errors.length;	i++)	{
			switch(errors[i])	{
				case	ErrorMode.minorFormatIssue:
					result.messages	~=	LintMessage(i	+	1,	"Minor	format	issue	detected	by	semiparse",	"warning");
					break;
				case	ErrorMode.suspiciousConstruct:
					result.messages	~=	LintMessage(i	+	1,	"Suspicious	construct	detected	by	semiparse",	"warning");
					break;
				case	ErrorMode.severeMalformation:
					result.messages	~=	LintMessage(i	+	1,	"Severe	malformation	detected	by	semiparse",	"error");
					result.hasErrors	=	true;
					break;
				case	ErrorMode.potentialSecurityRisk:
					result.messages	~=	LintMessage(i	+	1,	"Potential	security	risk	detected	by	semiparse",	"error");
					result.hasErrors	=	true;
					break;
				default:
					//	Nothing	for	ErrorMode.none
					break;
			}
		}

		//	Additional	checks	using	semiparse	constructs
		foreach(construct;	constructs)	{
			//	Check	for	immutable/const	usage	in	small	definitions
			if	(construct.type	==	ConstructType.smallDefinition)	{
				if	(construct.content.indexOf("immutable	")	!=	-1)	{
					result.messages	~=	LintMessage(construct.lineStart	+	1,
						"Immutable	keyword	found,	consider	if	it	should	be	used",	"warning");
				}
				if	(construct.content.indexOf("const	")	!=	-1)	{
					result.messages	~=	LintMessage(construct.lineStart	+	1,
						"Const	keyword	found,	consider	if	it	should	be	used",	"warning");
				}
			}
		}

	}	catch	(Exception	e)	{
		result.messages	~=	LintMessage(0,	"Error	reading	file:	"	~	e.msg,	"error");
		result.hasErrors	=	true;
	}

	return	result;
}

int	main(string[]	args)	{
	if	(args.length	<	2)	{
		writeln("Usage:	partial_linter	<file1.d>	[file2.d	...]");
		return	1;
	}

	LintResult[]	allResults;

	//	Process	each	D	file	argument
	foreach	(filename;	args[1	..	$])	{
		if	(filename.endsWith(".d"))	{
			auto	result	=	lintFile(filename);
			allResults	~=	result;

			//	Print	results	for	this	file
			if	(result.messages.length	>	0)	{
				writeln("Results	for	",	result.filename,	":");
				foreach	(msg;	result.messages)	{
					writeln("	[",	msg.severity,	"]	Line	",	msg.line,	":	",	msg.message);
				}
				writeln();
			}	else	{
				writeln("No	issues	found	in	",	filename);
			}
		}
	}

	//	Summary
	size_t	totalErrors	=	0;
	size_t	totalWarnings	=	0;

	foreach(result;	allResults)	{
		foreach(msg;	result.messages)	{
			if	(msg.severity	==	"error")	totalErrors++;
			else	if	(msg.severity	==	"warning")	totalWarnings++;
		}
	}

	writeln("Summary:	",	totalErrors,	"	errors,	",	totalWarnings,	"	warnings	across	all	files.");

	return	(totalErrors	>	0)	?	1	:	0;
}