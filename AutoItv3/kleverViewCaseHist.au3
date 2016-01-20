#include <ComboConstants.au3>
#include <ButtonConstants.au3>
#include <kleverGuiLib.au3>


;turn off "ESC close GUI"
Opt("GUICloseOnESC", 0)

$usageMsg = ""&@crlf& _
			@scriptname &"    Gui to view testCase history."&@crlf& _
			""

main()


;main function
Func main()
	GetInput()
	kleverViewCasehist()
EndFunc

Func GetInput()
	Local $szDrive, $szDir, $szFName, $szExt

	If IsArray($CmdLine) And $CmdLine[0] = 1 Then
		Local $TestPath = _PathSplit($CmdLine[1], $szDrive, $szDir, $szFName, $szExt)
		Global $Casename = $szFName&$szExt
		Global $CurrentTestCase = $CmdLine[1]
		Global $CurrenttestRun = StringReplace($CmdLine[1],"\"&$casename,"",-1)
	Else
		msgbox(0,"Error Input","Input Error: "&$CmdLine[1])
		Exit
	EndIf
EndFunc

Func kleverViewCasehist()
	ViewTestcaseHistory($Casename)
EndFunc