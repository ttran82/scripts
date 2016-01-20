#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_grep.exe
Tool to automate: customized search using gnu grep.exe tool
Argument Requirements:
	<require argument>
   [optional argument]
Input requirement:
   inputFile=[txt file]
   ignoreCase=[yes/no]
   searchPattern=[txt;txt;txt]
Output requirement:
   outputFile=[default={scriptname}.out]
Expected Behavior:
   If searchPattern is found -> passed
   If searchPattern is not found -> failed
#ce
;Standard normal included definitions
;Standard Common Scripting library
#include <WindowsConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <..\KleverLib.au3>

;Global Common Defintions

;Global Defintions unique to this script only

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.

Global $usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Run multiple search patterns on a text file using grep.exe"&@crlf& _
			""&@crlf& _
			@scriptname&" inputfile=<inputfile> searchPattern=<1;2;3;4> outputFile=[outputFile]"&@crlf& _
			""&@crlf& _
			" <inputfile>"&@TAB&"(Required) Any txt file."&@crlf& _
			@TAB&@TAB&"If inputfile is not provided, program will attempt to read current working folder\LAST file and get the last line to make that your inputfile." &@crlf& _
			" <searchPattern>"&@TAB&"Multiple patterns can be separated by using ;"&@crlf& _
			" [grepOption]"&@TAB&"(Optional) Any standard grep option.  Defaul = -m 1.  More details can be found by grep.exe --help in cmd."&@crlf& _
			" [outputFile]"&@TAB&"(Optional) output *.out file name"&@crlf& _
			" [grepFound]"&@TAB&"(Optional) 1/0.  Default = 1.  Determine whether to pass/fail when pattern is found."&@crlf& _
			""

;Flow of the main program
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()
	Local $myCmd = "grep.exe"
	Local $greptmp = "grep.out"
	Local $myToolsDir = EnvGet("KaffeineHome") & "\Tools"

	Local $grepCmd = $myToolsDir & "\" & $myCmd

	;Reading in search patterns
	Local $searchArray = StringSplit(Eval("searchPattern"), ";")
	Local $subArray, $readArray, $subreadArray = 0
	Local $subx, $suby
	Local $readx, $ready
	If IsArray($searchArray) Then
		For $i = 1 to $searchArray[0]
			;strip and leading and trailing whitespaces
			$searchArray[$i] = StringStripWS($searchArray[$i], 3)
			Kconsolewrite("Searching for: " & $searchArray[$i], 0, 2)
			$subArray = StringSplit($searchArray[$i], ":")
			If $subArray[0] > 1 Then
				$subx = $subArray[1]
				$suby = $subArray[2]
				$grepCmd = "grep.exe " & Eval("grepOption") & " " & $subx & " " & Eval("inputFile") & " > " & $greptmp

				;Remove any previous grep.out
				FileDelete(@WorkingDir & "\" & $greptmp)
				RunCommand($grepCmd, @WorkingDir)
				If _FileReadToArray(@WorkingDir & "\" & $greptmp, $readArray) Then
					$readArray[1] = StringStripWS($readArray[1], 3)
					Kconsolewrite("Found: " & $readArray[1], 0, 2)
					;check if it is what we're looking for
					If StringCompare($searchArray[$i], $readArray[1]) = 0 Then
						KConsoleWrite("Search matched - Expecting: " & $searchArray[$i] & ", Found: " &  $readArray[1], 0, 2)
						FileWriteLine(Eval("outputFile"), $readArray[1] & @CRLF)
					Else
						KConsoleWrite("Search mismatched - Expecting: " & $searchArray[$i] & ", Found: " & $readArray[1])
						FileWriteLine(Eval("outputFile"), "Search mismatched - Expecting: " & $searchArray[$i] & ", Found: " & $readArray[1] & @CRLF)
						$programExitCode = 1
					EndIf

				Else
					Kconsolewrite("Search failed looking for: " & $subx)
					$programExitCode = 1
				EndIf

			Else;will able to tell the difference
				;proceed to normal grep without giving the difference
				$grepCmd = "grep.exe " & Eval("grepOption") & " " & $searchArray[$i] & " " & Eval("inputFile") & " > " & $greptmp
				FileDelete(@WorkingDir & "\" & $greptmp)
				RunCommand($grepCmd, @WorkingDir)
				If _FileReadToArray(@WorkingDir & "\" & $greptmp, $readArray) Then
					$readArray[1] = StringStripWS($readArray[1], 3)
					KConsoleWrite("Search matched - Expecting: " & $searchArray[$i] & ", Found: " & $readArray[1])
					FileWriteLine(Eval("outputFile"), $readArray[1] & @CRLF)
				Else
					Kconsolewrite("Search failed looking for: " & $searchArray[$i])
					FileWriteLine(Eval("outputFile"), "Search failed looking for: " & $searchArray[$i] & @CRLF)
					$programExitCode = 1
				EndIf

			EndIf

			$readArray = 0

		Next

		If Eval("grepFound") = 0 Then
			$programExitCode = BitXOR($programExitCode, 1)
		EndIf

	Else
		KConsoleWrite("Errored parsing search patterns", 1)
	EndIf
EndFunc

;Function Definitions
Func CheckArguments()
	;This check is standard.  Do not change
	if isDeclared ("usage") Then
		;this is the only time you will use consolewrite.  After Programe start, use Kconsolewrite will write to log
		consoleWrite($usageMsg)
		Exit
	EndIf

	;My argument checks start here
	if not isDeclared("inputFile") Then
		KConsoleWrite("User did not provide inputFile.", 1)
	EndIf

	KFileExists(Eval("inputFile"))

	if not IsDeclared("searchPattern") Then
		KConsoleWrite("User did not provide any search patterns.", 1)
	EndIf

	if not IsDeclared("outputFile") Then
		AssignVariable("outputFile", @ScriptName&".out")
	EndIf

	if not IsDeclared("grepOption") Then
		AssignVariable("grepOption", "-m 1")
	EndIf

	if not IsDeclared("grepFound") Then
		AssignVariable("grepFound", 1)
	EndIf
EndFunc























