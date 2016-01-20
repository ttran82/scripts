#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <..\KleverLib.au3>

;If inputfile is not declared, you need to read current working folder\LAST file and get the last line and make that your inputfile

Global $overallstatus = 0
Global $appext = ".m2toes"
Global $appcmd = "m2toes.exe"

$usageMsg = ""&@crlf& _
			@scriptname &"    Run m2toes.exe on ts files and output reports."&@crlf& _
			""&@crlf& _
			" "&@scriptname&" inputFile=[file] outputFile=[outputname]"&@crlf& _
			" "&@scriptname&" inputListFile=[listfile] outputFile=[outputname]"&@crlf& _
			""&@crlf& _
			" [inputFile]"&@TAB&@TAB&"(Optional) Name of .ts file in curent running directory or Full path of the *.ts file "&@crlf& _
			" [m2toesOption]"&@TAB&@TAB&"(Optional) Extra m2toes options: -n -v -s -c -p -a -o -d.  Run m2toes to have full details."&@crlf& _
			" [inputListFile]"&@TAB&@TAB&"(Optional) Name of .m3u file in current running directory or Full path of the *.m3u file."&@crlf& _
			" [outputFile]"&@TAB&"(Optional) outputname of the captured file"&@crlf& _
			" no argument"&@TAB&"If no argument is provided, the program will read the first line of LAST file in the current running directory and use it as a capture file"&@crlf& _
			""

;Flow of the main program
CheckArguments()
ProgramStart()
main()
ProgramEnd()

;Function Definitions
Func main()
	local $filelist = GetInput_AutoM2Toes()
	AutoM2toes($filelist)
EndFunc

;Function Definitions
Func CheckArguments()
	;This check is standard.  Do not change
	if isDeclared ("usage") Then
		;this is the only time you will use consolewrite.  After Programe start, use Kconsolewrite will write to log
		consoleWrite($usageMsg)
		Exit
	EndIf
EndFunc

Func GetInput_AutoM2Toes()
	local $mylastfile = @WorkingDir&"\LAST"
	Local $farray[1]
	$farray[0] = 0

	If IsDeclared("inputFile") Then
		If KFileExists(@workingdir&"\"&$inputFile) Then
			_ArrayAdd($farray, $inputFile)
			$farray[0] = 1
		EndIf
	EndIf

	If isDeclared("inputListFile") Then
		local $listfilepath = @workingdir&"\"&eval("inputListFile")
		If KFileExists($listfilepath) Then
			$farray = KFileReadToArray($listfilepath)
		EndIf
	EndIf

	If Not IsDeclared("inputFile") And Not IsDeclared("inputListFile") Then
		$inputFile = GetLastItem()
		If KFileExists($inputFile) Then
			_ArrayAdd($farray, $inputFile)
			$farray[0] = 1
		EndIf
	EndIf

	return $farray
EndFunc


Func AutoM2toes($inarray)
    For $i=1 to $inarray[0]
		$m2toesfile = $inarray[$i]&$appext
		$mycommand = "m2toes.exe " & EnvGet("m2toesOption") & " " &$inarray[$i] &" > "&$m2toesfile
		RunCommand($mycommand, @WorkingDir)

		if (IsDeclared("outputFile")) Then
			if ($inarray[0] = 1) Then
				$newname = $outputFile
			Else
				$newname = $outputFile&$i
			EndIf
			Filemove($m2toesfile, $newname)
			$m2toesfile = $newname
		EndIf

		local $error = GrepSearch($m2toesfile, "error")
		ReportWriter(@WorkingDir&"\"&$inarray[$i],$m2toesfile, $error); for single ts file run
	Next
	$programExitCode = $overallstatus
EndFunc

Func ReportWriter($inputfilename,$m2toesfile,$error)

	local $failcasecounter=0
    local $filecounter = 1

	Local $reportname = @scriptname&".report.html"
	local $report
	Local $status = "Passed"

	local $linecounter=0

	local $array


	if FileExists ($reportname) Then ;count the lines of html report

		$array = KFileReadToArray($reportname)
		$linecounter=$array[0]

		For $i = 1 to $array[0]
			if StringRegExp($array[$i], "M2toes=Passed") = 1 Then
				$filecounter += 1
			EndIf

			if StringRegExp($array[$i], "M2toes=Failed") = 1 Then
				$filecounter += 1
				$failcasecounter += 1
			EndIf
		Next

	EndIf

	$finalreport = KFileOpen($reportname,1)

	If $error Then; had fail
		$status = "Failed"
		$overallstatus = 1
		$failcasecounter=$failcasecounter+1
		$linetowrite='<tr><td bgcolor="#FF0000">'&$inputfilename&'</td><td><a href="file:\\'&@WorkingDir&"\"&$m2toesfile&'.grep">'&"M2toes="&$status&"</a></td></tr>"
	Else
		$linetowrite="<tr><td>"&$inputfilename&'</td><td><a href="file:\\'&@WorkingDir&"\"&$m2toesfile&'">'&"M2toes="&$status&"</a></td></tr>"
	EndIf

	if $linecounter = 0 Then ; Brand new report
		FileWriteLine($finalreport, "<html>"&@crlf&"<head>"&@crlf&"<title>Klever M2toes Report</title>"& _
		@crlf&"<b>"&@crlf&"</b></head>"&@crlf&"<body lang=EN-US link=blue vlink=purple style='tab-interval:.5in'><br>")
		;@crlf&"<b>Source: "&@ScriptName&" "&$CmdlineRaw&@crlf&"</b></head>"&@crlf&"<body lang=EN-US link=blue vlink=purple style='tab-interval:.5in'><br>")
		FileWriteLine($finalreport, "##############")
		filewriteline($finalreport, '<table cellpadding="2" cellspacing="2" width="100%">')

		FileWriteLine($finalreport, $linetowrite)

		FileWriteLine($finalreport, "</table>")
		FileWriteLine($finalreport, "##############<br>")
		FileWriteLine($finalreport, "<b>Total:    "&$filecounter&"</b><br>")
		FileWriteLine($finalreport, "<b>Passed:   "&($filecounter-$failcasecounter)&"</b><br>")
		FileWriteLine($finalreport, "<b>Failed:   "&$failcasecounter&"</b>")
		FileWriteLine($finalreport, "</body></html>")
		FileClose($finalreport)

	Else ; Means has old report information
		FileClose($finalreport)
		_FileWritetoLine($reportname, 4, "<b>Source: "&@ScriptName&" "&$CmdlineRaw,1)
		_FileWritetoLine($reportname, $filecounter+8, $linetowrite,1)
		_FileWritetoLine($reportname, $filecounter+9, "</table>",1)
		_FileWritetoLine($reportname, $filecounter+10, "###############<br>",1)
		_FileWriteToLine($reportname, $filecounter+11, "<b>Total:    "&$filecounter&"</b><br>",1)
		_FileWriteToLine($reportname, $filecounter+12, "<b>Passed:   "&($filecounter-$failcasecounter)&"</b><br>",1)
		_FileWriteToLine($reportname, $filecounter+13, "<b>Failed:   "&$failcasecounter&"</b>",1)
		_FileWriteToLine($reportname, $filecounter+14, "</body></html>",1)

	EndIf

EndFunc