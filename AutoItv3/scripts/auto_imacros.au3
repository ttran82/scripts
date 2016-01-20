#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_imacros.exe
Tool to automate: imacros via Object creation
Argument Requirements:
	<require argument>
   [optional argument]
Input requirement:
   deviceIp=[ip of device under test, default=getenv[encip]] isVisible=[default] imacrosFile=<imacros script> extractOption=[default]  arg1=[] arg2[] ...
Output requirement:
   outputFile=[default={scriptname}.out]
#ce
;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>

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
			@scriptname&@TAB&"Runs specified IMacro Script which is passed as argument."&@crlf& _
			""&@crlf& _
			" Set Syntax: use this to set values from encoder under test"&@crlf& _
			"   "&@scriptname&" deviceIp=[x.x.x.x] isVisible=[yes/no] checkWarningMsg=[yes/no] imacrosFile=<Set_*> arg1=[] arg2=[] ..."&@crlf& _
			""&@crlf& _
			" Extract Syntax: use this to extract values from encoder under test"&@crlf& _
			"   "&@scriptname&" deviceIp=[x.x.x.x] isVisible=[yes/no] checkWarningMsg=[yes/no] outputFile=[myoutput.out] Comparison=[] Pattern=[] imacrosFile=<Ext_*/ExtAll_*> arg1=[] arg2=[] []..."&@crlf& _
			""&@crlf& _
			" Generic Syntax: use by script developers for testing general purpose imacro scripts"&@crlf& _
			"   "&@scriptname&" deviceIp=[x.x.x.x] isVisible=[yes/no] checkWarningMsg=[yes/no] outputFile=[myoutput.out] imacrosFile=<filename/fullpath> extractOption=<ONE/ALL> arg1=[] arg2=[] []..."&@crlf& _
			""&@crlf& _
			" isVisible"&@TAB&"[Optional] Should IMacro browser be visible while playing [Yes/No]."&@crlf& _
			" checkWarningMsg"&@TAB&"[Optional] Should IMacro browser be visible while playing [Yes/No]."&@crlf& _
			" closeOnExit"&@TAB&"[Optional] Should IMacro browser be closed upon script finishing."&@crlf& _
			" browserOption"&@TAB&"[Optional] Options: -fx,-ie,-cr.  -fx = Firefox, -ie = Internet Explorer, -cr = Chrome.  Default = -tray (Imacros Browser)."&@crlf& _
			" imacrosFile"&@TAB&"(Mandatory) IMacro Script that needs to run."&@crlf& _
			" extractOption"&@TAB&"(Optional) This parameters tells if the extract script extract a single or multiple values."&@crlf& _
			" outputFile"&@TAB&"(Optional) This parameter tells to what file the extracted values should be written to."&@crlf& _
			" arg1"&@TAB&"(Optional) The parameters which needs to be passed to the IMacro Script"&@crlf& _
			" arg2"&@TAB&"(Optional) The parameters which needs to be passed to the IMacro Script"&@crlf& _
			""

;Main Flow of the program
;Everything starts here

;This argument checks for the parameters which should not be a part of iimSet command.
Global $nPreArgs = 0

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

	;Checking device under test Ip
	If not isDeclared("deviceIp") Then
		Global $deviceIp = EnvGet("encIp")
	Else
		$nPreArgs = $nPreArgs + 1
	EndIf
	If eval("deviceIp" = "") Then
		KConsoleWrite("deviceIp is empty.",1)
	EndIf

	;Checking imacrosFile
	If Not IsDeclared("imacrosFile") Then
		KConsoleWrite("Parameter not found: imacrosFile",1)
	Else
		$nPreArgs = $nPreArgs + 1
	EndIf

	If StringRegExp(eval("imacrosFile"),'\\',0) = 0 Then
		Assign("imacrosFile", EnvGet("kleverTestScriptsDir") & "\iMacros\" & eval("imacrosFile"), 2)
	EndIf

	If Not FileExists(eval("imacrosFile")) Then
		KConsoleWrite("Imacro Script: "&eval("imacrosFile")&" is not existed."&@CRLF,1)
	EndIf

	;Checking Extract Options
	if Not IsDeclared("outputFile") Then
		Assign("outputFile", @ScriptName & ".out", 2)
	Else
		$nPreArgs = $nPreArgs + 1
	EndIf

	if IsDeclared("Comparison") Then
		$nPreArgs = $nPreArgs + 2
		If not IsDeclared("Pattern") Then
			KConsoleWrite("Comparison option is given without Pattern option",1)
		EndIf
	EndIf

	if Not IsDeclared("isVisible") Then
		Global $isVisible="No"
	Else
		$nPreArgs = $nPreArgs + 1
	EndIf

	if Not IsDeclared("checkWarningMsg") Then
		Global $checkWarningMsg="No"
	Else
		$nPreArgs = $nPreArgs + 1
	EndIf

	if EnvGet("browserOption") = "" Then
		AssignVariable("browserOption", "-tray")
		If StringInStr($isVisible, "No") Then
			AssignVariable("browserOption", "-tray")
		EndIf
	EndIf
	KConsoleWrite("Browser option: "&EnvGet("browserOption"), 2)

EndFunc

Func main()
	;Creating IMacros Object
	local $filename = "Imacros.exe"
	Global $iMacros = ObjCreate("imacros")

	;Check if imacros.exe is already running.  If it is, use it instead of opening a new one.

	Local $iRet
	If Not IsObj($iMacros) Then
		KConsoleWrite("IMacro Object not created successfully")
		KConsoleWrite("Closing Program", 1)
	Else
		$iRet = $iMacros.iimInit(EnvGet("browserOption"), False)
		$count = 0
		While $iRet = -1
			$count = $count + 1
			KConsoleWrite("IMacro not initialized successfully. Retrying")
			$iRet = iMacrosInit()
			Sleep(2000)
			If $count = 6 Then
				KConsoleWrite("IMacro not initialized successfully.")
				KConsoleWrite("Exiting with error code " & $iRet, 1)
				ExitLoop
			EndIf
		WEnd
	EndIf

	;the two routines that you need to run
	Global $iMacroTorun = Eval("imacrosFile")
	Global $iMacroStatus

	$iMacros.iimDisplay("Testing is in Progress...")
	IMacrosSetArguments()
	$iMacroStatus = IMacrosPlay($iMacroTorun)
	IMacrosCheckError($iMacroStatus)

	;Delete IMacros Object
	$iMacros.iimDisplay("Testing is finished...")

	If EnvGet("closeOnExit") = 1 Then
		$iMacros.iimExit()
	EndIf
	$iMacros = 0

		;Handle Comparision
	if IsDeclared("Comparison") Then
		;Read output file into variable
		local $text=KFileReadToArray(eval("outputFile"))
		if $text[0] = 0 Then
			KConsoleWrite("Imacros Ext gave empty output",1)
		EndIf

		;stripping leading and trailing white spaces
		local $mytext = StringStripWS($text[1], 3)
		;stripping any double quote char
		$mytext = StringReplace($mytext,'"',"")

		Switch eval("Comparison")
			Case "equal"
				if $mytext = eval("Pattern") Then
					KConsoleWrite("Equal passed: "&eval("Pattern"))
				Else
					KConsoleWrite("Equal failed: " & $mytext & ", while looking for " & eval("Pattern"))
					$programExitCode=1
				EndIf
			Case "lessthan"
				if int($mytext) <= int(eval("Pattern")) Then
					KConsoleWrite("Less Than passed: " &$mytext & " is less than " & eval("Pattern"))
				Else
					KConsoleWrite("Less Than passed: " &$mytext & " is not less than " & eval("Pattern"))
					$programExitCode=1
				EndIf
			Case "lessthanequal"
				if int($mytext) < int(eval("Pattern")) Then
					KConsoleWrite("Less Than passed: " &$mytext & " is less than or equal " & eval("Pattern"))
				Else
					KConsoleWrite("Less Than passed: " &$mytext & " is not less than or equal " & eval("Pattern"))
					$programExitCode=1
				EndIf
			Case "greater"
				if int($mytext) > int(eval("Pattern")) Then
					KConsoleWrite("Less Than passed: " &$mytext & " is greater than " & eval("Pattern"))
				Else
					KConsoleWrite("Less Than passed: " &$mytext & " is not greater than " & eval("Pattern"))
					$programExitCode=1
				EndIf
			Case "greaterequal"
				if int($mytext) >= int(eval("Pattern")) Then
					KConsoleWrite("Less Than passed: " &$mytext & " is greater than " & eval("Pattern"))
				Else
					KConsoleWrite("Less Than passed: " &$mytext & " is not greater than " & eval("Pattern"))
					$programExitCode=1
				EndIf
			Case Else
				KConsoleWrite("Invalid Compare option: "&eval("Compare"),1)
		EndSwitch
	EndIf
EndFunc

;Set all the IMacros Arguments.
;encIP is deviceIp
;we only need to provide other values

Func IMacrosSetArguments()
	;We can set the encIp automatically from the envget("encIP")
	$iMacros.iimSet("encIP", eval("deviceIp"))

	;extraact dir and filename separately if outputfile is a fullpath
	Global $workingDir = @WorkingDir
	if (IsDeclared("outputFile") And StringInStr(Eval("outputFile"), "\")) Then
		$fileArray = StringSplit($outputFile, "\")
		if IsArray($fileArray) Then
			$workingDir = ""
			For $arrayIndex = 1 To $fileArray[0] - 1
				$workingDirTemp = $fileArray[$arrayIndex]
				$workingDir = $workingDir & $workingDirTemp & "\"
			Next
			Global $outputFile = $fileArray[$fileArray[0]]
		EndIf
	EndIf

	;make sure workingdir path is created
	KDirCreate($workingDir)

	$iMacros.iimSet("outputDir", $workingDir)
	$iMacros.iimSet("outputFile", eval("outputFile"))

	;extracting imacros arguments
	If(isarray($CmdLine)) Then
		For $arrayIndex = 1 to $CmdLine[0]
			Local $linesplit = StringSplit($CmdLine[$arrayIndex], "=", 1)
			If ($linesplit[1] = "imacrosFile") or ($linesplit[1] = "deviceIp") or ($linesplit[1] = "outputFile") or ($linesplit[1] = "isVisible") or ($linesplit[1] = "checkWarningMsg") or ($linesplit[1] = "logFile") or ($linesplit[1] = "imacrosFile") Then
				;$iMacros.iimExit()
				;KConsoleWrite("Arguments are entered in wrong order.", 1)
			Else
				$iMacros.iimSet($linesplit[1], $linesplit[2])
			EndIf
		Next
	EndIf
EndFunc

func IMacrosPlay($iMacroTorun)
	$iMacroTorun = Chr(34) & $iMacroTorun & Chr(34)
	Local $iRet = $iMacros.iimPlay($iMacroTorun)
	if StringInStr($checkWarningMsg,"yes") Then
		$iMacros.iimPlayCode("TAG POS=1 TYPE=DIV ATTR=CLASS:warn<SP>bottomrule&&TXT:* EXTRACT=TXT")
		$extractValue = $iMacros.iimGetLastExtract()
		KConsoleWrite("The warning message is :" & $extractValue)
	EndIf
	Return $iRet
EndFunc

func IMacrosCheckError($error)
	If $error > 0 Then
		KConsoleWrite("IMacros: "&$imacrosFile& " ran successfully.", 0, 2)
	Else
		KConsoleWrite("IMacros: "&$imacrosFile& " errored: " & $iMacros.iimGetLastError(), 1)
	EndIf
EndFunc