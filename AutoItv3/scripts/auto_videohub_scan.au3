#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_videohub_scan.exe
Input requirement:
   videohubIp=[] videohubCmd=[] startPort=[1=default] endPort=[]
   browser=Chrome dp568ip=10.77.165.15
   dp568sdiPort=[]

Output requirement:
   videoScanOutput=[VideoHub_SDI_Scan]

#ce

;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>

;Global Defintions unique to this script only
Global $argToJava = ""

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.
;Here is the example
$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Scan the BlackMagic VideoHub switch and automatically detect video and audio formats"&@crlf& _
			""&@crlf& _
			@scriptname&" videohubIp=<> videohubCmd=<> startPort=[1] endPort=<> dp568Ip=<> dp568Port"&@crlf& _
			""&@crlf& _
			" <videohubIp>"&@TAB& "BlackMagic VideoHub Control IP address."&@crlf& _
			" <videohubCmd>"&@TAB& "auto_videohub_switch command"&@crlf& _
			" [startPort]"&@TAB& "(Optional) The starting port number to scan.  Default = 1"&@crlf& _
			" <endPort>"&@TAB& "The ending port number to stop scan."&@crlf& _
			" <dp568Ip>"&@TAB& "The Ip of the DP568 Decoder to analyze the port"&@crlf& _
			" <dp568Port>"&@TAB& "The VideoHub port going to the DP568 Decoder"&@crlf& _
			" [browser]"&@TAB& "The browser to use to control dp568.  Default = chrome."&@crlf& _
			" <videoScanOutput>"&@TAB& "The outputname of the scan output.  This is an html formatted file.  Default = VideoHub_SDI_Scan.html"&@crlf& _
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
	RunVideoScan()
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
	CheckMissingArgument("videohubIp")
	CheckMissingArgument("videohubCmd")
	CheckMissingArgument("endPort")
	CheckMissingArgument("dp568Ip")
	CheckMissingArgument("dp568Port")

	If EnvGet('startPort') == "" Then
		AssignVariable("startPort", 1)
	EndIf

	If EnvGet('startPort') > EnvGet('endPort') Then
		KConsoleWrite("startPort " & EnvGet('startPort') & " is larger than endport " & EnvGet('endPort') , 1)
	EndIf

	If EnvGet('videoScanOutput') == "" Then
		AssignVariable("videoScanOutput", 'VideoHub_SDI_Scan.html')
	EndIf
	If StringRegExp(EnvGet("videoScanOutput"),'\\',0) = 0 Then
		AssignVariable("videoScanOutput", @WorkingDir & "\"  & EnvGet("videoScanOutput"))
	EndIf

EndFunc

Func CreateHtml()
	local $myreport = EnvGet('videoScanOutput')
	If FileExists($myreport) Then
		FileMove($myreport, $myreport&".old")
	EndIf
	local $fh = KFileOpen($myreport,  $FO_OVERWRITE + $FO_CREATEPATH)
	FileWrite($fh, '<html>'&@CRLF)
	FileWrite($fh, '<title>VideoHub Status</title>'&@CRLF)
	FileWrite($fh, '<body>'&@CRLF)
	FileWrite($fh, '<H1>VideoHub Status: '&EnvGet('videohubIp') &'</H1>' &@CRLF)
	FileWrite($fh, '<H3>Ports scanned: '&EnvGet('startPort') & ' - ' & EnvGet('endPort') & ' using DP568 ' & EnvGet('dp568Ip') & '</H3>' &@CRLF)
	FileWrite($fh, '<H3>Scanned Date: '& DateString() & '</H3>' &@CRLF)
	FileWrite($fh, '<table border="1">'&@CRLF)
	FileWrite($fh, '<tr valign="top"><td><b>Port Number</td><td><b>Input Type</td><td><b>Video</td><td><b>Audio</td></tr>'&@CRLF)
	FileWrite($fh, '</table>'&@CRLF)
	FileWrite($fh, '</body>'&@CRLF)
	FileWrite($fh, '</html>'&@CRLF)
	FileClose($fh)
EndFunc

Func InsertHtml($mytext)
	local $myfile = EnvGet('videoScanOutput')
	if FileExists($myfile) Then
		$lines = _FileCountLines($myfile)
		$startline = $lines - 2
		_FileWriteToLine($myfile, $startline, $mytext)
	EndIf
EndFunc


Func RunVideoScan()
	;First witch videohub switch
	local $myvideohub = EnvGet('videohubIp')
	local $mystartport = EnvGet('startPort')
	local $myendport = EnvGet('endPort')
	local $mydp568 = EnvGet('dp568Ip')
	local $mydp568port = EnvGet('dp568Port')
	local $myvideohubcmd = EnvGet('videohubCmd')
	local $scanoutput = 'dp568.txt'

	CreateHtml()
	local $mytext
	RunCommand("auto_show_desktop.exe")
	While $mystartport <= $myendport
		;first switch videohub to start port
		$myswitchcmd = $myvideohubcmd & ' videohubIp=' & $myvideohub & ' inPort='&$mystartport & ' outPort='&$mydp568port
		RunCommand($myswitchcmd)
		RunCommand($myswitchcmd)
		;Then run the videoscan sikuli script

		$myscancmd = 'auto_sikuli.exe sikuliScriptDir=' & EnvGet('sikuliScriptHome') & ' sikuliScriptName=dp568.sikuli dp568Input=SDI checkVideo=1 checkAudio=1 outputFile=' & $scanoutput
		RunCommand($myscancmd)
		;Now need to read the scan output
		$myarray = KFileReadToArray(@WorkingDir & '\' & $scanoutput)
		KConsoleWrite("Found " & $myarray[0] & " entries from " & $scanoutput, 0, 2)
		$myinputtype = ""
		$myvideoformat = ""
		$myaudioformat = ""

		For $i=1 to $myarray[0]
			$mystr = StringSplit($myarray[$i], '=')
			If $mystr[0] = 2 Then
				$myarg = $mystr[1]
				$myvalue = $mystr[2]
				If $myarg == 'inputtype' Then
					$myinputtype = StringLower($myvalue)
				ElseIf $myarg == 'videoformat' Then
					$myvideoformat = StringLower($myvalue)
				ElseIf StringRegExp($myarg, 'group') = 1 Then
					$myaudioformat = $myaudioformat & $myarray[$i]&' ; '
				EndIf

			EndIf
		Next

		$mytext = '<tr valign="top"><td><b>'&$mystartport&'</td><td><b>'&$myinputtype&'</td><td><b>'&$myvideoformat&'</td><td><b>'&$myaudioformat&'</td></tr>'&@CRLF
		InsertHtml($mytext)
		$mystartport = $mystartport + 1
		;Remove dp568 report file
		FileDelete(@WorkingDir & '\' & $scanoutput)
	WEnd

EndFunc


