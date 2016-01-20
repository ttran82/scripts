#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_mpeg_ts_analyzer.exe
Tool to automate: imacros via Object creation
Argument Requirements:
	<require argument>
   [optional argument]
Input requirement:
   inputFile=<Name of the file to be analyzed.>
Output requirement:
   outputFile=[default={scriptname}.out]
#ce
;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>
#include <..\KleverWinLib.au3>

;Global Common Defintions

;Global Defintions unique to this script only

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.
;Here is the example
$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Analysis of a transport stream file using MPEG TS Analyzer"&@crlf& _
			""&@crlf& _
			" Get Syntax: use this to set values from encoder under test"&@crlf& _
			"   "&@scriptname&" inputFile=<Name of the ts file> outputFile=[Name of the analysis output]"&@crlf& _
			""&@crlf& _
			" inputFile"&@TAB&"[Optional] File name of the transport stream to be analyzed. Default=[LAST] recorded file."&@crlf& _
			" outputFile"&@TAB&"(Optional) This file contains the output of the analysis Default=["& @ScriptName &".out"&@crlf& _
			" videoPid"&@TAB&"(Optional} This parameter tells what video PID to analyze. Default=32"&@crlf& _
			" [Comparison]"&@TAB&"(Optional) Comparison options: equal,lessthan,lessthanequal,greater,greaterequal."&@crlf& _
			@TAB&@TAB&"This option requires Pattern option to be defined"&@crlf& _
			" [Pattern]"&@TAB&@TAB&"If Comparison is declared then (Required) Define AFD Value to search. [active_format: 4]"&@crlf& _
			@TAB&@TAB&"AFD value i.e. active_format: AFD should be in decimal."&@crlf& _
			" [auDescriptorCheck]"&@TAB&"(Optional) yes/no.  Will check SCTE128 au descriptor semantics"&@crlf& _
			""

;Main Flow of the program
;Everything starts here

;This argument checks for the parameters which should not be a part of iimSet command.


;This CheckArguments functions is where you determine if those parsed arguments satisfy your input and output requirements
CheckArguments()

;Program Start
ProgramStart()

;Your main program
main()

;Program End
ProgramEnd()


Func CheckArguments()
	;This first check is standard and is required in every scripts
	If isDeclared ("usage") Then
		consoleWrite($usageMsg)
		Exit
	EndIf

	;Your checks start here

	;Checking imacrosFile
	if not isDeclared("inputFile") Then
		KConsoleWrite("User did not provide inputFile.  The program will get file from LAST file")
		Global $inputFile = GetLastItem()
	EndIf

	If StringRegExp(eval("inputFile"),'\\',0) = 0 Then
		Assign("inputFile", @WorkingDir & "\"  & eval("inputFile"), 2)
	EndIf

	If KFileExists(eval("inputFile")) Then
		KConsoleWrite("Found file from LAST file: " &eval("inputFile")& " will be used as inputFile.")
	Else
		KConsoleWrite(eval("inputFile")& " does not exist.", 1)
	EndIf

	;Checking Output Options
	if Not IsDeclared("outputFile") Then
		Assign("outputFile", @ScriptName & ".out", 2)
	EndIf

	;Checking Video Pid option
	if Not IsDeclared("videoPid") Then
		Assign("videoPid", "32", 2)
	EndIf

	;Checking comparision option
	if IsDeclared("Comparison") Then
		if Not IsDeclared("pattern") Then
			KConsoleWrite("Pattern to be validated is not declared", 1)
		EndIf
	EndIf
EndFunc


Func main()

	Global $title = "MPEG-2 TS packet analyser"
	Global $program = $kleverCommonScriptsDir & "\MPEG-2 TS packet analyser.exe"
	Global $foundpattern = 0

	;Closing any current open programs
	KWinClose($title)

	;Running new instance of the program
	local $programid = Run($program)
	local $programwhdl = WinWaitActive($title)

	;Click on open icon
	KWinActivate($title)
	KControlCheck( ControlClick($title, "", "[NAME:ToolStrip1]", "left", 1, 12, 12), "Click Open File Icon")

	;Open Windows Controls
	local $openwhdl = WinWaitActive("Open","Files of &type:")
	KControlCheck( ControlSetText("Open", "Files of &type:",  "[CLASS:Edit; INSTANCE:1]", eval("inputFile")), "Type file name on open dialog")
	If @OSVersion = "WIN_7" Then
		KControlCheck( ControlClick("Open", "Files of &type:",  "[CLASS:Button; INSTANCE:1]", "left"), "Click OK on open file dialog")
	Else
		KControlCheck( ControlClick("Open", "Files of &type:",  "[CLASS:Button; INSTANCE:2]", "left"), "Click OK on open file dialog")
	EndIf

    ;Click on Filter option: Payload and Pid
	KWinActivate($title)
	KControlCheck( ControlClick($title, "", "[NAME:cboxPayloadStart]", "left"), "Select Payload Checkbox.")
	KControlCheck( ControlClick($title, "", "[NAME:cboxPID]", "left"), "Select Pid CheckBox.")
	KControlCheck( ControlSetText($title, "", "[NAME:tbPidFilter]", eval("videoPid")), "Enter Video Pid value.")

	if IsDeclared("Comparison") Then
		SearchPacket(eval("pattern"))
		SearchOutputFile()
	EndIf

	if IsDeclared("auDescriptorCheck") Then
		SearchPacket("Transport_private_data_length:")
		CheckAuDescriptor()
	EndIf

	KWinActivate($title)
	WinClose($title)
EndFunc

Func CheckAuDescriptor()
	If $foundpattern == 1 Then
		;decoding au descriptor semantics
		;first extract all 12 digits from the private data section
		GrepSearch(eval("outputFile"), "private_data_byte:")
		local $myfile = eval("outputFile") & ".grep"
		;process the grep file
		local $myarray = KFileReadToArray($myfile)
		local $datastr = ""
		If(isarray($myarray)) then
			For $arrayIndex = 1 to $myarray[0]
				;strip any leading and trailing spaces
				$myarray[$arrayIndex] = StringStripWS ( $myarray[$arrayIndex], 8 )
				$myarray[$arrayIndex] = StringReplace($myarray[$arrayIndex], "private_data_byte:", "")
				$myarray[$arrayIndex] = Hex($myarray[$arrayIndex], 2)
				;KConsoleWrite($myarray[$arrayIndex])
				$datastr = $datastr & $myarray[$arrayIndex]
			Next

			;now call the scte128 semantics decoder
			local $cmd = "auto_au_decode.exe"
			local $mycmd = $cmd & " privateData=" & $datastr
			RunCommand($mycmd, @WorkingDir, 1)

		EndIf
	Else
		KConsoleWrite("au Descriptor is not found in the capture stream.")
		$programExitCode=1
	EndIf

EndFunc


Func SearchPacket($findtext)
	;Click on Next Package
	KWinActivate($title)

	;Try searching for matching pattern 5 times
	Local $hFileOpen = FileOpen(eval("outputFile"), $FO_APPEND)
	local $count = 5
	While 1
		If $count = 0 Then ExitLoop
		KControlCheck( ControlClick($title, "", "[NAME:ToolStrip1]", "left", 1, 85, 12), "Click on Next Packet Arrow.")
		local $mytext = ControlGetText($title, "", "[NAME:viewer]")
		;local $afdtxt = "AFD start code"
		if StringInStr($mytext,$findtext) Then
			$programExitCode=0
			;FileWriteLine($outputFile, ControlGetText($title, "", "[NAME:viewer]"))
			;FileWriteLine(eval("outputFile"), $mytext)
			FileWriteLine($hFileOpen, $mytext)
			KConsoleWrite("Pattern found" , 0, 2)
			$foundpattern = 1
			ExitLoop
		Else
			;FileWriteLine(eval("outputFile"), $mytext)
			FileWriteLine($hFileOpen, $mytext)
			$programExitCode=1
		EndIf
		$count = $count - 1
	WEnd
	FileClose($hFileOpen)

EndFunc

Func SearchOutputFile()
	if IsDeclared("Comparison") Then

		Switch eval("Comparison")
			Case "equal"
				$found = GrepSearch(eval("outputFile"), eval("pattern"))
				if $found = 0 Then
					KConsoleWrite(eval("pattern") & " is not found.")
					$programExitCode=1
				EndIf
			Case "lessthan"
			Case "lessthanequal"
			Case "greater"
			Case "greaterequal"
			Case Else
				KConsoleWrite("Invalid Compare option: "&eval("Comparison"),1)
		EndSwitch
	EndIf
EndFunc