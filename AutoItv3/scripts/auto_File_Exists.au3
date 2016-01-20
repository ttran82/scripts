#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_File_Exist.exe
Tool to automate: if a file is existed or empty
Input requirement:
   inputfile=<file>	   ;input file
   found=pass/fail     ;make found condition to report a fail or pass condition

Output requirement:
   If pattern is found, program will return "Fail", else return "Passed"
#ce

;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>

;Global Defintions unique to this script only

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.
;Here is the example
$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Check if a file is existed or not (include zero bytes)"&@crlf& _
			""&@crlf& _
			@scriptname&" inputfile=<file> found=[pass/fail, default=fail]"&@crlf& _
			"If file exists or file size > 0 => Result = Found.  Based on found condtion, program will fail/pass it"&@crlf& _
			""&@crlf& _
			""


;Main Flow of the program
;Everything starts here
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()
	local $myfile = @WorkingDir&"\"&$inputfile
	if (FileExists($myfile) and (FileGetSize($myfile) > 0))  Then
		KConsoleWrite($myfile & " contains "& FileGetSize($myfile),0)
		if eval("found") = "fail" Then
			$programExitCode=1
		EndIf
	EndIf
EndFunc


Func CheckArguments()
	;This check is standard.  Do not change
	if isDeclared ("usage") Then
		;this is the only time you will use consolewrite.  After Programe start, use Kconsolewrite will write to log
		;this is for klever GUI script display function use
		consoleWrite($usageMsg)
		Exit
	EndIf
	;This is your check.  Any arguments that you needed for your program to run
	if not isDeclared("inputfile") Then
		KConsoleWrite("Missing Parameters",1)
	EndIf

	if not isDeclared("found") Then
		Global $found = "fail"
	EndIf

EndFunc