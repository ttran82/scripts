#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_sikuli.exe
Input requirement:
   sikuliScriptName
Output requirement:

sikuliHome = c:\sikuliX1.1
javaExe = "C:\Program Files\Java\jre7\bin\java.exe"

#ce

;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>

;Global Defintions unique to this script only
Global $argToJava = ""

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.
;Here is the example
$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Detect if a Putty Security Window is present and automatically anser YES"&@crlf& _
			""&@crlf& _
			@scriptname&" sanity.sikuli arg1=value1 arg2=value2 arg3=value3"&@crlf& _
			""&@crlf& _
			" <sikuliScriptName>"&@TAB& "Full path to Sikuli script to be executed.  If not, it will be currentscriptDir\scriptname."&@crlf& _
			" <sikuliHome>"&@TAB& "Sikuli binary home dir.  Default = C:\SikuliX1.1"&@crlf& _
			" <sikuliScriptDir>"&@TAB& "Sikuli scripts home dir.  Default = KleverTestScriptsdir\sikuli"&@crlf& _
			" [sikuliOutputFile]"&@TAB& "(Optional) Output from sikuli executable."&@crlf& _
			" [javaBinDir]"&@TAB& "(Optional)  Path to current java.exe binary"&@crlf& _
			" [...]"&@TAB&"Argument list that will pass on to sikuli script as arguments"&@crlf& _
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
	RunSikuliScript()
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
	CheckMissingArgument("sikuliHome")
	CheckMissingArgument("javaExe")
	CheckMissingArgument("sikuliScriptName")

	;check if the current sikuli scriptname is existed.  If not, find it in currentscriptdir
	local $scriptname = EnvGet("sikuliScriptName")
	If StringRegExp($scriptname,'\\',0) = 0 Then
		If EnvGet("sikuliScriptDir") <> "" Then
			AssignVariable("sikuliScriptName", EnvGet("sikuliScriptDir") & "\"  & $scriptname)
		Else
			AssignVariable("sikuliScriptName", EnvGet("KleverTestScriptsDir") & "\sikuli\"  & $scriptname)
		Endif
	EndIf

	If KFileExists(EnvGet("sikuliScriptName")) Then
		KConsoleWrite("Sikuli script: " & EnvGet("sikuliScriptName") & " is valid.", 0, 2)
	Else
		KConsoleWrite("Invalid sikuli script name.", 1)
	EndIf

	If KFileExists(EnvGet("javaExe")) Then
		KConsoleWrite("Java Exe: " & EnvGet("javaExe")& " is valid.", 0, 2)
	EndIf

	;Checking Output Options
	if Not IsDeclared("sikuliOutputFile") Then
		AssignVariable("sikuliOutputFile", @ScriptName & ".out")
	EndIf

	;Saving command line arguments list
	local $argList = $Cmdline
	If IsArray($argList) Then
		local $arraysize = $argList[0]

		For $i = 1 to $arraysize
			local $mystr = $argList[$i]
			If StringRegExp($mystr, "sikuliScriptName=") = 1 Then
				$argList[$i]=""
			EndIf

			If StringRegExp($mystr, "sikuliScriptDir=") = 1 Then
				$argList[$i]=""
			EndIf

			If StringRegExp($mystr, "javaBinDir=") = 1 Then
				$argList[$i]=""
			EndIf

			If StringRegExp($mystr, "logFile=") = 1 Then
				$argList[$i]=""
			EndIf
		Next

		$argToJava = KArrayToString($argList)
		Kconsolewrite("Arguments to sikuli command: " & $argToJava, 0, 2)

	EndIf

EndFunc

Func KArrayToString($myarray)
	local $mynewstr = ""

	If IsArray($myarray) Then
		If $myarray[0] > 0 Then
			For $i = 1 to $myarray[0]
				If $myarray[$i] <> "" Then
					$iPos = StringInStr($myarray[$i], "=")
					$myarg = StringLeft($myarray[$i], $iPos-1)
					$myvalue = StringMid($myarray[$i], $iPos+1)
					$mynewstr = $mynewstr & " " & $myarg & "=" & chr(34) & $myvalue & chr(34)
				EndIf
			Next
		EndIf
	EndIf
	return $mynewstr
EndFunc

Func RunSikuliScript()
	;check if sikuli.jar is present
	local $sikulijar = EnvGet("sikuliHome") & "\sikulix.jar"
	If KFileExists($sikulijar) Then
		KConsoleWrite("Sikuli jar: " & $sikulijar & " is valid.", 0, 2)
	EndIf

	If EnvGet("logFile") <> "" Then
		AssignVariable("sikuliOutputFile", EnvGet("logFile"))
	EndIf

	local $mycmd = chr(34) & EnvGet("javaExe") & chr(34) & " -jar " & $sikulijar & " -r " & EnvGet("sikuliScriptName") & " -- " & $argToJava & " >> " & EnvGet("sikuliOutputFile")

	RunCommand($mycmd,@WorkingDir)

EndFunc

