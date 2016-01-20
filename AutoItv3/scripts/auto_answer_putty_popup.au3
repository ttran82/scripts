#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_answer_putty_popup.exe
Input requirement:
   puttyPopupWait=20 seconds
Output requirement:
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
			@scriptname&@TAB&"Detect if a Putty Security Window is present and automatically anser YES"&@crlf& _
			""&@crlf& _
			@scriptname&" puttyPopupWait=[time in seconds]"&@crlf& _
			""&@crlf& _
			" [puttyPopupWait]"&@TAB&"Time to run this script.  Default is 20 seconds"&@crlf& _
			" [puttyPopupTitle]"&@TAB&"Putty popup title.  Default is PuTTY Security Alert"&@crlf& _
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
	CheckPuttyPopup()
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
	if not isDeclared("puttyPopupWait") Then
		AssignVariable("puttyPopupWait", 20)
	EndIf

	if not isDeclared("puttyPopupTitle") Then
		AssignVariable("puttyPopupTitle", "PuTTY Security Alert")
	EndIf

EndFunc

Func CheckPuttyPopup()
	local $puttypopupwin = EnvGet("puttyPopupTitle")
	local $yesbutton = "[CLASS:Button; INSTANCE:1]"
	local $counter = 0
	local $waittime = EnvGet("puttyPopupWait")

	while ($counter < ($waittime * 1000))
		If WinActive($puttypopupwin) Then
			WinActivate($puttypopupwin, $yesbutton)
			ControlClick($puttypopupwin, "Yes", $yesbutton, "left", 1, 45, 15)
			ControlClick($puttypopupwin, "Yes", $yesbutton, "left", 1, 45, 15)
		EndIf
		sleep(500)
		$counter = $counter + 500
	WEnd

EndFunc
