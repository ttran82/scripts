#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_telnet.exe
Tool to automate: telnet.exe
Argument Requirements:
	<encIp>
	[telnetPort]
	[telnetAction]
	[telnetLogFile]
	[telnetLogRotate]
Input requirement:
Output requirement:

#ce
;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>
#include <..\KleverWinLib.au3>

;Global Common Defintions

;Global Defintions unique to this script only

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.

Global $usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Create telnet session on customized port with log saving and rotations"&@crlf& _
			""&@crlf& _
			@scriptname&" encIp=[] telnetPort=6010 telnetAction=Open"&@crlf& _
			@scriptname&" encIp=[] telnetAction=Close"&@crlf& _
			@scriptname&' encIp=[] telnetAction=Check getLogOnFailure=1 fileList="/var/log/message;/usr/cp/Log/core_monitor.log" outputDir=Logs '&@crlf& _
			""&@crlf& _
			" <encIp>"&@TAB&"(Required). The ip of the encoder."&@crlf& _
			" <telnetPort>"&@TAB&"(Optional).  Default = 21)"&@crlf& _
			" If telnetPort=console.  The following options are available."&@crlf& _
			@TAB&" <consoleIp>"&@TAB&"Ip of the console server.  Default = 10.77.240.98"&@crlf& _
			@TAB&" [consoleUser]"&@TAB&"Login user of the console server.  Default = labuser"&@crlf& _
			@TAB&" [consolePw]"&@TAB&"Pw of the console server.  Default = terayon"&@crlf& _
			@TAB&" <consoleBoard>"&@TAB&"Individual board to access a specific unit.  Example: board108"&@crlf& _
			@TAB&" [consoleCmd]"&@TAB&"Command to access console.  Default = ./console2"&@crlf& _
			" [telnetAction]"&@TAB&"Open, Close, Check.  Default = Check for running.  If it is not, status = fail."&@crlf& _
			" If telnetAction=Open.  The following options are available."&@crlf& _
			@TAB&" [outputDir]"&@TAB&"{Optional} Directory where the log file will be stored.  If only a name is given, it will put under current dir/name folder.  If empty, it will be current dir."&@crlf& _
			@TAB&" [telnetLogFile]"&@TAB&"{Optional}.  Full path to filename or Default =  telnet_hostname_portnumber.log in current dir."&@crlf& _
			@TAB&" [telnetLogRotate]"&@TAB&"{Optional}.  0/1.  Set to 1 rotate log file.  Default = 0"&@crlf& _
			" If telnetAction=Check.  The following options are available."&@crlf& _
			@TAB&" [getLogOnFailure]"&@TAB&"{Optional} 0/1.  Default=0. Get files from remote hosts if telnet session check failed."&@crlf& _
			@TAB&" [fileList]"&@TAB&"{Optional} List of files to get from remote hosts separated by semi-colons.  To copy directories, but -r in front of the path."&@crlf& _
			@TAB&" [outputDir]"&@TAB&"{Optional} Directory where the files will copy to.  If only a name is given, it will put under current dir/name folder.  If empty, it will be current dir."&@crlf& _
			""

;Flow of the main program
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()
	Telnet_Action()
EndFunc

;Function Definitions
Func CheckArguments()
	;This check is standard.  Do not change
	if isDeclared ("usage") Then
		;this is the only time you will use consolewrite.  After Programe start, use Kconsolewrite will write to log
		consoleWrite($usageMsg)
		Exit
	EndIf

	;My argument checks start here
	CheckMissingArgument("encIp")

	if not IsDeclared("telnetPort") Then
		AssignVariable("telnetPort", "21")
	EndIf

	if not IsDeclared("telnetAction") Then
		AssignVariable("telnetAction", "Check")
	EndIf

	;Checking current output dir
	local $mydir = EnvGet("outputDir")
	If $mydir <> "" Then
		If StringRegExp($mydir,'\\',0) = 0 Then
			$mydir = @WorkingDir & "\" & $mydir
		EndIf
		KDirCreate($mydir)
	Else
		$mydir = @WorkingDir
	EndIf
	AssignVariable("outputDir", $mydir)


	If EnvGet("telnetAction") == 'Check' Then
		If EnvGet("getLogOnFailure") == "1" Then
			if EnvGet("fileList") == "" Then
				KConsoleWrite("getLogOnFailure enabled, but fileList is empty.", 1)
			EndIf
		EndIf
	EndIf

	local $my_file=EnvGet("telnetLogFile")
	if not IsDeclared("telnetLogFile") Then
		local $my_file = "telnet_" & EnvGet("telnetPort")& "_" & EnvGet("encIp") & ".txt"
		$my_file = EnvGet("outputDir") & "\" & $my_file
	Else
		If StringRegExp(EnvGet("telnetLogFile"),'\\',0) = 0 Then
			$my_file = EnvGet("outputDir") & "\" &  $my_file
		EndIf
	EndIf
	AssignVariable("telnetLogFile", $my_file)



	if not IsDeclared("telnetLogRotate") Then
		AssignVariable("telnetLogRotate", 0)
	EndIf

	If EnvGet("telnetPort") == 'console' Then
		;Check if the following arguments are entered:
		CheckMissingArgument("consoleBoard")

		if not IsDeclared("consoleIp") Then
			AssignVariable("consoleIp", "10.77.240.98")
		EndIf

		if not IsDeclared("consoleUser") Then
			AssignVariable("consoleUser", "labuser")
		EndIf

		if not IsDeclared("consolePw") Then
			AssignVariable("consolePw", "terayon")
		EndIf

		if not IsDeclared("consoleCmd") Then
			AssignVariable("consoleCmd", "./console2")
		EndIf
	EndIf


EndFunc

Func Close_telnet()
	local $telnetWinTitle = "Telnet - "& EnvGet('encIp')
	If EnvGet("telnetPort") == 'console' Then
		$telnetWinTitle = "Telnet - "& EnvGet('consoleIp')
	EndIf
	If WinExists($telnetWinTitle) Then
		WinActivate($telnetWinTitle)
		If WinActive($telnetWinTitle) Then
			;SendKeepActive($telnetWinTitle, "!]")
			send("!]")
			sleep(250)
			send("quit")
			;SendKeepActive($telnetWinTitle, "quit")
			sleep(250)
			send("{ENTER}")
			;WinClose($telnetWinTitle)
		Else
		EndIf
	Else
		KConsoleWrite("Telnet session is already closed.  Nothing to do.")
	EndIf
EndFunc


Func Open_telnet()
	local $telnetWinTitle = "Telnet - "& EnvGet('encIp')
	If EnvGet("telnetPort") == 'console' Then
		$telnetWinTitle = "Telnet - "& EnvGet('consoleIp')
	EndIf

	If WinExists($telnetWinTitle) == 1 Then
		KConsoleWrite("Telnet session is already running.  Nothing to do.")
	Else
		;Need to save old file
		If EnvGet("TelnetLogRotate") > 0 Then
			local $count = int(EnvGet("TelnetLogRotate"))
			local $telnetfile = EnvGet("telnetLogFile")
			While $count >= 0
				$count = $count - 1
				If $count == 0 Then
					If FileExists($telnetfile) Then
						FileCopy($telnetfile, $telnetfile&'.'&$count+1, 9)
					EndIf
				Else
					If FileExists($telnetfile&'.'&$count) Then
						FileCopy($telnetfile&'.'&$count, $telnetfile&'.'&$count+1, 9)
					EndIf
				EndIf

			WEnd
		EndIf

		If EnvGet("telnetPort") == 'console' Then
			local $mycommand="telnet.exe -d"& '"' & EnvGet('telnetLogFile') & '"' & " " & EnvGet("consoleServer")
				Kconsolewrite($mycommand)
				Run($mycommand,"",@SW_SHOW ,$RUN_CREATE_NEW_CONSOLE)
				sleep(250)
				If WinExists($telnetWinTitle) Then
					WinActivate($telnetWinTitle)
					If WinActive($telnetWinTitle) Then
						send(EnvGet("consoleUser"))
						sleep(250)
						send("{ENTER}")
						sleep(250)

						send(EnvGet("consolePw"))
						sleep(250)
						send("{ENTER}")
						sleep(250)

						send("cd " & EnvGet("consoleBoard"))
						sleep(250)
						send("{ENTER}")
						sleep(250)

						send(EnvGet("consoleCmd"))
						sleep(250)
						send("{ENTER}")
					EndIf
					sleep(1000)
					WinSetState($telnetWinTitle, "", @SW_MINIMIZE)

				Else
					KConsoleWrite("Console telnet session failed.", 1)
				EndIf
		Else
			local $mycommand="telnet.exe -d"& '"' & EnvGet('telnetLogFile') & '"' & " " & EnvGet("encIp") & " 6010"
			Kconsolewrite($mycommand)
			Run($mycommand,"",@SW_MINIMIZE ,$RUN_CREATE_NEW_CONSOLE)
		EndIf

	EndIf

EndFunc

Func Check_telnet()
	local $telnetWinTitle = "Telnet - "& EnvGet('encIp')
	If WinExists($telnetWinTitle) == 1 Then
		If FileExists(EnvGet("telnetLogFile")) Then
			KConsoleWrite("Telnet session currently running fine.", 0, 2)
		Else
			KConsoleWrite("Telnet session is running, but log file is not existed: " & EnvGet("telnetLogFile"), 1)
		EndIf
	Else
		;if getLogOnFailure is enabled
		KConsoleWrite("Telnet session is not currently running.")
		If EnvGet("getLogOnFailure") == "1" Then
			KConsoleWrite("getLogOnFailure is enabled", 0, 2)
			Runcommand("auto_pscp.exe", @WorkingDir)
		EndIf
		KConsoleWrite("Telnet session check failed.")
		$programExitcode = 1
	EndIf
EndFunc

Func Telnet_Action()
	local $myaction = EnvGet("telnetAction")

	Switch $myaction
		Case "Open"
			Open_telnet()
		Case "Close"
			Close_telnet()
		Case "Check"
			Check_telnet()
		Case Else
			KConsoleWrite("Invalid telnet actions not in range (Open, Close, Check) .", 1)
	EndSwitch
EndFunc




















