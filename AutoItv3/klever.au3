#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=.\Graphics\klever.ico
#AutoIt3Wrapper_Res_Comment=This is a test platform.
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GuiComboBox.au3>
#include <ComboConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <kleverLib.au3>
#include <kleverGuiLib.au3>
#include <KleverPasswordLib.au3>
#include <Crypt.au3>

;icon attach and program info
;#AutoIt3Wrapper_Res_Fileversion=1.2

;turn off "ESC close GUI"
Opt("GUICloseOnESC", 0)

Global $caselist, $scriptlist
Global $CurrentProjectsHome
Global $CurrentTestRun
Global $CurrentTestCase
Global $guiTesterSelect
Global $menuAdmin
Global $guiTestCaseFolderSelect
Global $guiTestCasefolderButton
Global $guiScriptfolderButton
Global $guiWorkingfolderButton
Global $guiLogfolderButton
Global $guiRunId
Global $guiTestrunCopy
Global $guiTestrunSelect

$usageMsg = ""&@crlf& _
			@scriptname &"    Gui for testCase create,modify,execute."&@crlf& _
			""

;flow

GetRunId()
RenewEnv()
ReadHistory() ; only gui need to read history file

$kleverTestRunsDir = $kleverProjectHome&"\TestRuns"
$kleverScriptHomeDir = $kleverProjectHome&"\ScriptHome"
$kleverLogDir = $kleverTestCasesDir&"\Logs"

$logFile = $kleverHome&"\Logs\"&@scriptname&"_"&dateString()&".log"
ProgramStart()
main()
ProgramEnd()

;main function
Func main()
	klevergui()
EndFunc

Func klevergui()
	local $msg,$mycommand
	Local $itemindex

	$kleverTestcaseConfig = $kleverTestCasesDir&"\Config"
	$kleverTestcaseInfo = $kleverTestCasesDir&"\Info"
	Global $currentTestrunConfig=$kleverTestcaseConfig&"\"&$testrunconfig
	$kleverLogDir = $kleverTestCasesDir&"\Logs"
	$kleverDeviceConfig = $kleverTestcaseConfig&"\Devices"


	InitialGuiTempVariables()

	Global $maingui = GUICreate("Klever Execution",1280,740,-1,-1)

;menu creation###########################################################################
	$menuFile = GUICtrlCreateMenu("File")
	$menuView = GUICtrlCreateMenu("View")
	$menuEdit = GUICtrlCreateMenu("Edit")
	$menuOption = GUICtrlCreateMenu("Options")
	$menuAdmin = GUICtrlCreateMenu("Admin")
	DisableGUI($menuAdmin)
	$menuAbout = GUICtrlCreateMenu("About")

	$menuFileExit = GUICtrlCreateMenuItem("Exit", $menuFile)
	$menuViewReport = GUICtrlCreateMenuItem("Report", $menuView)
	$menuViewAppLog = GUICtrlCreateMenuItem("Appilication Log", $menuView)
	$menuViewEncoderInUsed = GUICtrlCreateMenuItem("Encoder-In-Used", $menuView)
	$menuViewRunningTestcase = GUICtrlCreateMenuItem("Running Test Cases", $menuView)
	$menuViewTempDir = GUICtrlCreateMenuItem("Temp Dir", $menuView)

	$menuEditDeviceConfig = GUICtrlCreateMenuItem("Edit DeviceConfig",$menuEdit)
	$menuEditTestCase = GUICtrlCreateMenuItem("Edit TestCase",$menuEdit)
	$menuEditTestRunConfig = GUICtrlCreateMenuItem("Edit TestRunConfig",$menuEdit)
	$menuEditTestCaseAssessment = GUICtrlCreateMenuItem("Edit TestCase Assessment",$menuEdit)
	$menuEditSystemConfig = GUICtrlCreateMenuItem("Edit SystemConfig",$menuEdit)

	$menuOptionChangePass = GUICtrlCreateMenuItem("Change Password", $menuOption)
	$menuOptionWorkingDir = GUICtrlCreateMenuItem("Change Working Directory", $menuOption)
	$menuOptionProjectHome = GUICtrlCreateMenuItem("Change ProjectHome Directory", $menuOption)
	$menuOptionTempDir = GUICtrlCreateMenuItem("Change Temp Directory", $menuOption)
	$menuOptionFactorySetting = GUICtrlCreateMenuItem("Reset To Local Setting", $menuOption)

	$menuAdminManageTesters = GUICtrlCreateMenuItem("Manage Testers", $menuAdmin)

	$menuAboutVersion = GUICtrlCreateMenuItem("Version", $menuAbout)
	$menuAboutReleaseNotes = GUICtrlCreateMenuItem("Release Notes", $menuAbout)
	$menuAboutHelp = GUICtrlCreateMenuItem("Help", $menuAbout)

	Global $guiTab = GUICtrlCreateTab(5, 0, 1280, 740)
;encoder Run Tab ###########################################################################
	Global $guiRunTab = GUICtrlCreateTabItem("Run")

	$guiLabelencip = GUICtrlCreateLabel("Encoder IP", 10,30,100,20)
	Global $guiEncip = GUICtrlCreateInput($encIp,10,50,100,20)
	$guiLabelloginid = GUICtrlCreateLabel("Login", 120,30,100,20)
	Global $guiLoginid = GUICtrlCreateInput($loginId,120,50,100,20)
	$guiLabelpassword = GUICtrlCreateLabel("Password", 230,30,200,20)
	Global $guiPassword = GUICtrlCreateInput($passWord,230,50,200,20,0x0020)

;Test case option function###########################################################################
	;jobid input
	Global $guiJobidcheckbox = GUICtrlCreateCheckbox("JobId Override", 440, 25, 100,20)
	Global $guiJobidinput = GUICtrlCreateInput("Current", 440,50,100,20)
	DisableGUI($guiJobidinput)
	;hubinfo input
	Global $guiHubcheckbox = GUICtrlCreateCheckbox("Videohub outPort", 550, 25, 100,20)
	Global $guiHubinput = GUICtrlCreateInput($tempHubInput, 550,50,100,20)
	DisableGUI($guiHubinput)

	;device config select combobox
	Global $guiDeviceConfcheckbox = GUICtrlCreateCheckbox("Device Config", 660, 25, 200,20)
	Global $guiDeviceConfSelect = GUICtrlCreateCombo("", 660,50,200,20, $CBS_DROPDOWNLIST)
	local $Devicelist = SearchFile($kleverDeviceConfig, "*.cfg")
	InsertComboItem($guiDeviceConfSelect, $Devicelist)
	DisableGUI($guiDeviceConfSelect)

	;tester selectcombobox
	$guiTesterlabel = GUICtrlCreateLabel("Select Tester", 870, 30, 100, 20)
	$guiTesterSelect = GUICtrlCreateCombo($tempTesterName, 870,50,100,20,$CBS_DROPDOWNLIST)
	AssignVariable("TesterDbDir", $kleverSystemConfig&"\Testers")
	If KFileExists($kleverProjectHome&"\Configs\Testers") Then
		AssignVariable("TesterDbDir", $kleverProjectHome&"\Configs\Testers")
	Else
		Msgbox(32, "Missing Global User DB Dir", "Local User DB Dir will be used instead.")
		$kleverProjectHome = EnvGet("kleverHome")&"\ProjectSHome"
		AssignVariable("TesterDbDir", $kleverProjectHome&"\Configs\Testers")
		KleverProjectSHome_Setup()
	EndIf
	local $Testerlist = _FileListToArray(EnvGet("TesterDbDir"), "*", 1)
	InsertComboItem($guiTesterSelect, $Testerlist)

	;remoteclient
	Global $guiRemoteClientcheckbox = GUICtrlCreateCheckbox("Remote Client",980,25,100,20)
	Global $guiRemoteClientinput = GUICtrlCreateInput(eval("remoteClient"),980,50,100,20)
	DisableGUI($guiRemoteClientinput)

;create test case related items##################################################################

	;test case filter radios
	#cs
	GUICtrlCreateGroup("TestCase Filter", 5, 105, 370, 40)
	GUIStartGroup()
	$guiCasefilterAll = GUICtrlCreateRadio("ALL", 10, 118, 60,20)
	$guiCasefilterPass = GUICtrlCreateRadio("PASS", 70, 118, 60,20)
	$guiCasefilterFail = GUICtrlCreateRadio("FAIL", 130, 118, 60,20)
	GUIStartGroup()
	$guiCasefilterPropose = GUICtrlCreateRadio("PROPOSE", 220, 118, 70,20)
	$guiCasefilterConfirm = GUICtrlCreateRadio("CONFIRM", 290, 118, 70,20)
	GUICtrlSetState($guiCasefilterAll, $GUI_CHECKED)
	GUICtrlSetState($guiCasefilterPropose, $GUI_CHECKED)
	#ce

	local $guiCurrentTestRunlabel = GUICtrlCreateLabel("Current TestRun:", 10, 90, 100, 20)
	Global $guiCurrentTestRun = GUICtrlCreateLabel("", 120, 90, 530, 20)

	;test case search
	$guiTestcaserefresh = GUICtrlCreateButton("Case Refresh", 660, 90, 75, 20)
	$guiTestcasesearchinput = GUICtrlCreateInput("", 745, 90, 240, 20)
	$guiTestcasesearch = GUICtrlCreateButton("Case Search", 995, 90, 75, 20)
	GUICtrlSetState($guiTestcasesearchinput, $GUI_DROPACCEPTED)
	Global $guiTestcasetotal = GUICtrlCreateLabel("",1080,90,100,20)


	;test case list
	Global $guiCaselist = GUICtrlCreateListView("", 10, 120, 1260, 520,$LVS_SHOWSELALWAYS)
	_GUICtrlListView_AddColumn($guiCaselist,"TestCases",550)
	_GUICtrlListView_AddColumn($guiCaselist,"Status",60)
	_GUICtrlListView_AddColumn($guiCaselist,"CaseID",250)
	_GUICtrlListView_AddColumn($guiCaselist,"Run Status",80)
	_GUICtrlListView_AddColumn($guiCaselist,"LastRan Date",100)
	_GUICtrlListView_AddColumn($guiCaselist,"LastRan Result",90)
	_GUICtrlListView_AddColumn($guiCaselist,"LastRan Computer",120)

;convienient tool################################################################################
	$guiOpenConsole = GUICtrlCreateButton("Open Console", 1105, 30,80,20)
	$guiOpenSSH = GUICtrlCreateButton("Open SSH", 1105, 50,80,20)
	$guiOpenBrowser = GUICtrlCreateButton("Open Browser", 1185, 50, 80, 20)
	$guiOpenTelnet6010 = GUICtrlCreateButton("Telnet 6010", 1105, 70,80,20)
	$guiOpenJAVAClient = GUICtrlCreateButton("Open JAVA", 1185, 70,80,20)

;test case list related buttons######################################################
	$guiExecute = GUICtrlCreateButton("Execute" ,10, 645, 50, 30)
	$guiExecutePreView = GUICtrlCreateButton("Preview" ,10, 675, 50, 30)
	$guiCaseIdModify = GUICtrlCreateButton("Assign"&@CRLF&"CaseID", 60, 645, 50, 30, $BS_MULTILINE)
	$guiViewCaseHistory = GUICtrlCreateButton("View"&@CRLF&"Case History", 60, 675, 100, 30, $BS_MULTILINE)
	$guiClearCaseHistory = GUICtrlCreateButton("Clear"&@CRLF&"Case History", 160, 675, 100, 30, $BS_MULTILINE)
	$guiEditCaseAssessment = GUICtrlCreateButton("Edit"&@CRLF&"Case Assessment", 260, 675, 100, 30, $BS_MULTILINE)

	$guiRemovecase = GUICtrlCreateButton("Remove"&@crlf&"Case", 110, 645, 50, 30, $BS_MULTILINE)
	DisableGUI($guiRemovecase)
	$guiSchedulecase = GUICtrlCreateButton("Sche"&@crlf&"Case", 160, 645, 50, 30, $BS_MULTILINE)
	DisableGUI($guiSchedulecase)

	$guiProposecase = GUICtrlCreateButton("Propose"&@crlf&"Case", 210, 645, 50, 30, $BS_MULTILINE)
	$guiConfirmcase = GUICtrlCreateButton("Confirm"&@crlf&"Case", 260, 645, 50, 30, $BS_MULTILINE)
	$guiBlockcase = GUICtrlCreateButton("Block"&@crlf&"Case", 310, 645, 50, 30, $BS_MULTILINE)

	$guiExecueAll = GUICtrlCreateButton("Execute"&@crlf&"All",370, 645, 60, 30, $BS_MULTILINE)
	DisableGUI($guiExecueAll)
	$guiWinScheduler = GUICtrlCreateButton("Window"&@crlf&"Scheduler",370,675,60,30, $BS_MULTILINE)


;Start of Setup Tab ##################################################################################

	Global $guiSetupTab = GUICtrlCreateTabItem("Setup")

	Global $guiAllowRemoteExecute = GUICtrlCreateCheckbox("Allow Remote Execution",10,25,150,20)
	If RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa", "forceguest") = 0 Then
		GUICtrlSetState($guiAllowRemoteExecute,$GUI_CHECKED)
	EndIf

	;dataEthnet selectcombobox
	$guiDataEthnetlabel = GUICtrlCreateLabel("Select DataEthernet", 900, 30, 150, 20)
	Global $guiDataEthSelect = GUICtrlCreateCombo($tempDataEthernet, 900,50,150,20,$CBS_DROPDOWNLIST)
	If @IPAddress4 <> "0.0.0.0" Then
		GUICtrlSetData($guiDataEthSelect,@IPAddress4)
	EndIf
	If @IPAddress3 <> "0.0.0.0" Then
		GUICtrlSetData($guiDataEthSelect,@IPAddress3)
	EndIf
	If @IPAddress2 <> "0.0.0.0" Then
		GUICtrlSetData($guiDataEthSelect,@IPAddress2)
	EndIf
	If @IPAddress1 <> "0.0.0.0" Then
		GUICtrlSetData($guiDataEthSelect,@IPAddress1)
	EndIf

	;ControlEthnet selectcombobox
	$guiControlEthnetlabel = GUICtrlCreateLabel("Select ControlEthernet", 1060, 30, 150, 20)
	Global $guiControlEthSelect = GUICtrlCreateCombo($tempControlEthernet, 1060,50,150,20,$CBS_DROPDOWNLIST)
	If @IPAddress4 <> "0.0.0.0" Then
		GUICtrlSetData($guiControlEthSelect,@IPAddress4)
	EndIf
	If @IPAddress3 <> "0.0.0.0" Then
		GUICtrlSetData($guiControlEthSelect,@IPAddress3)
	EndIf
	If @IPAddress2 <> "0.0.0.0" Then
		GUICtrlSetData($guiControlEthSelect,@IPAddress2)
	EndIf
	If @IPAddress1 <> "0.0.0.0" Then
		GUICtrlSetData($guiControlEthSelect,@IPAddress1)
	EndIf

	;search testcase root folder and look for folders, then create combobox with subfolders##########
	$guiTestRunsfolderlabel = GUICtrlCreateLabel("Select TestRuns", 10,53,100,20)
	$TestrunFolderlist = SearchFile($kleverProjectHome&"\TestRuns","*.*")
	If FileExists($kleverTestCasesDir) Then
		$guiTestCaseFolderSelect = GUICtrlCreateCombo($kleverTestCasesDir, 120,50, 500,20, $CBS_DROPDOWNLIST)
	Else
		$guiTestCaseFolderSelect = GUICtrlCreateCombo($kleverTestRunsDir&"\Current", 120,50, 500,20, $CBS_DROPDOWNLIST)
	EndIf

	For $x=1 to $TestrunFolderlist[0]
		GUICtrlSetData($guiTestCaseFolderSelect, $kleverProjectHome&"\TestRuns\"&$TestrunFolderlist[$x])
	Next

;create testcase copy button and open testrun.config button######################################
	$guiRunIdLabel = GUICtrlCreateLabel("RunId="&$runId, 630, 53, 80,20)
	$guiRunId = GUICtrlCreateButton("Assign RunId", 700,50,80,20)
	$guiTestrunCopy = GUICtrlCreateButton("Copy TestRuns", 790, 50, 80,20)

;background color for center part#
	$guileftborder = GUICtrlCreateGraphic(5, 155, 1270, 480)
	GUICtrlSetBkColor(-1, 0x004080)
	DisableGUI($guileftborder)

;create test case display item text
	ReadTestRunConfig()

	$guiTestCasefolderlabel = GUICtrlCreateLabel("TestCaseDir:",10,82,100,20)
	$guiTestCasefolderButton = GUICtrlCreateButton($kleverTestCasesDir, 120,80,500,20)

	$guiScriptfolderlabel = GUICtrlCreateLabel("ScriptDir:", 10,107,100,20)
	$guiScriptfolderButton = GUICtrlCreateButton($kleverTestScriptsDir, 120,105,500,20)

	$guiWorkingfolderlabel = GUICtrlCreateLabel("WorkingDir:",10,132,100,20)
	$guiWorkingfolderButton = GUICtrlCreateButton($kleverWorkingDir,120,130,500,20)

	$guiLogfolderlabel = GUICtrlCreateLabel("LogDir:",10,157,100,20)
	$guiLogfolderButton = GUICtrlCreateButton($kleverLogDir,120,155,500,20)

;Start of Setup Tab ##################################################################################
	$guiEditTab = GUICtrlCreateTabItem("Edit")

	Local $guiTestcaselabel = GUICtrlCreateLabel("Current TestCase:",10,30,100,20)
	Global $guiTestcaseselectedlabel = GUICtrlCreateLabel("",120,30,400,20)

	Global $displaystate=BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY)
	Global $guiTestcasedisplay = GUICtrlCreateEdit("Infomation", 10,50, 640, 600,$displaystate)
	GUICtrlSetState($guiTestcasedisplay,$GUI_ONTOP)


	$guiViewcase = GUICtrlCreateButton("View"&@crlf&"Case", 10, 660, 100, 30, $BS_MULTILINE)
	$guiNewcase = GUICtrlCreateButton("New"&@crlf&"Case", 120, 660, 100, 30, $BS_MULTILINE)
	$guiSavecase = GUICtrlCreateButton("Save"&@crlf&"Case", 230, 660, 100, 30, $BS_MULTILINE)
	$guiModify = GUICtrlCreateButton("Modify", 340, 660, 100, 30)
	$guiRename = GUICtrlCreateButton("Rename", 450, 660, 100, 30)

	;create scripts
	$guiScriptrefresh = GUICtrlCreateButton("Refresh Script", 660, 25, 100, 20)
	$guiScriptsearchinput = GUICtrlCreateInput("", 770, 25, 300, 20)
	GUICtrlSetState($guiScriptsearchinput, $GUI_DROPACCEPTED)

	Global $guiScripttotal = GUICtrlCreateLabel("",1080,30,50,20)
	$guiScriptsearch = GUICtrlCreateButton("Search Script", 1140, 25, 100, 20)

	Global $guiScriptlist = GUICtrlCreateList("", 660, 50, 600, 200)
	$guiScriptdisplay = GUICtrlCreateEdit("Infomation", 660,250, 600,400,BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY))

	;scan testcase folder and script folder, initial the lists#
	GUICtrlSetData($guiCurrentTestRun,$kleverTestcasesDir)
	DisplayTestCasesList($kleverTestCasesDir,"*.test*")
	DisplayScriptsList($kleverCommonScriptsDir, "auto_*.exe")
	DisplayScriptsList($kleverTestScriptsDir,"klever_*.exe",0)
	GUICtrlSetData($guiScripttotal, _GUICtrlListBox_GetCount($guiScriptlist)&" found")
	RebuildDevicecfgCombo()

	GUICtrlCreateTabItem(""); end tabitem definition

	If KLoginGUI($tempTesterName) == 1 Then
		$TesterName = GUICtrlRead($guiTesterSelect)
		GUISetState()
	Else
		Exit
	EndIf


;set the sortcallback
	_GUICtrlListView_RegisterSortCallBack($guiCaseList)

	While 1
		$msg = GUIGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $menuFileExit; Exit
			KHistoryRenew()
			ExitLoop
		Case $msg = $menuAboutReleaseNotes; Release Notes
			run("notepad.exe Release_notes.txt", @WorkingDir)
		Case $msg = $guiViewCaseHistory
			If ProcessExists("kleverViewCaseHist.exe") Then
				ProcessClose("kleverViewCaseHist.exe")
			EndIf

			local $testcasearray = ListviewSelection($guiCaselist)
			If $testcasearray[0] = 0 Then ContinueLoop
			$casefile=$testcasearray[1]

			;If the testcase is a testgroup
			;Redraw the testview with these test case only
			If StringRegExp($casefile, ".testgroup", 0) = 1 Then
				local $currenttestgroup = $kleverTestcasesDir&"\"&$casefile
				local $caselist
				_FileReadToArray($currenttestgroup, $caselist)
				If IsArray($caselist) Then
					DisplayTestCasesInfo($kleverTestCasesDir, $caselist, $guiCaselist)
				EndIf
			Else
				$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
				$CurrentTestRun = $casefolderselection
				$CurrentTestCase = $CurrentTestRun&"\"&$casefile
				Run("kleverViewCaseHist.exe "&'"'&$CurrentTestCase&'"')
			EndIf

		Case $msg = $guiAllowRemoteExecute
			If GUICtrlRead($guiAllowRemoteExecute) = 1 Then
				;first check if your current system is compatible for remote execution
				If StringRegExp($kleverProjectHome, "^\\", 0) = 1 Then
					;allow remote execution
					RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa", "forceguest", "REG_DWORD", 0)
				Else
					Msgbox(16, "Misconfiguration", "Your current ProjectHome setting does not allow remote execution."&@CRLF&"Please reconfigure before your can enable this feature"&@CRLF&"Current Encoder Project Home: \\10.77.164.121\export\KleverHome\ProjectSHome"&@CRLF&"Other must in the form: \\<ip>\your\path")
					GUICtrlSetState($guiAllowRemoteExecute,$GUI_UNCHECKED)
				EndIf
			Else
				;don't allow remote execution
				RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa", "forceguest", "REG_DWORD", 1)
			EndIf
		Case $msg = $guiClearCaseHistory
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			local $testcasearray = ListviewSelection($guiCaselist)
			If $testcasearray[0] = 0 Then ContinueLoop
			$selectedlist = @CRLF
			For $x = 1 to $testcasearray[0]
				$selectedlist &= $testcasearray[$x]&@CRLF
			Next
			$userselect = msgbox(4,"Clear Case History","Clear selected testcases' history files?"&@CRLF&$selectedlist)
			If $userselect = 6 Then
				For $x = 1 to $testcasearray[0]
					$casefile=$testcasearray[$x]
					FileDelete($kleverTestCasesDir&"\Info\"&$casefile&".*")
				Next
				;DisplayTestCasesList($kleverTestcasesDir,"*.test*")
			EndIf
		Case $msg = $guiEditCaseAssessment ;edit the testcase.assessment
			KInputRenew()
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			local $testcasearray = ListviewSelection($guiCaselist)
			If $testcasearray[0] = 0 Then ContinueLoop
			$casefile=$testcasearray[1]
			$currenttestcaseAssessment = $kleverTestcaseInfo&"\"&$casefile&".assessment"
			run('notepad.exe "'&$currenttestcaseAssessment&'"')

		Case $msg = $guiJobidcheckbox;change the state of jobid inputbox base on the checkbox
			If GUICtrlRead($guiJobidcheckbox)= 1 Then
				EnableGUI($guiJobidinput)
			Else
				DisableGUI($guiJobidinput)
			EndIf
		Case $msg = $guiRemoteClientcheckbox;change the state of remote client inputbox
			If GUICtrlRead($guiRemoteClientcheckbox)= 1 Then
				EnableGUI($guiRemoteClientinput)
			Else
				DisableGUI($guiRemoteClientinput)
			EndIf
		Case $msg = $guiHubcheckbox;change the state of hub inputbox base on the checkbox
			If GUICtrlRead($guiHubcheckbox)= 1 Then
				EnableGUI($guiHubinput)
			Else
				DisableGUI($guiHubinput)
			EndIf
		Case $msg = $guiDeviceConfcheckbox;change the state of device config combobox base on the checkbox
			If GUICtrlRead($guiDeviceConfcheckbox)= 1 Then
				EnableGUI($guiDeviceConfSelect)
				DisableGUI($guiEncip)
				DisableGUI($guiLoginId)
				DisableGUI($guiPassword)
			Else
				DisableGUI($guiDeviceConfSelect)
				EnableGUI($guiEncip)
				EnableGUI($guiLoginId)
				EnableGUI($guiPassword)
			EndIf
		Case $msg = $guiTesterSelect;If changing User selection
				$testerName = GUICtrlRead($guiTesterSelect)
				If KLoginGUI($testerName) == 1 Then
					$TesterName = GUICtrlRead($guiTesterSelect)
				Else
					MsgBox(16, "Failed to authenticate", "Application will close.")
					Exit
				EndIf
		Case $msg = $menuViewReport;open report
			Run("kleverreport.exe")
		Case $msg = $menuViewAppLog;open folder of klever.log
			run("explorer.exe "&'"'&$kleverAppLogDir&'"')
		Case $msg = $guiDataEthSelect;select data ethnet
			$dataEth = GUICtrlRead($guiDataEthSelect)
			KHistoryRenew()
			SetupDataEth()
		Case $msg = $guiControlEthSelect;select data ethnet
			$controlEth = GUICtrlRead($guiControlEthSelect)
			KHistoryRenew()
		Case $msg = $guiOpenConsole;open console
			KInputRenew()
			LoadDeviceConfig()
			local $mycmd = "auto_telnet.exe telnetPort=console"
			;determine if an existing telnet is already existed.  Close if it is.
			local $consoleWinTitle = "Telnet - "& EnvGet("consoleServer")
			If WinExists($consoleWinTitle) Then
				local $mycmd = "auto_telnet.exe telnetPort=console telnetAction=Close"
			Else
				local $consolefile = $kleverTempDir & "\" & "telnet_console" & "_" & EnvGet("encIp") & ".txt"
				local $mycmd = "auto_telnet.exe telnetPort=console telnetAction=Open telnetLogRotate=5 telnetLogFile="&$consolefile
			EndIf
			Run($mycmd, "", @SW_HIDE)

		Case $msg = $guiOpenSSH;open SSH
			KInputRenew()
			If $encIp = "" Or $loginId = "" Or $passWord = "" Then
				MsgBox(0,"Error","Encoder ip or id or password is empty")
			Else
				$mycommand="putty.exe -pw "&$passWord&" "&$loginId&"@"&$encIp
				RunSSH($mycommand,0,1)
				run("auto_answer_putty_popup.exe", @WorkingDir, @SW_HIDE)
			EndIf
		Case $msg = $guiOpenBrowser;open encoder
			$encIp = GUICtrlRead($guiEncip)
			If $encIp = "" Then
				MsgBox(0,"Error","Encoder ip is empty")
			Else
				ShellExecute("http://"&$encIp)
			EndIf
		Case $msg = $guiOpenTelnet6010;open telnet port 6010
			KInputRenew()
			LoadDeviceConfig()
			;determine if an existing telnet is already existed.  Close if it is.
			$encIp = GUICtrlRead($guiEncip)
			local $consoleWinTitle = "Telnet - "& EnvGet("encIp")
			If WinExists($consoleWinTitle) Then
				local $mycmd = "auto_telnet.exe telnetPort=6010 telnetAction=Close"
			Else
				local $consolefile = $kleverTempDir & "\" & "telnet_6010" & "_" & EnvGet("encIp") & ".txt"
				local $mycmd = "auto_telnet.exe telnetPort=6010 telnetAction=Open telnetLogRotate=5 telnetLogFile="&$consolefile
			EndIf
			Run($mycmd, "", @SW_HIDE)
		Case $msg = $guiOpenJAVAClient;open Java client
			KInputRenew()
			If $encIp = "" Or $loginId = "" Or $passWord = "" Then
				MsgBox(0,"Error","Encoder ip or id or password is empty")
			Else
			EndIf
		Case $msg = $guiWinScheduler
			Run("control.exe schedtasks")
		Case $msg = $menuViewEncoderInUsed
			$kleverTestcaseInfo = GUICtrlRead($guiTestCaseFolderSelect) & "\Info"
			$mycommand = 'SimpleEditor searchDir="'&$kleverTestcaseInfo&'" searchPattern=*.Inused'
			Run($mycommand, $kleverDeviceConfig)
		Case $msg = $menuViewRunningTestcase
			$kleverTestcaseInfo = GUICtrlRead($guiTestCaseFolderSelect) & "\Info"
			$mycommand = 'SimpleEditor searchDir="'&$kleverTestcaseInfo&'" searchPattern=*.running'
			Run($mycommand, $kleverDeviceConfig)
		Case $msg = $menuViewTempDir
			run("explorer.exe "&'"'&$kleverTempDir&'"')
		Case $msg = $menuEditDeviceConfig
			$mycommand = 'SimpleEditor searchDir="'&$kleverDeviceConfig&'" searchPattern=*.cfg*'
			Run($mycommand, $kleverDeviceConfig)
		Case $msg = $menuEditSystemConfig
			$mycommand = 'SimpleEditor searchDir="'&$kleverSystemConfig&'" searchPattern=*.cfg'
			Run($mycommand, $kleverSystemConfig)
		Case $msg = $menuEditTestCase
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			If $casefolderselection = "" Then
				$casefolderselection = $kleverTestCasesDir
			EndIf
			$mycommand = 'SimpleEditor searchDir="'&$casefolderselection&'" searchPattern=*.testcase'
			Run($mycommand, $kleverSystemConfig)
		Case $msg = $menuEditTestCaseAssessment
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect) & "\Info"
			$mycommand = 'SimpleEditor searchDir="'&$kleverTestcaseInfo&'" searchPattern=*.assessment'
			Run($mycommand, $kleverDeviceConfig)
		Case $msg = $menuOptionChangePass ; change current password
			GUIChangeCurrentPassword(GUICtrlRead($guiTesterSelect))
		Case $msg = $menuOptionWorkingDir ; setting Working directory
			KleverSetDir($kleverWorkingDir,"kleverWorkingDir")
			GUICtrlSetData($guiWorkingfolderButton,$kleverWorkingDir)
			KHistoryRenew()
			SetNetShare($kleverWorkingDir)
		Case $msg = $menuOptionProjectHome; setting Testcase directory
			KleverSetDir($kleverProjectHome,"kleverProjectHome")
			KleverProjectSHome_Setup()
			GUICtrlSetState($guiDeviceConfcheckbox,$GUI_UNCHECKED)
			GUICtrlSetData($guiTestcasefolderButton,$kleverTestcasesDir)
			GUICtrlSetData($guiScriptfolderButton,$kleverTestScriptsDir)
			GUICtrlSetData($guiLogfolderButton,$kleverLogDir)
		Case $msg = $menuOptionFactorySetting
			$msgreturn = msgbox(1,"Factory Setting","Do you want to reset ProjectSHome to default? All related path will be change.")
			If $msgreturn = 2 Then ContinueLoop
			If $msgreturn = 1 Then
				$kleverProjectHome = @ScriptDir&"\ProjectSHome"
				KleverProjectSHome_Setup()
				GUICtrlSetState($guiDeviceConfcheckbox,$GUI_UNCHECKED)
				GUICtrlSetData($guiTestcasefolderButton,$kleverTestcasesDir)
				GUICtrlSetData($guiScriptfolderButton,$kleverTestScriptsDir)
				GUICtrlSetData($guiLogfolderButton,$kleverLogDir)
			EndIf
		Case $msg = $menuOptionTempDir; setting Testcase directory
			KleverSetDir($kleverTempDir,"kleverTempDir")
			KHistoryRenew()
		Case $msg = $menuAdminManageTesters; Tester DB Management
			$mycommand = 'KleverTesterManager.exe testerDir="'&EnvGet("TesterDbDir")&'"'
			Run($mycommand, $kleverSystemConfig)
		Case $msg = $guiTestCaseFolderSelect;select the testcase sub folders under testcase root folder
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			$currenttestrunconfig = $casefolderselection & "\Config\" & $testrunconfig
			ReadTestRunConfig()
			KHistoryRenew()
			$kleverLogDir = $kleverTestCasesDir&"\Logs"
			DisplayTestCasesList($casefolderselection, "*.test*")

			DisplayScriptsList($kleverCommonScriptsDir, "auto_*.exe")
			DisplayScriptsList($kleverTestScriptsDir, "klever_*.exe", 0)

			RebuildDevicecfgCombo()
			GUICtrlSetData($guiCurrentTestRun,$kleverTestcasesDir)
			GUICtrlSetData($guiTestcasefolderButton,$kleverTestcasesDir)
			GUICtrlSetData($guiScriptfolderButton,$kleverTestScriptsDir)
			GUICtrlSetData($guiLogfolderButton,$kleverLogDir)
			GUICtrlSetData($guiRunIdLabel,"RunId="&$runId)
			GUICtrlSetState($guiDeviceConfcheckbox,$GUI_UNCHECKED)
		Case $msg = $guiTestrunCopy;copy testcase and set the testrun.config
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			$newcasefolder = FileSelectFolder("Select the Folder you want to copy to", $kleverTestRunsDir, 1+2+4, $kleverTestRunsDir)
			Dircopy($casefolderselection, $newcasefolder,1)
		Case $msg = $menuEditTestRunConfig;edit the testrun.config file
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			$currenttestrunconfig = $kleverTestcaseConfig&"\" & $testrunconfig
			run('notepad.exe "'&$currenttestrunconfig&'"')
		Case $msg = $guiRunId;edit runid of current testrun
			Run('notepad.exe "'&$kleverTestcaseConfig&'\testrun.RunId"')
		Case $msg = $guiExecueAll;testing, for multi testcase selection
			ContinueLoop
		Case $msg = $guiCaseIdModify;modify selected testcase's caseID
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			local $testcasearray = ListviewSelection($guiCaselist)
			If $testcasearray[0] = 0 Then ContinueLoop
			$casefile=$testcasearray[1]

			;get the current caseid or create caseid file if not exist
			$newcaseidfile = $casefolderselection&"\CaseId\"&$casefile&".caseID"
			If Not FileExists($newcaseidfile) Then
				$caseidfile = KFileOpen($newcaseidfile,1+8)
				$caseidline = ""
			Else
				$caseidfile = KFileOpen($newcaseidfile,0)
				$tempcaseidline = stringsplit(FileReadLine($caseidfile),"=")
				$caseidline = $tempcaseidline[2]
				FileClose($caseidfile)
			EndIf

			;input new caseid, inputbox has a timeout of 10sec
			$newcaseid = InputBox("New CaseID","Please input new CaseID for "&$newcaseidfile&". Digit only.",$caseidline," M",-1,-1,Default,Default,20)
			If $newcaseid = "" And $caseidline = "" Then
				$newcaseid = "N/A"
			ElseIf $newcaseid = "" And $caseidline <> "" Then
				$newcaseid = $caseidline
			EndIf
			$caseidfile = KFileOpen($newcaseidfile,2)
			FileWriteLine($caseidfile,"caseId="&$newcaseid)
			FileClose($caseidfile)

			;refresh the caselist to show the caseid change
			;DisplayTestCasesList($casefolderselection,"*.test*")
		Case $msg = $guiTestcasesearch;search for testcase
			$guiCaseSearchPattern = GUICtrlRead($guiTestcaseSearchInput)
			;If $guiCaseSearchPattern = "" Then ContinueLoop
			;SearchTestCasesList($kleverTestCasesDir,$guiCaseSearchPattern)
			DisplayTestCasesList($kleverTestCasesDir,"*"&$guiCaseSearchPattern&"*"&".test*")
		Case $msg = $guiTestcaserefresh;search for testcase
			DisplayTestCasesList($kleverTestCasesDir,"*.test*")
		Case $msg = $guiRemovecase;delete selected case
			local $testcasearray = ListviewSelection($guiCaseList)
			If $testcasearray[0] = 0 Then ContinueLoop
			$casefile=$testcasearray[1]
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			$msgboxselection = msgbox(4,"Test Case Delete","Do you want to delete the test case "&$casefile&"?")
			if $msgboxselection = 6 Then
				FileDelete($casefolderselection&"\"&$casefile)
				;DisplayTestCasesList($casefolderselection,"*.test*")
			EndIf
		Case $msg = $guiProposecase ; propose Case
			KInputRenew()
			local $testcasearray = ListviewSelection($guiCaseList)
			If $testcasearray[0] = 0 Then ContinueLoop
			For $x = 1 to $testcasearray[0]
				WriteTestcaseAssessment($testcasearray[$x], "Proposed")
			Next
			;DisplayTestCasesList($kleverTestcasesDir,"*.test*")
		Case $msg = $guiConfirmcase ; confirm Case
			KInputRenew()
			local $testcasearray = ListviewSelection($guiCaseList)
			If $testcasearray[0] = 0 Then ContinueLoop
			For $x = 1 to $testcasearray[0]
				WriteTestcaseAssessment($testcasearray[$x], "Confirmed")
			Next
			;DisplayTestCasesList($kleverTestcasesDir,"*.test*")
		Case $msg = $guiBlockcase ; block Case
			KInputRenew()
			local $testcasearray = ListviewSelection($guiCaseList)
			If $testcasearray[0] = 0 Then ContinueLoop
			For $x = 1 to $testcasearray[0]
				WriteTestcaseAssessment($testcasearray[$x], "Blocked")
			Next
			;DisplayTestCasesList($kleverTestcasesDir,"*.test*")
		Case $msg = $guiScriptsearch;rescan the script folder
			$guiScriptsearchpattern = GUICtrlRead($guiScriptsearchinput)
			If $guiScriptsearchpattern = "" Then ContinueLoop

			$scriptlist = ListBoxGetAllItems($guiScriptlist)
			ResetGUIctrl($guiScriptlist);reset testcase list
			For $i = 1 to $scriptlist[0]
				If StringRegExp($scriptlist[$i],"(?i)"&$guiScriptsearchpattern) = 1 Then
					GUICtrlSetData($guiScriptlist,$scriptlist[$i])
				EndIf
			Next
			GUICtrlSetData($guiScripttotal, $scriptlist[0]&" found")
		Case $msg = $guiScriptrefresh;rescan the script folder
			DisplayScriptsList($kleverCommonScriptsDir, "auto_*.exe")
			DisplayScriptsList($kleverTestScriptsDir,"klever_*.exe",0)
			GUICtrlSetData($guiScripttotal, _GUICtrlListBox_GetCount($guiScriptlist)&" found")
		Case $msg = $guiWorkingfolderButton;open working folder
			run("explorer.exe "&'"'&$kleverWorkingDir&'"')
		Case $msg = $guiScriptfolderButton;open script folder
			run("explorer.exe "&'"'&$kleverTestScriptsDir&'"')
		Case $msg = $guiTestCasefolderButton;open testcase root folder
			run("explorer.exe "&'"'&$kleverTestCasesDir&'"')
		Case $msg = $guiLogfolderButton;open testcase root folder
			run("explorer.exe "&'"'&$kleverLogDir&'"')
		Case $msg = $guiExecute;execute the selected test case
			local $mycommand = TestCasePrepare()
			If $mycommand <> "" Then
				RunCommand($mycommand, $kleverTestCasesDir, 0, 1)
			EndIf
		Case $msg = $guiExecutePreView;execute the selected test case
			local $mycommand = TestCasePrepare()
			If $mycommand <> "" Then
				MsgBox(0, "Execution Preview", $mycommand)
			EndIf
		Case $msg = $guiRename;rename selected testcase or testgroup
			local $testcasearray = ListviewSelection($guiCaseList)
			If $testcasearray[0] = 0 Then ContinueLoop
			$casefile=$testcasearray[1]
			$splitname = StringSplit(StringReplace($casefile,".","#t#",-1),"#t#",1)
			$thefilename = $splitname[1]
			$thefileextension = $splitname[2]

			;running status check
			If FileExists($kleverTestCasesDir&"\Info\"&$casefile&".running") Then
				MsgBox(0,"Current Running","Case "&$casefile&" currently is running. Please rename it later.",10)
			EndIf

			$errorcheck = RenameTestCase($casefile,$thefilename,$thefileextension)
			If $errorcheck = 0 Then ContinueLoop
			;refresh the caselist to show the caseid change
			;DisplayTestCasesList($kleverTestCasesDir,"*.test*")
		Case $msg = $guiModify;edit current case
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			local $testcasearray = ListviewSelection($guiCaseList)
			If $testcasearray[0] = 0 Then ContinueLoop
			$casefile=$testcasearray[1]
			GUICtrlSetData($guiTestcaseselectedlabel,$casefile)
			If $displaystate = -1 Then
				$saveflag = SaveModifyingTestCase($casefile,$casefolderselection)
				If $saveflag = 0 Then
					;DisplayTestCasesList($casefolderselection,"*.test*")
				EndIf

			EndIf

			GUICtrlSetData($guiTestcasedisplay, "")
			;display the selected testcase
			$testcaseinfo = FileOpen($casefolderselection&"\"&$casefile, 0)
			If $testcaseinfo = -1 Then
				MsgBox(0, "Error", "Unable to open "&$testcaseinfo&" file.",5)
			Else
				RebuildTestcaseDisplay(1, FileRead($testcaseinfo) )
				FileClose($testcaseinfo)
			EndIf
		Case $msg = $guiNewcase;create new case
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			GUICtrlSetData($guiTestcaseselectedlabel,"NewCase.testcase")
			If $displaystate = -1 Then
				$saveflag = SaveModifyingTestCase($casefile,$casefolderselection)
				If $saveflag = 0 Then
				;	DisplayTestCasesList($casefolderselection,"*.test*")
				EndIf
			EndIf
			RebuildTestcaseDisplay(1)
		Case $msg = $guiSavecase;save current case
			$casefile = GUICtrlRead($guiTestcaseselectedlabel)
			If $casefile = "" Then
				$casefile = "NewTestCase.testcase"
			EndIf
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			If Not FileExists($casefolderselection) Then
				$casefolderselection = @ScriptDir
			EndIf
			If $displaystate = -1 Then
				$saveflag = SaveModifyingTestCase($casefile,$casefolderselection)
				If $saveflag = 0 Then
				;	DisplayTestCasesList($casefolderselection,"*.test*")
				EndIf
			EndIf
			RebuildTestcaseDisplay(0)
		Case $msg = $guiViewcase ;display selected case content
			;local $testcasearray = ListviewSelection($guiCaseList)
			;If $testcasearray[0] = 0 Then ContinueLoop
			$casefile=GUICtrlRead($guiTestcaseselectedlabel)
			$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
			;asking for save before next step
			If $displaystate = -1 Then
				$saveflag = SaveModifyingTestCase($casefile,$casefolderselection)
				If $saveflag = 0 Then
					;DisplayTestCasesList($casefolderselection,"*.test*")
				EndIf
				RebuildTestcaseDisplay(0)
			EndIf

			;display the testcase content
			$testcaseinfo = FileOpen($casefolderselection&"\"&$casefile, 0)
			If $testcaseinfo = -1 Then
				MsgBox(0, "Error", "Unable to open "&$testcaseinfo&" file.",5)
			EndIf
			GUICtrlSetData($guiTestcasedisplay, FileRead($testcaseinfo))
			FileClose($testcaseinfo)
		Case $msg = $guiTab	;display selected case content when hitting Edit tab
			If GUICtrlRead($guiTab) = 2 Then
				local $testcasearray = ListviewSelection($guiCaseList)
				If $testcasearray[0] = 0 Then ContinueLoop
				$casefile=$testcasearray[1];only view the first testcase
				$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
				GUICtrlSetData($guiTestcaseselectedlabel,$casefile)
				;asking for save before next step
				If $displaystate = -1 Then
					$saveflag = SaveModifyingTestCase($casefile,$casefolderselection)
					If $saveflag = 0 Then
						DisplayTestCasesList($casefolderselection,"*.test*")
					EndIf
					RebuildTestcaseDisplay(0)
				EndIf

				;display the testcase content
				$testcaseinfo = FileOpen($casefolderselection&"\"&$casefile, 0)
				If $testcaseinfo = -1 Then
					MsgBox(0, "Error", "Unable to open "&$testcaseinfo&" file.",5)
				EndIf
				GUICtrlSetData($guiTestcasedisplay, FileRead($testcaseinfo))
				FileClose($testcaseinfo)
			EndIf
		Case $msg = $guiScriptlist;display selected script usage
			$scriptfile = _GUICtrlListBox_GetText($guiScriptlist,_GUICtrlListBox_GetAnchorIndex($guiScriptlist))
			;$scriptfile = GUICtrlRead($guiScriptlist)
			local $myresult = StringRegExp($scriptfile, "^auto_")
			$kleverUsageDir = $kleverTestScriptsDir&"\Usage"
			$scriptfullpath = $kleverTestScriptsDir&"\"&$scriptfile
	        if ($myresult = 1) Then
			$kleverUsageDir = $kleverCommonScriptsDir&"\Usage"
			$scriptfullpath = $kleverCommonScriptsDir&"\"&$scriptfile
			EndIf

			DirCreate($kleverUsageDir)

			$scriptusagepath = $kleverUsageDir&"\"&$scriptfile&".usage"
			$scriptusagetemp = @TempDir&"\"&$scriptfile&".usage"
			If $scriptfile = "" Then ContinueLoop
			$mycommand='"'&$scriptfullpath&'"' & " usage=yes " & " > " & $scriptusagetemp
			FileDelete($scriptusagepath)

			RunWait(@ComSpec  & " /c " & $mycommand, @WorkingDir, @SW_HIDE)
			Filecopy($scriptusagetemp, $scriptusagepath)
			$usagefile = FileOpen($scriptusagepath, 0)
			If $usagefile = -1 Then
				MsgBox(0, "Error", "Unable to open "&$scriptusagepath)
			EndIf
			GUICtrlSetData($guiScriptdisplay, FileRead($usagefile))
			FileClose($usagefile)
		Case $msg = $guiCaseList;sort the testcaselist by click column
			_GUICtrlListView_SortItems($guiCaseList, GUICtrlGetState($guiCaseList))
		EndSelect
	WEnd

;unset the sortcallback
	_GUICtrlListView_UnRegisterSortCallBack($guiCaseList)
EndFunc

Func WriteTestcaseAssessment($casefile, $action = "Proposed")
	local $casestatusfile = FileOpen($kleverTestCasesDir&"\Info\"&$casefile&".status",2)
	FileWriteLine($casestatusfile,$action)
	FileClose($casestatusfile)

	;Write to assessment log
	local $caseAssessmentFile = $kleverTestCasesDir&"\Info\"&$casefile&".assessment"
	_FileWriteLog($caseAssessmentFile, "Test case is set to " & $action & " by "&$TesterName & " on " &@ComputerName&"("&@IPAddress1&")")
EndFunc

Func KleverProjectSHome_Setup()
	;KleverSetDir($kleverProjectHome,"kleverProjectHome")
	; renew all important global path variables
	$kleverTestRunsDir = $kleverProjectHome&"\TestRuns"
	$kleverTestCasesDir = $kleverTestRunsDir&"\Current"
	$kleverScriptHomeDir = $kleverProjectHome&"\ScriptHome"
	$kleverTestScriptsDir = $kleverScriptHomeDir&"\Current"
	$kleverLogDir = $kleverTestCasesDir&"\Logs"
	;rebuild the testrunselect combobox
	;GUICtrlDelete($guiTestCaseFolderSelect)
	GUICtrlSetData($guiTestCaseFolderSelect, "", "Current")
	$TestrunFolderlist = SearchFile($kleverTestRunsDir,"*.*")
	;$guiTestCaseFolderSelect = GUICtrlCreateCombo($kleverTestRunsDir&"\Current", 110,50, 500,20, $CBS_DROPDOWNLIST)
	For $x=1 to $TestrunFolderlist[0]
		GUICtrlSetData($guiTestCaseFolderSelect, $kleverTestRunsDir&"\"&$TestrunFolderlist[$x])
	Next

	;refresh lists
	$casefolderselection = GUICtrlRead($guiTestCaseFolderSelect)
	$currenttestrunconfig = $casefolderselection & "\Config\" & $testrunconfig
	ReadTestRunConfig()
	KHistoryRenew()
	DisplayTestCasesList($casefolderselection, "*.test*")
	DisplayScriptsList($kleverCommonScriptsDir, "auto_*.exe")
	DisplayScriptsList($kleverTestScriptsDir, "klever_*.exe",0)
	RebuildDevicecfgCombo()
EndFunc

Func InitialGuiTempVariables()
	;Set temp variables and use to build GUI with history value
	Global $tempJobidinput = "Current"
	Global $tempHubInput = "Current"
	Global $tempTesterName = "Automation"
	Global $tempDeviceConf = ""
	Global $tempDataEthernet = @IPAddress1
	Global $tempControlEthernet = @IPAddress2

	If IsDeclared("VideohuboutPort") Then
		$tempHubInput = eval("VideohuboutPort")
	EndIf
	If IsDeclared("TesterName") Then
		$tempTesterName = $testerName
	EndIf
	If IsDeclared("dataEth") Then
		$tempDataEthernet = $dataEth
	EndIf
	If IsDeclared("controlEth") Then
		$tempControlEthernet = $controlEth
	EndIf
EndFunc

Func SetNetShare($dirtoshare)
	local $mycommand = "net share workingdir /delete"
	KConsoleWrite("Current Dir="&@workingdir&@CRLF, 0)
	KConsoleWrite("--> "&$mycommand&@CRLF, 0)
	RunWait($mycommand, @workingdir,@SW_HIDE)
	$mycommand = "net share workingdir="&$dirtoshare
	KConsoleWrite("Current Dir="&@workingdir&@CRLF, 0)
	KConsoleWrite("--> "&$mycommand&@CRLF, 0)
	Runwait($mycommand, @workingdir,@SW_HIDE)
EndFunc

Func TestCasePrepare()
	KInputRenew()
	local $testcasearray = ListviewSelection($guiCaseList)
	local $mycommand = ""

	If $encIp = "" Or $loginId = "" Or $passWord = "" Or $testcasearray[0] = 0 Then
		MsgBox(0,"Error","Encoder ip or id or password is empty, or script is not selected",5)
	Else
		;if one case, run without wait, if not wait
		;$runwait = 1;

		if $testcasearray[0] = 1 Then
			$casefile = $testcasearray[1]
		Else
			$casefile = ComposeTestCaseFile($testcasearray)
		Endif

		if ($casefile <> "") Then
			$tempJobidinput = GUICtrlRead($guiJobidinput)
			$tempHubInput = GUICtrlRead($guiHubinput)
			$tempTesterName = GUICtrlRead($guiTesterSelect)
			$tempDeviceConf = GUICtrlRead($guiDeviceConfSelect)
			$tempRemoteClient = GUICtrlRead($guiRemoteClientinput)

			$subcommand_jobid = ""
			$subcommand_updateResult = "updateResult=yes"
			If GUICtrlRead($guiJobidcheckbox)=1 And $tempJobidinput <> "" Then
				Assign("JobId", $tempJobidinput, 2)
				$subcommand_jobid = "JobId="&$jobId
				$subcommand_updateResult = ""
			EndIf
			$subcommand_videohubinput = ""
			If GUICtrlRead($guiHubcheckbox)=1 And $tempHubInput <> "" Then
				$subcommand_videohubinput = "VideohuboutPort="&$tempHubInput
				Assign("VideohuboutPort",$tempHubInput,2)
				EnvSet("VideohuboutPort", $tempHubInput)
			EndIf
			$subcommand_tester = "TesterName=Automation"
			If $tempTesterName <> "Automation" Then
				$subcommand_tester = "TesterName="&$tempTesterName
				Assign("TesterName",$tempTesterName,2)
			EndIf
			$subcommand_testDevice = ""
			;If GUICtrlRead($guiDeviceConfcheckbox)=1 And $tempDeviceConf <> "" Then
			;	$subcommand_testDevice = "testDevice="&$tempDeviceConf
			;EndIf

			$subcommand_remoteClient = ""
			If GUICtrlRead($guiRemoteClientcheckbox)=1 And $tempRemoteClient <> "" Then
				$subcommand_remoteClient = "remoteClient="&$tempRemoteClient & " remoteHost=" & $tempControlEthernet
			EndIf

			local $newarray = StringSplit(GUICtrlRead($guiTestCaseFolderSelect), '\')
			local $testrunoption = 'testRun='&$newarray[$newarray[0]]

			KHistoryRenew()
			GUICtrlSetData($guiTestcaseselectedlabel,$casefile)
			$mycommand = "kleverCli.exe /ErrorStdOut " & $subcommand_remoteClient & " " &$testrunoption& " " & "encIp="&$encIp & " loginID="&$loginId& " password="&$passWord&" "&$subcommand_jobid&" "&$subcommand_updateResult&" testcase="&$casefile&" "&$subcommand_videohubinput&" "&$subcommand_tester&" "&$subcommand_testDevice& " 2>> "&'"'&$logFile&'"'
			If GUICtrlRead($guiDeviceConfcheckbox)=1 And $tempDeviceConf <> "" Then
				$mycommand = "kleverCli.exe /ErrorStdOut " & $subcommand_remoteClient & " " &$testrunoption& " " & $subcommand_jobid&" "&$subcommand_updateResult&" testcase="&$casefile&" "&$subcommand_videohubinput&" "&$subcommand_tester&" "& " testDevice="&$tempDeviceConf & " " & " 2>> "&'"'&$logFile&'"'
			EndIf

		EndIf
	EndIf
	return $mycommand
EndFunc

;filefullname contains extension
;filename only the name
Func RenameTestCase($filefullname,$filename,$fileextension)
	Local $renameresult = 1
	$newfilename = InputBox("New Name","Please input/modify new name.  Do not add any extension"&$filefullname&".", $filename, " M", -1, -1, Default, Default, 20)
	If $newfilename = "" Or $newfilename = $filename Then
		$renameresult = 0
	ElseIf FileExists($kleverTestCasesDir&"\"&$newfilename&"."&$fileextension) Then
		msgbox(0,"Error renaming testcase","The new name already existed. Please use another name.",10)
		$renameresult = 0
	Else
		$errorcheck = FileMove($kleverTestCasesDir&"\"&$filefullname,$kleverTestCasesDir&"\"&$newfilename&"."&$fileextension)
		If $errorcheck = 0 Then
			msgbox(0,"Error renaming testcase","Can not rename file "&$filefullname&", Can not copy to "&$kleverTestcasesDir,15)
			$renameresult = 0
		Else
			FileMove($kleverTestCasesDir&"\Info\"&$filefullname&".last",$kleverTestCasesDir&"\Info\"&$newfilename&"."&$fileextension&".last")
			FileMove($kleverTestCasesDir&"\Info\"&$filefullname&".ran",$kleverTestCasesDir&"\Info\"&$newfilename&"."&$fileextension&".ran")
			FileMove($kleverTestCasesDir&"\CaseId\"&$filefullname&".caseId",$kleverTestCasesDir&"\CaseId\"&$newfilename&"."&$fileextension&".caseId")
			GUICtrlSetData($guiTestcaseselectedlabel, $newfilename&"."&$fileextension)
		EndIf
	EndIf
	Return $renameresult
EndFunc

;Write testcase in array to a file
;If fail return 0, else return the fullpath to the file just created
Func ComposeTestCaseFile($testcasearray)
	Local $testfile = "selection_"&dateString()&".testgroup"
	Local $testfilefull = $kleverTestCasesDir&"\"&$testfile
	_ArrayDelete($testcasearray, 0)
	if _FileWriteFromArray($testfilefull, $testcasearray) Then
		return $testfile
	Else
		Msgbox(0, "Error", "Failed to create "&$testfilefull)
		return ""
	EndIf
EndFunc

Func SaveModifyingTestCase($file,$savepath)
	;save modifying testcase before next move
	local $newfile = ""
	$msgboxselection = msgbox(4,"Save","Do you want to save your current case file?")
	if $msgboxselection = 6 Then
		$savecontent = GUICtrlRead($guiTestcasedisplay)
		$newfile = KFileSave("Test Case", $savepath, "Test Cases (*.testcase)", 16, $file, $savecontent)
		If IsString($newfile) Then
			$newfile = StringReplace($newfile, $savepath, "")
			$newfile = StringReplace($newfile, "\", "")
			GUICtrlSetData($guiTestcaseselectedlabel, $newfile)
		Endif
		return 0 ;file been saved, need to refresh testcaselist
	Else
		return 1 ; file save cancelled
	EndIf
EndFunc

;rebuildflag 0 build readonly TestcaseDisplay
;			 1 build writeable TestcaseDisplay
Func RebuildTestcaseDisplay($rebuildflag, $text = "")
	If $rebuildflag=0 Then
		$displaystate=BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY)
		GUICtrlSetStyle($guiTestcasedisplay, $displaystate)
	Else
		$displaystate=-1
		GUICtrlSetData($guiTestcasedisplay, $text)
		GUICtrlSetState($guiTestcasedisplay,$GUI_ONTOP+$GUI_DROPACCEPTED)
		GUICtrlSetStyle($guiTestcasedisplay, $GUI_SS_DEFAULT_EDIT)
	EndIf
EndFunc

Func ResetGUIctrl($guiHandle)
	GUICtrlSetData($guiHandle,"")
EndFunc

Func DisableGUI($guiHandle)
	GUICtrlSetState($guiHandle, $GUI_DISABLE)
EndFunc

Func EnableGUI($guiHandle)
	GUICtrlSetState($guiHandle, $GUI_ENABLE)
EndFunc

Func ReadTestRunConfig()
	$kleverScriptHomeDir = $kleverProjectHome&"\ScriptHome"
	If Not FileExists ($currenttestrunconfig) Then
		$kleverTestScriptsDir = $kleverScriptHomeDir&"\Current"
	Else
		$defaultarray=KFileReadToArray($currenttestrunconfig)
		AssignVariable($defaultarray)
		If IsDeclared("testscriptsdir") Then
			$kleverTestScriptsDir = $kleverScriptHomeDir&"\"&$testscriptsdir
		Else
			msgbox(0,"Error",$testscriptsdir&" is not declared in "&$currenttestrunconfig)
		EndIf
	EndIf
EndFunc

Func DisplayScriptsList($folder,$searchpattern,$reset=1)
	;Global $guiScripttotal
	;Global $guiscriptlist
	If $reset = 1 Then
		ResetGUIctrl($guiScriptlist)
	EndIf
	$scriptlist = SearchFile($folder,$searchpattern)
	DisplayFileList($scriptlist,$guiScriptlist)
EndFunc

Func DisplayFileList($listarray,$guilisthandle)
	For $lop = 1 to $listarray[0]
		GUICtrlSetData($guilisthandle, $listarray[$lop])
	Next
EndFunc

Func DisplayTestCasesInfo($folder, $list, $guilisthandle)
	;first clear the existing list
	_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($guilisthandle))

	local $currentcasestatusfile
	local $currentcasestatus
	local $currentTestCaseRunStatus
	local $currentcaseidfile
	local $currentestcaseID
	local $currentcaselastfile
	local $file

	For $x=1 to $list[0]
		$currentcasestatusfile = $folder&"\"&$testcaseInfoDirName&"\"&$list[$x]&".status"
		$currentcasestatus = CurrentCaseStatus($currentcasestatusfile)

		If FileExists($folder&"\"&$testcaseInfoDirName&"\"&$list[$x]&".running") Then
			$currentTestCaseRunStatus = "Running"
		Else
			$currentTestCaseRunStatus = "Idle"
		EndIf

		$currentcaseidfile = $folder&"\CaseId\"&$list[$x]&".caseID"
		$currentestcaseID = CurrentCaseID($currentcaseidfile)

		$currentcaselastfile = $folder&"\"&$testcaseInfoDirName&"\"&$list[$x]&".last"
		$file = FileOpen($currentcaselastfile,0)
		If $file = -1 Then
			$msgtoshow = "N/A"
			$guiCaselisttriggle=GUICtrlCreateListViewItem($list[$x]&"|"&$currentcasestatus&"|"&$currentestcaseID&"|"&$currentTestCaseRunStatus&"|N/A|N/A|N/A",$guilisthandle)
		Else
			$lineArg = stringsplit(fileread($file),",")
			$guiCaselisttriggle=GUICtrlCreateListViewItem($list[$x]&"|"&$currentcasestatus&"|"&$currentestcaseID&"|"&$currentTestCaseRunStatus&"|"&$lineArg[9]&"|"&$lineArg[8]&"|"&$lineArg[6],$guilisthandle)
		EndIf
		FileClose($file)
	Next
	GUICtrlSetData($guiTestcasetotal, $list[0]&" found")
EndFunc


Func DisplayTestCasesList($folder, $searchpattern)
	$caselist = SearchFile($folder,$searchpattern)

	DisplayTestCasesInfo($folder, $caselist, $guiCaselist)
	;GUICtrlSetData($guiTestcasetotal, $caselist[0]&" found")
EndFunc

Func SearchTestCasesList($folder, $searchpattern)
	Local $currentcaselist

	ReDim $caselist[1]
	$caselist[0]=0

	$currentcaselist = ListViewGetAllItems($guiCaselist)
	For $i = 1 to $currentcaselist[0]
		If StringRegExp($currentcaselist[$i],"(?i)"&$searchpattern) = 1 Then
			_ArrayAdd($caselist,$currentcaselist[$i])
			$caselist[0] += 1
		EndIf
	Next

	DisplayTestCasesInfo($folder, $caselist, $guiCaselist)
	;GUICtrlSetData($guiTestcasetotal, $caselist[0]&" found")
EndFunc

;check the caseid of testcase and return it
;$file is the .caseid file
Func CurrentCaseID($file)
	local $currentcaseID = "N/A"
	If FileExists($file) Then
		$caseidfile = KFileOpen($file,0)
		$tempcaseidline = stringsplit(FileReadLine($caseidfile),"=")
		$caseidline = $tempcaseidline[2]
		FileClose($caseidfile)
		If IsString($caseidline) = 1 Then
			$currentcaseID = $caseidline
		;Else
			;$currentcaseID = "N/A"
		EndIf
	;Else
		;$currentcaseID = "N/A"
	EndIf
	Return $currentcaseID
EndFunc

Func CurrentCaseStatus($file)
	If FileExists($file) Then
		$casestatusfile = KFileOpen($file,0)
		$currentcasestatus = FileReadLine($casestatusfile)
		FileClose($casestatusfile)
	Else
		$currentcasestatus = "New"
	EndIf
	Return $currentcasestatus
EndFunc

Func InsertComboItem($guih, $mylist)
	If $mylist[0] > 0 Then
		For $x = 1 to $mylist[0]
			GUICtrlSetData($guih,$mylist[$x])
		Next
	Else
		$guih = GUICtrlCreateCombo("", 670,22,140,20,$CBS_DROPDOWNLIST)
	EndIf
EndFunc

Func RebuildComboList($guih, $mylist)
	ResetGUIctrl($guih)
	InsertComboItem($guih, $mylist)
	DisableGUI($guiDeviceConfSelect)
EndFunc

Func RebuildDevicecfgCombo()
	local $Devicelist = SearchFile($kleverDeviceConfig, "*.cfg")
	RebuildComboList($guiDeviceConfSelect, $Devicelist)
EndFunc

Func KleverSetDir($dir,$dirvarname)
	$newdir = InputBox("Setup new path",'Please input the new path. Example:"c:\path". Blank is not allowed',$dir, " M",-1,-1)
	if $newdir <> "" Then
		assign($dirvarname,$newdir)
	EndIf
EndFunc

Func KInputRenew()
	$encIp = GUICtrlRead($guiEncip)
	$loginId = GUICtrlRead($guiLoginid)
	$passWord = GUICtrlRead($guipassword)
	$kleverTestCasesDir = GUICtrlRead($guiTestCaseFolderSelect)
	$kleverTestcaseConfig = $kleverTestCasesDir&"\Config"
	$kleverTestcaseInfo = $kleverTestCasesDir&"\Info"
	$kleverLogDir = $kleverTestCasesDir&"\Logs"
	$kleverDeviceConfig = $kleverTestcaseConfig&"\Devices"

	$tempHubInput = GUICtrlRead($guiHubinput)
	$tempTesterName = GUICtrlRead($guiTesterSelect)
	If GUICtrlRead($guiHubcheckbox)=1 And $tempHubInput <> "" Then
		$videohubinput=$tempHubInput
	EndIf
	If $tempTesterName <> "" Then
		$TesterName=$tempTesterName
	EndIf

	DirCreate($kleverTestCasesDir&"\"&$testcaseInfoDirName)
	DirCreate($kleverDeviceConfig)

	;Check if Device override is used
	If GUICtrlRead($guiDeviceConfcheckbox)=1 Then
		Local $currentDeviceConfig = $kleverTestcaseConfig&"\Devices\"&GUICtrlRead($guiDeviceConfSelect)
		If FileExists($currentDeviceConfig) Then
			local $devicearray=KFileReadToArray($currentDeviceConfig)
			AssignVariable($devicearray)
		EndIf
	EndIf
EndFunc

Func KHistoryRenew()
	KInputRenew()
	GetRunId()

	;Handle klever history; this history is only needed for the gui
	local $array = KFileReadToArray($kleverHistoryConfig)
	$history = FileOpen($kleverHistoryFile, 2)
	If $history = -1 Then
		MsgBox(0, "Error", "Unable to open klever history file.")
	Else
		For $arrayIndex = 1 to $array[0]
			FileWriteLine($history, $array[$arrayIndex]&"="&eval($array[$arrayIndex]))
		Next
	EndIf
	fileclose($history)

	;Handle klevercli history; this history is needed for anything running from cli
	local $array = KFileReadToArray($kleverCliHistoryConfig)
	$history = FileOpen($kleverCliHistoryFile, 2)
	If $history = -1 Then
		MsgBox(0, "Error", "Unable to open klever history file.")
	Else
		For $arrayIndex = 1 to $array[0]
			FileWriteLine($history, $array[$arrayIndex]&"="&eval($array[$arrayIndex]))
		Next
	EndIf
	fileclose($history)

	;RenewEnv() - Why do I need to do this?
EndFunc

;Provide pop-up window asking for tester login and password
;Will  return 1 with authentication is sucessful, else return 0
Func KLoginGUI($login)
	local $success = 0

	local $logingui = GUICreate("Klever Tester Authorization", 300, 183)

	local $testerlabel = GUICtrlCreateLabel("Tester Name:", 10, 10, 100, 20)
	local $tester = GUICtrlCreateInput($login, 120, 10, 100, 20)

	local $passwordlabel = GUICtrlCreateLabel("Password:", 10, 80, 100, 20)
	local $password = GUICtrlCreateInput("", 120, 80, 100, 20,$ES_PASSWORD)

	local $ok=GUICtrlCreateButton("OK",10,140,100,20)

	;$accEnter = GUICtrlCreateDummy()
	local $AccelKeys[1][2] = [["{ENTER}", $ok]]
	GUISetAccelerators($AccelKeys, $logingui)

	GUISetState()
	While 1
		local $nMsg = GUIGetMsg()
		Switch $nMsg
			Case $ok
				local $result = CheckPassword(GUICtrlRead($tester), GUICtrlRead($password))
				If $result = 1 Then
					$success = 1
					GUICtrlSetData($guiTesterSelect, GUICtrlRead($tester))
					ExitLoop
				Else
					ExitLoop
				EndIf
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd

	GUIDelete($logingui)
	return $success
EndFunc

;Check Password
;return 1 = ok, 0 = bad
Func CheckPassword($login, $pass)
	local $success = 0
	;First check if entered password is empty
	If StringCompare($pass, "") <> 0 Then
		local $dir = EnvGet("TesterDbDir")
		local $logindbfile = $dir & "\" & $login
		local $testtempfile = @TempDir&"\.ktempfile"
		_Crypt_DecryptFile($logindbfile, $testtempfile, "modulus" , $CALG_AES_128)
		local $testerinfo = KFileReadLine($testtempfile)
		FileDelete($testtempfile)
		If IsArray($testerinfo) Then
			;compare entered password against db password
			If KPasswordDecrypt($testerinfo[1], $pass) = $pass Then
				$success = 1
				;check if user is admin type
				If $testerinfo[3] = "admin" Then
					EnableAdminGUI(1)
				Else
					EnableAdminGUI(0)
				EndIf
			Else
				Msgbox(16, "Wrong password entered", "Klever will close.")
			EndIf
		EndIf
	Else
		Msgbox(16, "Empty password entered", "Klever will close.")
	EndIf
	return $success
EndFunc

;Create Add new tester login GUI
Func GUIChangeCurrentPassword($login)
	local $success = 0

	;First check if tester db file exists
	local $dir = EnvGet("TesterDbDir")
	local $testerdbfile = $dir & "\" & $login
	local $testtempfile = @TempDir&"\.ktempfile"
	_Crypt_DecryptFile($testerdbfile, $testtempfile, "modulus" , $CALG_AES_128)
	local $testerinfo = KFileReadLine($testtempfile)
	FileDelete($testtempfile)
	If IsArray($testerinfo) Then
		local $changegui = GUICreate("Changing "&$login&" password", 300, 200)

		local $guiloginlabel = GUICtrlCreateLabel("Current Password:", 10, 10, 100, 20)
		local $guicpassword = GUICtrlCreateInput("", 120, 10, 150, 20,$ES_PASSWORD)

		local $guirealnamelabel = GUICtrlCreateLabel("New Password:", 10, 40, 100, 20)
		local $guinpassword = GUICtrlCreateInput("", 120, 40, 150, 20,$ES_PASSWORD)

		local $buttonChange=GUICtrlCreateButton("Change",10,180,100,20)
		local $buttonCancel=GUICtrlCreateButton("Cancel",180,180,100,20)

		GUISetState()
		While 1
			local $nMsg = GUIGetMsg()
			Switch $nMsg
				Case $buttonChange
					;first check if current password is matched
					local $cpassfromgui = GUICtrlRead($guicpassword)
					local $cpassfromdb = KPasswordDecrypt($testerinfo[1], $cpassfromgui)

					If $cpassfromgui = $cpassfromdb Then
						local $npassfromgui = KPasswordEncrypt(GUICtrlRead($guinpassword))
						ChangeTesterFile($dir, $login, $npassfromgui, $testerinfo[2], $testerinfo[3], $testerinfo[4], $testerinfo[5])
						ExitLoop
					Else
						Msgbox(16, "Unauthorized password entered", "Klever will close.")
						Exit
					EndIf
				Case $buttonCancel
					Exitloop
				Case $GUI_EVENT_CLOSE
					Exitloop
			EndSwitch
		WEnd
		GUIDelete($changegui)
	EndIf

	return $success
EndFunc

;FileReadLine
Func KFileReadLine($file, $line=1)
	Local $myfile = FileOpen($file)
	If $myfile = -1 Then
		MsgBox(0, "Error", "Unable to open file " &$file )
		Exit
    EndIf

	local $myline = FileReadLine($myfile, $line)
	FileClose($myfile)

	local $testerinfo = 0
	$testerinfo = StringSplit($myline, ",")
	If $testerinfo[0] = 5 Then
		;good
	Else
		$testerinfo = 0
		MsgBox(0, "Error", "Bad Tester info.  It is recommended to re-create a new tester.")
	EndIf
	return $testerinfo
EndFunc

;1 = enable
;0 = disable
Func EnableAdminGUI($enable)
	If $enable = 1 Then
		EnableGUI($menuAdmin)
		EnableGUI($guiTestCasefolderButton)
		EnableGUI($guiScriptfolderButton)
		EnableGUI($guiLogfolderButton)
		EnableGUI($guiRunId)
		EnableGUI($guiTestrunCopy)
	Else
		DisableGUI($menuAdmin)
		DisableGUI($guiTestCasefolderButton)
		DisableGUI($guiScriptfolderButton)
		DisableGUI($guiLogfolderButton)
		DisableGUI($guiRunId)
		DisableGUI($guiTestrunCopy)
	EndIf
EndFunc

;success = 0/1; 1 = good
Func ChangeTesterFile($dir, $login, $pass, $name, $type, $date, $email)
	;encrypt the password
	local $success = 1
	local $loginfullpath = $dir & "\" & $login
	local $linetowrite = $pass &","& $name &","& $type &","& $date &","& $email
	;Create new file
	Local $file = FileOpen($loginfullpath, 10)
	; Check if file opened for writing OK
	If $file = -1 Then
		MsgBox(0, "Error", "Unable to open file:" & $loginfullpath)
		$success = 0
	Else
		FileWrite($file, $linetowrite)
		FileClose($file)
	EndIf

	_Crypt_EncryptFile($loginfullpath, $loginfullpath&".encrypted", "modulus" , $CALG_AES_128)
	FileMove($loginfullpath&".encrypted", $loginfullpath, 1)

	return $success
EndFunc

Func LoadDeviceConfig()
	If GUICtrlRead($guiDeviceConfcheckbox)=1 Then
		Local $currentDeviceConfig = $kleverTestcaseConfig&"\Devices\"&GUICtrlRead($guiDeviceConfSelect)
	Else
		Local $currentDeviceConfig = $kleverTestcaseConfig&"\Devices\"&GUICtrlRead($guiEncip&".conf")
	EndIf

	If FileExists($currentDeviceConfig) Then
		local $devicearray=KFileReadToArray($currentDeviceConfig)
		AssignVariable($devicearray)
	EndIf
EndFunc

