#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_pingcheck.exe
Tool to automate: ping check to time how long it takes for a device to come up
Input requirement:
   arguments = deviceIp=[x.x.x.x] timeOut=<default=120 seconds>
   <require argument>
   [optional argument]
Output requirement:
   If the device ip is reachable, exit immediately -> passed
   If the device ip is not reachable, retry 'til timeOut is reached -> failed
#ce

;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>

;Global Common Defintions

;Global Defintions unique to this script only

$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Do a device ping check."&@crlf& _
			""&@crlf& _
			""&@scriptname&" deviceIp=[ipaddr] timeOut=[seconds]"&@crlf& _
			""&@crlf& _
			" ipaddr"&@TAB&"(Optional) Device Ip to check. Default current device ip."&@crlf& _
			" timeOut"&@TAB&"(Optional) Time out for check period. Default=120sec"&@crlf& _
			""



;Main Flow of the program
;Everything starts here
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()
	Pingcheck()
EndFunc

Func CheckArguments()
	if isDeclared ("usage") Then
		consoleWrite($usageMsg)
		Exit
	EndIf

	If not isDeclared("deviceIp") Then
		Global $deviceIp=EnvGet("encIp")
		If $deviceIp="" Then
			KConsoleWrite("Missing Parameter: $deviceIp",1)
		EndIf
	EndIf

	if Not IsDeclared("timeOut") Then
		Global $timeOut=120000
	Else
		$timeOut = $timeOut*1000
	EndIf
EndFunc

Func Pingcheck()
	EncoderPingcheck($deviceIp,$timeOut)
EndFunc