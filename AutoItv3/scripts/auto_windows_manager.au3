#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_windows_manager.exe
Tool to automate: H264info.exe tool
Argument Requirements:
	<windows_title>
	<windows_text>
	<windows_action>
Input requirement:
   inputFile=[captured file]
   processDur=[5 seconds default] ;since this tool will take very long time depend of captured duration, it is recommended to have a default processDur to stop the analysis.
Output requirement:
   outputFile=[default={scriptname}.out]
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
			@scriptname&@TAB&"Manage windows application for: closing, maximize, minimize"&@crlf& _
			""&@crlf& _
			@scriptname&" windows_title=<title> windows_text=[app txt] windows_active=<0,1,2>"&@crlf& _
			""&@crlf& _
			" <windows_title>"&@TAB&"(Required).  Title of the currently opened widnows application"&@crlf& _
			" [widnows_text]"&@TAB&"(Optional). The text of the window."&@crlf& _
			" <windows_action>"&@TAB&"(Optional).  -1 = Close, 0=Show, 1=Minimize, 2=Maximize (Default)"&@crlf& _
			""

;Flow of the main program
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()
	WindowsAction()
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
	CheckMissingArgument("windows_title")

	if not IsDeclared("windows_action") Then
		AssignVariable("windows_action", "2")
	EndIf

EndFunc

Func WindowsAction()
	;Opt("WinTitleMatchMode", 3)

	local $action = EnvGet("windows_action")
	local $title = EnvGet("windows_title")
	local $text = EnvGet("windows_text")

	local $connection_title = "Connection warning"
	If WinExists($connection_title) Then
		WinActivate($connection_title)
		sleep(500)
		Send("{ENTER}")
		sleep(500)
	EndIf

	KConsoleWrite(@CRLF)

	Local $mytitle = WinGetTitle($title)
	If $mytitle == "" Then
		KConsoleWrite("Failed to get window title: " & $title, 1)
	Else
		$title = $mytitle
		KConsoleWrite("Found window title: " & $title & @CRLF, 0, 2)
	EndIf


	Switch $action
		Case -1
			WinClose($title, $text)
			WinKill($title, $text)

			If WinExists($title) Then
				KConsoleWrite("Failed to close window: " & $title, 1)
			Else
				KConsoleWrite("Closed window: " & $title & " successfully.", 0, 2)
			EndIf
		Case 0
			KWinActivate($title,"",1)
			KWinSetState($title, $text, @SW_SHOW)
		Case 1
			KWinActivate($title,"",1)
			KWinSetState($title, $text, @SW_MINIMIZE)
		Case 2
			KWinActivate($title,"",1)
			KWinSetState($title, $text, @SW_MAXIMIZE)
	EndSwitch
EndFunc






















