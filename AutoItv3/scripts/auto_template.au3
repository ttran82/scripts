#cs
Provided Script requirement as requested by QA Team
ScriptName: klever_template
Tool to automate: for example m2toes.exe
Input requirement:
   arg1=<value1>, arge2=<value2>, outputFile=[value3], arg4=[value4]
   <require argument>
   [optional argument]
Output requirement:
   If outputFile is not provided, the default outputFile will be @scriptname.ts
   Otherwise, output file will be from provide argument
   After captured is produced, will check if the captured file is compliant
   Return Pass/Fail based on compliant result
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
			@scriptname&@TAB&"Records a stream using vlc."&@crlf& _
			""&@crlf& _
			@scriptname&" arg1=<value1>, arg2=<value2>, outputFile=[value3]"&@crlf& _
			""&@crlf& _
			" <value1>"&@TAB&"Value 1"&@crlf& _
			" <value2>"&@TAB&"Value 2"&@crlf& _
			""


;Main Flow of the program
;Everything starts here

;This CheckArguments functions is where you determine if those parsed arguments satisfy your input and output requirements
CheckArguments()

;Program Start
ProgramStart()

;Your main program
main()

;Program End
ProgramEnd()

func main()
	MyStep(1)
	MyStep(2)
	MyStep(3)
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
	if not isDeclared("arg1") or not IsDeclared("arg2") Then
		KConsoleWrite("Missing Parameters",1)
	EndIf
EndFunc

Func Mystep($var)
	KConsoleWrite($var)
EndFunc
