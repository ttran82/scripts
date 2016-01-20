#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GuiListBox.au3>
#include <ButtonConstants.au3>
#include <Array.au3>
#include <File.au3>

#include <.\KleverLib.au3>
#include <.\KleverWinLib.au3>
#include <.\KMpegTSLib.au3>

Opt("GUICloseOnESC", 0)

;Flow of the main program
;Global @WorkingDir = @WorkingDir
Global $auoutFile = "au_info.out"
Global $aucmd = "auto_au_decode.exe"
Global $ptscmd = "auto_first_pts.exe"

main()

Func main()
	KleverAuInfoMain()
EndFunc

Func KleverAuInfoMain()
	Local $msgkse
	Local $displaystate=BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY)
	Local $currentitem=""

	$maingui = GUICreate("MPEG-2 TS Packet Extended Analyzer", 800, 720, -1, -1, BitOr($GUI_SS_DEFAULT_GUI,$WS_OVERLAPPEDWINDOW,$WS_EX_ACCEPTFILES))
	;create search related
	$menuFile = GUICtrlCreateMenu("File")
	$menuFileOpen = GUICtrlCreateMenuItem("Open", $menuFile)
	$menuFileExit = GUICtrlCreateMenuItem("Exit", $menuFile)

	$guiFileLable = GUICtrlCreateLabel("VideoPid:", 5, 5, 60 ,20)
	$guiVideoPid = GUICtrlCreateinput("32",55, 2, 45, 20)
	$guiFileLable = GUICtrlCreateLabel("AudioPid:", 110, 5, 60 ,20)
	$guiAudioPid = GUICtrlCreateinput("33",160, 2, 45, 20)

	$guiFileLable = GUICtrlCreateLabel("File:", 5, 30, 20 ,20)
	$guiFilePath = GUICtrlCreateinput("",27, 27, 500, 20)

	$guiFileAnalyzePrevious = GUICtrlCreateButton("Previous", 580, 5, 70,20)
	GUICtrlSetState($guiFileAnalyzePrevious, $GUI_DISABLE)
	$guiFileAnalyze = GUICtrlCreateButton("Au Analyze", 650, 5, 70,20)
	$guiPTSAnalyze = GUICtrlCreateButton("First PTS", 650, 25, 70,20)

	GUICtrlSetState($guiFileAnalyze, $GUI_DISABLE)
	GUICtrlSetState($guiPTSAnalyze, $GUI_DISABLE)

	$guiFileAnalyzeNext = GUICtrlCreateButton("Next", 720, 5, 70,20)
	GUICtrlSetState($guiFileAnalyzeNext, $GUI_DISABLE)

	$guiAuPrivateDataLable = GUICtrlCreateLabel("Au Hex Data:", 5, 55, 90 , 20)
	$guiAuPrivateData = GUICtrlCreateinput("",75, 53, 280, 20)
	$guiAuDecodeButton = GUICtrlCreateButton("Au Single Decode", 400, 53, 100,20)

	;create an editbox
	$guidisplayeditbox = GUICtrlCreateEdit("Display",5, 85, 720, 700 ,$displaystate)

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
					Assign("outputFile", $aucmd & ".out", 2)
					runAuDecode(GUICtrlRead($guiAuPrivateData))

					;now display output
					KDisplayEditArea($guidisplayeditbox, eval("outputFile"))

				Case $msg = $menuFileOpen
					local $selectedFile = FileOpenDialog("Select the captured file to be analyzed", @WorkingDir & "\", "All (*.*)")
					If $selectedFile Then
						GUICtrlSetData($guiFilePath, $selectedFile)
						GUICtrlSetState($guiFileAnalyze, $GUI_ENABLE)
						GUICtrlSetState($guiPTSAnalyze, $GUI_ENABLE)
					EndIf

				Case $msg = $guiFileAnalyze
					;First Open MPEG2 TS Analyzer
					local $myfile = GUICtrlRead($guiFilePath)
					runMPEG2Analyzer($myfile)
					Assign("outputFile", $aucmd & ".out", 2)
					SelectFilterPayload()
					SelectFilterPid()
					EditFilterPid(GUICtrlRead($guiVideoPid))
					SearchNextPacket("Transport_private_data_length:")
					local $myreturn = CheckAuDescriptor()
					GUICtrlSetData($guiAuPrivateData, $myreturn)
					runAuDecode(GUICtrlRead($guiAuPrivateData))
					;now display output
					KDisplayEditArea($guidisplayeditbox, eval("outputFile"))
					GUICtrlSetState($guiFileAnalyzeNext, $GUI_ENABLE)
					GUICtrlSetState($guiFileAnalyzePrevious, $GUI_ENABLE)

				Case $msg = $guiFileAnalyzeNext
					SearchNextPacket("Transport_private_data_length:")
					local $myreturn = CheckAuDescriptor()
					GUICtrlSetData($guiAuPrivateData, $myreturn)
					Assign("outputFile", $aucmd & ".out", 2)
					runAuDecode(GUICtrlRead($guiAuPrivateData))
					;now display output
					KDisplayEditArea($guidisplayeditbox, eval("outputFile"))

				Case $msg = $guiFileAnalyzePrevious
					SearchPreviousPacket("Transport_private_data_length:")
					local $myreturn = CheckAuDescriptor()
					GUICtrlSetData($guiAuPrivateData, $myreturn)
					Assign("outputFile", $aucmd & ".out", 2)
					runAuDecode(GUICtrlRead($guiAuPrivateData))
					;now display output
					KDisplayEditArea($guidisplayeditbox, eval("outputFile"))

				Case $msg = $guiPTSAnalyze
					local $myfile = GUICtrlRead($guiFilePath)
					local $videopid = GUICtrlRead($guiVideoPid)
					local $audiopid = GUICtrlRead($guiAudioPid)

					;now display output
					Assign("outputFile", $ptscmd & ".out", 2)
					runFindFirstPTS($myfile, $videopid, $audiopid)
					KDisplayEditArea($guidisplayeditbox, eval("outputFile"))

			EndSelect
	WEnd

EndFunc

Func runAuDecode($data)
	;call auto_au_decode
	local $mycmd = $aucmd & " privateData=" & $data
	;remove previous output file
	FileDelete(@WorkingDir & "\" & eval("outputFile"))
	RunWait($mycmd, @WorkingDir)
EndFunc

Func runFindFirstPTS($myfile, $vpid, $apid)
	local $mycmd = $ptscmd & " inputFile=" & $myfile & " videoPid="&$vpid & " audioPid="&$apid
	FileDelete(@WorkingDir & "\" & eval("outputFile"))
	RunWait($mycmd, @WorkingDir)
EndFunc

Func CheckAuDescriptor()
	local $datastr = ""

	If $foundpattern == 1 Then
		;decoding au descriptor semantics
		;first extract all 12 digits from the private data section
		GrepSearch(Eval("outputFile"), "private_data_byte:")
		local $myfile = @WorkingDir & "\" & Eval("outputFile") & ".grep"
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

