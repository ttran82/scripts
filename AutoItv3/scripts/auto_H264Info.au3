#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_h264info.exe
Tool to automate: H264info.exe tool
Argument Requirements:
	<require argument>
   [optional argument]
Input requirement:
   inputFile=[captured file]
   processDur=[5 seconds default] ;since this tool will take very long time depend of captured duration, it is recommended to have a default processDur to stop the analysis.
Output requirement:
   outputFile=[default={scriptname}.out]
#ce
;Standard normal included definitions
;Standard Common Scripting library
#include <WindowsConstants.au3>
#include <File.au3>
#include <Array.au3>
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

Global $usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Decode NAL packet Info of H264 ES."&@crlf& _
			""&@crlf& _
			@scriptname&" inputfile=<inputfile> outputFile=[outputFile]"&@crlf& _
			""&@crlf& _
			" <inputfile>"&@TAB&"(Required).  Will take *.mv4 file.  If input is .ts file, the program will run m2toes to get *.mv4"&@crlf& _
			@TAB&@TAB&"If inputfile is not provided, program will attempt to read current working folder\LAST file and get the last line to make that your inputfile." &@crlf& _
			" [processDur]"&@TAB&"(Optional) default = 5 seconds.  Since the analysis can take very long, this option will limit the analysis time."&@crlf& _
			" [outputFile]"&@TAB&"(Optional) default output to *.H264Info.log file name"&@crlf& _
			""

;Flow of the main program
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()
	Global $myCmd = "h264info.exe"
	Global $myCmdLog = "h264info.log"
	Global $myCmdIni = "h264info.ini"
	Local $myToolsDir = EnvGet("KaffeineHome") & "\Tools"

	Global $H264InfoCmd = $myToolsDir & "\" & $myCmd
	Global $H264InfoLog = $myToolsDir & "\" & $myCmdLog
	Global $H264InfoIni = $myToolsDir & "\" & $myCmdIni

	SetupH264Info()
	RunH264Info(@WorkingDir& "\" & Eval("inputFile"))

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
		KConsoleWrite("User did not provide inputFile.  The program will get file from LAST file", 0, 2)
		AssignVariable("inputFile", GetLastItem())

		If KFileExists(eval("inputFile")) Then
			KConsoleWrite("Found latest file from LAST file: " &eval("inputFile")& " will be used as inputFile.", 0, 2)
		Else
			KConsoleWrite("Problem getting valid inputfile: "&eval("inputFile")& " from LAST file.", 1)
		EndIf
	EndIf
	KFileExists(Eval("inputFile"))

	if not IsDeclared("outputFile") Then
		AssignVariable("outputFile", @ScriptName&".H264Info.log")
	EndIf

	if not IsDeclared("processDur") Then
		AssignVariable("processDur", 5)
	EndIf

EndFunc

Func SetupH264Info()
	;First check if cmd exists
	If Not FileExists($H264InfoCmd) Then
		KConsoleWrite($H264InfoCmd&" is not found.",1)
	EndIf
	KConsoleWrite("H264Cmd: " & $H264InfoCmd,0,2)
	KConsoleWrite("H264Ini: " & $H264InfoIni,0,2)
	KConsoleWrite("InputFile: " & @WorkingDir& "\" & Eval("inputFile"), 0, 2)

	;First determine if the input file is *.mv4
	if StringRegExp(Eval("inputFile"), ".mv4") = 1 Then
		;
	Else
		KConsoleWrite("Provided input is a TS file - will need to run m2toes to find any VES.")
		;Need to run m2toes to split the video elementary stream
		local $mycommand = "auto_m2toes.exe inputFile="&Eval("inputFile")
		RunCommand($mycommand, @WorkingDir, 1)
		; Shows the filenames of all files in the current directory.
		Local $search = FileFindFirstFile("*.mv4")
		; Check if the search was successful
		If $search = -1 Then
			KConsoleWrite("Did not find any VES in file: " & Eval("inputFile"),1)
		EndIf
			AssignVariable("inputFile", FileFindNextFile($search))
		FileClose($search)
		KConsoleWrite("Found VES: " & EnvGet("inputFile"))
	EndIf

	;Write a new H264ini
	WriteH264Ini($myCmdIni, EnvGet("inputFile"))
	FileCopy (@WorkingDir&"\"&$myCmdIni, $H264InfoIni, 1)

	;Preparing a new H264Info log
	FileCopy ($H264InfoLog, $H264InfoLog&".old", 1)
	FileDelete($H264InfoLog)

EndFunc

Func WriteH264Ini($inifile, $inputfile)
	AssignVariable("H264InfoOutput",  @WorkingDir& "\H264Info.out")
	local $fd = KFileOpen($inifile, 2)
	FileWrite($fd, "[Paths]" & @CRLF)
	FileWrite($fd, "InputPath=" & @WorkingDir & "\" & $inputfile & @CRLF)
	FileWrite($fd, "OutputPath=" & Eval("H264InfoOutput") & @CRLF)
	FileClose($fd)
EndFunc

;Launch MPEG2 TS Anlayzer providing input file
Func RunH264Info($infile)
	;Closing any current open programs
	Global $title = "H264info alpha .26"
	Global $errortitle = "h264info"
	KWinClose($title)

	local $cleartogo = 1

	;Running new instance of the program
	KConsoleWrite("Running H264Info GUI Analysis...")
	local $programid = Run($H264InfoCmd)
	local $programwhdl = WinWaitActive($title)

	;Click on open icon
	KWinActivate($title)
	local $inputpath = ControlGetText($title, "", "[CLASS:Edit; INSTANCE:1]")
	If StringCompare($inputpath, $infile, 2) <> 0  Then
		Kconsolewrite("Inputfile is not the same: " & $infile & " " & $inputpath)
		$programExitCode = 1
		$cleartogo = 0
	EndIf
	local $outputpath = ControlGetText($title, "", "[CLASS:Edit; INSTANCE:2]")
	If StringCompare($outputpath, Eval("H264InfoOutput"), 2) <> 0 Then
		Kconsolewrite("Outputfile is not the same: " & Eval("H264InfoOutput") & " " & $outputpath)
		$programExitCode = 1
		$cleartogo = 0
	EndIf

	If $cleartogo == 1 Then
		KControlCheck( ControlClick($title, "",  "[CLASS:Button; INSTANCE:3]", "left"), "Click Start Button")

		Local $counter = 0

		While $counter < Eval("processDur")
			If WinExists($errortitle) Then
				KControlCheck( ControlClick($errortitle, "",  "[CLASS:Button; INSTANCE:1]", "left"), "Click OK Button")
			EndIf

			Sleep(1000)

			If WinExists($errortitle) Then
				KControlCheck( ControlClick($errortitle, "",  "[CLASS:Button; INSTANCE:1]", "left"), "Click OK Button")
			EndIf
			$counter = $counter + 1
		WEnd

		;KWinActivate($title)
		ControlFocus($title, "", "[CLASS:Button; INSTANCE:11]")
		KControlCheck( ControlClick($title, "",  "[CLASS:Button; INSTANCE:11]", "left"), "Click Abort Button")
	EndIf

	WinWaitActive($title)
	KWinClose($title)
	WinWaitClose($title)

	While WinExists($title)
		Sleep(500)
		KWinClose($title)
	WEnd


	;copy log file back to workingdir
	FileCopy($H264InfoLog, @WorkingDir&"\"&Eval("outputFile"))
	KConsoleWrite("Done!")
EndFunc
























