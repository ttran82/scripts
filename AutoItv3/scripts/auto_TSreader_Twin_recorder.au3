#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <..\KleverLib.au3>

If Not isDeclared("captureDur") Then
	Global $captureDur = 10
EndIf

If Not isDeclared("loopCount") Then
	Global $loopCount = 1
EndIf

If Not isDeclared("delayTime") Then
	Global $delayTime = 0
EndIf

if Not IsDeclared("isVisible") Then
	Global $isVisible = "no"
EndIf

$usageMsg = ""&@crlf& _
			@scriptname&"    Records a regular stream and a proxy stream from a given output ip."&@crlf& _
			""&@crlf& _
			@scriptname&" udp1IP=<udpaddr> udp1Port=<udpport> udp2Ip=<udp2addr> udp2Port=<udp2port> captureDur=[dur] loopCount=[loop] delayTime=[seconds] offsetTime=[miliseconds] outputFile=[outputname]"&@crlf& _
			""&@crlf& _
			" This program use klever_TSReader_recorder.exe as a basic capture."&@crlf& _
			" <udp1addr>"&@TAB&"<Required> Multicast Ip address 1."&@crlf& _
			" <udp2port>"&@TAB&"<Required> Multicast Port 1."&@crlf& _
			" <udp2addr>"&@TAB&"<Required> Multicast Ip address 2."&@crlf& _
			" <udp2port>"&@TAB&"<Required> Multicast Port 2."&@crlf& _
			" [outputFile]"&@TAB&"[Optional] outputname_1, outputname2 will begiven to first and second stream respectively"&@crlf& _
			" [captureDur]"&@TAB&"[Optional] Duration of record time in seconds. Default 10s."&@crlf& _
			" [loopCount]"&@TAB&"[Optional] Loop times of record. Default 1."&@crlf& _
			" [delayTime]"&@TAB&"[Optional] In second.  Default 0."&@crlf& _
			" [checkMulticast]"&@TAB&"[Optional] yes/no.  Default=yes.  Set to skip multicast check"&@crlf& _
			" [offsetTime]"&@TAB&"[Optional] In miliseconds.  Offset time between first and second capture.  Default 0."&@crlf& _
			""

;Flow of the main program
CheckArguments()
ProgramStart()
main()
ProgramEnd()


;Function Definitions
func main()
	AutoTSReaderTwinRecorder()
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
	if Not isDeclared("udp1Ip") or Not isDeclared("udp1Port") or Not isDeclared("udp2Ip") or Not isDeclared("udp2Port") Then
		KConsoleWrite("Missing Parameters",1)
	EndIf

	If EnvGet("checkMulticast") == "" Then
		EnvSet("checkMulticast", "yes")
	EndIf
EndFunc

Func AutoTSReaderTwinRecorder()
	local $sub_outputFile1 = ""
	local $sub_outputFile2 = ""

	For $x = 1 to  $loopCount

		local $outputname = "_"&DateString()
		local $stream1name = "tsReader_"&$udp1Ip&"_"&$udp1Port&$outputname
		local $stream2name = "tsReader_"&$udp2Ip&"_"&$udp2Port&$outputname

		if (IsDeclared("outputFile")) Then
			if ($loopCount = 1) Then
				$outputname = $outputFile
				$stream1name = $outputname&"_1"
				$stream2name = $outputname&"_2"
			Else
				$stream1name = $outputname&"_1"&"_"&$x
				$stream2name = $outputname&"_2"&"_"&$x
			EndIf

			$sub_outputFile1 = " outputFile="&$stream1name
			$sub_outputFile2 = " outputFile="&$stream2name
		EndIf

		$mycommand1 = "auto_TSreader_recorder.exe udpIp="&$udp1Ip&" udpport="&$udp1Port & " captureDur="&$captureDur & $sub_outputFile1 & " isVisible=" & $isVisible
		$mycommand2 = "auto_TSreader_recorder.exe udpIp="&$udp2Ip&" udpport="&$udp2Port & " captureDur="&$captureDur & $sub_outputFile2 & " isVisible=" & $isVisible
		RunCommand($mycommand1, @WorkingDir, 0)
		If IsDeclared("offsetTime") Then
			sleep(Eval("offsetTime"))
		EndIf
		RunCommand($mycommand2, @WorkingDir, 1)
	Next
EndFunc
