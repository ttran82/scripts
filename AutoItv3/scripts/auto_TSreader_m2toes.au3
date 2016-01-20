#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <..\KleverLib.au3>


If Not isDeclared("captureDur") Then
	Global $captureDur = 60
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
			@scriptname&@TAB&"Records a stream using vlc, then analyse the capture using m2toes."&@crlf& _
			""&@crlf& _
			@scriptname&" udpIP=<udpaddr> udpPort=<udpport> captureDur=[dur=60] loopCount=[loop=1] delayTime=[delay=0] outputFile=[outputname]"&@crlf& _
			""&@crlf& _
			" This program uses auto_TSReader_recorder.exe and auto_m2toes.exe as basic scripts."&@crlf& _
			" <udpaddr>"&@TAB&"<Required> Multicast Ip address."&@crlf& _
			" <udpport>"&@TAB&"<Required> Multicast Port."&@crlf& _
			" [dur]"&@TAB&@TAB&"[Optional] Duration of record time in seconds. Default 60s."&@crlf& _
			" [loop]"&@TAB&@TAB&"[Optional] Loop times of record. Default 1."&@crlf& _
			" [delay]"&@TAB&@TAB&"[Optional] In second.  Default 0."&@crlf& _
			" [outputname]"&@TAB&"[Optional] outputname.ts will be created.  If not specified vlc_udpaddr_udpport_datestring.ts will be createdd"&@crlf& _
			" [isVisible]"&@TAB&"[Optional] Should TSReader be visible while recording [Yes/No]."&@crlf& _
			""

;Flow of the main program
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()
	AutoTSReaderM2toes()
EndFunc

;Function Definitions
Func CheckArguments()
	;This check is standard.  Do not change
	if isDeclared ("usage") Then
		;this is the only time you will use consolewrite.  After Programe start, use Kconsolewrite will write to log
		consoleWrite($usageMsg)
		Exit
	EndIf
	if not isDeclared("udpIp") or not IsDeclared("udpPort") Then
		KConsoleWrite("Missing Parameters",1)
	EndIf
EndFunc

Func AutoTSReaderM2toes()
	local $mycommand
	Local $TSReaderCaplog
	Local $TSReaderCapfile

	For $x = 1 to  $loopCount
		local $outputname = "TSReader_"&$udpIp&"_"&$udpPort&"_"&DateString()

		if (IsDeclared("outputFile")) Then
			if ($loopCount = 1) Then
				$outputname = $outputFile
			Else
				$outputname = $outputFile&"_"&$x
			EndIf
		EndIf


		local $sub_outputFile = ""
		if (IsDeclared("outputFile")) Then
			$sub_outputFile = " outputFile="&$outputname
		EndIf
		$mycommand = "auto_TSReader_recorder.exe udpIp="&$udpIp&" udpport="&$udpPort & " captureDur="&$captureDur & $sub_outputFile & " isVisible=" & $isVisible
		RunCommand($mycommand, @WorkingDir, 1)
		$vlcCapfile = $outputname&".ts"
		$mycommand = "auto_m2toes.exe inputFile="&$vlcCapfile
		RunCommand($mycommand, @WorkingDir, 1)
		sleep($delayTime*1000)
	Next
EndFunc