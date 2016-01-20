#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GuiListBox.au3>
#include <ButtonConstants.au3>
#include <Array.au3>
#include <File.au3>

Opt("GUICloseOnESC", 0)

;Flow of the main program
Global $auDir = @WorkingDir
Global $outputFile = "au_info.out"
Global $title = "MPEG-2 TS packet analyser"
Global $program = "MPEG-2 TS packet analyser.exe"
Global $foundpattern = 0
Global $aucmd = "auto_au_decode.exe"

main()

Func main()
	KleverAuInfoMain()
EndFunc

Func KleverAuInfoMain()
	Local $msgkse
	Local $displaystate=BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY)
	Local $currentitem=""

	$maingui = GUICreate("Au Information Decoder", 800, 720, -1, -1, BitOr($GUI_SS_DEFAULT_GUI,$WS_OVERLAPPEDWINDOW,$WS_EX_ACCEPTFILES))
	;create search related
	$menuFile = GUICtrlCreateMenu("File")
	$menuFileOpen = GUICtrlCreateMenuItem("Open", $menuFile)
	$menuFileExit = GUICtrlCreateMenuItem("Exit", $menuFile)

	$guiFileLable = GUICtrlCreateLabel("File:", 5, 10, 20 ,20)
	$guiFilePath = GUICtrlCreateinput("",25, 10, 500, 20)
	$guiVideoPid = GUICtrlCreateinput("32",530, 10, 45, 20)
	$guiFileAnalyzePrevious = GUICtrlCreateButton("Previous", 580, 10, 70,20)
	GUICtrlSetState($guiFileAnalyzePrevious, $GUI_DISABLE)
	$guiFileAnalyze = GUICtrlCreateButton("Analyze", 650, 10, 70,20)
	GUICtrlSetState($guiFileAnalyze, $GUI_DISABLE)
	$guiFileAnalyzeNext = GUICtrlCreateButton("Next", 720, 10, 70,20)
	GUICtrlSetState($guiFileAnalyzeNext, $GUI_DISABLE)

	$guiAuPrivateDataLable = GUICtrlCreateLabel("Data:", 5, 35, 30 , 20)
	$guiAuPrivateData = GUICtrlCreateinput("",35, 35, 250, 20)
	$guiAuDecodeButton = GUICtrlCreateButton("Single Decode", 290, 35, 100,20)

	;create an editbox
	$guidisplayeditbox = GUICtrlCreateEdit("Display",5, 60, 720, 700 ,$displaystate)

	GUISetState(@SW_SHOW)

	; Just idle around
	While 1
			$msg = GUIGetMsg()
			Select
				Case $msg = $GUI_EVENT_CLOSE Or $msg = $menuFileExit; Exit
					WinClose($title)
					ExitLoop

				Case $msg = $guiAuDecodeButton
					;call auto_au_decode
					runAuDecode(GUICtrlRead($guiAuPrivateData))

					;now display output
					displayAuInfo($guidisplayeditbox)

				Case $msg = $menuFileOpen
					local $selectedFile = FileOpenDialog("Select the captured file to be analyzed", @WorkingDir & "\", "All (*.*)")
					If $selectedFile Then
						GUICtrlSetData($guiFilePath, $selectedFile)
						GUICtrlSetState($guiFileAnalyze, $GUI_ENABLE)
					EndIf

				Case $msg = $guiFileAnalyze
					;First Open MPEG2 TS Analyzer
					runMPEG2Analyzer(GUICtrlRead($guiVideoPid), GUICtrlRead($guiFilePath))
					SearchNextPacket("Transport_private_data_length:")
					local $myreturn = CheckAuDescriptor()
					GUICtrlSetData($guiAuPrivateData, $myreturn)
					runAuDecode(GUICtrlRead($guiAuPrivateData))
					;now display output
					displayAuInfo($guidisplayeditbox)
					GUICtrlSetState($guiFileAnalyzeNext, $GUI_ENABLE)
					GUICtrlSetState($guiFileAnalyzePrevious, $GUI_ENABLE)

				Case $msg = $guiFileAnalyzeNext
					SearchNextPacket("Transport_private_data_length:")
					local $myreturn = CheckAuDescriptor()
					GUICtrlSetData($guiAuPrivateData, $myreturn)
					runAuDecode(GUICtrlRead($guiAuPrivateData))
					;now display output
					displayAuInfo($guidisplayeditbox)

				Case $msg = $guiFileAnalyzePrevious
					SearchPreviousPacket("Transport_private_data_length:")
					local $myreturn = CheckAuDescriptor()
					GUICtrlSetData($guiAuPrivateData, $myreturn)
					runAuDecode(GUICtrlRead($guiAuPrivateData))
					;now display output
					displayAuInfo($guidisplayeditbox)

			EndSelect
	WEnd

EndFunc

Func runAuDecode($data)
	;call auto_au_decode

	local $mycmd = $aucmd & " privateData=" & $data
	;remove previous output file
	local $outFile = $aucmd & ".out"
	FileDelete(@WorkingDir & "\" & $outFile)
	RunWait($mycmd, @WorkingDir)
EndFunc

Func displayAuInfo($wh)
	;now display output
	local $outFile = $aucmd & ".out"
	local $itemcontent = FileOpen($outFile, 0)
	If $itemcontent = -1 Then
		MsgBox(0, "Error", "Unable to open "&$itemcontent&" file.")
	EndIf
	GUICtrlSetData($wh, FileRead($itemcontent))
	FileClose($itemcontent)
EndFunc

Func runMPEG2Analyzer($videoPid, $inputFile)
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

    ;Click on Filter option: Payload and Pid
	KWinActivate($title)
	KControlCheck( ControlClick($title, "", "[NAME:cboxPayloadStart]", "left"), "Select Payload Checkbox.")
	KControlCheck( ControlClick($title, "", "[NAME:cboxPID]", "left"), "Select Pid CheckBox.")
	KControlCheck( ControlSetText($title, "", "[NAME:tbPidFilter]", $videoPid), "Enter Video Pid value.")

EndFunc

Func SearchNextPacket($findtext)
	;Click on Next Package
	;Remove any previous output file
	FileDelete($auDir & "\" & $outputFile)

	KWinActivate($title)

	;Try searching for matching pattern 5 times
	local $count = 5
	While 1
		If $count = 0 Then ExitLoop
		KControlCheck( ControlClick($title, "", "[NAME:ToolStrip1]", "left", 1, 85, 12), "Click on Next Packet Arrow.")
		local $mytext = ControlGetText($title, "", "[NAME:viewer]")
		;local $afdtxt = "AFD start code"
		if StringInStr($mytext,$findtext) Then
			$programExitCode=0
			;FileWriteLine($outputFile, ControlGetText($title, "", "[NAME:viewer]"))
			FileWriteLine($auDir & "\" & $outputFile, $mytext)
			$foundpattern = 1
			ExitLoop
		Else
			FileWriteLine($auDir & "\" & $outputFile, $mytext)
			$programExitCode=1
		EndIf
		$count = $count - 1
	WEnd

EndFunc

Func SearchPreviousPacket($findtext)
	;Click on Next Package
	;Remove any previous output file
	FileDelete($auDir & "\" & $outputFile)

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
			FileWriteLine($auDir & "\" & $outputFile, $mytext)
			$foundpattern = 1
			ExitLoop
		Else
			FileWriteLine($auDir & "\" & $outputFile, $mytext)
			$programExitCode=1
		EndIf
		$count = $count - 1
	WEnd

EndFunc

Func CheckAuDescriptor()

	local $datastr = ""

	If $foundpattern == 1 Then
		;decoding au descriptor semantics
		;first extract all 12 digits from the private data section
		GrepSearch($outputFile, "private_data_byte:")
		local $myfile = $auDir & "\" & $outputFile & ".grep"
		;process the grep file
		local $myarray = KFileReadToArray($myfile)
		local $datastr = ""
		If(isarray($myarray)) then
			For $arrayIndex = 1 to $myarray[0]
				;strip any leading and trailing spaces
				$myarray[$arrayIndex] = StringStripWS ( $myarray[$arrayIndex], 8 )
				$myarray[$arrayIndex] = StringReplace($myarray[$arrayIndex], "private_data_byte:", "")
				$myarray[$arrayIndex] = Hex($myarray[$arrayIndex], 2)
				$datastr = $datastr & $myarray[$arrayIndex]
			Next

			;now call the scte128 semantics decoder

		EndIf
	Else
		MsgBox(0, "ERROR", "au Descriptor is not found in the capture stream.")
	EndIf

	return $datastr
EndFunc

Func KWinClose($title, $text="")
	; Closing any previous opening program
	While WinExists($title)
		WinClose($title)
	WEnd
EndFunc

Func KWinActivate($title, $text="", $retry=5)
	local $timeout = 0
	local $wait = 1000
	local $whdl = WinActivate($title, $text)

	While $whdl = 0 And $timeout < $retry
		Sleep($wait)
		$timeout = $timeout + 1
		$whdl = WinActivate($title, $text)
	WEnd

	if $whdl = 0 Then
		Msgbox(0, "ERROR", "Failed to get windows handle " & $timeout & " after " & $retry & " retries.")
	EndIf

    sleep($wait)

	return $whdl
EndFunc

Func KControlCheck($return, $text)
	If $return = 0 Then
		Msgbox(0, "ERROR", $text & " failed.")
	EndIf
EndFunc

Func GrepSearch($file, $pattern)
	local $myapp = "grep.exe"
	local $grepext = ".grep"
	local $found = 0
	local $grepfile = $file&$grepext
	local $mycommand= "cmd /c " & $myapp & " -i " & Chr(34) & $pattern & Chr(34) & " " & $file & " > " & $grepfile

	Runwait($mycommand,$auDir)

	if (FileExists($auDir & "\" & $grepfile) and (FileGetSize($auDir & "\" & $grepfile) > 0))  Then
		$found=1
	EndIf

	return $found
EndFunc

Func KFileReadToArray($file)
	local $array[1]
	$array[0] = 0
	If Not FileExists($file) Then
		MsgBox(0, "ERROR", "File="&$file&" is not exist")
	EndIf
	If (_filereadtoarray($file,$array)=0) Then
		MsgBox(0, "ERROR", "File="&$file&" read errored "&@error)
	EndIf
	return $array
EndFunc
