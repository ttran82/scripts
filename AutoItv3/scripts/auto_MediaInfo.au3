#cs-----------------------------------------------------
Provided Script requirement as requested by QA Team
ScriptName: auto_MediaInfo.au3
Tool to automate mediainfo:
Input requirement:
   auto_MediaInfo.exe inputfile=<inputfile> InformFile=[InformFile] Comparison=[equal,lessthan,lessthanequal,greater,greaterequal,notequal] Pattern=[string for comparing] ComparisonMargin=[ComparisonMargin in percentage] outputFile=[outputFile]
   <require argument>
   [optional argument]
Output requirement:
Case Details:-
	case "equal" --> for checking quality between pettern and output from mediainfo
	case "lessthan" --> for checking that mediainfo output should be less than pattern
	case "lessthanequal" --> for checking that mediainfo output should be in between +/- "ComparisonMargin%"  compared to pattern
	case "greaterthan" --> for checking that mediainfo output should be more than pattern
	case "greaterequal" --> for checking that mediainfo output should be in between +/- "ComparisonMargin%"  compared to pattern
	case "notequal" --> for checking non-quality between pettern and output from mediainfo
Note:-
	By default, ComparisonMargin is 5%
ChangeList:
LastChange: removed the margin comparison on lessthan and greater. It will only be in lessthanequal and greaterequal.
ChangedBy: Swarup
#ce-----------------------------------------------------
#include <WindowsConstants.au3>
#include <File.au3>
#include <Array.au3>
#include <..\kleverLib.au3>

Global $DefaultInformFile = @ScriptDir&"\Configs\DefaultInform.csv"
Global $mediaInfoOption = ""
Global $MediaInfoOutPutFile

Global $usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Run mediaInfo_CLI.exe on media files."&@crlf& _
			""&@crlf& _
			@scriptname&" inputfile=<inputfile> InformFile=[InformFile] outputFile=[outputFile]"&@crlf& _
			@scriptname&" inputfile=<inputfile> Inform=[InformSyntax] outputFile=[outputFile]"&@crlf& _
			@scriptname&" inputfile=<inputfile> Inform=[InformFile] Comparison=[equal,lessthan,lessthanequal,greater,greaterequal,notequal] Pattern=[string for comparing] outputFile=[outputFile]"&@crlf& _
			""&@crlf& _
			" <inputfile>"&@TAB&"(Required) capture file name."&@crlf& _
			@TAB&@TAB&"If inputfile is not provided, program will attempt to read current working folder\LAST file and get the last line to make that your inputfile." &@crlf& _
			" [InformFile]"&@TAB&"(Optional) path to inform.csv file"&@crlf& _
			" [Inform]"&@TAB&@TAB&"(Optional) Inform syntax as understand by MediaInfo_cli.exe."&@crlf& _
			@TAB&@TAB&"Video;%Format% - this is getting encoding format"&@crlf& _
			@TAB&@TAB&"Video;%Width% - this is getting video width resolution"&@crlf& _
			@TAB&@TAB&"The whole list of all possible parameters can be seen by executing mediainfo_cli.exe --Info-Parameters in dos"&@crlf& _
			" [Comparison]"&@TAB&"(Optional) Comparison options: equal,notequal,lessthan,lessthanequal,greaterthan,greaterequal."&@crlf& _
			@TAB&@TAB&"This option requires Pattern option to be defined"&@crlf& _
			" [ComparisonMargin]"&@TAB&"(Optional) Defines what ranges in % are acceptable against the MediaInfo output"&@crlf& _
			" [Pattern]"&@TAB&"(Optional) Define what option to search against the MediaInfo output"&@crlf& _
			" [outputFile]"&@TAB&"(Optional) output .info file name"&@crlf& _
			""


;Flow of the main program
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()

	SetMediaInfoOutput()
	;run MediaInfo command
	AutoMediaInfo()

	;Handle Comparision
	if IsDeclared("Comparison") Then
		;Read output file into variable
		local $text=KFileReadToArray($MediaInfoOutPutFile)
		if (not IsArray($text)) or ($text[0] < 1) Then
			KConsoleWrite("MediaInfo Inform Analysis gave empty output.",0)
			$programExitCode = 1
		Else
			;stripping leading and trailing white spaces
			local $mytext = StringStripWS($text[1], 3)
			$margin = eval("ComparisonMargin")
			$checkpattern = eval("Pattern")
			local $maxtext = int($checkpattern + (($margin/100) * $checkpattern))
			local $mintext = int($checkpattern - (($margin/100) * $checkpattern))

			Switch eval("Comparison")
				Case "equal"
					if $mytext = eval("Pattern") Then
						KConsoleWrite("Equal passed: "&eval("Pattern"))
					Else
						KConsoleWrite("Equal failed: " & $mytext & ", while looking for " & eval("Pattern"))
						$programExitCode=1
					EndIf
				Case "lessthan"
					if int(eval("mytext")) < int($checkpattern)  Then
						KConsoleWrite("lessthan passed: " &$mytext & " is less than " & eval("Pattern"))
					Else
						KConsoleWrite("lessthan failed: " &$mytext & " is not less than " & eval("Pattern"))
						$programExitCode=1
					EndIf
				Case "lessthanequal"
					if (int($mintext) <= int(eval("mytext")) And int(eval("mytext")) <= int($maxtext)) Then
						KConsoleWrite("lessthanequal passed: " &$mytext & " is in acceptable range of "& $margin &"% for " & eval("Pattern"))
					Else
						KConsoleWrite("lessthanequal failed: " &$mytext & " is not in acceptable range of "& $margin &"% for " & eval("Pattern"))
						$programExitCode=1
					EndIf
				Case "greater"
					if int(eval("mytext")) > int($checkpattern)  Then
						KConsoleWrite("greaterthan passed: " &$mytext & " is greater than " & eval("Pattern"))
					Else
						KConsoleWrite("greater failed: " &$mytext & " is not greater than " & eval("Pattern"))
						$programExitCode=1
					EndIf
				Case "greaterequal"
					if (int($mintext) <= int(eval("mytext")) And int(eval("mytext")) <= int($maxtext)) Then
						KConsoleWrite("greaterthanequal passed: " &$mytext & " is in acceptable range of "& $margin &"% for " & eval("Pattern"))
					Else
						KConsoleWrite("greaterthanequal failed: " &$mytext & " is not in acceptable range of "& $margin &"% for " & eval("Pattern"))
						$programExitCode=1
					EndIf
				Case "notequal"
					if $mytext <> eval("Pattern") Then
						KConsoleWrite("Not Equal passed: " &$mytext & " is not equal to " & eval("Pattern"))
					Else
						KConsoleWrite("Not Equal failed: " &$mytext & " is equal to " & eval("Pattern"))
						$programExitCode=1
					EndIf
				Case Else
					KConsoleWrite("Invalid Compare option: "&eval("Compare"),1)
			EndSwitch
		EndIf


	EndIf

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
	if not isDeclared("inputFile") Then
		KConsoleWrite("User did not provide inputFile.  The program will get file from LAST file", 0, 2)
		Global $inputFile = GetLastItem()
		If KFileExists($inputFile) Then
			KConsoleWrite("Found latest file from LAST file: " &$inputFile& " will be used as inputFile.", 0, 2)
		Else
			KConsoleWrite("Problem getting valid inputfile: "&$inputFile& " from LAST file.", 1)
		EndIf
	EndIf

	if IsDeclared("InformFile") Then
		if IsDeclared("Inform") Then
			KConsoleWrite("InformFile and Inform cannot be both defined.",1)
		EndIf
		GetMediaInfoInput()
	EndIf

	if IsDeclared("Inform") Then
		GetInformSyntax()
	EndIf

	if IsDeclared("Comparison") Then
		If not IsDeclared("Pattern") Then
			KConsoleWrite("Comparison option is given without Pattern option",1)
		EndIf

		If not IsDeclared("ComparisonMargin") Then
			Global $ComparisonMargin = 5
	    EndIf
	EndIf

EndFunc

Func GetMediaInfoInput()
	Local $pathsplitarray
	Local $szDrive, $szDir, $szFName, $szExt
	If Not IsDeclared("InformFile") Then
		Global $InformFile = $DefaultInformFile
	ElseIf IsDeclared("InformFile") And Not FileExists($InformFile) Then
		KConsoleWrite("Inform File "&$InformFile&" is not existed. Using default.")
		$InformFile = $DefaultInformFile
	EndIf

	$pathsplitarray = _PathSplit($InformFile,$szDrive, $szDir, $szFName, $szExt)
	FileCopy($InformFile, @WorkingDir&"\"&$szFName, 1)
	If FileExists(@WorkingDir&"\"&$szFName) Then
		$mediaInfoOption = " --Inform=file://"&$szFName
	Else
		KConsoleWrite("Can not copy Inform File "&$InformFile&" to "&@WorkingDir,1)
	EndIf
EndFunc

Func GetInformSyntax()
		;write Inform syntax into a file
		global $InformFile = "Mediainfo.csv"
		local $fhandle = KFileOpen($InformFile, 2)
		FileWriteLine($fhandle, eval("Inform"))
		FileClose($fhandle)

		$mediaInfoOption = " --Inform=file://" & $InformFile
EndFunc

Func SetMediaInfoOutput()
	$MediaInfoOutPutFile = $inputFile&".Info"
	If IsDeclared("outputFile") Then
		$MediaInfoOutPutFile = $outputFile
	EndIf
EndFunc

Func AutoMediaInfo()
	$mycommand = "MediaInfo_CLI.exe "&$mediaInfoOption&" "&$inputFile& " > " &'"'&$MediaInfoOutPutFile&'"'
	RunCommand($mycommand,@WorkingDir)
EndFunc