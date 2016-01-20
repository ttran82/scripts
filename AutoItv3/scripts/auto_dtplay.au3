#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_dtplay.exe
Tool to automate: dtplay.exe, run a hidden dos prompt command with autoit specific name for each instance of play.
Input requirement:
   command = [(default)=play/stop] target=<address:port/asi[port]>
   <require argument>
   [optional argument]
Output requirement:
   Before play, program needs to check if DTA160 card is present before running.
   If command is not provided, it is in play mode.
   for "play", play out address:port destination
   for "stop", stop also base on address:port destination dictated by autoit window naming.
#ce

;Standard normal included definitions
;Standard Common Scripting library
#include <File.au3>
#include <Array.au3>
#include <..\KleverLib.au3>
#include <..\kleverHashLib.au3>

;Global Common Defintions
Global $CoffeeMachineHome = envget("CoffeeMachineHome")
Global $CoffeeMachineMediaDir = $CoffeeMachineHome&"\Media"
Global $InusedHash = _CreateHashTable()

;Global Defintions unique to this script only
Global $DtplayCMD = "Dtplay.exe"
Global $MediaInfoCMD = "Mediainfo_Cli.exe"
Global $DtplayInusedFile = "dtplay.Inused"
Global $InputFileName
Global $mediaInfoDirName = "MediaInfo"

Global $dektec160portSelection = 4   ; 1 = asi1, 2 = asi2, 3 = asi3, 4 = ip

$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Run dtplay.exe."&@crlf& _
			""&@crlf& _
			"Play:"&@TAB&@scriptname&" Command=[play] Target=<addr:port> InputFile=<inputfile>"&@crlf& _
			"Play:"&@TAB&@scriptname&" Command=[play] Target=<asi1/asi2/asi3> InputFile=<inputfile>"&@crlf& _
			"Stop:"&@TAB&@scriptname&" Command=<stop> Target=<addr:port> InputFile=[inputfile]"&@crlf& _
			""&@crlf& _
			" Command"&@TAB&"Select play or stop mode. Default=play."&@crlf& _
			" "&@TAB&@TAB&"(Stop Mode Required. Play Mode Optional)"&@crlf& _
			" Inputfile"&@TAB&"Input media file."&@crlf& _
			" "&@TAB&@TAB&"(Play Mode Required. Stop Mode Optional)"&@crlf& _
			" Target"&@TAB&"(Required) multicast address:port."&@crlf& _
			""



;Main Flow of the program
;Everything starts here
CheckArguments()
ProgramStart()
main()
ProgramEnd()

func main()
	DeviceCheck()
	ReadDtplayInused()
	AutoDtplay()
EndFunc

Func CheckArguments()
	if isDeclared ("usage") Then
		consoleWrite($usageMsg)
		Exit
	EndIf

	If not isDeclared("Inputfile") Then
		If not isDeclared("Command") Or Eval("Command") = "Play" Then
			KConsoleWrite("Missing Parameters: InputFile",1)
		EndIf
	EndIf

	if not isDeclared("Target") Then
		KConsoleWrite("Missing Parameters: Target",1)
	EndIf

	Select
		Case $Target = "asi1"
			$dektec160portSelection = 1
		Case $Target = "asi2"
			$dektec160portSelection = 2
		Case $Target = "asi3"
			$dektec160portSelection = 3
	EndSelect

	If Not IsDeclared("Command") Then
		Global $Command = "Play"
	EndIf

    ReadCoffeeMachineHistory()
	If $Command = "Play" Then
		If StringRegExp($InputFile,':\\',0) = 0 Then
			$InputFile = $CoffeeMachineMediaDir&"\"&$InputFile
		EndIf
		If Not FileExists($InputFile) Then
			KConsoleWrite("Input File "&$InputFile&" is not existed."&@CRLF,1)
		EndIf
	EndIf
EndFunc

;Check is the machine has DekTec DTA-160 card
Func DeviceCheck()
	Local $cI_CompName = @ComputerName
	Local $wbemFlagReturnImmediately = 0x10
	Local $wbemFlagForwardOnly = 0x20
	Local $flag=0

	$objWMI = ObjGet("winmgmts:\\" & $cI_Compname & "\root\CIMV2")
	$objItems = $objWMI.ExecQuery("SELECT * FROM CIM_LogicalDevice", "WQL", $wbemFlagReturnImmediately + $wbemFlagForwardOnly)
	If IsObj($objItems) Then
	   For $objItem In $objItems
		   If StringRegExp($objItem.Description,"DTA-160") Then
			   $flag=1
			   ExitLoop
		   EndIf
	   Next
	   If $flag=0 Then
		   KConsoleWrite("Can not find DekTec DTA-160 Card on current machine.",1)
	   EndIf
	EndIf
EndFunc
Func ReadCoffeeMachineHistory()
	Local $historyFile = "CoffeeMachine.hist"
	Local $hfile = $CoffeeMachineHome&"\"&$historyFile
	If KFileExists($hfile) Then
		Local $harray=KFileReadToArray($hfile)
		AssignVariable($harray)
	EndIf
EndFunc

;if dtplay inused file existed, create a hash table.
;hash table key is multicastaddr:port, value is process id
Func ReadDtplayInused()
	Local $array
	If FileExists($CoffeeMachineHome&"\"&$DtplayInusedFile) And _FileCountLines($CoffeeMachineHome&"\"&$DtplayInusedFile) > 0 Then
		$array=KFileReadToArray($CoffeeMachineHome&"\"&$DtplayInusedFile)
		If IsArray($array) Then
			For $x=1 to $array[0]
				$splitline = StringSplit($array[$x],",")

				_SetHashItem($InusedHash,StringStripWS($splitline[1],3), StringStripWS($splitline[2],3)&","&StringStripWS($splitline[3],3))
			Next
		Else
			KConsoleWrite("Failed to read "&$CoffeeMachineHome&"\"&$DtplayInusedFile)
		EndIf
	EndIf
EndFunc

Func AutoDtplay()
	Select
		Case $Command = "Play"
			If _HashItemExists($InusedHash,$Target) Then
				KConsoleWrite($Target&" is already inused by "&_GetHashItem($InusedHash,$Target),1)
			EndIf
			Local $rate = GetBitRate($InputFile)
			Local $runPID = PlayDtPlay($InputFile,$rate)
			_SetHashItem($InusedHash,$Target, $runPID&","&$InputFileName)
			UpdateInusedList()
		Case $Command = "Stop"
			StopDtPlay()
			UpdateInusedList()
		Case Else
			KConsoleWrite("Unknow Command "&$Command,1)
	EndSelect
EndFunc

;update dtplay.inused file
;get all (key,value) from hash table and overwrite dtplay.inused file
Func UpdateInusedList()
	Local $temp=KFileOpen($CoffeeMachineHome&"\"&$DtplayInusedFile,2)
	For $vKey In $InusedHash
		filewriteline($temp,$vKey & "," & _GetHashItem($InusedHash,$vKey) & @CRLF)
	Next

	fileclose($temp)
EndFunc

Func GetBitRate($tsfile)
	Local $szDrive, $szDir, $szFName, $szExt
	Local $array = _PathSplit($tsfile,$szDrive, $szDir, $szFName, $szExt)

	Local $bitrate = 0;
	Local $bitratefile = $szFName&".bitrate"
	$InputFileName = $szFName&$szExt

	Local $mycommand = $MediaInfoCMD&" --Inform=General;%OverallBitRate% "&'"'&$tsfile&'"'&" > "&$mediaInfoDirName&"\"&$bitratefile
	Local $workingdir = $szDrive&$szDir
	RunCommand($mycommand,$workingdir)

	If FileExists($workingdir&"\"&$mediaInfoDirName&"\"&$bitratefile) Then
		$bitrate = FileReadLine($workingdir&"\"&$mediaInfoDirName&"\"&$bitratefile,1)
	EndIf
	If $bitrate = 0 Then
		KConsoleWrite("Failed to get bitrate of "&$tsfile,1)
	Else
		Return $bitrate
	EndIf
EndFunc

Func PlayDtPlay($tsfile,$bitrate)
	Local $mycommand = $DtplayCMD&" "&'"'&$tsfile&'"'&" -r "&$bitrate&" -l 0 -n "&$dektec160portSelection&" -ipt 10 -ipa "&$Target
	KConsoleWrite($mycommand)
	Local $PID = Run($mycommand,@WorkingDir)
	If $PID = 0 Then
		KConsoleWrite("Failed to use "&$DtplayCMD&" to play "&$tsfile&" on "&$Target,1)
	Else
		Return $PID
	EndIf
EndFunc

Func StopDtPlay()
	If _HashItemExists($InusedHash, $Target) Then
		Local $line = _GetHashItem($InusedHash,$Target)
		Local $Splitline = StringSplit($line,",")
		ProcessClose($Splitline[1])
		_RemoveHashItem($InusedHash, $Target)
		;KConsoleWrite("Process closed.",0)
	Else
		KConsoleWrite("Process Not Found.",0)
	EndIf
EndFunc