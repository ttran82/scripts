#include <File.au3>
#include <Array.au3>
#Include <Timers.au3>
#include <Constants.au3>

;#User defined Varialbe Tag Base
Global $parameterList=""

;Global Variables
Global $controlEth="", $dataEth=@IPAddress1
Global $infoMsg
Global $usageMsg
Global $reportFile = ""

;Klever Global variables available during runtime
Global $startTime, $endTime

;Global $kleverHome = @scriptdir
Global $kleverHome = envget("KleverHome")
Global $kleverAppLogDir = $kleverHome&"\Logs"
;global $kleverScriptDir = $kleverHome ; all the executable files belongs to klever, klever_cli, klever_m2toes, etc

Global $kleverProjectHome = $kleverHome&"\ProjectsHome"
;Global $kleverCommonScriptsDir = $kleverHome&"\Scripts"
Global $kleverCommonScriptsDir = EnvGet("KaffeineHome")&"\Tools"
Global $kleverTestRunsDir = $kleverProjectHome&"\TestRuns"
Global $kleverScriptHomeDir = $kleverProjectHome&"\ScriptHome"
Global $kleverWorkingDir = $kleverHome&"\Working"

Global $kleverCurrentDir = @WorkingDir
Global $kleverCurrentDepotDir = $kleverCurrentDir&"\DepotFiles"

Global $kleverTestCasesDir = $kleverTestRunsDir&"\Current"
Global $kleverLogDir = $kleverTestCasesDir&"\Logs"
Global $kleverTestScriptsDir = $kleverScriptHomeDir&"\Current"
Global $kleverTestScriptsConfigDir = $kleverTestScriptsDir&"\Config"

Global $kleverTempDir = $kleverHome&"\Temp"

Global $kleverConfigDir = $kleverHome&"\Configs"

Global $kleverHistoryFile = $kleverHome&"\klever.hist"
Global $kleverCliHistoryFile = $kleverHome&"\klevercli.hist"
Global $kleverTestcaseConfig = $kleverTestCasesDir&"\Config"
Global $kleverTestcaseInfo = $kleverTestCasesDir&"\Info"
Global $kleverDeviceConfig = $kleverTestcaseConfig&"\Devices"
Global $kleverSystemConfig = $kleverConfigDir&"\System"
Global $kleverDefaultsConfig = $kleverSystemConfig&"\kleverdefaults.cfg"
Global $kleverHistoryConfig = $kleverSystemConfig&"\kleverhistory.cfg"
Global $kleverCliHistoryConfig = $kleverSystemConfig&"\kleverclihistory.cfg"
DirCreate($kleverLogDir)
DirCreate($kleverDeviceConfig)

;Global program variables
If(not isdeclared("logFile")) then
	;Global $logFile = $kleverTempDir&"\"&@scriptname&"_"&dateString()&".log"
	Global $logFile = $kleverAppLogDir&"\"&@scriptname&".log"
	If FileExists($LogFile) Then
		FileMove($LogFile,$Logfile&".old",1)
	EndIf
EndIf

;Passed, Failed, or Errored
Global $testcaseResult[4]
$testcaseResult[0] = "Passed"
$testcaseResult[1] = "Failed"
$testcaseResult[2] = "Errored"
$testcaseResult[3] = "Stopped"

Global $testcaseDBResult[4]
$testcaseDBResult[0] = "pass"
$testcaseDBResult[1] = "fail"
$testcaseDBResult[2] = "errored"
$testcaseDBResult[3] = "stopped"

Global $programExitCode = 0  ; 0="Passed", 1="Failed", 2="Errored", 3="Stopped"		;This is for final status
Global $continueOnFailure = 0  ; By default, test case will fail if a test sequence fails.  This feature allow the test to continue.  Please use this carefully

if @ScriptName = "klevercli.exe" or @ScriptName = "klever.exe" Then
	ReadDefaults()
EndIf

ReadCliHistory()

;ReadHistory() only the GUI should read the History file.  The rest use what available from EnvGet()
ParseArguments()

Global $computerName = Envget("controlEth")
;ComputerNameFormat = name/number
If EnvGet("computerNameFormat") = "name" Then
	$computerName = @ComputerName
EndIf

;**********************************************************************Klever Prework Functions Group Start*******************************************************************************

;#################################################################
;read default value from kleverdefault file
;assign to global
;#################################################################
Func ReadDefaults()
	$defaultarray=KFileReadToArray($kleverDefaultsConfig)
	AssignVariable($defaultarray)
EndFunc

;#################################################################
;read history from hist file
;will overwrite the default if it's in the history
;#################################################################
Func ReadHistory()
	Local $harray=KFileReadToArray($kleverHistoryFile)
	AssignVariable($harray)
EndFunc

;#################################################################
;read history from hist file
;will overwrite the default if it's in the history
;#################################################################
Func ReadCliHistory()
	Local $harray=KFileReadToArray($kleverCliHistoryFile)
	AssignVariable($harray)
EndFunc

;#################################################################
;renew the env
;#################################################################
Func RenewEnv()
	$array=KFileReadToArray($kleverDefaultsConfig)
	For $arrayIndex = 1 to $array[0]
		$linesplit = StringSplit($array[$arrayIndex], "=", 1)
		Envset($linesplit[1], EnvGet($linesplit[1]))
	Next
EndFunc

;#################################################################
;handle the commandline, seperate the commandline into several
;global variables
;#################################################################
Func ParseArguments()
	AssignVariable($CmdLine)
EndFunc

;#################################################################
;major function to set the default/history/commandline readins to
;global variables
;"parameterList" need to be the last in commandline mode
;#################################################################
Func AssignVariable($array, $value = 1)
	If(isarray($array)) then
		For $arrayIndex = 1 to $array[0]
			Local $linesplit = StringSplit($array[$arrayIndex], "=", 1)

			;need to handle parameter with embedded =
			If $linesplit[0] > 2 Then
				local $mytarray = _ArrayToString($linesplit, '=', 2, 0)
				$linesplit[0] = 2
				$linesplit[2] = $mytarray
			EndIf

			If ($linesplit[1] = "parameterList") Then
				;check if linesplit[2] is a full path or not
				If FileExists($linesplit[2]) Then
					$parameterlistfile = $linesplit[2]
				Else
					$parameterlistfile = @WorkingDir&"\"&$linesplit[2]
				EndIf
				local $larray=KFileReadToArray($parameterlistfile)
				AssignVariable($larray)
			Else
				Assign($linesplit[1], $linesplit[2], 2)
				Envset($linesplit[1], $linesplit[2])
				ShowDebug($linesplit[1] & " " & EnvGet($linesplit[1]))
			EndIf
		Next
	Else
		Assign($array, $value, 2)
		EnvSet($array, $value)
		ShowDebug($array & " " & EnvGet($array))
	EndIf
EndFunc

;Check for undeclared argument
Func CheckMissingArgument($arg)
	;Checking for provided argument
	If EnvGet($arg) == "" Then
		KConsoleWrite("Required Parameter not found: "& $arg, 1)
	EndIf
EndFunc

;**********************************************************************Klever Prework Functions Group End*********************************************************************************

;**********************************************************************Klever Modified Functions Group Start******************************************************************************

;#################################################################
;read a file to a array with error log handling
;return the array
;#################################################################
Func KFileReadToArray($file)
	local $array[1]
	$array[0] = 0
	If Not FileExists($file) Then
		KConsoleWrite("File="&$file&" is not exist", 0)
	EndIf
	If (_filereadtoarray($file,$array)=0) Then
		KConsoleWrite("File="&$file&" read errored "&@error, 0)
	EndIf
	return $array
EndFunc

;#################################################################
;read a file to a array with error log handling
;return the array
;#################################################################
Func KFileWriteToLog($file, $verbosity=0)
	local $array = KFileReadToArray($file)
	local $arrayIndex = 1
	For $arrayIndex = 1 to $array[0]
		KConsoleWrite($array[$arrayIndex], 0, $verbosity)
	Next
EndFunc

;#################################################################
;Create Directory and send to log
;#################################################################
Func KDirCreate($dir)
	DirCreate($dir)
	if not FileExists($dir) Then
		KConsoleWrite("Can not create "&$dir &@CRLF, 1)
	Else
		KConsoleWrite("Dir Created="&$dir, 0, 2)
	EndIf
EndFunc

;#################################################################
;Do a fileopen with 0(read),1(append),2(overwrite) mode
;will try $retryoverride times if failed to open the file
;#################################################################
Global $fileOpenRetry = EnvGet("fileOpenRetry")
Func KFileOpen($file,$openmode,$retryoverride=$fileOpenRetry, $exit_on_error=1)
	;Msgbox(0, "TT", "file="&$file&" retryoverride="&$retryoverride);
	$filehandle = FileOpen($file, $openmode)
	$retry=0
	While ($filehandle = -1)
		Sleep(1000)
		$retry=$retry+1
		If $retry > $retryoverride Then
			KConsoleWrite("Error opening "&$file&" Retry = "&$retry,$exit_on_error)
		EndIf
		$filehandle = FileOpen($file, $openmode)
	WEnd
	Return $filehandle
EndFunc

;#################################################################
;write a line of text to the selected line with override option
;If failed to write will try $retryoverride times, default is
;defined by $fileOpenRetry in kleverdefault file
;#################################################################
Global $fileOpenRetry = EnvGet("fileOpenRetry")
Func KFileWriteToLine($file,$linenumber,$text,$overwrite,$retryoverride=$fileOpenRetry)
	$writelinehandle = _FileWriteToLine($file, $linenumber, $text , $overWrite)
	$errortype=@error
	$retry=0
	While ($writelinehandle = 0 And $errortype <> "")
		sleep(1000)
		$retry=$retry+1
		If $retry > $retryoverride Then
			KConsoleWrite("Error opening "&$file&"Retry = "&$retry,1)
		EndIf
		$writelinehandle=_FileWriteToLine($file, $linenumber, $text , $overWrite)
	WEnd
	Return $writelinehandle
EndFunc

;#################################################################
;a error check of FileOpen
;#################################################################
Func KFileOpenCheck($file, $exitonerror)
	If $file = -1 Then
		KConsoleWrite("Unable to open file " & $file,$exitonerror)
	EndIf
EndFunc

;#################################################################
;delete a file.
;will check if the file is there or not. After delete will
;check if the deletio success or not
;#################################################################
Func KFileDelete($file)
	If FileExists($file) Then
		KConsoleWrite("Deleting file "&$file,0)
		FileDelete($file)
		;check fileexist after delete
		If FileExists($file) Then
			KConsoleWrite("Can not delete file "&$file,0)
		EndIf
	Else
		KConsoleWrite("File "&$file&" is not exist.",0)
	EndIf
EndFunc

;#################################################################
;set a file to readonly or writable by setmode
;#################################################################
Func KFileSetAttrib($file,$setmode)
	If $setmode = "Read" Then
		KFileMakeReadonly($file)
	EndIf
	If $setmode = "Write" Then
		KFileMakeWritable($file)
	EndIf
EndFunc

;#################################################################
;set a file to readonly
;$file is file full path
;#################################################################
Func KFileMakeReadonly($file)
	$error = FileSetAttrib($file, "+RS")
	If $error = 0 Then
		KConsoleWrite("Problem setting attributes.",1)
	;Else
		;KConsoleWrite($file&" set to Readonly",0)
	EndIf
EndFunc

;#################################################################
;set a file to writable
;$file is file full path
;#################################################################
Func KFileMakeWritable($file)
	$error = FileSetAttrib($file, "-RS")
	If $error = 0 Then
		KConsoleWrite("Problem setting attributes.",1)
	;Else
		;KConsoleWrite($file&" set to Readonly",0)
	EndIf
EndFunc

;#################################################################
;KConsoleWrite write the msg to log with verbosity level default=0
;error     1 means print usage, exit the program
;          0 means continue normally
;verbosity 0 default, minimal message
;		   1 contains full command line
;	 	   2 contains informative information.
;#################################################################
Func KConsoleWrite($privatemsg, $error=0, $verbosity=0)
	if IsDeclared("LogOverride") Then
		;delete it first
	EndIf

	if ($privatemsg <> "") then
		If isDeclared("WriteToConsole") Then
			consolewrite($privatemsg)
		EndIf

		If Envget("Verbosity") >= $verbosity Then
			_FileWriteLog($logFile, $privatemsg)
		EndIf
	EndIf

	if $error=1 Then
		;_FileWriteLog($logFile, $usageMsg)
		If isDeclared("WriteToConsole") Then
			consolewrite($usageMsg)
		EndIf
		$programExitCode=2
		ProgramEnd()
	endif
EndFunc

;#################################################################
;$option	2 = Path must Exist
;			16 = Prompt to OverWrite File
;Return		0 = save success
;			1 = selection failed
;			2 = bad file filter
;#################################################################
Func KFileSave($filetype,$defaultsavedir, $filter,$option, $defaultname, $datatosave)
	$saveto=FileSaveDialog("Save "&$filetype&" to", $defaultsavedir, $filter, $option, $defaultname)
	$filesaveerror = @error
	if $filesaveerror = 1 Then
		KConsoleWrite($saveto&" selection failed", 0)
		Return 1
	Elseif $filesaveerror = 2 Then
		KConsoleWrite("Bad file filter", 0)
		Return 2
	Else
		_FileWriteLog($logFile, "File Save="&$saveto)
		$savefile = FileOpen($saveto, 2)
		FileWrite($savefile, $datatosave)
		FileClose($savefile)
		Return $saveto
	EndIf
EndFunc

;#################################################################
;check if the file exist
;#################################################################
Func KFileExists($myfile)
	local $status = 1;
	if Not FileExists($myfile) Then
		$status = 0
    	KConsoleWrite($myfile&" is not existed")
	Endif
	return $status
EndFunc

;#################################################################
;exit the program with exitcode
;exitcode is use for log
;#################################################################
Func KExit()
	Exit($programExitCode)
EndFunc

;**********************************************************************Klever Modified Functions Group End******************************************************************************

;**********************************************************************Common Functions Group Start*************************************************************************************

;#################################################################
;run at program start
;setup starttime, env, and write logs
;#################################################################
Func ProgramStart()
	$startTime = _Timer_Init()

	KConsoleWrite(@CRLF)
	KConsoleWrite("=> " & @scriptname&" begins ... "&$startTime&@CRLF, 0, 2)

EndFunc

;#################################################################
;run when program finish or errored
;write finish time and finish message to log then exit program
;for klevercli will make sure .ran/,last/.running files will
;be take care even errored
;#################################################################
Func ProgramEnd($doexit = 1)
	;_FileWriteLog($logFile, "==> ErrorCode: "&@error&@CRLF)
	$endtime = round((_Timer_Diff($startTime)/1000), 2)
	_FileWriteLog($logFile, "<= " & @scriptname&" ended ...("&$testcaseResult[$programExitCode]&").  Elapsed time = "&$endtime&" seconds.")
	_FileWriteLog($logFile, @CRLF)
	_FileWriteToLine($logFile, 1,"["&$testcaseResult[$programExitCode]&"] "&@scriptname&" ended ....  Elapsed time = "&$endtime&" seconds.",1)

	;Update test case related files for klevercli.exe
	If isDeclared("testCase") Then
		;Write overallstatus to log
		_FileWriteLog($logFile, "***Overall Stats: " & GetOverallStatus() )
		_FileWriteLog($logFile, @CRLF)
		_FileWriteToLine($logFile, 2, "***Overall Stats: " & GetOverallStatus())

		Global $Testcase_finishedtime = DateString()
		Global $Testcase_duration = round((_Timer_Diff($startTime)/1000), 2)

		;Need to remove your self from the inused list
		$inusedmsgtodel=$testerName&","&$computerName&","&$jobId
		$encinusedfile = $kleverTestcaseInfo&"\"&EnvGet("EncInUsed")&".Inused"
		$inusedarray=KFileReadToArray($encinusedfile)
		For $x=1 to $inusedarray[0]
			If StringCompare($inusedarray[$x],$inusedmsgtodel)=0 Then
				$file=KFileWriteToLine($encinusedfile,$x,"",1,EnvGet("fileOpenRetry"))
				ExitLoop
			EndIf
		Next

		If isDeclared("inUsedFlag") Then
			$checksize = FileGetSize($encinusedfile)
			If $checksize = 0 And @error <> 1 Then
				FileDelete($encinusedfile)
			EndIf
		EndIf
		;End inused

        If isDeclared("updateResult") Then
			UpdateTestCaseLast()
			UpdateTestCaseRan()
		Endif
		UpdateTestCaseRunning(1)

		;Copy current log to working dir when error encountered
		FileCopy($LogFile, $kleverCurrentDir)
	EndIf

	if $doexit=1 Then
		KExit()
	EndIf

EndFunc

;###################################################################
;Report overall status of all the Runcommand operations
;###################################################################
Func GetOverallStatus()
	local $passed = "Passed ("&EnvGet("Passed")&")"
	local $failed = "Failed ("&EnvGet("Failed")&")"
	local $errored = "Errored ("&EnvGet("Errored")&")"
	return $passed & " " & $failed & " " & $errored
EndFunc

;###################################################################
;Increment Runcommand return status
;###################################################################
Func UpdateOverallStatus($rstatus)
	local $status = $testcaseResult[$rstatus]
	EnvSet($status, int (EnvGet($status)) + 1 )
	KconsoleWrite(GetOverallStatus(), 0, 2)
EndFunc

;################################################################
;update LAST file in workingdir with the $filename
;it will append on the first line
;################################################################
Func UpdateLastFile($myfilename)
	local $lastfile = @WorkingDir&"\LAST"
	;First check if file exsited
	If KFileExists($myfilename) = 0 Then
		$programExitCode = 1
		Else
	;if ($programExitCode = 0) Then
		FileWriteLine($lastfile, $myfilename)
	;EndIf
	EndIf
EndFunc

;################################################################
;get LAST file in workingdir with the $filename
;it will append on the first line
;################################################################
Func GetLastItem($line = -1)
	local $file=""
	local $lastfile = @WorkingDir&"\LAST"
	If KFileExists($lastfile) Then
		$file = FileReadLine($lastfile,$line)
	EndIf
	return $file
EndFunc

;################################################################
;get current runId
;################################################################
Func GetRunID()
	If IsDeclared("runId") Then
		Assign("runId", "N/A", 2)
	EndIf

	Local $defaultarray
	$error = _FileReadToArray($kleverTestcasesDir&"\Config\testrun.runId",$defaultarray)
	If $error = 1 Then
		AssignVariable($defaultarray)
	EndIf
EndFunc

;#################################################################
;RunCommand in run/runwait show/hide mode
;wait     1 run and wait until the run complete
;         0 run the command then go to next line
;skiperror
;         1 will allow test error exception.  Thus, will not register exit condition
;#################################################################
Func RunCommand($mycommand, $workingdir=@WorkingDir, $wait=1, $hide=@SW_SHOW, $skiperror=0)

    Global $useCommandPrompt = "True"
	local $currentStatus = 0

    if $hide = 1 then
		$hide = @SW_HIDE
	EndIf
	If $hide = 0 Then
		$hide = @SW_SHOW
	Endif


	ShowDebug($mycommand)

	If Not FileExists($workingdir) Then
		KDirCreate($workingdir)
	EndIf

	KConsoleWrite("Initiate cmd: "&$mycommand&@CRLF, 0, 2)
	$mycommand = CommandLinePatch($mycommand)

	KConsoleWrite("--> "&$mycommand&@CRLF, 0, 1)

	;$mycommand = chr(34) & $mycommand & chr(34)

	If $useCommandPrompt = "True" Then
		;CheckCommand($mycommand)
		$mycommand = "cmd /c "& $mycommand
	EndIf
	;KConsoleWrite("Cleaned up cmd: "&$mycommand&@CRLF, 0, 2)

	;If IsDeclared("remoteClient") Then ; perform execution on remote machine
	;	KConsoleWrite("Command: " & $mycommand & "will run on remote client: " & eval("remoteClient"))
	;	local $remotecommand = "psexec \\"&eval("remoteClient") & " " & $mycommand
	;	$runreturn=runwait($mycommand, $workingdir&"\",$hide)

    StopCheck()
	KConsoleWrite("Modified cmd: "&$mycommand&@CRLF, 0, 2)
	;Else ; Perform execution on local machine
		If $wait = 1 Then
			$runreturn=runwait($mycommand, $workingdir&"\",$hide)
			KConsoleWrite("Runcommand return value: "&$runreturn, 0, 2)
			;to handle different command return status
			Select
				;grep return status 1 = passed, 2 = errored.  Need to put 1 to 0
				Case  StringRegExp($mycommand, "^grep") = 1
					If($runreturn = 1) Then
						$programExitCode=0
						$currentStatus = 0
					EndIf

				;handle qftest batch return
				Case  StringRegExp($mycommand, "qftest.exe") = 1
					If($runreturn > 1) Then
						$programExitCode=1
						$currentStatus = 1
					EndIf
					If($runreturn < 0) Then
						$programExitCode=2
						$currentStatus = 2
					EndIf

				;for any klever_ commands
				Case Else

					If($runreturn = 2) Then
						$programExitCode=2
						$currentStatus = 2
					Elseif ($runreturn = 1) Then
						$programExitCode=1
						$currentStatus = 1
					EndIf
			EndSelect

		Else
			$runreturn=run($mycommand, $workingdir&"\", $hide)
			KConsoleWrite("Runcommand return value: "&$runreturn, 0, 2)
			If($runreturn = 0) Then
				$programExitCode=2
				$currentStatus = 2
			Else
				;we need to store the current Pid
				EnvSet("CurrentRunningPID", $runreturn)
			EndIf
		EndIf
	;EndIf

	KConsoleWrite("Program exit code: "&$programExitCode, 0, 2)

	;take care of functions that allow to run with error
	If $skiperror = 1 Then
		$programExitCode=0
		KConsoleWrite("Error exception.  Test will continue...", 0, 2)
	EndIf

	UpdateOverallStatus($currentStatus)
	CheckRunError()
	EnvSet("currentStatus", $testcaseResult[$currentStatus])
	;return $programExitCode
	return $currentStatus
EndFunc

Func StopCheck()
	local $stopfile = $logFile&".STOP"
	if FileExists($stopfile) Then
		local $msg = KFileReadToArray($stopfile)
		KConsoleWrite($msg[1])
		$programExitCode=3
		ProgramEnd()
	EndIf
EndFunc


Func CommandLinePatch($mycommand)
	local $cmdarray = stringsplit($mycommand, " ")

	;converting env variable
	For $i = 1 to $cmdarray[0]
		StringRegExp($cmdarray[$i], "Inform=", 1)
		If (@error = 0) Then
			;do not convert if it has Inform syntax, which currently in auto_MediaInfo.exe parameter list
		Else
			$cmdarray[$i] = EnvPatch($cmdarray[$i])
		EndIf
	Next

	;do not use CommandPrompt

	local $kcmd = $cmdarray[1]
	local $subcommand_logFile

	;extract remoteClient argument out of current list of arguments
	local $cmdend
	local $tarray

	;KSET encIp "encIp"
	if StringRegExp($kcmd, "KSET") = 1 Then

		if $cmdarray[0] < 3 Then
			KConsoleWrite("KSET syntax: KSET varname varvalue" & @CRLF,1)
		EndIf

		local $varname = $cmdarray[2]
		local $varvalue = _ArrayToString($cmdarray, " " , 3)
		$varvalue = StringReplace($varvalue, '"', "")

		EnvSet($varname, $varvalue)
		$kcmd = "echo " & $kcmd
	EndIf

	;KLOADCONFIG configFile labelName
	if StringRegExp($kcmd, "KLOADCONFIG") = 1 Then
		if $cmdarray[0] < 2 Then
			KConsoleWrite("KLOADCONFIG syntax: KLOADCONFIG ConfileFile [labelName]" & @CRLF,1)
		EndIf
		local $labelName = ""
		local $configFile = $cmdarray[2]
		if $cmdarray[0] > 2 Then
		    $labelName = $cmdarray[3]
		EndIf

		$configFile = $kleverTestcaseConfig & "\Sources\" & $configFile

		If Not FileExists(eval("configFile")) Then
			KConsoleWrite("configFile: " & $configFile & " is not existed."&@CRLF,1)
		EndIf
		KconsoleWrite("Using configFile: "&eval("configFile"), 0, 2)
	    LoadConfig($configFile, $labelName)
		$kcmd = "echo " & $kcmd
	EndIf

	;KLOADCONFIG configFile labelName
	if StringRegExp($kcmd, "KLOADSOURCE") = 1 Then
		if $cmdarray[0] < 2 Then
			KConsoleWrite("KLOADSOURCE syntax: KLOADSOURCE ConfileFile [labelName]" & @CRLF,1)
		EndIf
		local $labelName = ""
		local $configFile = $cmdarray[2]
		if $cmdarray[0] > 2 Then
		    $labelName = $cmdarray[3]
		EndIf

		$configFile = $kleverTestcaseConfig & "\Sources\" & $configFile

		If Not FileExists(eval("configFile")) Then
			KConsoleWrite("configFile: " & $configFile & " is not existed."&@CRLF,1)
		EndIf
		KconsoleWrite("Using configFile: "&eval("configFile"), 0, 2)
	    LoadConfig($configFile, $labelName)
		$kcmd = "echo " & $kcmd
	EndIf

	;KLOADDEVICE configFile labelName
	if StringRegExp($kcmd, "KLOADDEVICE") = 1 Then
		if $cmdarray[0] < 2 Then
			KConsoleWrite("KLOADDEVICE syntax: KLOADDEVICE ConfileFile [labelName]" & @CRLF,1)
		EndIf
		local $labelName = ""
		local $configFile = $cmdarray[2]
		if $cmdarray[0] > 2 Then
		    $labelName = $cmdarray[3]
		EndIf

		$configFile = $kleverTestcaseConfig & "\Devices\" & $configFile

		If Not FileExists(eval("configFile")) Then
			KConsoleWrite("configFile: " & $configFile & " is not existed."&@CRLF,1)
		EndIf
		KconsoleWrite("Using configFile: "&eval("configFile"), 0, 2)
	    LoadConfig($configFile, $labelName)
		$kcmd = "echo " & $kcmd
	EndIf

	;KLOADPARAM configFile labelName
	if StringRegExp($kcmd, "KLOADPARAM") = 1 Then
		if $cmdarray[0] < 2 Then
			KConsoleWrite("KLOADPARAM syntax: KLOADPARAM ConfileFile [labelName]" & @CRLF,1)
		EndIf
		local $labelName = ""
		local $configFile = $cmdarray[2]
		if $cmdarray[0] > 2 Then
		    $labelName = $cmdarray[3]
		EndIf

		If StringRegExp($configFile,'\\',0) = 0 Then
			$configFile = $kleverCurrentDir & "\" & $configFile
		EndIf

		If Not FileExists(eval("configFile")) Then
			KConsoleWrite("configFile: " & $configFile & " is not existed."&@CRLF,1)
		EndIf
		KconsoleWrite("Using configFile: "&eval("configFile"), 0, 2)
	    LoadConfig($configFile, $labelName)
		$kcmd = "echo " & $kcmd
	EndIf

	;KPUT <local_filename> [unix_destination]
	if StringRegExp($kcmd, "KPUT") = 1 Then
		if $cmdarray[0] < 2 Then
			KConsoleWrite("KPUT syntax: KPUT localfilename [unix_destination]" & @CRLF,1)
		EndIf

		if $cmdarray[0] = 2 Then
		    RunSecurePutScript($cmdarray[2],$kleverCurrentDir);
		Else
			RunSecurePutScript($cmdarray[2]& " " &$cmdarray[3],$kleverCurrentDir);
		EndIf

		$kcmd = "echo " & $kcmd
	EndIf

	;KPAUSE Use to put breakpoint during test executation for debugging
	if StringRegExp($kcmd, "KPAUSE") = 1 Then
		MsgBox(0, "KPAUSE: Break-point Debugger", "Press OK to continue test case execution")
		$kcmd = "echo " & $kcmd
	EndIf

	if StringRegExp($kcmd, "\\klever_") = 1 Then
		$subcommand_logFile = ' logFile="'&$logFile&'"'
		$useCommandPrompt = "False"
	EndIf

	if StringRegExp($kcmd, "^klever_") = 1 Then
		$kcmd = '"'&$kleverTestScriptsDir&"\"&$kcmd&'"'
		$subcommand_logFile = ' logFile="'&$logFile&'"'
		$useCommandPrompt = "False"
	EndIf

	if StringRegExp($kcmd, "^auto_") = 1 Then
		$kcmd = '"'&envGet("KaffeineHome")&"\Tools\"&$kcmd&'"'
		$subcommand_logFile = ' logFile="'&$logFile&'"'
		$useCommandPrompt = "False"
	EndIf

	if StringRegExp($kcmd, "putty.exe") = 1 Then
		$useCommandPrompt = "False"
	EndIf

	if StringRegExp($kcmd, "java.exe") = 1 Then
		$useCommandPrompt = "False"
	EndIf

	local $cmdend = _ArrayToString($cmdarray, " ", 2)

	If $useCommandPrompt = "False" Then
		if Not FileExists(StringReplace($kcmd, '"', "")) Then
			KConsoleWrite($kcmd&" is not found.",1)
		EndIf
	EndIf

	return $kcmd & " " & $cmdend & $subcommand_logFile
EndFunc


;#################################################################
;Replace %% with env
;#################################################################
Func EnvPatch($string)
	local $array = StringRegExp($string, '%\w+%', 3)

	While 1
		$pop = _ArrayPop( $array )
		If $pop <> "" Then
			$replace = StringReplace($pop, "%", "")
			$replace = EnvGet($replace)
			$string = StringReplace($string, $pop, $replace)
		Else
			ExitLoop
		EndIf
	WEnd

	return $string
EndFunc

Func LoadConfig($configFile, $labelName)
	Local $array=KFileReadToArray($configFile)
	local $subarray=0

	If(isarray($array)) then
		For $arrayIndex = 1 to $array[0]

			If StringRegExp($array[$arrayIndex],"^#",0)=1 Then
				ContinueLoop
			EndIf

			If $labelName = "" Then
				$subarray = StringSplit($array[$arrayIndex], ",")
				SetEnv($subarray);
			Else
				If StringRegExp($array[$arrayIndex],$labelName,0)=1 Then
					$subarray = StringSplit($array[$arrayIndex], ",")
					SetEnv($subarray);
				EndIf
			EndIf
		Next
	EndIf
EndFunc

Func SetEnv($array)
	If(isarray($array)) then
		For $arrayIndex = 1 to $array[0]
			Local $linesplit = StringSplit($array[$arrayIndex], "=", 1)
			Envset(StringStripWS($linesplit[1],3) , StringStripWS($linesplit[2],3))
		Next
	EndIf
EndFunc

Func CheckCommand($command)
	;local $cmdarray = stringsplit($command, " ")
	;local $cmd = "which.exe " & chr(34) & $cmdarray[1] & chr(34)
	local $cmd = "which.exe " & chr(34) & $command & chr(34)

	KConsoleWrite($cmd ,0, 2)
	Local $runreturn = Run(@ComSpec & " /c " &$cmd&" > "&@TempDir&"\which.tmp", @workingdir)
	sleep(500)

	if FileGetSize(@TempDir&"\which.tmp") = 0 Then
		KConsoleWrite($command & " is not found.",1)
	EndIf
EndFunc


;#################################################################
;run SSH window
;#################################################################
Func RunSSH($mycommand,$wait,$hide)
	local $ifhide = @SW_SHOW
    if $hide = 1 then
		$ifhide = @SW_HIDE
	EndIf

	ShowDebug($mycommand)

	KConsoleWrite($mycommand&@CRLF, 0)

	If $wait = 1 Then
		runwait("cmd /c "&$mycommand, @scriptdir,$ifhide)
	Else
		run("cmd /c "&$mycommand, @scriptdir, $ifhide)
	EndIf
EndFunc

;#################################################################
;Run will have either Errored or Ran successfully.
;RunWait exit code: 0=Passed, 1=Failed, 2=Errored
;#################################################################
Func CheckRunError()

	;TT DEbug
	;UpdateOverallStatus()

	;logic to handle stopCondition
	local $stopCondition = 2
	If EnvGet("stopCondition") == "Failed" Then
		$stopCondition = 1
	EndIf

	if ($programExitCode >= $stopCondition) Then
		;logic to handle continueOnFailure.  This will negate stopCondition
		If isDeclared("testCase") and (Eval("continueOnFailure" = "1") or EnvGet("continueOnFailure") = "1") Then ;script error
			KConsoleWrite("Error encountered.  Continue executing testcase.")
		Else
			ProgramEnd()
		EndIf

	EndIf
EndFunc

;#################################################################
;debug message box
;#################################################################
Func ShowDebug($debugmsg)
    if (Eval("ShowDebug") = "windows") or (EnvGet("ShowDebug") = "windows") Then
		msgbox(0,"Debug",$debugmsg)
	EndIf
	if (Eval("ShowDebug") = "console") or (EnvGet("ShowDebug") = "console") Then
		KConsoleWrite($debugmsg)
	EndIf
EndFunc

;#################################################################
;function will create a string of date time
;YYYY/MM/DD_HH/MM/SS
;usually using at the end file log
;#################################################################
Func DateString()
	Return @year&@mon&@Mday&"_"&@hour&@min&@sec
EndFunc

;#################################################################
;Get the env value of a given env
;#################################################################
Func KEnvGet($getvar)
	$myenv = EnvGet($getvar)
	;msgbox(0,"testing",$myenv)
	return $myenv
EndFunc

;#################################################################
;set the env to a given value
;#################################################################
Func KEnvSet($setvar, $value)
	return(EnvSet($setvar, $value))
EndFunc

;**********************************************************************Common Functions Group End***************************************************************************************

;**********************************************************************Klever Programs' Functions Group Start***************************************************************************
;#################################################################
;update the .running file
;will check if .running file is already there or not at the
;beginning of the run, and will delete the .running file
;after the run
;also create encoder.inuse file at the beginning
;#################################################################
Func UpdateTestCaseRunning($flag)
	Local $runningfile = $kleverTestcaseInfo&"\"&$testcaseRunning
	;Running status
	;JobID, EncIP, RunId, caseId, EncVersion, ComputerName, TesterName, CaseStatus

	$runningmsg = $JobID&","&$encIp&","&$runId&","&$caseId&","&$EncVersion&","&$computerName&","&$testerName&","&"running"
	If $flag = 0 Then
		If FileExists($runningfile) Then
			$runningarray=KFileReadToArray($runningfile)
			For $x=1 to $runningarray[0]
				$splitline = StringSplit($runningarray[$x],",")
				If $splitline[2] = $encIp Then
					If StringLower(EnvGet("SkipEncoderCheck")) == "yes" Then
						KConsoleWrite("Skipping Encoder Inused Check in runnign file.")
					Else
						KConsoleWrite("The Encoder is currently in used by "&$splitline[7]&" on "&$splitline[6],1)
					EndIf
				EndIf
			Next
		EndIf

		;set the encip is inUsed
		;Also create the file
		EncoderInuseSet()

		RunningEditAtBegin($runningfile,$runningmsg)
	EndIf

	If $flag = 1 Then ;Finish The running
		If FileExists($runningfile) Then
			RunningEditAtEnd($runningfile,$runningmsg)
		Else
			KConsoleWrite($runningfile&" is missing at the end of testcase run.",0)
		EndIf
	EndIf

EndFunc


;#################################################################
;create .running file and put necessary information in it
;#################################################################
Func RunningEditAtBegin($therunningfile,$runningmsgtowrite)
	$file = KFileOpen($therunningfile, 1)
	FileWriteLine($file, $runningmsgtowrite)
	FileClose($file)
EndFunc

;#################################################################
;read .running file to array and delete the line write in by
;current run
;delete the .running file if .running is empty
;#################################################################
Func RunningEditAtEnd($therunningfile,$runningmsgtodel)
	$runningarray=KFileReadToArray($therunningfile)
	For $x=1 to $runningarray[0]
		If StringCompare($runningarray[$x],$runningmsgtodel)=0 Then
			$file=KFileWriteToLine($therunningfile,$x,"",1,EnvGet("fileOpenRetry"))
			ExitLoop
		EndIf
	Next
	$checksize = FileGetSize($therunningfile)
	If $checksize = 0 And @error <> 1 Then
		FileDelete($therunningfile)
	EndIf
EndFunc

;#################################################################
;create encoder.Inused file and assign inUsedFlag
;for programend() use
;#################################################################
Func EncoderInuseSet()
	if IsDeclared("encIp") Then
		EnvSet("EncInUsed", $encIp)
		$inusefile = KFileOpen($kleverTestcaseInfo&"\"&EnvGet("EncInUsed")&".Inused",1)
		KconsoleWrite("Creating file "&$kleverTestcaseInfo&"\"&EnvGet("EncInUsed")&".Inused",0)
		FileWriteLine($inusefile, $testerName&","&$computerName&","&$jobId)
		FileClose($inusefile)
		Assign("inUsedFlag", true, 2)
	EndIf
EndFunc

;#################################################################
;update the .last file
;#################################################################
Func UpdateTestCaseRan()
	;Ran status
	;JobID, EncIP, RunId, caseId, EncVersion, ComputerName, TesterName, CaseStatus, Finished Time, Duration, MISC

	$ranmsg = $JobID&","&$encIp&","&$runId&","&$caseId&","&$EncVersion&","&$computerName&","&$testerName&","&$testcaseResult[$programExitCode]&","&$Testcase_finishedtime&","&$Testcase_duration&","&$testcaseMISC
	$file = KFileOpen($kleverTestcaseInfo&"\"&$testcaseRan, 1)
	FileWriteLine($file, $ranmsg)
	FileClose($file)
EndFunc

;#################################################################
;update the .last file
;using in klevercli
;#################################################################
Func UpdateTestCaseLast()
    ;Last status
	;JobID, EncIP, $runId, $caseId, EncVersion, ComputerName, TesterName, CaseResult, Finished Time, Duration, $TotalFailed, $TotalErroed,$TotalPassed

	$MISCfile = $kleverWorkingDir&"\"&$jobId&"\MISC"
	If FileExists($MISCfile) Then
		$file = KFileOpen($MISCfile,0,1,0) ;Try to open only one time, if fail , continue
		$testcaseMISC=FileReadLine($file)
		If $testcaseMISC = "" Then
			$testcaseMISC = "N/A"
		EndIf
		FileClose($file)
	EndIf

	$totalfailed = 0
	$totalerrored = 0
	$totalpassed = 0

	$currentlastfile = $kleverTestcaseInfo&"\"&$testcaseLast
	If FileExists($currentlastfile) Then
		$file = KFileOpen($currentlastfile, 0)
		$temparray = StringSplit(FileReadLine($file),",")
		If $temparray[0] = 14 Then
			$totalpassed = $temparray[12]
			$totalfailed = $temparray[13]
			$totalerrored = $temparray[14]
		EndIf
		FileClose($file)
	EndIf
	If $testcaseResult[$programExitCode] = "Passed" Then
		$totalpassed = $totalpassed+1
	EndIf
	If $testcaseResult[$programExitCode] = "Failed" Then
		$totalfailed = $totalfailed+1
	EndIf
	If $testcaseResult[$programExitCode] = "Errored" Then
		$totalerrored = $totalerrored+1
	EndIf

	$lastmsg = $JobID&","&$encIp&","&$runId&","&$caseId&","&$EncVersion&","&$computerName&","&$testerName&","&$testcaseResult[$programExitCode]&","&$Testcase_finishedtime&","&$Testcase_duration&","&$testcaseMISC&","&$totalpassed&","&$totalfailed&","&$totalerrored
	$file = KFileOpen($currentlastfile, 2)
	FileWriteLine($file, $lastmsg)
	FileClose($file)
EndFunc

;#################################################################
;SearchFile
;searchdir  		directory of search
;searchpattern      search pattern like *.txt
;#################################################################
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

;#################################################################
;SearchFolder
;path 		directory of search
;will return array contains only folders' names
;#################################################################
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

;#################################################################
;$pattern is the pattern to grep
;#################################################################
Func GrepSearch($file, $pattern)
	local $myapp = "grep.exe"
	local $grepext = ".grep"
	local $found = 0
	local $grepfile = $file&$grepext
	local $mycommand=$myapp & " -i " & Chr(34) & $pattern & Chr(34) & " " & $file & " > " & $grepfile

	RunCommand($mycommand,@workingDir)

	if (FileExists($grepfile) and (FileGetSize($grepfile) > 0))  Then
		$found=1
		KConsoleWrite($myapp & " found " &$pattern&" in " &$file, 0, 2)
	EndIf

	return $found
EndFunc

;#################################################################
;do a ping check to the encoder to make sure is runable
;#################################################################
Func EncoderPingcheck($timeOut=2000)
	local static $EncoderError[4] =  ["Host is offline", "Host is unreachable", "Bad destination", "Other Errors"]

	local $localencIp = EnvGet("encIp")
	CheckVar($localencIp)

	$check=Ping($localencIp,$timeOut)

	If $check=0 Then
		KConsoleWrite("Encoder "&$localencIp&" failed ping. Error = "& $EncoderError[@error],1)
	EndIf
EndFunc

;#################################################################
;function to check if env variable is empty or not
;#################################################################
Func CheckEnv($var)
	If EnvGet($var) = "" Then
		KconsoleWrite("Environment: " & $var & " is empty.", 1)
	EndIf
EndFunc

;#################################################################
;function to check if current variable is empty or not
;#################################################################
Func CheckVar($var)
	If $var = "" Then
		KconsoleWrite("Variable: " & $var & " is empty.", 1)
	EndIf
EndFunc

;#################################################################
;function to run plink command with a script file
;#################################################################
Func RunSecurePlinkScript($plinkscript,$runningdir,$wait=1)
	local $scriptfullpath = $runningdir&"\"&$plinkscript
	local $localencIp = EnvGet("encIp")
	local $localloginId = EnvGet("loginId")
	local $localpassWord = EnvGet("passWord")
	if not FileExists($scriptfullpath) Then
		$scriptfilename = "plink_"&DateString()
		$tempscript=KFileOpen($runningdir&"\"&$scriptfilename, 2)
		FileWriteLine($tempscript,$plinkscript)
		FileClose($tempscript)
		$plinkscript = $runningdir&"\"&$scriptfilename
	Endif
	CheckVar($localencIp)
	CheckVar($localloginId)
	CheckVar($localpassWord)
	local $plink = chr(34) &$kleverCommonScriptsDir & "\plink.exe" & chr(34)
	$mycommand=$plink & " -pw "&$localpassWord&" "&$localloginId&"@"&$localencip&" -m "&$plinkscript
	RunCommand($mycommand, $runningdir, $wait)
EndFunc

;#################################################################
;function to run putty command with a script file
;puttyscript is the putty script file name only
;#################################################################
Func RunSecureTestScript($puttyscript,$runningdir,$wait=1,$show=@SW_SHOW)
	local $scriptfullpath = $runningdir&"\"&$puttyscript
	local $localencIp = EnvGet("encIp")
	local $localloginId = EnvGet("loginId")
	local $localpassWord = EnvGet("passWord")
	if not FileExists($scriptfullpath) Then
		$scriptfilename = "puttyscript_"&DateString()
		$tempscript=KFileOpen($runningdir&"\"&$scriptfilename, 2)
		FileWriteLine($tempscript,$puttyscript)
		FileClose($tempscript)
		$puttyscript = $scriptfilename
	Endif
	CheckVar($localencIp)
	CheckVar($localloginId)
	CheckVar($localpassWord)
	local $putty = chr(34) &$kleverCommonScriptsDir & "\putty.exe" & chr(34)
	$mycommand=$putty & " -pw "&$localpassWord&" "&$localloginId&"@"&$localencip&" -m "&$puttyscript
	RunCommand($mycommand, $runningdir, $wait,$show)
EndFunc

;##################################################################
;function to run pscp command
;get file or dir from encoder machine
;for now, only consider "-r dir" and "file" two mode.
;pscpscript is the pscp script file full path
;##################################################################
Func RunSecureGetScript($pscpscript,$runningdir,$wait=1,$show=@SW_SHOW)
	local $localencIp = EnvGet("encIp")
	local $localloginId = EnvGet("loginId")
	local $localpassWord = EnvGet("passWord")
	CheckVar($localencIp)
	CheckVar($localloginId)
	CheckVar($localpassWord)
	if not FileExists($pscpscript) Then
		$scriptfilename = $kleverCurrentDepotDir&"\pscpscript_"&DateString()
		$tempscript=KFileOpen($scriptfilename, 2)
		FileWriteLine($tempscript,$pscpscript)
		FileClose($tempscript)
		$pscpscript = $scriptfilename
	Endif

	$runget = KFileOpen($pscpscript,0)

	while 1
		$line = filereadline($runget)
		If $line = "" Then ExitLoop
		$splitline = stringsplit($line," ")
		if $splitline[0]>1 Then
			$mycommand="pscp.exe "&$splitline[1]&" -unsafe -pw "&$localpassWord&" "&$localloginId&"@"&$localencIp&":"&$splitline[2]&' "'&$runningdir&'"'
			RunCommand($mycommand,$runningdir,$wait,$show)
		Else
			$mycommand="pscp.exe -unsafe -pw "&$localpassWord&" "&$localloginId&"@"&$localencIp&":"&$splitline[1]&' "'&$runningdir&'"'
			RunCommand($mycommand,$runningdir,$wait,$show)
		EndIf
	WEnd
	FileClose($runget)
EndFunc

;##################################################################
;function to run pscp command
;put file to encoder machine
;pscpscript is the pscp script file full path
;##################################################################
Func RunSecurePutScript($pscpscript,$runningdir,$wait=1,$show=@SW_SHOW)
	local $localencIp = EnvGet("encIp")
	local $localloginId = EnvGet("loginId")
	local $localpassWord = EnvGet("passWord")
	CheckVar($localencIp)
	CheckVar($localloginId)
	CheckVar($localpassWord)
	if not FileExists($pscpscript) Then
		$scriptfilename = $kleverCurrentDepotDir&"\pscpscript_"&DateString()
		$tempscript=KFileOpen($scriptfilename, 2)
		FileWriteLine($tempscript,$pscpscript)
		FileClose($tempscript)
		$pscpscript = $scriptfilename
	Endif

	$runput = KFileOpen($pscpscript,0)

	while 1
		$line = filereadline($runput)
		If $line = "" Then ExitLoop
		$splitline = stringsplit($line," ")
		if $splitline[0]>1 Then
			$mycommand="pscp.exe -unsafe -pw "&$localpassWord&" "&$splitline[1]& " " &$localloginId&"@"&$localencIp&":"&$splitline[2]
		Else
			$mycommand="pscp.exe -unsafe -pw "&$localpassWord&" "&$splitline[1]& " " &$localloginId&"@"&$localencIp&":~"
		EndIf
		RunCommand($mycommand,$runningdir,$wait,$show)
	WEnd
	FileClose($runput)
EndFunc

;####################################################################
;function to check if a multicast stream is alive
;will use mcfirst command
;####################################################################
Func CheckMulticastAddr($addr, $port, $testdur=2, $pcount=1, $negate=0)
	If EnvGet("checkMulticast") == "yes" Then
		local $cmd = "mcfirst"
		local $myoutput = $cmd&"_"&_Timer_Init()&".out"
		If $addr == "" Then
			$addr = "232.32.32.32"
		EndIf
		local $mycmd = $cmd & " -c " & $pcount & " -t " & $testdur & " " & $addr & " " & $port & " | grep " & Chr(34) & $pcount & " packets received" & Chr(34) & " > " & $myoutput
		RunCommand($mycmd, $kleverCurrentDir)
		local $line = FileReadLine($kleverCurrentDir&"\"&$myoutput)
		local $array = StringSplit($line, " ")
		If $array[0] > 0 Then
			If int($array[1]) = 0 Then
				KConsoleWrite($addr & ":" & $port & " is not reachable.")
				If $negate = 1 then
					KConsoleWrite("Negative testing logic applied.")
					$programExitCode = 0
				Else
					$programExitCode = 1
				EndIf
			Else
				KConsoleWrite($addr & ":" & $port & " is reachable.", 0, 2)
				If $negate = 1 then
					KConsoleWrite("Negative testing logic applied.")
					$programExitCode = 1
				Else
					$programExitCode = 0
				EndIf
			EndIf
		Else
			KConsoleWrite("Program could not check the current multicast address.  Test will proceed blindly.")
		EndIf

		If Envget("Verbosity") < 2 Then
			FileDelete($kleverCurrentDir&"\"&$myoutput)
		EndIf
	EndIf

	return $programExitCode
EndFunc

;#################################################################################################################################
; function to run process video parameter for looing script.Two functions are implemented inside below function.
; i)Random(min, max, count)
; 	Example bitRate=Random(1000,10000,4)  This will return bitRate=a,b,c,d  where they're all randomized between 1000 and 10000
; ii)Choose(a,b,c,d,etc)
; 	Example scaledWidth=Choose(352,480,528,544,640,704,720)  This will return one value from this list.
;#################################################################################################################################
Func ProcessParameters($var)
	local $rvalue = $var
	$var = StringLower($var)
	;Randomize a value from a given list
	If StringRegExp($var,"random",0) Then
		KConsoleWrite("Detecting Random in Parameter: " & $var)
		$var = StringRegExpReplace ( $var, "random", "")
		$var = StringRegExpReplace ( $var, "[()]", "")
		local $myarray = StringSplit($var, ",",1)
		local $count = 1
		if $myarray[0] > 2 Then
			$count = $myarray[3]
		EndIf

		$rvalue = ""
		While $count > 0
			$comma = ""
			if $rvalue <> "" Then
				$comma = ","
			EndIf

			$rvalue = $rvalue & $comma & Random ($myarray[1],$myarray[2],1)
			$count = $count - 1
		WEnd
	EndIf

	;Choose a value from a given list
	If StringRegExp($var,"choose",0) Then
		KConsoleWrite("Detecting Choose in Parameter: " & $var)
		$var = StringRegExpReplace ( $var, "choose", "")
		$var = StringRegExpReplace ( $var, "[()]", "")
		local $myarray = StringSplit($var, ",",1)
		local $lottery = Random(1, $myarray[0], 1)
		$rvalue = $myarray[$lottery]
	EndIf

	KConsoleWrite("Values generated: " & $rvalue)
	return $rvalue
EndFunc
;##################################################################
;function to check the current status if pass or fail
;##################################################################
Func SetStatus()
	If EnvGet("currentStatus") == "Failed" Then
		KconsoleWrite("Detecting failure condition"&@CRLF, 2)
		Assign("myStatus", 1, 2)
	EndIf
EndFunc
;##################################################################
;function to delete unwanted files while we run looping scripts
;If you do not want to delete the capture then make sure the set doNotDelete to yes in the script
;Default it is deleted so that we free up space by deleting captures for all pass cases
;##################################################################
Func DeleteUnWantedFile($filename = 0)
	If Eval("myStatus") == 0 Then
		$currentfile = $filename
		if not $filename Then
			local $currentfile = @WorkingDir&"\"&GetLastItem()
		EndIf

		If EnvGet("doNotDelete") <> "yes" Then
			KFileDelete($currentfile)
			KconsoleWrite($currentfile& " is deleted successfully"&@CRLF, 2)
		EndIf
	EndIf
EndFunc
;**********************************************************************Klever Programs' Functions Group End*****************************************************************************