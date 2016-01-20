#cs
	Provided Script requirement as requested by QA Team
	ScriptName: auto_videohub_switch.exe
	Tool to automate: video hub switching command: devicestate.exe
	Argument Requirements:
		VideoHubIp
	<require argument>
		inPort, outPort
	[optional argument]
		None
	VideoHubIp=[ip of video hub server, default=getenv[videoHubIp]] inPort=<#> outPort=<#>
#ce
;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>

;Global Common Defintions
Global $hubPortType = 1
Global $hubComboIndex, $hubnumberindex

;Global Defintions unique to this script only

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.
;Here is the example
$usageMsg = "" & @CRLF & _
		@ScriptName & @TAB & "Support videohub with 288 inputs and outputs.  Switches required hub input to the output port." & @CRLF & _
		"" & @CRLF & _
		""&@scriptname&" VideoHubIp=[x.x.x.x] inPort=<input port> outPort=<output port>" & @CRLF & _
		"VideoHubIp"&@TAB&"(Optional) Ip of the VideoHub server. Default is taken from the environment variables. i.e. 10.77.240.100" & @crlf & _
		"inPort"&@TAB&@TAB&"(Mandatory) Input Port of the Video hub to set. i.e. 5" & @crlf & _
		"outPort"&@TAB&@TAB&"(Optional) Output Port of the Video hub to which the input is to set. i.e. 114.  Default is taken from env of hubInput" & @crlf & _
		""

;Main Flow of the program
;Everything starts here

;This CheckArguments functions is where you determine if those parsed arguments satisfy your input and output requirements
CheckArguments()
ProgramStart()
main()
ProgramEnd()

Func CheckArguments()
	;This first check is standard and is required in every scripts
	If IsDeclared("usage") Then
		ConsoleWrite($usageMsg)
		Exit
	EndIf

	;Your checks start here
	If Not IsDeclared("VideoHubIp") Then
		Global $VideoHubIp = EnvGet("VideoHubIp")
	EndIf

	If Eval("VideoHubIp") = "" Then
		KConsoleWrite("VideoHubIp is empty.", 1)
	EndIf

	If Not IsDeclared("inPort") Then
		KConsoleWrite("inPort is empty.", 1)
	EndIf

	If Not IsDeclared("outPort") Then
		KConsoleWrite("User did not provide outPort.  Trying to use outPort from device's VideohuboutPort: "& Envget("VideohuboutPort"))
		Global $outPort = EnvGet("VideohuboutPort")
		if ($outPort = "") Then
			KConsoleWrite("outPort is empty.", 1)
		EndIf
	EndIf
EndFunc   ;==>CheckArguments

Func main()


	local $myconsolecmd = "DeviceState.exe " & $VideoHubIp

	KConsoleWrite("Setting Videohub output "&$outPort& " to input "&$inPort)

    #cs
	KConsoleWrite("Running: "&$myconsolecmd, 2)
	$hDLL = Run($myconsolecmd,"",@SW_SHOW, $STDIN_CHILD + $STDOUT_CHILD + $STDERR_CHILD)
	Sleep(2000)
	StdinWrite($hDLL, "q")
	Sleep(1000)
	StdinWrite($hDLL, "q")
	Local $sOutput = "" ; Store the output of StdoutRead to a variable.
	While 1
        $sOutput &= StdoutRead($hDLL) ; Read the Stdout stream of the PID returned by Run.
		If StringRegExp($sOutput, "Monitoring video outputs:	72") Then

			If ($outPort > 72) Then
			$outPort = $outPort - 72
			$hubPortType = 2
			EndIf

			KConsoleWrite("VideoHub has 72 monitoring output ports", 2)
			ExitLoop
		EndIf

		If StringRegExp($sOutput, "Video inputs:                288") Then
			KConsoleWrite("VideoHub has 288 input ports", 2)
			ExitLoop
		EndIf

        If @error Then ; Exit the loop if the process closes or StdoutRead returns an error.
            ExitLoop
        EndIf
    WEnd
	#ce

	$hubComboIndex = $inPort - 1
	$hubnumberindex = $outPort - 1

	KConsoleWrite("Running: "&$myconsolecmd, 2)
	$hDLL = Run($myconsolecmd,"",@SW_SHOW, $STDIN_CHILD)
	Sleep(1000)
	$mycmd = "R " & $hubPortType & " " & $hubnumberindex & " " & $hubComboIndex
	KConsoleWrite("Interactive command: "&$mycmd, 2)
	StdinWrite($hDLL,$mycmd)
	Sleep(1000)
	StdinWrite($hDLL, "q")
	ProcessClose($hDLL)
EndFunc   ;==>main
