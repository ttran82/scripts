#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_imacros.exe
Tool to automate:
Input requirement:
   input=<input> deviceIp=[ip of device under test, default=getenv[encip]] output=[output] something=[something]
   <require argument>
   [optional argument]
Output requirement:

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
			""&@scriptname&" deviceIp=[x.x.x.x] scriptName=<> arg1=[] arg2[] ..." &@crlf& _
			""&@crlf& _
			" scriptName"&@TAB&"(Mandatory) IMacro Script that needs to run."&@crlf& _
			" arg1"&@TAB&"(Optional) The parameters which needs to be passed to the IMacro Script"&@crlf& _
			" arg2"&@TAB&"(Optional) The parameters which needs to be passed to the IMacro Script"&@crlf& _
			""

;Main Flow of the program
;Everything starts here
CheckArguments()
main()

Func CheckArguments()
	If isDeclared ("usage") Then
		consoleWrite($usageMsg)
		Exit
	EndIf

	If not isDeclared("deviceIp") Then
		Global $deviceIp = EnvGet("encIp")
		If $deviceIp = "" Then
			KConsoleWrite("Parameter not found: deviceIp",1)
		EndIf
	EndIf

	If Not IsDeclared("scriptName") Then
		KConsoleWrite("Parameter not found: scriptName",1)
	EndIf

EndFunc

func main()
	;Creating IMacros Object
	Global $iMacros = ObjCreate("IMacros")
	If Not IsObj($iMacros) Then
		KConsoleWrite("IMacro Object not created successfully")
		KConsoleWrite("Closing Program", 1)
	Else
		$iRet = $iMacros.iimInit()
		$count = 0
		While $iRet = -1
			$count = $count + 1
			KConsoleWrite("IMacro not initialized successfully. Retrying")
			$iRet = $iMacros.iimInit()
			Sleep(2000)
			If $count = 6 Then
				KConsoleWrite("IMacro not initialized successfully.")
				KConsoleWrite("Exiting with error code " & $iRet, 1)
				ExitLoop
			EndIf
		WEnd
	EndIf

	;the two routines that you need to run
	Global $scriptArguments
	Global $scriptTorun
	Global $scriptStatus

	IMacrosSetArguments()
	$scriptStatus = IMacrosPlay($scriptTorun)
	IMacrosCheckError($scriptStatus)
	;Delete IMacros Object
	$iMacros.iimExit()
EndFunc

;Set all the IMacros Arguments.
;encIP is set automatically from envget("encIP")
;we only need to provide other values
Func IMacrosSetArguments()
	;We can set the encIp automatically from the envget("encIP")
	$encIP = Eval("encIp")
	$iMacros.iimSet("encIP", $encIP)
	If(isarray($CmdLine)) Then
		For $arrayIndex = 1 to $CmdLine[0]
			Local $linesplit = StringSplit($CmdLine[$arrayIndex], "=", 1)

			If ($linesplit[1] = "scriptName") Then
				$scriptTorun = $kleverTestScriptsDir & "\iMacros\" & $linesplit[2]
			Else
				$iMacros.iimSet($linesplit[1], $linesplit[2])
			EndIf
		Next
	EndIf
EndFunc

func IMacrosPlay($scriptTorun)
	$scriptTorun = Chr(34) & $scriptTorun & Chr(34)
	Local $iRet = $iMacros.iimPlay($scriptTorun)
	Return $iRet
EndFunc

func IMacrosCheckError($error)
	If $error > 0 Then
		KConsoleWrite("IMacros ScriptName: "&$scriptName& " ran successfully.")
	Else
		KConsoleWrite("IMacros ScriptName: "&$scriptName& " errored: " & $iMacros.iimGetLastError(), 1)
	EndIf
EndFunc