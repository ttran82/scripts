#include <WindowsConstants.au3>
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

If Not isDeclared("multicasttype") Then
	Global $multicasttype = "udp"
EndIf

$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Records a stream using vlc."&@crlf& _
			""&@crlf& _
			"General Syntax:"&@crlf& _
			@TAB&@scriptname&" udpIp=<udpaddr> udpPort=<udpport> multicasttype=[udp/rtp] captureDur=[dur=60] loopCount=[loop=1] delayTime=[delay=0] outputFile=[outputname]"&@crlf& _
			"Samples:"&@crlf& _
			@TAB&"Multicast capture: "&@scriptname&" udpIp=1.2.3.4 udpPort=5678 multicasttype=rtp/udp captureDur=60 loopCount==1 delayTime=0 outputFile=test"&@crlf& _
			@TAB&"Unicast capture: "&@scriptname&" udpIp=" & Chr(34) & Chr(34) & " udpPort=5678 multicasttype=udp/rtp captureDur=60 loopCount==1 delayTime=0 outputFile=test"&@crlf& _
			""&@crlf& _
			" [udpip]"&@TAB&@TAB&"[Required] Multicast Ip address.  Provide blank to perform unicast capture."&@crlf& _
			" <udpport>"&@TAB&"<Required> Multicast Port."&@crlf& _
			" [multicasttype]"&@TAB&"[Optional] Default = udp."&@crlf& _
			" [captureDur]"&@TAB&"[Optional] Duration of record time in seconds. Default 60s."&@crlf& _
			" [loopCount]"&@TAB&"[Optional] Number of consecutive catpures. Default 1."&@crlf& _
			" [delayTime]"&@TAB&"[Optional] Delays between consecutive captures in seconds.  Default 0."&@crlf& _
			" [outputFile]"&@TAB&"[Optional] outputname.ts will be created.  If not specified vlc_udpaddr_udpport_datestring.ts will be createdd"&@crlf& _
			" [TailEncZenc]"&@TAB&"[Optional] yes/no.  This option will only work when encode under test is a Modulus encoder"&@crlf& _
			@TAB&@TAB&"This option can also invoked automatically by setting the env variable TailEncZenc=yes in the testcase"&@crlf& _
			" [checkMulticast]"&@TAB&"[Optional] yes/no.  Default=yes.  Set to skip multicast check"&@crlf& _
			" [vlcInstallDir]"&@TAB&"[Optional] Allow user to use a customized path of VLC installation."&@crlf& _
			""

;Flow of the main program
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()
	AutoVlcRecorder()
EndFunc

;Function Definitions
Func CheckArguments()
	;This check is standard.  Do not change
	if isDeclared ("usage") Then
		;this is the only time you will use consolewrite.  After Programe start, use Kconsolewrite will write to log
		consoleWrite($usageMsg)
		Exit
	EndIf

	if not isDeclared("udpIp") Then
		AssignVariable("udpIp", "")
	;	AssignVariable("checkMulticast", "no")
	EndIf

	;If EnvGet("udpIp") == "" Then
	;	AssignVariable("checkMulticast", "no")
	;EndIf

	if not isDeclared("checkMulticast") Then
		AssignVariable("checkMulticast", "yes")
	EndIf

	if not IsDeclared("udpPort") Then
		KConsoleWrite("Missing Parameter: udpPort",1)
	EndIf

	If EnvGet("TailEncZenc") == "" Then
		AssignVariable("TailEncZenc", "no")
	EndIf

	;User can override this path by setting this in SystemConfig.  vlcInstallDir=
	Global $vlcCommand = "vlc.exe"
	If EnvGet("vlcInstallDir") <> "" Then
		$vlcCommand = EnvGet("vlcInstallDir") & "\" & "vlc.exe"
		KConsoleWrite("Detected VLC Command: " & $vlcCommand,0,2)
		If FileExists($vlcCommand) = 0 Then
			KConsoleWrite($vlcCommand&" is not found.",1)
		EndIf
	EndIf


EndFunc

Func AutoVlcRecorder()
	local $mycommand
	Local $vlcCaplog
	Local $vlcCapfile

	For $x = 1 to  $loopCount
		local $outputname = "vlc_"&$udpIp&"_"&$udpPort&"_"&DateString()

		if (IsDeclared("outputFile")) Then
			if ($loopCount = 1) Then
				$outputname = $outputFile
			Else
				$outputname = $outputFile&"_"&$x
			EndIf
		EndIf

		$vlcCaplog = $outputname&".log"
		$vlcCapfile = $outputname&".ts"

		local $vlc_log_option = ""
		If Envget("Verbosity") > 1 Then
			$vlc_log_option = "--extraintf=logger --verbose=0 --file-logging --logfile="&$vlcCaplog
		EndIf

		$mycommand = Chr(34) & $vlcCommand & Chr(34) & " " & $vlc_log_option & " --run-time "&$captureDur&" "&$multicasttype&"://@"&$udpIp&":"&$udpPort&" :demux=dump :demuxdump-file=.\"&$vlcCapfile&" --play-and-exit"

		;Check multicast before capturing


		if CheckMulticastAddr($udpIp, $udpPort, 1) = 0 Then
			;if Multicast address is reachable
			If EnvGet("TailEncZenc") = "yes" and EnvGet("EncMade") = "Modulus" Then
				local $tailcmd = "tail -F /var/log/zenc > /tmp/myzenc"
				RunSecureTestScript($tailcmd,$kleverCurrentDepotDir,0)
				local $mypid = EnvGet("CurrentRunningPID")
			EndIf
			RunCommand($mycommand,@WorkingDir,1,0)
			WriteTSplaylist($vlcCapfile)

			If EnvGet("TailEncZenc") = "yes" and EnvGet("EncMade") = "Modulus" Then
				;First close the tail command
				local $tailcmd = "killall -9 tail"
				RunSecureTestScript($tailcmd,$kleverCurrentDepotDir,1)
				local $getscript = "/tmp/myzenc"
				RunSecureGetScript($getscript,$kleverCurrentDir)
				;Now Check if the file existed
				local $myzenc = $kleverCurrentDir&"\myzenc"
				If FileExists($myzenc) Then
					;copy the zenc log to final destination
					local $newzenc = $kleverCurrentDir&"\"&$vlcCapfile&".zenc"
					FileMove($myzenc, $newzenc)
				Else
					KConsoleWrite("Failed to get zenc log from encoder.")
				EndIf

			EndIf
		Else
			;if not create an empty file
			$vlcCapfile = "failed_"&$vlcCapfile
			_FileCreate(@WorkingDir&"\"&$vlcCapfile)
		EndIf
		UpdateLastFile($vlcCapfile)
		;sleep($delayTime*1000)
	Next
EndFunc

Func WriteTSplaylist($tsfile)
	if FileExists($tsfile) Then
		FileWriteLine(@WorkingDir&"\"&@ScriptName&".m3u",@WorkingDir&"\"&$tsfile&@CRLF)
	EndIf
	KConsoleWrite("Capture Done"&@CRLF)
EndFunc