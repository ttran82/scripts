#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_lynx.exe
Tool to automate: lynx
Input requirement:
   script=<lynx script file> deviceIp=[ip of device under test, default=getenv[encip]] output=[default=scriptname.lynx]
   <require argument>
   [optional argument]
Output requirement:
   run lynx -accept_all_cookies -dump -cmd_script=<lynx scriptfile> http://ip > output
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
			@scriptname&@TAB&"Create Lynx script file to automate."&@crlf& _
			""&@crlf& _
			@scriptname&" scriptFile=<script> deviceIp=[deviceip] outPut=[outputfile]"&@crlf& _
			""&@crlf& _
			" script"&@TAB&"<Required> lynx script file, full path/filename(working folder)."&@crlf& _
			" deviceIp"&@TAB&"[Optional] ip of device under test, default=encip"&@crlf& _
			" outputfile"&@TAB&"[Optional] output the lynx script with given name or path. default=scriptname.lynx"&@crlf& _
			""


;Main Flow of the program
;Everything starts here
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()
	ExecLynxScript()
EndFunc

Func CheckArguments()
	if isDeclared ("usage") Then
		consoleWrite($usageMsg)
		Exit
	EndIf

	if not isDeclared("scriptFile") Then
		KConsoleWrite("Missing Parameters: scriptFile",1)
	Else
		If Not FileExists($scriptFile) Then
			$scriptFile = @WorkingDir&"\"&$scriptFile
		EndIf
		If Not FileExists($scriptFile) Then
			KConsoleWrite("Can not find script file "&$scriptFile,1)
		EndIf
	EndIf

	If not IsDeclared("$deviceIp") Then
		Global $deviceIp=EnvGet("encIp")
		If $deviceIp="" Then
			KConsoleWrite("Missing Parameter: $deviceIp",1)
		EndIf
		Global $loginId = EnvGet("loginId")
		Global $passWord = EnvGet("passWord")
	EndIf

	If Not IsDeclared("outPut") Then
		Global $outPut = @ScriptName&".lynx"
	EndIf
EndFunc

Func ExecLynxScript()
	Local $lynxCMD = "lynx.exe"
	Local $lynx_opt = " -accept_all_cookies"
	Local $mycommand = $lynxCMD&$lynx_opt&" -cmd_script="&'"'&$scriptFile&'"'&" http://"&$deviceIp
	RunCommand($mycommand,@WorkingDir)
EndFunc