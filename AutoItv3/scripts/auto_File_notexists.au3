#cs
Provided Script requirement as requested by QA Team
ScriptName: klever_exist.exe
Tool to automate: if a file is existed
Input requirement:
   inputfile=<file>

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
			@scriptname&@TAB&"Check if a file is existed"&@crlf& _
			""&@crlf& _
			@scriptname&" inputfile=<file>"&@crlf& _
			"If file does not exist or file size = 0 => Result = Passed.  Else, Result = Failed"&@crlf& _
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
		KConsoleWrite($myfile & "contains "& FileGetSize($myfile),0)
		$programExitCode=1
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
EndFunc