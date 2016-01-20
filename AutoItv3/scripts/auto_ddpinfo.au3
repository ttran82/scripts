#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_ddpinfo.exe
Tool to automate: ddpinfo.exe
Parameter requirements:
   inputFile=[captured file/audio file] outputFile=[outputFile]
		*inputFile can be capture.ts files or audio.mpa file.  Default file is 33.mpa
		*outputFile will be default to scriptname.out

Performance requirements:
	This tool will automate ddpinfo.exe process and will output the metadata information to an output file
	Sample command line to run:
	ddpinfo -m0xffff -i33.mpa | head -n 100 > file.out
#ce

;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>
#include <..\KleverHashLib.au3>

;Global Defintions unique to this script only

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.
;Here is the example
$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Analyze dolby audio stream using ddpinfo.exe"&@crlf& _
			""&@crlf& _
			@scriptname&" inputFile=[default=32.mpa] Comparison=[equal] String=[string] Pattern=[string] outputFile=["&@scriptname&".out]"&@crlf& _
			""&@crlf& _
			" [inputFile]"&@TAB&"Can be capture.ts file or audio.mpa file.  Default = 32.mpa"&@crlf& _
			" [Comparison]"&@TAB&"only valid when running with snmpget.  Options: equal,lessthan,greater"&@crlf& _
			" [String]"&@TAB&"Specify the string to query for value.  These strings are based on ddpinfo output."&@crlf& _
			" [Pattern]"&@TAB&@TAB&"Specify the string/number that should be expected.  Options: string/number to compare to"&@crlf& _
			" [outputFile]"&@TAB&"Default outputFile"&@crlf& _
			""


;Main Flow of the program
;Everything starts here

Global $outputHash = _CreateHashTable()

;This CheckArguments functions is where you determine if those parsed arguments satisfy your input and output requirements
CheckArguments()

;Program Start
ProgramStart()

;Your main program
main()

;Program End
ProgramEnd()

func main()
	CheckInputFile()
	RunddpInfo()
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

	if not isDeclared("inputFile") Then
		KConsoleWrite("User did not provide inputFile.  The program will get file from LAST file")
		Assign("inputFile", GetLastItem(), 2)
	EndIf
	If not KFileExists(eval("inputFile")) Then
		KConsoleWrite("Inputfile is not found: "&$inputFile, 1)
	EndIf

	if not isDeclared("outputFile") Then
		Assign("outputFile", @scriptname&".out", 2)
	EndIf

	;Check for Comparison options
	if IsDeclared("Comparison") Then
		if (not IsDeclared("String")) or (not IsDeclared("Pattern")) Then
			KConsoleWrite("Comparison is declared without String and Pattern.",1)
		EndIf
	EndIf
EndFunc

Func RunddpInfo()
	local $ddpinfo = "ddpinfo.exe -m0xffff -i"
	local $ddpinfo_temp = "ddpinfo.temp"
	local $ddpinfo_cmd = $ddpinfo & eval("inputFile") & " | head -n 100 > " & $ddpinfo_temp

	Runcommand($ddpinfo_cmd, @WorkingDir)

	;now we need to trim the ddpinfo output
    ddpInfoOutputCleanup($ddpinfo_temp)

	if IsDeclared("Comparison") Then
		ComparisonCheck()
	EndIf
EndFunc

Func ComparisonCheck()
	KConsoleWrite("Analyzing output based on user input..." , 0)
	;First load ddpinfo output into hash table
	ReadFiletoHash($outputHash,$kleverCurrentDir&"\"&eval("outputFile"),": ")

	local $rvalue = _GetHashItem($outputHash,eval("String"))

	local $result = "Failed"

	Switch eval("Comparison")
		Case "equal"
			if eval("Pattern") = $rvalue Then
				$result = "Passed"
			Else
				$programExitCode=1
			EndIf
		Case "lessthan"
			if int(eval("Pattern")) < int($rvalue) Then
				$result = "Passed"
			Else
				$programExitCode=1
			EndIf
		Case "greater"
			if int(eval("Pattern")) > int($rvalue) Then
				$result = "Passed"
			Else
				$programExitCode=1
			EndIf
		Case Else
			KConsoleWrite("Invalid Compare option: "&eval("Compare"),1)
	EndSwitch

	KConsoleWrite("Expecting " & eval("String") & " " & Chr(34) & eval("Comparison") & Chr(34) & " " & eval("Pattern") & ".  Returned value: " &$rvalue & ".  Result = " & $result , 0)

EndFunc


Func ddpInfoOutputCleanup($file)
	local $tempfile = KFileopen($file,0)
	local $outputhd = FileOpen($kleverCurrentDir&"\"&eval("outputFile"), 2);

	While 1
		$line = FileReadLine($tempfile);
		If @error = -1 Then ExitLoop
		;Skip if line is an empty space
		If StringIsSpace($line) Then ContinueLoop

		; Detecting ~~~~~~~~~~~~~~
		StringRegExp($line, "^~~~~~~~", 1);
		If (@error = 0) Then
			While 1
				local $line = FileReadLine($tempfile)
				If @error = -1 Then ExitLoop

				StringRegExp($line, "^~~~~~~~", 1);
				If @error = 0 Then
					ExitLoop(1);
				EndIf

				$line = StringStripWS($line, 3)

				If not StringIsSpace($line) Then
					;$line = StringRegExpReplace ( $line, ": ", "=", 1)
					FileWriteLine($outputhd, $line);
				EndIf

			WEnd
		EndIf

	WEnd

	FileFlush($outputhd)
	FileClose($outputhd)
	FileClose($tempfile)
EndFunc

Func CheckInputFile()
	If StringRegExp(eval("inputFile"), ".ts") Then
		;First check if it has DD+ audio type
		KConsoleWrite("Checking inputfile for E-AC-3 type.", 0)
		local $mycmd = "auto_MediaInfo.exe Inform=" & Chr(34) & "Audio;%Format%" & Chr(34) & " inputFile=" & eval("inputFile") & " Comparison=equal Pattern=E-AC-3"
		local $test = RunCommand($mycmd, @WorkingDir)
		If $test > 0 Then
			KConsoleWrite(eval("inputFile") & " is not a Dolby Digital Plus file.", 1)
		EndIf

		;Need to run m2toes to extract *.mpa file
		local $m2toes = "auto_m2toes.exe"
		local $m2toes_cmd = $m2toes & " inputFile=" & eval("inputFile")
		Runcommand($m2toes_cmd, @workingdir)
		;Now check if there is any 33.mpa file available
		local $search = FileFindFirstFile("*.mpa")
		If $search = -1 Then
			KConsoleWrite("Cannot find any audio in captured file: "&$inputFile, 1)
		Else
			Assign("inputFile", FileFindNextFile($search), 2)
			KConsoleWrite("Audio file will be used for analysis: "&Eval("inputFile"))
		EndIf

	EndIf

EndFunc
