#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <KleverLib.au3>

Opt("GUICloseOnESC", 0)

Global $currenttestrunconfig = $kleverTestcaseConfig&"\"&$testRunConfig

Global $testcaseRan
Global $testcaseRunning
Global $testcaseLast
Global $testcaseMISC="n/a"

Global $EncVersion

$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Run testCase in commandline modes."&@crlf& _
			""&@crlf& _
			""&@scriptname&" encIp=<EncAddrr> jobid=[jobid] testCase=<testCase/testGroup> testDevice=[configFile]"&@crlf& _
			""&@scriptname&" testCase=<testCase/testGroup>"&@crlf& _
			""&@crlf& _
			" <encIp>"&@TAB&@TAB&"Encoder Ip Address."&@crlf& _
			" [jobid]"&@TAB&@TAB&"JobId of current run."&@crlf& _
			" <testRun>"&@TAB&@TAB&"TestRun name.  The full path will be kleverProjectHome\TestRuns\testRun"&@crlf& _
			" <testcase>"&@TAB&@TAB&"Full path of the *.testCase file."&@crlf& _
			" <testGroup>"&@TAB&@TAB&"Full path of the *.testGroup file."&@crlf& _
			" <configFile>"&@TAB&@TAB&"device.conf or device.group file."&@crlf& _
			""

CheckArguments()
main()


Func main()
	;Adding
	$kleverTestCasesDir = EnvGet("kleverProjectHome") & "\TestRuns\" & EnvGet("testRun")
	EnvSet("kleverTestCasesDir", $kleverTestCasesDir)

	$kleverLogDir = $kleverTestCasesDir&"\Logs"

	$kleverTestcaseConfig = $kleverTestcasesDir&"\Config"
	$kleverTestScriptsConfigDir = $kleverTestScriptsDir&"\Config"
	Local $testDeviceArray = GetTestDevices()
	Local $testcasearray = GetTestCases()

	;TestDevice loop
	For $d = 1 to $testDeviceArray[0]
		;Need to read each device config
		Local $currentDeviceConfig = $kleverTestcaseConfig&"\Devices\"&$testDeviceArray[$d]
		If FileExists($currentDeviceConfig) Then
			local $devicearray=KFileReadToArray($currentDeviceConfig)
			AssignVariable($devicearray)
		EndIf

		local $Job_Override = 0
		If IsDeclared("jobId") Then
			local $Override_JobId = eval("jobId")
			local $Job_Override = 1
		EndIf

		;Testcase loop
		For $i = 1 to $testcasearray[0]
			;Need to reset testcase status and overallstatus
			$programExitCode = 0
			$continueOnFailure = 0
			EnvSet("continueOnFailure", 0)

			EnvSet($testcaseResult[0], 0)
			EnvSet($testcaseResult[1], 0)
			EnvSet($testcaseResult[2], 0)

			$testcase = $testcasearray[$i]
			cliProgramStart()
			GetRunID()
			GetCaseID()

			$kleverTestcaseInfo = $kleverTestcasesDir&"\Info"
			$kleverTestcaseConfig = $kleverTestcasesDir&"\Config"
			$currenttestrunconfig = $kleverTestcaseConfig&"\"&$testRunConfig

			LoadRunningConfig()
			$kleverTestScriptsDir = EnvGet("kleverProjectHome") & "\ScriptHome\" & EnvGet("testscriptsdir")
			EnvSet("kleverTestScriptsDir", $kleverTestScriptsDir)
			RenewEnv()

			;SetupDataEth()
			RunTestCase()

			;Preparing for RemoteDBUpdate($status)
			RemoteDBUpdate($testcaseDBResult[$programExitCode])

			ProgramEnd(0)

			;Copy current log to working dir for continuing test cases
			FileCopy($LogFile, $kleverCurrentDir)
			if $Job_Override = 1 Then
				$jobId = $Override_JobId
			Else
				$jobId = ""
			EndIf
		Next

	Next

EndFunc

Func CheckArguments()
	if not isDeclared("testCase") Or not isDeclared("encIp")  Then
		consoleWrite("Missing Parameters")
		consoleWrite($usageMsg)
		Exit(2)
	EndIf

	If IsDeclared("remoteClient") Then ; perform execution on remote machine
		local $mycommand = RemoteClientCheck("klevercli.exe " & $CmdLineRaw)

		If EnvGet("remotePcUser") == "" Then
			AssignVariable("remotePcUser", EnvGet("Administrator"))
			KConsoleWrite("Username for remote pc is not defined.  Use default: " & EnvGet("remotePcUser"), 0, 2)
		EndIf
		If EnvGet("remotePcPass") == "" Then
			AssignVariable("remotePcPass", EnvGet("vcp@arris"))
			KConsoleWrite("Password for remote pc is not defined.  Use default: " & EnvGet("remotePcPass"), 0, 2)
		EndIf

		KConsoleWrite("Command: " & $mycommand & " will run on remote client: " & eval("remoteClient"))
		local $remotecommand = "psexec -u " & EnvGet("remotePcUser") & " -p " & EnvGet("remotePcPass") & " -i -d \\"&eval("remoteClient") & " " &$mycommand
		KConsoleWrite(@CRLF & $remotecommand & @CRLF)
		local $runreturn=run($remotecommand, @workingdir&"\")
		KConsoleWrite("Return Pid: " & $runreturn & @CRLF)
		Exit(0)
	EndIf
EndFunc

Func RemoteClientCheck($mycommand)
	local $cmdarray = stringsplit($mycommand, " ")
	local $kcmd = $cmdarray[1]
	local $cmdend

	;if StringRegExp($kcmd, "^klevercli.exe") = 1 Then
	;	$kcmd = '"'&envGet("KleverHome")&"\"&$kcmd&'"'
		;$kcmd = '"'&"C:\Program Files\Kaffeine\Klever\"&$kcmd&'"'
	;EndIf

	for $i = 2 to $cmdarray[0]
		if StringRegExp($cmdarray[$i], "remoteClient", 0)=1 Then
			$tarray = StringSplit($cmdarray[$i], "=")
			Assign("remoteClient", $tarray[2],2)
		Else
			if StringRegExp($cmdarray[$i], "logFile", 0)=1 Then
				;do not add it back to argument list
			Else
				$cmdend = $cmdend & " " & $cmdarray[$i]
			EndIf
		EndIf
	Next

	return $kcmd & " " & $cmdend
EndFunc


Func GetTestDevices()
	Local $myarray

    Local $defaultarray[2]
	$defaultarray[0] = 1
	$defaultarray[1] = ""

	if IsDeclared("testDevice") Then
		Local $devicegroupfile = $kleverTestcaseConfig&"\Devices\"&$testDevice
		$defaultarray[1] = $testDevice
		;if tesdevice is a group, parse the group
		if  (StringRegExp($testDevice, ".group",0)=1) Then
			if FileExists($devicegroupfile) Then
				_FileReadToArray($devicegroupfile, $myarray)
			Else
				consoleWrite($devicegroupfile&" is not found"&@CRLF)
				Exit(2)
			EndIf
		Else
			$myarray = $defaultarray
		EndIf
	Else
		$myarray = $defaultarray
	EndIf

	consoleWrite($myarray[0]&" Devices under Test Found."&@CRLF)
	return $myarray
EndFunc

Func GetTestCases()
	Local $testgroupfile = $kleverTestCasesDir&"\"&$testcase
	Local $myarray

	Local $defaultarray[2]
	$defaultarray[0] = 1
	$defaultarray[1] = $testCase

	;if testcase is a testgroup, parse the testgroup
	if  (StringRegExp($testCase, "testgroup",0)=1) Then
		if FileExists($testgroupfile) Then
			_FileReadToArray($testgroupfile, $myarray)
		Else
			consoleWrite($testgroupfile&" is not found"&@CRLF)
			Exit(2)
		EndIf
	Else
		$myarray = $defaultarray
	EndIf

	consoleWrite($myarray[0]&" Testcases Found."&@CRLF)
	return $myarray
EndFunc

Func cliProgramStart()
	$startTime = _Timer_Init()
	CreateJobID()

	KConsoleWrite("-->"&@scriptname &"/ErrorStdOut testcase="&$testcase, 0, 1)
	KConsoleWrite(@scriptname&" begins ... "&$startTime, 0, 1)
	_FileWriteToLine($logFile, 1,"--> "&@scriptname & " starts..."&@CRLF,0)
EndFunc

Func RunTestCase()
	$testcaseRan = $testCase&".ran"
	$testcaseRunning = $testCase&".running"
	$testcaseLast = $testCase&".last"
	GetCaseInfo()
    GetClientInfo()
	EncoderPingCheck()
	EncoderInuseCheck()
	GetEncoderInfo()
	EncoderVersionCheck()
	UpdateTestCaseRunning(0)
	RemoteDBUpdate("running")
	klevercmd()

EndFunc

Func RemoteDBUpdate($status)
	;Check if RemoteDB update is available
	If EnvGet("caseId") == "" or  EnvGet("caseId") == "N/A" or EnvGet("rpcUpdateFlag") == "no" Then
		KConsoleWrite("rpcUpdateDBFlag detected.  Skipping rpc update." , 0, 2)
	Else
		local $rpcCmd = EnvGet("rpcUpdate")
		local $rpcUser = EnvGet("atmUser")

		local $mynote = StringReplace(EnvGet("logFile"), "\export", "", 1)
		local $myarray = StringSplit(EnvGet("kleverTestCasesDir"), "\")
		local $temp = $myarray[0]

		$mynote = chr(34) & "From Klever Run: " & $myarray[$temp] & ".  Test name: " & EnvGet("testcase") & ". Log - http:" & $mynote & chr(34)

		If $rpcCmd <> "" Then
			local $mycmd = $rpcCmd & " atmTestResult="&$status & " atmTestNote=" & $mynote
			KConsoleWrite("==========================DB Update Routine Start ======================")
			;saving current programexitcode

			local $programexitcode_save = $programExitCode
			Runcommand($mycmd, @WorkingDir, 1, @SW_SHOW, 1)
			$programExitCode = $programexitcode_save
			KConsoleWrite("==========================DB Update Routine End ======================")
		EndIf
	EndIf
EndFunc

Func GetEncoderInfo()
	If not IsDeclared("versionCheckCommand") Then
		Assign("versionCheckCommand", "klever_get_version.exe", 2)
	EndIf

	local $encoderinfo = "encoder_version.info"
	local $encoderinfopath = $kleverCurrentDir & "\" & $encoderinfo
	local $myCommand = $kleverTestScriptsDir & "\" & eval("versionCheckCommand")
	If FileExists($myCommand) Then
		Run("auto_answer_putty_popup.exe", @WorkingDir, @SW_HIDE)
		RunCommand(eval("versionCheckCommand") & " encIp=" & EnvGet("encIp") &" outputFile=" & $encoderinfo, $kleverCurrentDir)
		LoadConfig($encoderinfopath, "")
	Else
		KConsoleWrite("Version Check Command: " & $myCommand & " is not available.  Encoder's version is unknown.")
	EndIf

EndFunc

Func CreateJobID()
	If not IsDeclared("jobId") or $jobId = "" Then
		;Global $jobId = "Job_"&$startTime
		Assign("jobId", "Job_"&$startTime, 2)
	EndIf
	$kleverLogDir = $kleverTestCasesDir&"\Logs"
	$logFile = $kleverLogDir&"\"&$jobId&".log"
	Envset("logFile", $logFile)
	If FileExists($LogFile) Then
		FileMove($LogFile,$Logfile&".old",1)
	EndIf
	KDirCreate($kleverLogDir)
	$kleverCurrentDir = $kleverWorkingDir&"\"&$jobId
	AssignVariable("kleverCurrentDir", $kleverWorkingDir&"\"&$jobId)
	KDirCreate($kleverCurrentDir)

	$kleverCurrentDepotDir = $kleverCurrentDir&"\DepotFiles"
	AssignVariable("kleverCurrentDepotDir", $kleverCurrentDir&"\DepotFiles")
	KDirCreate($kleverCurrentDepotDir)

	KConsoleWrite("Current Dir="&$kleverCurrentDir&@CRLF, 0)
EndFunc

Func EncoderInuseCheck()
	Local $inusearray
	If StringLower(EnvGet("SkipEncoderCheck")) == "yes" Then
		KConsoleWrite("Skipping Encoder Inused Check.")
	Else
		If FileExists($kleverTestcaseInfo&"\"&EnvGet("encIp")&".Inused") Then
			$inusefile= KFileOpen($kleverTestcaseInfo&"\"&EnvGet("encIp")&".Inused",0)
			$splitline = StringSplit(FileReadLine($inusefile),",")
			FileClose($inusefile)
			KConsoleWrite("Encoder "&EnvGet("encIp")&" is being use by "&$splitline[1]&" on "&$splitline[2]&". Jobid = "&$splitline[3],1)
		EndIf
	EndIf
EndFunc

Func LoadRunningConfig()
	If FileExists($currenttestrunconfig) Then
		local $defaultarray=KFileReadToArray($currenttestrunconfig)
		AssignVariable($defaultarray)
	EndIf
EndFunc

Func EncoderVersionCheck()
	$EncVersion = EnvGet("Encversion")

	If IsDeclared("ExpectedVersion") Then
		If	$ExpectedVersion <> $EncVersion Then
			KConsoleWrite("Checking Version, Expected="&$ExpectedVersion&" Current="&$EncVersion&" Failed.",1)
		Else
			KConsoleWrite("Checking Version, Expected="&$ExpectedVersion&" Current="&$EncVersion&" Passed.",0)
		EndIf
	Else
		KConsoleWrite("ExpectedVersion is not declared. Test is using current version: "&$EncVersion & ". Version Check passed.",0)
	EndIf

EndFunc

Func GetClientInfo()
	$drive_ProjectHome = StringLeft($kleverProjectHome,2)
	$drive_Working = StringLeft($kleverWorkingDir,2)
	$msgtowrite =  @CRLF
	$msgtowrite &= "======== Automation Client Info=======================================================" & @CRLF
	$msgtowrite &= "ComputerName="&@ComputerName&"("&EnvGet("controlEth")&")"&@CRLF
	$msgtowrite &= "OS="&@OSVersion&"("&@OSArch&")"&@CRLF
	$msgtowrite &= "RemoteHost="&eval("RemoteHost")&@CRLF
	$msgtowrite &= "TesterName="&$testerName&@CRLF
	$msgtowrite &= "ProjectHome DiskUsage:"&KGetDriveInfo($drive_ProjectHome)&@CRLF
	$msgtowrite &= "WorkingDir DiskUsage:"&KGetDriveInfo($drive_Working)&@CRLF
	$msgtowrite &= KGetMemoryInfo()&@CRLF
	$msgtowrite &= "======================================================================================" & @CRLF

	_FileWriteToLine($logFile, 2, $msgtowrite, 0)
EndFunc

Func GetCaseID()
	Local $defaultarray
	$error = _FileReadToArray($kleverTestcasesDir&"\CaseId\"&$testcase&".caseId",$defaultarray)
	If $error = 1 Then
		AssignVariable($defaultarray)
	EndIf
EndFunc

;RunId
;CaseId
;Testcasepath
Func GetCaseInfo()
	$msgtowrite =  @CRLF
	$msgtowrite &= "======== Test Case Info=======================================================" & @CRLF
	$msgtowrite &= "RunId="&EnvGet("runId")&@CRLF
	$msgtowrite &= "CaseId="&EnvGet("caseId")&@CRLF
	$msgtowrite &= "TestCase="&$testcase&@CRLF
	$msgtowrite &= "TestCasesDir="&$kleverTestCasesDir&@CRLF
	$msgtowrite &= "TestScriptsDir="&$kleverTestScriptsDir&@CRLF
	$msgtowrite &= "TestScriptWorkingDir="&$kleverCurrentDir&@CRLF
	$msgtowrite &= "======================================================================================" & @CRLF

	_FileWriteToLine($logFile, 2, $msgtowrite, 0)
EndFunc

Func KGetDriveInfo($drive)
	$DriveInfo = StringUpper($Drive)
	;$DriveInfo &= " -  File System = " & DriveGetFileSystem($DriveArray[$DriveCount])
	;$DriveInfo &= ",  Label = " & DriveGetLabel($DriveArray[$DriveCount])
	;$DriveInfo &= ",  Serial = " & DriveGetSerial($DriveArray[$DriveCount])
	$DriveInfo &= " Type = " &  DriveGetType($Drive)
	$DriveInfo &= ",  Free = " & round((DriveSpaceFree($Drive)/1024), 2) & "GB"
	$DriveInfo &= ",  Total = " & round((DriveSpaceTotal($Drive)/1024), 2) & "GB"
	$DriveInfo &= ",  Status = " & DriveStatus($Drive)
	;$DriveInfo &= @CRLF
	Return $DriveInfo
EndFunc

Func KGetMemoryInfo()
	$mem = MemGetStats()

	$MemoryInfo = "Physical RAM: "
	$MemoryInfo &= "Free = "& round(($mem[2]/1024), 2) & "MB"
	$MemoryInfo &= ", Total = "& round(($mem[1]/1024), 2) & "MB"
	Return $MemoryInfo
EndFunc

Func klevercmd()
	Local $msg
	GUICreate(@scriptname&"  "&$jobId,400,80,1,1, -1,$WS_EX_TOPMOST)
	;put progress bar here for later
	GUICtrlCreateLabel(@MON&"-"&@MDAY&"-"&@YEAR&" "&@HOUR&":"&@MIN&":"&@SEC&@CRLF& "Current test: "&$testcase & @CRLF &"Running by " & eval("testerName") &" from "& eval("remotehost") & @CRLF &"Device Under Test: " & eval("encIp"), 15, 15, 400, 80)
	GUISetState(@SW_SHOW)
	$my_tempfile = $kleverCurrentDepotDir&"\"&$testCase&"_"&DateString();
	FileCopy($kleverTestcasesDir&"\"&$testCase, $my_tempfile, 8);
	;clean up comments #
	testcasecleanup($my_tempfile);
	testcaseproc($my_tempfile)
	GUIDelete()
EndFunc

Func testcaseproc($tempfile)
	$scriptfile = KFileopen($tempfile,0)
	local $cliStartTime = _Timer_Init()
	local $cliEndTime = round((_Timer_Diff($cliStartTime)/1000), 2)
	local $returnstatus = 0
	While 1

		;Detecting STOP
		StopCheck()

		$line = FileReadLine($scriptfile);

		If @error = -1 Then ExitLoop
	    $check = 0;

		; Clean up any leading and trailing white spaces
		$line = StringStripWS($line, 3)

		; Dectecting #
		StringRegExp($line, "^#", 1);
		If (@error = 0) Then
			$check = 1;
			KConsoleWrite($line)
			ContinueLoop
		EndIf

		$cliStartTime = _Timer_Init()

		; Detecting TEST
		StringRegExp($line, "^TEST", 1);
		If (@error = 0) Then
			$check = 1;
			;Create temporary test file
			$puttyscriptfilename = "puttyscript_"&DateString()
			$tfile = FileOpen($kleverCurrentDepotDir&"\"&$puttyscriptfilename, 2);

			While 1
				$line = FileReadLine($scriptfile)
				;Until finding the TESTEND, we need to close the file and run it
				StringRegExp($line, "^TESTEND", 1);
				If @error = 0 Then
					FileFlush($tfile)
					FileClose($tfile);
					Run("auto_answer_putty_popup.exe", @WorkingDir, @SW_HIDE)
					$returnstatus = RunSecureTestScript($puttyscriptfilename,$kleverCurrentDepotDir);
					;UpdateOverallStatus($returnstatus)
					$returnstatus = 0
					ExitLoop(1);
				EndIf
				FileWriteLine($tfile, $line);
			WEnd
			FileClose($tfile);

		EndIf

		; Detecting GET
		StringRegExp($line, "^GET", 1);
			If (@error = 0) Then
				$check = 1;
				;Create temporary get file
				$pscpscriptfilename = "pscpscript_"&DateString()
				$gfile = FileOpen($kleverCurrentDepotDir&"\"&$pscpscriptfilename, 2);

				While 1
					$line = FileReadLine($scriptfile)
					;Until finding the GETEND, we need to close the file and run it
					StringRegExp($line, "^GETEND", 1);
					If @error = 0 Then
						FileFlush($gfile)
						FileClose($gfile);
						sleep(500);
						Run("auto_answer_putty_popup.exe", @WorkingDir, @SW_HIDE)
						$returnstatus = RunSecureGetScript($kleverCurrentDepotDir&"\"&$pscpscriptfilename,$kleverCurrentDir);
						;UpdateOverallStatus($returnstatus)
						$returnstatus = 0
						ExitLoop(1);
					EndIf

					FileWriteLine ($gfile, $line);
				WEnd

				FileClose($gfile);
			EndIf

		; Detecting PUT
		StringRegExp($line, "^PUT", 1);
			If (@error = 0) Then
				$check = 1;
				;Create temporary put file
				$pscpscriptfilename = "pscpscript_"&DateString()
				$pfile = FileOpen($kleverCurrentDepotDir&"\"&$pscpscriptfilename, 2);

				While 1
					$line = FileReadLine($scriptfile)
					;Until finding the GETEND, we need to close the file and run it
					StringRegExp($line, "^PUTEND", 1);
					If @error = 0 Then
						FileFlush($pfile)
						FileClose($pfile);
						sleep(500);
						$returnstatus = RunSecurePutScript($kleverCurrentDepotDir&"\"&$pscpscriptfilename,$kleverCurrentDir);
						;UpdateOverallStatus($returnstatus)
						$returnstatus = 0
						ExitLoop(1);
					EndIf

					FileWriteLine ($pfile, $line);
				WEnd

				FileClose($pfile);
			EndIf

		; Dectecting WC
		StringRegExp($line, "^<WC>", 1);
			If (@error = 0) Then
				$check = 1;
				$line = StringReplace($line,"<WC>","")
				KConsoleWrite($line)
			EndIf

		; Detecting WAIT
		StringRegExp($line, "^WAIT+", 1);
			If (@error = 0) Then
				$check = 1;
				$waitmeter = stringsplit($line," ")
				$Kaffeinedir = StringReplace($kleverHome,"\Klever","")
				Select
					Case $waitmeter[0] = 2
						RunWait("auto_wait.exe " &$waitmeter[2])
					Case $waitmeter[0] = 3
						RunWait("auto_wait.exe " &$waitmeter[2]&" "&$waitmeter[3])
					Case Else
						RunWait("auto_wait.exe 1")
				EndSelect
			EndIf

		; Else Run the exec as in the script
		If $check = 0 Then
			$clistartTime = _Timer_Init()
			$mycommand = $line
			$returnstatus = RunCommand($mycommand, $kleverCurrentDir, 1, 1);
			;UpdateOverallStatus($returnstatus)
		EndIf

		$cliEndtime = round((_Timer_Diff($cliStartTime)/1000), 2)
		EnvSet("elapsedTime", $cliEndtime)

		;UpdateOverallStatus($returnstatus)
		$returnstatus = 0

	Wend
	FileClose($scriptfile)
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