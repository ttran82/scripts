#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>
#include <GuiListView.au3>
#include <File.au3>

#Autoit3Wrapper_icon=.\Graphics\kleverreport.ico

;turn off "ESC close GUI"
Opt("GUICloseOnESC", 0)

$usageMsg = ""&@crlf& _
			@scriptname &"    Gui for testCase Report."&@crlf& _
			""

Global $CurrentProjectsHome
Global $CurrentTestRun
Global $CurrentTestCase
Global $CurrentJob


main()


;main function
Func main()
	GetHistory()
	kleverReportGUI()
EndFunc

Func kleverReportGUI()
	local $msg,$mycommand

	$maingui = GUICreate("Klever Report",1200,810,-1,-1,$WS_OVERLAPPEDWINDOW)

;menu setup##############################################
	$menuFile = GUICtrlCreateMenu("File")
	$menuEdit = GUICtrlCreateMenu("Edit")
	$menuOption = GUICtrlCreateMenu("Option")
	$menuAbout = GUICtrlCreateMenu("About")
	$menuFileExit = GUICtrlCreateMenuItem("Exit", $menuFile)
	$menuOptionProjectsHome = GUICtrlCreateMenuItem("ProjectsHome Directory", $menuOption)
	$menuAboutVersion = GUICtrlCreateMenuItem("Version", $menuAbout)
	$menuAboutHelp = GUICtrlCreateMenuItem("Help", $menuAbout)

;projectshome selection label######################################
	$guiRefreshTestRunsButton = GUICtrlCreateButton("Refresh", 10,10,60,30, $BS_MULTILINE)
	$CurrentProjectsHome = $kleverProjectSHomeDir
	$guilabel1 = GUICtrlCreateLabel("ProjectsHome Selection=",10,45,120,25)
	$guiCurrentProjectsHomeLabel = GUICtrlCreateLabel($CurrentProjectsHome,130,45,400,25)

;create lever 1 report list#################################################
	Global $guiTestRunReportList = GUICtrlCreateListView("",10,65,1183,125)
	_GUICtrlListView_AddColumn($guiTestRunReportList,"Test Runs",100)
	_GUICtrlListView_AddColumn($guiTestRunReportList,"RunId",50)
	_GUICtrlListView_AddColumn($guiTestRunReportList,"Total Failed",100)
	_GUICtrlListView_AddColumn($guiTestRunReportList,"Total Passed",100)
	_GUICtrlListView_AddColumn($guiTestRunReportList,"Total Errors",100)
	_GUICtrlListView_AddColumn($guiTestRunReportList,"Total Idle",100)
	_GUICtrlListView_AddColumn($guiTestRunReportList,"Total Running",100)
	_GUICtrlListView_AddColumn($guiTestRunReportList,"Total",100)
	_GUICtrlListView_AddColumn($guiTestRunReportList,"Coverage %",95)

;testruns selection label##########################################
	$guiViewSelectedTestRunButton = GUICtrlCreateButton("View"&@CRLF&"TestRun Result",10,200,90,30, $BS_MULTILINE)
	$guiExportTestCasesInfoToCSV = GUICtrlCreateButton("Export"&@CRLF&"TestRun Result",105,200,90,30,$BS_MULTILINE)
	$guilabel2 = GUICtrlCreateLabel("Test Run Selection=",10,235,100,25)
	$guiCurrentTestRunsLabel = GUICtrlCreateLabel("",110,235,400,25)

;create lever 2 report list#################################################
	Global $guiTestCaseReportList = GUICtrlCreateListView("",10,255,1183,480)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"Test Cases",310)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"Status",60)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"RunId",50)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"CaseId",50)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"Run Status",70)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"LastRan Date",100)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"LastRan Result",90)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"LastRan Version",100)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"LastRan Client",100)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"LastRan Tester",100)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"Vulnerability",100)
	_GUICtrlListView_AddColumn($guiTestCaseReportList,"Total Ran",70)

;testcases selection label##########################################
	$guiViewSelectedTestCaseButton = GUICtrlCreateButton("View"&@CRLF&"TestCase History",10,745,90,30, $BS_MULTILINE)

	GUISetState()

;set the sortcallback
	_GUICtrlListView_RegisterSortCallBack($guiTestRunReportList)
	_GUICtrlListView_RegisterSortCallBack($guiTestCaseReportList)
;display
	TestRunReportUpdate()

	While 1
		$msg = GUIGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE or $msg = $menuFileExit; Exit
			HistoryRenew()
			ExitLoop
		Case $msg = $guiRefreshTestRunsButton;refresh the TestRun list
			$CurrentProjectsHome = $kleverProjectSHomeDir
			TestRunReportUpdate()
			GUICtrlSetData($guiCurrentProjectsHomeLabel,$currentProjectsHome)
		Case $msg = $guiViewSelectedTestRunButton;open selected testrun's testcase report
			$selectedTestrunArray = ListviewSelection($guiTestRunReportList)
			If $selectedTestrunArray[0] = 0 Then ContinueLoop
			$selectedTestrun = $selectedTestrunArray[1]
			$CurrentTestRun = $kleverTestRunsDir&"\"&$selectedTestrun
			TestCasesReportUpdate($CurrentTestRun,"*.testcase")
			GUICtrlSetData($guiCurrentTestRunsLabel,$CurrentTestRun)
		Case $msg = $guiViewSelectedTestCaseButton;open selected testcase's detail report
			$selectedTestcaseArray = ListviewSelection($guiTestCaseReportList)
			If $selectedTestcaseArray[0] = 0 Then ContinueLoop
			$selectedTestcase = $selectedTestcaseArray[1]
			$CurrentTestCase = $CurrentTestRun&"\"&$selectedTestcase
			Run("kleverViewCaseHist.exe "&$CurrentTestCase)
		Case $msg = $guiExportTestCasesInfoToCSV
			If Not IsDeclared("selectedTestrun") Then ContinueLoop
			$PathToSave = FileSaveDialog("File Save To..",@DocumentsCommonDir,"Documents(*.csv)", 2+16, $selectedTestrun&"_"&DateString()&".csv")
			If $PathToSave <> "" Then
				GUICtrlListView_SaveCSV($guiTestCaseReportList, $PathToSave)
			EndIf
		Case $msg = $guiTestRunReportList
			_GUICtrlListView_SortItems($guiTestRunReportList, GUICtrlGetState($guiTestRunReportList))
		Case $msg = $guiTestCaseReportList
			_GUICtrlListView_SortItems($guiTestCaseReportList, GUICtrlGetState($guiTestCaseReportList))
		Case $msg = $menuOptionProjectsHome
			$errorcheck = SetDir($kleverProjectSHomeDir,"kleverProjectSHomeDir")
			If $errorcheck = 1 Then ContinueLoop
			HistoryRenew()
			GlobalVariablesRenew()
			$CurrentProjectsHome = $kleverProjectSHomeDir
			TestRunReportUpdate()
			GUICtrlSetData($guiCurrentProjectsHomeLabel,$currentProjectsHome)
		EndSelect
	WEnd
;unset the sortcallback
	_GUICtrlListView_UnRegisterSortCallBack($guiTestRunReportList)
	_GUICtrlListView_UnRegisterSortCallBack($guiTestCaseReportList)
EndFunc

Func ViewTestcaseHistory($case)
	local $msg,$mycommand
	$subgui = GUICreate($CurrentTestCase&" History Report",1200,510,-1,-1,$WS_OVERLAPPEDWINDOW)
	$guiViewLogbutton = GUICtrlCreateButton("View Log",10,10,80,30)
	$guiRefreshLogButton = GUICtrlCreateButton("Refresh", 100,10,80,30)
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
	$exitcheck = JobHistoryUpdate($case)
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
					$mycommand = "tail_win32.exe -f "&$ViewJob&".log"
					Run($mycommand,$CurrentTestRun&"\Logs");,@SW_HIDE)

				Case $msg = $guiRefreshLogButton
					JobHistoryUpdate($case)
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

Func JobHistoryUpdate($case)
	Local $casearray
	Local $exitflag = 0
	HistoryRenew()
	_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($guiTestCaseHistoryReport))
	$casehistory = $CurrentTestRun&"\Info\"&$case&".ran"
	If FileExists($casehistory) Then
		$errorcheck = _FileReadToArray($casehistory,$casearray)
		If $errorcheck = 0 Or $casearray[0] < 1 Then
			msgbox(0,"Error Read History","Unable to read "&$case&"'s history.  Try again later!!!")
			$exitflag = 1
		Else
			For $x = 1 to $casearray[0]
				$line = StringReplace($casearray[$x],",","|")
				GUICtrlCreateListViewItem($line,$guiTestCaseHistoryReport)
			Next
		EndIf
	Else
		msgbox(0,"Error Open History","This testcase "&$case&" does not has a history.")
		$exitflag = 1
	EndIf
	return $exitflag
EndFunc

Func SetDir($dir,$dirvarname)
	$error = 0
	$newdir = InputBox("Setup new path",'Please input the new path. Example:"c:\path". Blank is not allowed',$dir, " M",-1,-1)
	If $newdir <> $dir And $newdir <> "" Then
		assign($dirvarname,$newdir)
	Else
		$error = 1
	EndIf
	Return $error
EndFunc

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

Func GlobalVariablesRenew()
	$kleverTestRunsDir = $kleverProjectSHomeDir&"\TestRuns"
	$kleverTestCasesDir = $kleverTestRunsDir&"\Current"
	$kleverTestcaseConfig = $kleverTestCasesDir&"\Config"
	$kleverTestcaseInfo = $kleverTestCasesDir&"\Info"
	$kleverLogDir = $kleverTestCasesDir&"\Logs"
EndFunc

Func TestCasesReportUpdate($folder, $searchpattern)

	_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($guiTestCaseReportList))

	$caselist = SearchFile($folder,$searchpattern)
	For $x=1 to $caselist[0]

		$currentcasestatusfile = $folder&"\Info\"&$caselist[$x]&".status"
		$currentcasestatus = CurrentCaseStatus($currentcasestatusfile)

		If FileExists($folder&"\Info\"&$caselist[$x]&".running") Then
			$currentTestCaseRunStatus = "Running"
		Else
			$currentTestCaseRunStatus = "Idle"
		EndIf

		$currentcaseidfile = $folder&"\CaseId\"&$caselist[$x]&".caseID"
		$currentcaseID = GetID($currentcaseidfile)

		$currentrunidfile = $folder&"\Config\testrun.runId"
		$currentrunID = GetID($currentrunidfile)

		$currentcaseranfile = $folder&"\Info\"&$caselist[$x]&".ran"
		$currentcaseran = CurrentCaseRan($currentcaseranfile)

		$currentcaselastfile = $folder&"\Info\"&$caselist[$x]&".last"
		$file = FileOpen($currentcaselastfile,0)
		If $file = -1 Then
			$msgtoshow = "N/A"
			$currentVulunerability = "F=0 E=0 P=0"
			GUICtrlCreateListViewItem($caselist[$x]&"|"&$currentcasestatus&"|"&$currentrunID&"|"&$currentcaseID&"|"&$currentTestCaseRunStatus&"|N/A|N/A|N/A|N/A|N/A|"&$currentVulunerability&"|"&$currentcaseran,$guiTestCaseReportList)
		Else
			$lineArg = stringsplit(fileread($file),",")
			Local $Pass = $lineArg[12]
			Local $Fail = $lineArg[13]
			Local $Err = StringStripWS($lineArg[14],2)
			$vpercent = round(($Fail + $Err ) / ($Pass + $Fail + $Err)  * 100)
			$currentVulunerability = $vpercent & "% " & "F="&$Fail&" E="&$Err&" P="&$Pass
			GUICtrlCreateListViewItem($caselist[$x]&"|"&$currentcasestatus&"|"&$currentrunID&"|"&$currentcaseID&"|"&$currentTestCaseRunStatus&"|"&$lineArg[9]&"|"&$lineArg[8]&"|"&$lineArg[5]&"|"&$lineArg[6]&"|"&$lineArg[7]&"|"&$currentVulunerability&"|"&$currentcaseran,$guiTestCaseReportList)
		EndIf
		FileClose($file)
	Next
	;GUICtrlSetData($guiTestcasetotal, $caselist[0]&" found")
EndFunc

Func GetID($file)
	If FileExists($file) Then
		$idfile = FileOpen($file,0)
		If $idfile = -1 Then
			$currentID = "Unknown"
		Else
			$tempidline = stringsplit(FileReadLine($idfile),"=")
			$idline = $tempidline[2]
			FileClose($idfile)
			If StringIsDigit($idline) = 1 Then
				$currentID = $idline
			Else
				$currentID = "N/A"
			EndIf
		EndIf
	Else
		$currentID = "N/A"
	EndIf
	Return $currentID
EndFunc

Func CurrentCaseRan($file)
	If FileExists($file) Then
		$linenum=_FileCountLines($file)
	Else
		$linenum=0
	EndIf
	return $linenum
EndFunc

Func CurrentCaseStatus($file)
	If FileExists($file) Then
		$casestatusfile = FileOpen($file,0)
		If $casestatusfile = -1 Then
			$currentcasestatus = "Unknown"
		Else
			$currentcasestatus = FileReadLine($casestatusfile)
			FileClose($casestatusfile)
		EndIf
	Else
		$currentcasestatus = "Proposed"
	EndIf
	Return $currentcasestatus
EndFunc

Func ListviewSelection($listviewhandle)
	Local $itemindex=_GUICtrlListView_GetSelectedIndices(GUICtrlGetHandle($listviewhandle),True)
	Local $myarray[$itemindex[0]+1]
	$myarray[0] = $itemindex[0]
	;only display the first selecting item even mulitple select
	For $x=1 to $myarray[0]
		$myarray[$x] = _GUICtrlListView_GetItemText(GUICtrlGetHandle($listviewhandle),$itemindex[$x],0)
	Next
	return $myarray
EndFunc

Func TestRunReportUpdate()
	$testrunsfolderlist = SearchFolder($kleverTestRunsDir)
	Global $total,$totalrunning,$totalidle,$totalpass,$totalfail,$totalerror,$coverage

	_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($guiTestRunReportList))
	_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($guiTestCaseReportList))
	For $x = 1 to  $testrunsfolderlist[0]
		$total = 0
		$totalrunning = 0
		$totalidle = 0
		$totalpass = 0
		$totalfail = 0
		$totalerror = 0
		$coverage = 0
		$casefilelist = SearchFile($kleverTestRunsDir&"\"&$testrunsfolderlist[$x],"*.testcase")
		$total = $casefilelist[0]
		$kleverTestCasesDir = $kleverTestRunsDir&"\"&$testrunsfolderlist[$x]
		$kleverTestcaseInfo = $kleverTestCasesDir&"\Info"
		Local $currentrunId = GetID($kleverTestCasesDir&"\Config\testrun.runId")

		For $y = 1 to $casefilelist[0]
			If FileExists($kleverTestcaseInfo&"\"&$casefilelist[$y]&".running") Then
				$totalrunning = $totalrunning + 1
			EndIf
			$caselastfile = $kleverTestcaseInfo&"\"&$casefilelist[$y]&".last"
			If FileExists($caselastfile) Then
				$caselastfileopen = FileOpen($caselastfile,0)
				If $caselastfileopen = -1 Then
					msgbox(0,"Error","Can not read file "&$caselastfile)
				Else
					$line = FileReadLine($caselastfileopen)
					$splitline = StringSplit($line,",")
					If $splitline[8] = "Passed" Then
						$totalpass = $totalpass+1
					ElseIf $splitline[8] = "Failed" Then
						$totalfail = $totalfail+1
					ElseIf $splitline[8] = "Errored" Then
						$totalerror = $totalerror+1
					EndIf
					FileClose($caselastfileopen)
				EndIf
			EndIf
		Next
		$totalidle = $total-$totalpass-$totalfail-$totalerror
		$coverage = round(($totalpass+$totalfail)/$total, 2)*100
		GUICtrlCreateListViewItem($testrunsfolderlist[$x]&"|"&$currentrunId&"|"&$totalfail&"|"&$totalpass&"|"&$totalerror&"|"&$totalidle&"|"&$totalrunning&"|"&$total&"|"&$coverage,$guiTestRunReportList)
	Next

EndFunc

Func SearchFolder($path)
	Local $rawlist = SearchFile($path,"*.*")
	Local $newarray[1]
	$newarray[0] = 0
	$i=0
	If $rawlist[0] > 0 Then
		For $x = 1 to  $rawlist[0]
			$attr = FileGetAttrib($path&"\"&$rawlist[$x])
			If StringRegExp($attr,"D",0)=1 Then
				_ArrayAdd($newarray, $rawlist[$x])
				$i=$i+1
			EndIf
		Next
		$newarray[0] = $i
	EndIf
	return $newarray
EndFunc

Func SearchFile($searchdir,$searchpattern)
	Local $filenamelist[1]
	Local $lastindex=0
	$search = FileFindFirstFile($searchdir&"\"&$searchpattern)

	while 1
		$searchresult = FileFindNextFile($search)
		If @error Then ExitLoop
		$lastindex = _ArrayAdd($filenamelist, $searchresult)
	WEnd
	$filenamelist[0]=$lastindex
	FileClose($search)
	FileClose($searchresult)
	Return $filenamelist
EndFunc

; #FUNCTION# =========================================================================================================
; Name...........: _GUICtrlListView_SaveCSV()
; Description ...: Exports the details of a ListView to a .csv file.
; Syntax.........: _GUICtrlListView_SaveCSV($hListView, $sFile, [$sDelimiter = ",", $sQuote = '"']])
; Parameters ....: $hListView - Handle of the ListView.
;                  $sFile - FilePath, this should ideally use the filetype .csv e.g. @ScriptDir & "\Example.csv"
;                  $sDelimiter - [Optional] Delimiter to be used for the csv file. [Default = ,]
;                  $sQuote - [Optional] Style of quotes to be used for the csv file. [Default = "]
; Requirement(s).: v3.2.12.1 or higher
; Return values .: Success - Returns filepath.
;                  Failure - Returns filepath & sets @error = 1
; Author ........: guinness & ProgAndy for the csv idea.
; Example........; Yes
;=====================================================================================================================
Func GUICtrlListView_SaveCSV($hListView, $sFile)
    Local $hFileOpen, $iError = 0, $sItem, $sString
    Local $iColumnCount = _GUICtrlListView_GetColumnCount($hListView)
    Local $iItemCount = _GUICtrlListView_GetItemCount($hListView)

	$sColName = "Test Cases,Status,RunID,CaseID,Run Status,LastRan Date,LastRan Result,LastRan Version,LastRan Client,LastRan Tester,Vulnerability,Total Ran"&@CRLF
	$sString &= $sColName
    For $A = 0 To $iItemCount - 1
        For $B = 0 To $iColumnCount -1
            $sItem = _GUICtrlListView_GetItemText($hListView, $A, $B)
			$sString &= $sItem
            ;$sString &= $sQuote & StringReplace($sItem, $sQuote, $sQuote & $sQuote, 0, 1) & $sQuote
            If $B < $iColumnCount - 1 Then
                $sString &= ","
            EndIf
			;msgbox(0,"",$sString)
        Next
        $sString &= @CRLF
    Next
    $hFileOpen = FileOpen($sFile, 2)
    FileWrite($hFileOpen, $sString)
    FileClose($hFileOpen)
    If @error Then
        $iError = 1
    EndIf
    Return SetError($iError, 0, $sFile)
EndFunc

Func DateString()
	Return @year&@mon&@Mday&"_"&@hour&@min&@sec
EndFunc