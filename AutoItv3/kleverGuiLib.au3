#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GuiListBox.au3>
#include <File.au3>

Func ViewTestcaseHistory($case)
	local $msg,$mycommand
	$subgui = GUICreate($CurrentTestCase&" History Report",1200,510,-1,-1,$WS_OVERLAPPEDWINDOW)
	$guiViewLogbutton = GUICtrlCreateButton("View Log",10,10,80,30)
	$guiRefreshLogButton = GUICtrlCreateButton("Refresh", 100,10,80,30)
	$guiStopButton = GUICtrlCreateButton("Stop Test",190,10,80,30)
	$guiViewLocalButton = GUICtrlCreateButton("View Local JobDir",280,10,100,30)
	$guiViewNetworkedButton = GUICtrlCreateButton("View Network JobDir",390,10,120,30)
	;$guiViewJobbutton = GUICtrlCreateButton("View Job",95,10,80,30)
	Global $guiTestCaseHistoryReport = GUICtrlCreateListView("",10,50,1180,450)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"JobID",120)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"EncIP",100)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"RunId",60)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"CaseId",60)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"EncVersion",100)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"ComputerName",100)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"TesterName",100)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"TestcaseResult",100)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"Finishedtime",100)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"Duration",80)
	_GUICtrlListView_AddColumn($guiTestCaseHistoryReport,"MISC",200)

	GUISetState()
	$exitcheck = JobHistoryUpdate($case,$guiTestCaseHistoryReport)
	If $exitcheck = 0 Then
		_GUICtrlListView_RegisterSortCallBack($guiTestCaseHistoryReport)
		While 1
			$msg = GUIGetMsg()
			Select
				Case $msg = $GUI_EVENT_CLOSE
					ExitLoop
				Case $msg = $guiViewLogbutton
					$selectedJob = ListviewSelection($guiTestCaseHistoryReport)
					If $selectedJob[0] = 0 Then ContinueLoop
					$ViewJob = $selectedJob[1]
					local $mytailcommand = "Wintail.exe"
					If EnvGet('tailCmd') <> "" Then
						$mytailcommand = EnvGet('tailCmd')
					EndIf

					$mycommand = $mytailcommand & " "&$ViewJob&".log"
					Run($mycommand,$CurrentTestRun&"\Logs")
				Case $msg = $guiRefreshLogButton
					JobHistoryUpdate($case,$guiTestCaseHistoryReport)
				Case $msg = $guiViewLocalButton
					$selectedJob = ListviewSelection($guiTestCaseHistoryReport)
					If $selectedJob[0] = 0 Then ContinueLoop
					$ViewJob = $selectedJob[1]
					$JobFolder = JobLogToFolder($ViewJob&".log",$CurrentTestRun&"\Logs")
					If FileExists($JobFolder) Then
						Run("explorer.exe "&$JobFolder)
					ElseIf $JobFolder = 0 Then
						msgbox(0,"Error","Can not find the Job log.",20)
					Else
						msgbox(0,"Error","Can not find the Job Folder.",20)
					EndIf
				Case $msg = $guiViewNetworkedButton
					$selectedJob = ListviewSelection($guiTestCaseHistoryReport)
					If $selectedJob[0] = 0 Then ContinueLoop
					$ViewJob = $selectedJob[1]
					;$remotePc = $selectedJob[6]
					$remotePc = ListviewSelection($guiTestCaseHistoryReport, 5)
					$JobFolder = JobLogToFolder($ViewJob&".log",$CurrentTestRun&"\Logs")
					;Now we need to convert current JobFolder to networked version
					$JobFolderSplit = stringsplit($JobFolder,":")
					$NetworkedJobFolder = "\\"&$remotePc[1]&"\"&$JobFolderSplit[1]&"$"&$JobFolderSplit[2]

					If FileExists($NetworkedJobFolder) Then
						Run("explorer.exe "&$NetworkedJobFolder)
					ElseIf $NetworkedJobFolder = 0 Then
						msgbox(0,"Error","Can not find the networked Job Dir.  Try to access "&"\\"&$remotePc[1]& " and provide login/password if prompted.",20)
					Else
						msgbox(0,"Error","Can not find the Job Folder.  Try to access "&"\\"&$remotePc[1]& " and provide login/password if prompted.",20)
					EndIf
				Case $msg = $guiStopButton
					$selectedJob = ListviewSelection($guiTestCaseHistoryReport)
					If $selectedJob[0] = 0 Then ContinueLoop
					$ViewJob = $selectedJob[1]
					;create stop file
					If FileExists($CurrentTestRun&"\Info\"&$case&".running") Then
						local $stopfile = FileOpen($CurrentTestRun&"\Logs\"&$ViewJob&".log.STOP", 2)
						FileWriteLine($stopfile,"Stopped by " & envGet("testerName") & " from " & @ComputerName)
						FileClose($stopfile)
					EndIf

				Case $msg = $guiTestCaseHistoryReport
					_GUICtrlListView_SortItems($guiTestCaseHistoryReport, GUICtrlGetState($guiTestCaseHistoryReport))
			EndSelect
		WEnd
		_GUICtrlListView_UnRegisterSortCallBack($guiTestCaseHistoryReport)
		GUIDelete()
	Else
		GUIDelete()
	EndIf
EndFunc

Func JobLogToFolder($logfile,$logfileFolder)
	Local $path = 0
	If FileExists($logfileFolder&"\"&StringStripWS($logfile,3)) Then
		$pattern = "TestScriptWorkingDir="
		$grepfile = @TempDir&"\grep.tmp"
		;delete previous grep file
		FileDelete($grepfile)

		$mycommand="grep.exe "&'"'&$pattern&'"'&" "&$logfileFolder&"\"&StringStripWS($logfile,3)&" > "&$grepfile
		RunWait(@ComSpec&" /c "&$mycommand,@TempDir,@SW_HIDE)
		if (FileExists($grepfile) and (FileGetSize($grepfile) > 0))  Then
			$line = Filereadline($grepfile)
			$splitline = stringsplit($line,"=")
			If IsArray($splitline) Then
				$path = $splitline[2]
			EndIf
		EndIf
	EndIf
	Return $path
EndFunc

Func JobHistoryUpdate($case,$guihandle)
	Local $casearray1,$casearray2
	Local $exitflag = 0
	;for kleverreport renew history
	If StringRegExp(@ScriptName, "KleverReport") Then
		HistoryRenew()
	EndIf
	_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($guihandle))
	$caserunning = $CurrentTestRun&"\Info\"&$case&".running"
	$casehistory = $CurrentTestRun&"\Info\"&$case&".ran"
	If Not FileExists($casehistory) And Not FileExists($caserunning) Then
		msgbox(0,"History not Found","Testcase "&$case&" does not has a history.")
		$exitflag = 1
	EndIf

	If FileExists($casehistory) Then
		$errorcheck = _FileReadToArray($casehistory,$casearray2)
		If $errorcheck = 0 Or $casearray2[0] < 1 Then
			msgbox(0,"Error Read History","Unable to read "&$case&"'s history.  Try again later!!!")
			$exitflag = 1
		Else
			For $x = 1 to $casearray2[0]
				$line = StringReplace($casearray2[$x],",","|")
				GUICtrlCreateListViewItem($line,$guihandle)
			Next
		EndIf
	EndIf

	If FileExists($caserunning) Then
		$errorcheck = _FileReadToArray($caserunning,$casearray1)
		If $errorcheck = 1 Then
			For $x = 1 to $casearray1[0]
				$line = StringReplace($casearray1[$x],",","|")
				GUICtrlCreateListViewItem($line,$guihandle)
			Next
		EndIf
	EndIf
	return $exitflag
EndFunc

Func JobCurrentRunningUpdate($case,$guihandle)
	$casecurrentrunning = $CurrentTestRun&"\Info\"&$case&".running"
EndFunc

Func ListviewSelection($listviewhandle, $subitem=0)
	Local $itemindex=_GUICtrlListView_GetSelectedIndices(GUICtrlGetHandle($listviewhandle),True)
	Local $myarray[$itemindex[0]+1]
	$myarray[0] = $itemindex[0]
	;only display the first selecting item even mulitple select
	For $x=1 to $myarray[0]
		$myarray[$x] = _GUICtrlListView_GetItemText(GUICtrlGetHandle($listviewhandle),$itemindex[$x],$subitem)
	Next
	return $myarray
EndFunc

Func ListBoxGetAllItems($guiHandle)
	Local $azArray[1]
	$azArray[0] = 0
	$totalitems = _GUICtrlListBox_GetCount($guiHandle)
	If $totalitems > 0 Then
		For $i = 0 To $totalitems - 1
			_ArrayAdd($azArray, _GUICtrlListBox_GetText($guiHandle, $i))
		Next
		$azArray[0] = $totalitems
	EndIf
	Return $azArray
EndFunc

Func ListViewGetAllItems($guiHandle)
	Local $azArray[1]
	$azArray[0] = 0
	$totalitems = _GUICtrlListView_GetItemCount($guiHandle)
	If $totalitems > 0 Then
		For $i = 0 To $totalitems - 1
			_ArrayAdd($azArray, _GUICtrlListView_GetItemText($guiHandle, $i))
		Next
		$azArray[0] = $totalitems
	EndIf
	Return $azArray
EndFunc

;used by kleverreport
Func GetHistory()
	Local $historyarray
	$reporthistory = @ScriptDir&"\"&@ScriptName&".hist"
	If FileExists($reporthistory) Then
		$historyfile = FileOpen($reporthistory,0)
		If $historyfile = -1 Then
			msgbox(0,"Error", "Can not read history file "&@ScriptDir&"\"&@ScriptName&".hist",10)
		Else
			$line = FileReadLine($historyfile)
			Global $kleverProjectSHomeDir=$line
			FileClose($historyfile)
		EndIf
	Else
		If FileExists(@ScriptDir&"\klever.hist") Then
			$mycommand = "grep -i kleverprojecthome klever.hist > greptmp.txt"
			RunWait("Cmd /c "&$mycommand,@ScriptDir,@SW_HIDE)
			$errorcheck = _FileReadToArray(@ScriptDir&"\greptmp.txt",$historyarray)
			If $errorcheck = 1 And $historyarray[0] > 0 Then
				$historyline = StringSplit($historyarray[1],"=")
				Global $kleverProjectSHomeDir=StringStripWS($historyline[2],2)
				FileDelete(@ScriptDir&"\greptmp.txt")
			EndIf
		Else
			Global $kleverProjectSHomeDir=@ScriptDir&"\ProjectSHome"
		EndIf
	EndIf
	Global $kleverTestRunsDir = $kleverProjectSHomeDir&"\TestRuns"
	Global $kleverTestCasesDir = $kleverTestRunsDir&"\Current"
	Global $kleverTestcaseConfig = $kleverTestCasesDir&"\Config"
	Global $kleverTestcaseInfo = $kleverTestCasesDir&"\Info"
	Global $kleverLogDir = $kleverTestCasesDir&"\Logs"
EndFunc

;used by kleverreport
Func HistoryRenew()
	$reporthistory = @ScriptDir&"\"&@ScriptName&".hist"
	$historyfile = FileOpen($reporthistory,2)
	If $historyfile = -1 Then
		msgbox(0,"Error", "Can not renew history file "&$reporthistory)
	Else
		FileWriteLine($historyfile,$kleverProjectSHomeDir)
		FileClose($historyfile)
	EndIf
EndFunc

Func SearchInFile($file, $pattern)
	local $myapp = "grep.exe"
	local $grepext = ".grep"
	local $found = 0
	local $grepfile = $file&$grepext
	local $mycommand=$myapp &" -i "&$pattern&" "&$file&" > "&$grepfile

	RunWait($mycommand,@workingDir)

	if (FileExists($grepfile) and (FileGetSize($grepfile) > 0))  Then
		$found=1
	EndIf
	return $found
EndFunc

;#################################################################
;ScriptCleanUp   will modify the origin File
;cleanup "#" line and white space
;#################################################################
Func TestCaseCleanUp($filepath)
	Dim $preclean
	If Not _FileReadToArray($filepath,$preclean) Then
		MsgBox(4096,"Error", "Error reading file "&$filepath)
		Exit
	EndIf
	$clean = FileOpen($filepath,2)
	for $lop = 1 to $preclean[0]

		;Msgbox(0, "TTT", $preclean[$lop]);
		$result1 = StringCompare($preclean[$lop],"")
		$result2 = StringCompare($preclean[$lop]," ")
		;$result3 = StringCompare(Stringleft($preclean[$lop],1),"#")
		If $result1 <> 0 And $result2 <> 0 Then
			FileWriteLine($clean,$preclean[$lop])

		EndIf
	Next
	fileclose($clean)
EndFunc

;##################################################################
;function to setup dataEth. Now works on remote machine
;##################################################################
Func SetupDataEth()
	If IsDeclared("dataEth") Then

		;Handle TSReader

		local $regfile = $kleverSystemConfig&"\Klever_UDPMulticast.reg"
		RegImport($regfile)
		$regfile = $kleverSystemConfig&"\Klever_UDPUnicast.reg"
		RegImport($regfile)
		$regfile = $kleverSystemConfig&"\Klever_RTPMulticast.reg"
		RegImport($regfile)
		$regfile = $kleverSystemConfig&"\Klever_RTPUnicast.reg"
		RegImport($regfile)

		;Change routing table for VLC to receive multicast address
		$mycommand = "route delete "&EnvGet("igmpMulticastAddr")
		RunCommand($mycommand, @WorkingDir, 1,1)
		$mycommand = "route add " & EnvGet("igmpMulticastAddr") & " mask " & EnvGet("igmpMulticastMask") & " " & eval("dataEth") & " metric " & EnvGet("igmpMulticastMetric")
		RunCommand($mycommand, @WorkingDir, 1,1)
	EndIf
EndFunc

Func RegImport($regfile)
	local $msgtowrite = '"UDPMulticastInterface"="'&eval("dataEth")&'"'
	If FileExists($regfile) Then
		$linenum = _FileCountLines($regfile)
		KFileWriteToLine($regfile,$linenum,$msgtowrite,1)
		local $mycommand = "reg import "& chr(34) & $regfile & chr(34)
		RunWait("cmd /c "&$mycommand, $kleverSystemConfig)
	Else
		msgbox(0,"Error",$regfile&" is not exists.",15)
	EndIf
EndFunc