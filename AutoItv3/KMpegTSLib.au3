#include <Array.au3>
#include <File.au3>

;Flow of the main program
Global $title = "MPEG-2 TS packet analyser"
Global $program = "MPEG-2 TS packet analyser.exe"
Global $foundpattern = 0

;Launch MPEG2 TS Anlayzer providing input file
Func runMPEG2Analyzer($inputFile)
	;Closing any current open programs
	KWinClose($title)

	;Running new instance of the program
	local $programid = Run($program)
	local $programwhdl = WinWaitActive($title)

	;Click on open icon
	KWinActivate($title)
	KControlCheck( ControlClick($title, "", "[NAME:ToolStrip1]", "left", 1, 12, 12), "Click Open File Icon")

	;Open Windows Controls
	local $openwhdl = WinWaitActive("Open","Files of &type:")
	KControlCheck( ControlSetText("Open", "Files of &type:",  "[CLASS:Edit; INSTANCE:1]", $inputFile), "Type file name on open dialog")
	If @OSVersion = "WIN_7" Then
		KControlCheck( ControlClick("Open", "Files of &type:",  "[CLASS:Button; INSTANCE:1]", "left"), "Click OK on open file dialog")
	Else
		KControlCheck( ControlClick("Open", "Files of &type:",  "[CLASS:Button; INSTANCE:2]", "left"), "Click OK on open file dialog")
	EndIf
EndFunc

Func SelectFilterPayload()
	KWinActivate($title)
	ControlCommand($title, "", "[NAME:cboxPayloadStart]", "Check")
	KConsoleWrite("Selected Payload Filter.", 0, 2)
EndFunc

Func SelectFilterPid()
	KWinActivate($title)
	ControlCommand($title, "", "[NAME:cboxPID]", "Check")
	KConsoleWrite("Selected Pid Filter.", 0, 2)
EndFunc

Func EditFilterPid($pid)
	KWinActivate($title)
	;If IsNumber($pid) Then
		KControlCheck( ControlClick($title, "", "[NAME:tbPidFilter]", "left", 2, 45, 10), "Get Filter Edit focus")
		KControlCheck( ControlSend($title, "", "[NAME:tbPidFilter]", "{BACKSPACE}{BACKSPACE}{BACKSPACE}{BACKSPACE}"), "Modify pid value")
		KControlCheck( ControlSetText($title, "", "[NAME:tbPidFilter]", $pid),  "Enter Pid value")
	KConsoleWrite("Enter pid value: "&$pid, 0, 2)
	;EndIf
EndFunc

Func GotoFirstPacket()
	KWinActivate($title)
	KControlCheck( ControlClick($title, "", "[NAME:ToolStrip1]", "left", 1, 40, 12), "Click on First Packet")
	KConsoleWrite("Go to first package.", 0, 2)
EndFunc

Func SearchNextPacket($findtext)
	;Click on Next Package
	;Remove any previous output file
	local $myfile = @WorkingDir & "\" & eval("outputFile")
	FileDelete($myfile)

	KWinActivate($title)

	;Try searching for matching pattern 5 times
	local $count = 5
	While 1
		If $count = 0 Then ExitLoop
		KControlCheck( ControlClick($title, "", "[NAME:ToolStrip1]", "left", 1, 85, 12), "Click on Next Packet Arrow.")
		local $mytext = ControlGetText($title, "", "[NAME:viewer]")

		;MsgBox(0, "TT", $mytext)

		ControlSend($title, "", "[CLASS:Button; INSTANCE:2]", "{ENTER}")

		;local $afdtxt = "AFD start code"
		if StringInStr($mytext,$findtext) Then
			$programExitCode=0
			;FileWriteLine($outputFile, ControlGetText($title, "", "[NAME:viewer]"))
			FileWriteLine($myfile, $mytext)
			$foundpattern = 1
			ExitLoop
		Else
			FileWriteLine($myfile, $mytext)
			$programExitCode=1
		EndIf
		$count = $count - 1
		sleep(500)
	WEnd
EndFunc

Func SearchPreviousPacket($findtext)
	;Click on Next Package
	;Remove any previous output file
	local $myfile = @WorkingDir & "\" & Eval("outputFile")
	FileDelete($myfile)

	KWinActivate($title)

	;Try searching for matching pattern 5 times
	local $count = 5
	While 1
		If $count = 0 Then ExitLoop
		KControlCheck( ControlClick($title, "", "[NAME:ToolStrip1]", "right", 1, 65, 12), "Click on Previous Packet Arrow.")
		local $mytext = ControlGetText($title, "", "[NAME:viewer]")
		;local $afdtxt = "AFD start code"
		if StringInStr($mytext,$findtext) Then
			$programExitCode=0
			;FileWriteLine($outputFile, ControlGetText($title, "", "[NAME:viewer]"))
			FileWriteLine($myfile, $mytext)
			$foundpattern = 1
			ExitLoop
		Else
			FileWriteLine($myfile, $mytext)
			$programExitCode=1
		EndIf
		$count = $count - 1
		sleep(500)
	WEnd

EndFunc

; Hex To Binary
Func _HexToBinaryString($HexValue)
	Local $Allowed = '0123456789ABCDEF'
	Local $Test,$n
	Local $Result = ''
	if $hexValue = '' then
	SetError(-2)
	Return
	EndIf

	$hexvalue = StringSplit($hexvalue,'')
	for $n = 1 to $hexValue[0]
	if not StringInStr($Allowed,$hexvalue[$n]) Then
	SetError(-1)
	return 0
	EndIf
	Next

	Local $bits = "0000|0001|0010|0011|0100|0101|0110|0111|1000|1001|1010|1011|1100|1101|1110|1111"
	$bits = stringsplit($bits,'|')
	for $n = 1 to $hexvalue[0]
	$Result &= $bits[Dec($hexvalue[$n])+1]
	Next

	Return $Result
EndFunc
