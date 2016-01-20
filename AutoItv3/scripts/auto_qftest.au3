#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_qftest
Tool to automate: Automate general QF-TEST
Input requirement:
   clientName=<unique client name> logFile=[default jobname] qftestArgs=[qftest arguments that will be passed to -variable]
   <require argument>
   [optional argument]
Output requirement:
   runlog of qftest: will be used for debugging

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
			@scriptname&@TAB&"Automate QF-TEST in batch mode"&@crlf& _
			""&@crlf& _
			@scriptname&" qftestLog=[log] clientName=<client> qftestFile=<qftestfile> qftestVars=[args]" &@crlf& _
			""&@crlf& _
			" [qftestBin]"&@TAB&"Fullpath to qftest binary.  Default = qftest.exe."&@crlf& _
			" [qftestLog]"&@TAB&@TAB& "Fullpath or filename for qftest output log.  If only filename is given, full path will be in current jobdir.  Default = current jobdir + jobname.log" &@crlf& _
			" <clientName>"&@TAB&"Assign a unique QF-TEST client name."&@crlf& _
			" <qftestFile>"&@TAB&"qftest file.  Can be full/partial path."&@crlf& _
			" [qftestVars]"&@TAB & "List of all arguments that will be passed onto QF-TEST" &@crlf& _
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

func main()
	;KConsoleWrite("TT3:" & Eval("qftestVars"))
	;KConsoleWrite("TT3:" & Eval("qftestLog"))
	;KConsoleWrite("TT3:" & Eval("qftestFile"))

	local $prearg = "-batch -run -compact"
	local $runlog = "-runlog " & Eval("qftestLog") & "\b+"

	local $mycommand = Eval("qftestBin") & " " & $prearg & " " & $runlog & " " & Eval("qftestVars") & " " & Eval("qftestFile")
	RunCommand($mycommand,@WorkingDir)
EndFunc

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

	if not isDeclared("qftestBin") Then
		Assign("qftestBin", "qftest.exe", 2)
		KConsoleWrite("User did not provide fullpath to qftest bin.  Default path " & Eval("qftestBin") & " will be used.", 0, 2)
	EndIf

	If not isDeclared("qftestLog") Then
		local $mylog = "qftest_"&DateString()&".log"
		Assign("qftestLog", $mylog, 2)
		KConsoleWrite("User did not provide qftestLog.  Default log " & Eval("qftestLog") & " will be used", 0, 2)
	EndIf

	If StringRegExp(Eval("qftestLog"),'\\',0) = 0 Then
		Assign("qftestLog", $kleverCurrentDir&"\"&Eval("qftestLog"), 2)
	EndIf

	;check clientName
	CheckMissingArgument("clientName")

	;Checking qftestFile
	CheckMissingArgument("qftestFile")

	If StringRegExp(Eval("qftestFile"),'\\',0) = 0 Then
		Assign("qftestFile", $kleverTestScriptsDir & "\qftest\" & Eval("qftestFile"), 2)
	EndIf

	If Not FileExists(eval("qftestFile")) Then
		KConsoleWrite("qftestFile: "&eval("qftestFile")&" is not existed."&@CRLF,1)
	EndIf



EndFunc