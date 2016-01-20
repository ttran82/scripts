#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_atm_rpc.exe
Tool to automate: rpc.mpl script on Aptest server
    Working script example: http://10.77.240.126/run/rpc.mpl?rpctoken=0a8e9572fa311c37c0077bc27b0baeec&username=ttran1&suite=ME7000&command=result&sess=000004&uuid=C564D898-1366-11E4-8905-13CCF16B1D86&result=pass&note=testing...
	Need wget command to run this command.
	wget -O tt -q "http://10.77.240.126/run/rpc.mpl?rpctoken=0a8e9572fa311c37c0077bc27b0baeec&username=ttran1&suite=ME7000&command=result&sess=000004&uuid=C564898-1366-11E4-8905-13CCF16B1D86&result=stopped&note=testing..."

Input requirement:
   atmPath=[] atmToken=[] atmUser=[] testSuite=<> testSession=<> testUuid=<> testResult=<> testNote=[]
   <require argument>
   [optional argument]
Output requirement: Return output of rpc.mpl


#ce

;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>

;Global Defintions unique to this script only

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.
;Here is the example
$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Update Aptest test case result via rpc.mpl given Suite, Session, and Testcase ID"&@crlf& _
			""&@crlf& _
			@scriptname&" atmPath=[] atmToken=[] atmUser=[] atmSuite=<> atmSession=<> atmTestId=<> atmTestResult=<> atmTestNote=[]" &@crlf& _
			@scriptname&" atmPath=[] atmToken=[] atmUser=[] atmSuite=<> atmCmd=[]" &@crlf& _
			""&@crlf& _
			" *[atmPath]"&@TAB&"Full path to rpc script.  Default = http://10.77.240.126/run/rpc.mpl"&@crlf& _
			" *[atmToken]"&@TAB&"Aptest authentication token.  Default = 0a8e9572fa311c37c0077bc27b0baeec"&@crlf& _
			" *[atmUser]"&@TAB&"Aptest User.  Default = automation"&@crlf& _
			" [atmCmd]"&@TAB&@TAB&"Aptest RPC full command.  This is optional and can be use to run other rpc command on Aptest server"&@crlf& _
			" *<atmSuite>"&@TAB&"Aptest Suite.  Must provide"&@crlf& _
			" *<atmSession"&@TAB&"Aptest Running Session.  Must provide"&@crlf& _
			" *<atmTestId>"&@TAB&"Aptest Test Case unique UUID.  Must provide"&@crlf& _
			" <atmTestResult>"&@TAB&"Aptest Test Case result: running, pass, fail, rerun, blocked.  Must provide."&@crlf& _
			" [atmTestNote]"&@TAB&"Aptest Test Case comment.  Default=Ran by Klever user %testerName%.  Logfile = %logFile%"&@crlf& _
			" [outputFile]"&@TAB&"Default outputFile"&@crlf& _
			""


;Main Flow of the program
;Everything starts here

;This CheckArguments functions is where you determine if those parsed arguments satisfy your input and output requirements
CheckArguments()

;Program Start
ProgramStart()

;Your main program
main()

;Program End
ProgramEnd()

Func CheckArguments()
	;This check is standard.  Do not change
	if isDeclared ("usage") Then
		;this is the only time you will use consolewrite.  After Programe start, use Kconsolewrite will write to log
		;this is for klever GUI script display function use
		consoleWrite($usageMsg)
		Exit
	EndIf

	;This is your check.  Any arguments that you needed for your program to run
	;My argument checks start here

	;check if qftest application is available in the system

	If EnvGet("atmPath") = "" Then
		AssignVariable("atmPath", "http://10.77.240.126/run/rpc.mpl")
		KConsoleWrite("User did not provide fullpath to rpc script.  Default path " & EnvGet("atmPath") & " will be used.", 0, 2)
	EndIf

	If EnvGet("atmToken") = "" Then
		;rpc token as configured on admin page of Aptest Server
		AssignVariable("atmToken", "0a8e9572fa311c37c0077bc27b0baeec")
		KConsoleWrite("User did not provide rpctoken.  Default token will be used.", 0, 2)
	EndIf

	if EnvGet("atmUser") = "" Then
		If Eval("testerName") <> "" Then
			AssignVariable("atmUser", Eval("testerName"))
		Else
			AssignVariable("atmUser", "automation")
			KConsoleWrite("Current Klever tester name is empty.  Using automation as user.", 0, 2)
		EndIf
	EndIf

	;checking testSuite
	If EnvGet("atmSuite") = "" Then
		KConsoleWrite("Missing atmSuite argument.",1)
	EndIf

	;Checking testSession
	If EnvGet("atmSession") = "" Then
		If EnvGet("runId") = "" Then
			KConsoleWrite("Missing atmSession argument or runId has not been assign to Klever Run.",1)
		EndIf
		AssignVariable("atmSession", EnvGet("runId"))
	EndIf

	;Checking testId
	If EnvGet("atmTestId") = "" Then
		If EnvGet("caseId") = "" Then
			KConsoleWrite("Missing atmTestID argument or CaseId has not been assign to Klever Testcase.",1)
		EndIf
		;setting atmTestID = caseID
		AssignVariable("atmTestId", EnvGet("caseId"))
	EndIf

	;Checking testResult
	CheckMissingArgument("atmTestResult")

	if not isDeclared("outputFile") Then
		Assign("outputFile", @scriptname&".out", 2)
	EndIf

EndFunc


func main()

	If not IsDeclared("atmTestNote") Then
		;given comment to test result
		Assign("atmTestNote", "Test triggered by "& EnvGet("testerName") & " via " & @ScriptName, 2)
	Else
		Assign("atmTestNote", "Test triggered by "& EnvGet("testerName") & " via " & @ScriptName & ". " & Eval("atmTestNote"), 2)
	EndIf

	Global $wgetcmd = "wget.exe -O "&Eval("outputFile")&" -q "

	Global $getlog = Eval("outputFile")&".getTestList"
	Global $resultlog = Eval("outputFile")&".result"

	Global $myatmPath = EnvGet("atmPath")&"?"
	Global $myatmToken = "rpctoken="&EnvGet("atmToken")
	Global $myatmUser = "&username="&EnvGet("atmUser")
	Global $mytestSuite ="&suite="&EnvGet("atmSuite")

	If not IsDeclared("atmCmd") Then
		atmGetTestID()
		local $testid = verifyTestID()
		atmUpdateResult($testid)
	Else
		local $mycommand = $wgetcmd&chr(34)&$myatmPath&$myatmToken&$myatmUser&$mytestSuite&Eval("atmCmd")&chr(34)
		RunCommand($mycommand,@WorkingDir)
	EndIf

EndFunc

;First find the test case number from the list
;http://10.77.240.126/run/rpc.mpl?rpctoken=0a8e9572fa311c37c0077bc27b0baeec&username=ttran1&suite=ME7000&command=getTestList&sessnum=000004
func atmGetTestID()
	local $mytestid = -1

	local $myatmCmd = "&command=getTestList"
	local $mytestSession = "&sessnum="&EnvGet("atmSession")

	$wgetcmd = "wget.exe -O "&$getlog&" -q "

	local $mycommand = $wgetcmd&chr(34)&$myatmPath&$myatmToken&$myatmUser&$mytestSuite&$myatmCmd&$mytestSession&chr(34)
	RunCommand($mycommand, @WorkingDir)
EndFunc

;Looking for TestID from log
func verifyTestID()
	local $outfile = $getlog & ".grep"
	local $mycommand = "grep " & chr(34)& "/" & EnvGet("atmTestId") & ".bts" & chr(34) & " " & $getlog & " > " & $outfile
	RunCommand($mycommand, @WorkingDir)
	local $myarray = KFileReadToArray($outfile)
	If $myarray[0] < 1 Then
		Kconsolewrite("Testcase ID: "&EnvGet("atmTestId") & " is not found in session " & EnvGet("atmSession"), 1)
	EndIf
	Kconsolewrite("Testcase ID: "&EnvGet("atmTestId") & " found.", 0, 2)

	return $myarray[1]
EndFunc

;Update test case result after from test case id
;http://10.77.240.126/run/rpc.mpl?rpctoken=0a8e9572fa311c37c0077bc27b0baeec&username=ttran1&suite=ME7000&command=result&sess=000004&id=1.0Gibson.dir/10.bts&result=fail&EXECDATA_buildnumber=gibson_build_4&note=testing...
func atmUpdateResult($testid)

	local $myatmCmd = "&command=result"
	local $mytestSession = "&sess="&EnvGet("atmSession")
	local $mytestUuid = "&id="&$testid
	local $mytestResult = "&result="&Eval("atmTestResult")
	local $mytestNote = "&note="&Eval("atmTestNote")

	local $mytestBuild = "&EXECDATA_buildnumber="&EnvGet("EncVersion")

	$wgetcmd = "wget.exe -O "&$resultlog&" -q "

	local $mycommand = $wgetcmd&chr(34)&$myatmPath&$myatmToken&$myatmUser&$mytestSuite&$myatmCmd&$mytestSession&$mytestUuid&$mytestResult&$mytestBuild&$mytestNote&chr(34)
	RunCommand($mycommand,@WorkingDir)
EndFunc

