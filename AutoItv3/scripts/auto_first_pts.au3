#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_first_pts.exe
Tool to automate: Decoding capture stream and display first pts value of video and audio.
Argument Requirements:
	<require argument>
   [optional argument]
Input requirement:
   data=12 bytes of data in hex to be decode
Output requirement:
   outputFile=[default={scriptname}.out]
#ce
;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>
#include <..\KleverWinLib.au3>
#include <..\KMpegTSLib.au3>

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
			@scriptname&@TAB&"Find first PTS of Video and Audio and display their difference."&@crlf& _
			""&@crlf& _
			@scriptname&" inputFile=[inputfile] videoPid=<vpid> audioPid=<apid> outputFile=[InformFile] "&@crlf& _
			""&@crlf& _
			" inputFile"&@TAB&@TAB&"(Optional) Name of captured file in curent running directory or Full path of the captured file "&@crlf& _
			" videoPid"&@TAB&@TAB&"<Required> Video pid to look for."&@crlf& _
			" audioPid"&@TAB&@TAB&"<Required> Audio pid to look for."&@crlf& _
			" outputFile"&@TAB&"(Optional) This file contains the output of the analysis Default=["& @ScriptName &".out"&@crlf& _
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
	if not isDeclared("inputFile") Then
		KConsoleWrite("User did not provide inputFile.  The program will get file from LAST file", 0, 2)
		local $myfile = GetLastItem()
		Assign("inputFile", $kleverCurrentDir & "\" & $myfile, 2)
		If KFileExists(eval("inputFile")) Then
			KConsoleWrite("Found latest file from LAST file: " &$inputFile& " will be used as inputFile.", 0, 2)
		Else
			KConsoleWrite("Problem getting valid inputfile: "&$inputFile& " from LAST file.", 1)
		EndIf
	EndIf

	If StringRegExp(eval("inputFile"),'\\',0) = 0 Then
		Assign("inputFile", @WorkingDir & "\" & eval("inputFile"), 2)
	EndIf

	If Not FileExists(eval("inputFile")) Then
		KConsoleWrite("Input File: "&eval("inputFile")&" is not existed."&@CRLF,1)
	EndIf

	;Checking Output Options
	if Not IsDeclared("outputFile") Then
		Assign("outputFile", @ScriptName & ".out", 2)
	EndIf

	if Not IsDeclared("videoPid") Then
		KConsoleWrite("Video pid not provided.", 1)
	EndIf

	if Not IsDeclared("audioPid") Then
		KConsoleWrite("Audio pid not provided.", 1)
	EndIf
EndFunc


Func main()
	FindFirstPTS()
EndFunc

Func LogConsoleWrite($text)
	KConsoleWrite($text, 0, 2)
	FileWriteLine(eval("outputFile"), $text)
EndFunc

Func FindFirstPTS()
	;First launch the app and open capture file
	runMPEG2Analyzer(eval("inputFile"))
	local $tempfile = @WorkingDir & "\" & eval("outputFile") & ".temp"

	;first save the final output
	local $mainoutput = Eval("outputFile")

	;Get Video PTS value
	;First check Payload
	Assign("outputFile", @ScriptName & ".videopts.out", 2)
	SelectFilterPayload()
	;Then select pid filter
	SelectFilterPid()
	;Enter video pid value
	EditFilterPid(eval("videoPid"))
	SearchNextPacket("PTS:")
	local $videopts = GetPTSValue()
	local $videopts_sec = Round($videopts/90000, 3)
	KConsoleWrite("Found First Video PTS: " & $videopts, 0, 2)

	;Get Audio PTS value
	Assign("outputFile", @ScriptName & ".audiopts.out", 2)
	GotoFirstPacket()
	EditFilterPid(eval("audioPid"))
	SearchNextPacket("PTS:")
	local $audiopts = GetPTSValue()
	local $audiopts_sec = Round($audiopts/90000, 3)
	KConsoleWrite("Found First Audio PTS: " & $audiopts, 0, 2)

	Assign("outputFile", $mainoutput, 2)
	local $avdiff = Round(($audiopts_sec - $videopts_sec),3)
	KConsoleWrite("AudioPTS:" & $audiopts_sec & ", " & "VideoPTS:" & $videopts_sec)
	LogConsoleWrite("A/V Diff:" & $avdiff)

	If ($avdiff > 0) Then
		$programExitCode = 1;
		KConsoleWrite("Audio PTS is behind video PTS")
	EndIf

	If (abs($avdiff) > 4) Then
		$programExitCode = 1;
		KConsoleWrite("A/V PTS diff is more than 4 seconds.")
	EndIf

	KWinClose($title)
EndFunc

;Search temp from MPEG TS Analyzer output
Func GetPTSValue()

	local $value = ""

	If $foundpattern == 1 Then
		;decoding au descriptor semantics
		;first extract all 12 digits from the private data section
		GrepSearch(eval("outputFile"), "PTS:")
		local $myfile = eval("outputFile") & ".grep"
		;process the grep file
		local $myarray = KFileReadToArray($myfile)
		local $datastr = ""
		If(isarray($myarray)) then
			$value = $myarray[1]
			$value = StringStripWS ( $value, 8 )
			$value = StringReplace($value, "PTS:", "")
		EndIf
	Else
		KConsoleWrite("PTS is not found in the capture stream.", 1)
	EndIf

	return $value
EndFunc
