#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_pscp.exe
Input requirement:
   <deviceIp>
   <fileList> separate by semicolon
   [outputDir]
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
			@scriptname&@TAB&"Perform pscp copy on any remote ssh host."&@crlf& _
			""&@crlf& _
			@scriptname&" deviceIp=<> fileList=<> outputDir=[]"&@crlf& _
			""&@crlf& _
			" <deviceIp>"&@TAB& "(required) If not found, will try to look for encIp first."&@crlf& _
			" <loginId>"&@TAB& "(required) If not found."&@crlf& _
			" <passWord>"&@TAB& "(required) If not found."&@crlf& _
			" <fileList>"&@TAB& "List of all files to get separate by semi-colon.  Ex: /var/log/message;/usr/cp/Log/core_monitor.log;-r /usr/cp/lib/mib"&@crlf& _
			" [outputDir]"&@TAB& "(Optional) Full path to dir or will be in currentdir\outputdir."&@crlf& _
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
	RunPSCP()
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

	if Not IsDeclared("deviceIp") Then
		if EnvGet("encIp") <> "" Then
			AssignVariable("deviceIp", EnvGet("encIp"))
		Endif
	EndIf

	CheckMissingArgument("deviceIp")
	CheckMissingArgument("loginId")
	CheckMissingArgument("passWord")
	CheckMissingArgument("fileList")

	;check if the current sikuli scriptname is existed.  If not, find it in currentscriptdir


EndFunc


Func RunPSCP()
	If EnvGet("outputDir") == "" Then
		AssignVariable("outputDir", @WorkingDir)
	EndIf
	local $my_outputdir = EnvGet("outputDir")
	If StringRegExp($my_outputdir,'\\',0) = 0 Then
		AssignVariable("outputDir", @WorkingDir & "\"  & $my_outputdir)
	EndIf

	Kconsolewrite("current outputdir: " & EnvGet("outputDir"))

	;first check if pscp command is present
	local $pscpcmd = "pscp.exe"
	CheckCommand($pscpcmd)

	;list file list
	local $mylist = EnvGet("fileList")
	local $myfilelist = StringSplit($mylist, ";")

	local $mycommand
	local $splitline
	For $i = 1 to $myfilelist[0]
		$splitline = stringsplit($myfilelist[$i]," ")
		if $splitline[0]>1 Then
			$mycommand=$pscpcmd & " " &$splitline[1]& " -unsafe -pw " & EnvGet('passWord') &" "& EnvGet('loginId') & "@" & EnvGet('deviceIp') &":"&$splitline[2]&' "'&EnvGet("outputDir")&'"'
		Else
			$mycommand=$pscpcmd & " -unsafe -pw "& EnvGet('passWord') &" "& EnvGet('loginId') & "@" & EnvGet('deviceIp') &":"&$splitline[1]&' "'&EnvGet("outputDir")&'"'
		EndIf
		RunCommand($mycommand,EnvGet("outputDir"))
	Next

EndFunc

