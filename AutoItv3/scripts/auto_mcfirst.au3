#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_mcfirst.exe
Tool to automate: mcfirst command.  This command will check for multicast stream.
Input requirement:
   aliveCheck=[active/inactive] packetCount=[seconds], testDuration=[seconds], udpIp=<multicastaddr>, udpPort=<port> outputFile=[outFile]
   <require argument>
   [optional argument]
Output requirement:
   If outputFile is not provided, the default outputFile will be @scriptname.out
   Otherwise, output file will be from provide argument.
   aliveCheck = active, if multicast address is active, result = passed, otherwise fail.  This is default condition
   aliveCheck = inactive, if multicast address is active, result = fail, other pass.  This is negative condition
#ce

;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>

;Global Defintions unique to this script only

;A very detail of usage for this script.
$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Check if a multicast/unicast is active/inactive"&@crlf& _
			""&@crlf& _
			@scriptname&" aliveCheck=[active/inactive] packetCount=[seconds], testDuration=[seconds], udpIp=<multicastaddr>, udpPort=<port> outputFile=[outFile]"&@crlf& _
			""&@crlf& _
			" [aliveCheck]"&@TAB&"active/inactive.  Default is active"&@crlf& _
			" [packetCount]"&@TAB&"Default = 1. Number of packets to count.  Program will exit as soon as the count is met regardless of testDuration"&@crlf& _
			" [testDuration]"&@TAB&"Default = 3.  Number of seconds the program need to run while aliveCheck condition is not met."&@crlf& _
			" <udpIp>"&@TAB&"multicast address.  When testing unicast, leave this parameter blank."&@crlf& _
			" <port>"&@TAB&"multicast port"&@crlf& _
			" [outputFile]"&@TAB&"command output.  If not specified "&@scriptname & ".out will be createdd"&@crlf& _
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
	EnvSet("checkMulticast", "yes")
	local $negativeTest = 0
	If EnvGet("aliveCheck") == "inactive" Then
		$negativeTest=1
	EndIf
	CheckMulticastAddr(Envget("udpIp"), Envget("udpPort"),  Envget("testDuration"),  Envget("packetCount"),  $negativeTest)

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
	if not isDeclared("udpIp") or not IsDeclared("udpPort") Then
		KConsoleWrite("Missing Parameters",1)
	EndIf

	If EnvGet("udpIp") == "" Then
		AssignVariable("udpIp", "232.32.32.32")
	EndIf

	if not isDeclared("packetCount") Then
		AssignVariable("packetCount", 1)
	EndIf

	if not isDeclared("testDuration") Then
		AssignVariable("testDuration", 3)
	EndIf

	if not isDeclared("aliveCheck") Then
		AssignVariable("aliveCheck", "active")
	EndIf

	if not isDeclared("outputFile") Then
		AssignVariable("outputFile", @ScriptName&".out")
	EndIf

	if not isDeclared("negativeTest") Then
		AssignVariable("negativeTest", "yes")
	EndIf
EndFunc
