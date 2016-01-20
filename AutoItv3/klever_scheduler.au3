#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <KleverLib.au3>

Opt("GUICloseOnESC", 0)

$usageMsg = ""&@crlf& _
			@scriptname &"    Run klever testcase scheduler."&@crlf& _
			" "&@ScriptName &@TAB&"encip=<encip> loginId=<loginId> passWord=<passWord> testCase=<testcase> scheDate=<schedate> scheTime=<schetime>"&@crlf& _
			""&@crlf& _
			" encIp"&@tab&@tab&"encoder Ip"&@crlf& _
			" loginId"&@tab&@tab&"encoder loginId"&@crlf& _
			" passWord"&@tab&@tab&"encoder password"&@crlf& _
			" testCase"&@tab&@tab&"testcase name"&@crlf& _
			" scheDate"&@tab&@tab&"the date to run testcase. Day/Mon/Year"&@crlf& _
			" scheTime"&@tab&@tab&"the time to run testcase. 24h format. default 00:00"&@crlf& _
			""


main()
ProgramEnd()

;main function
Func main()
	If isDeclared("encIp") And isDeclared("loginId") And IsDeclared("passWord") And IsDeclared("testcase") And IsDeclared("scheDate") And IsDeclared("scheTime") Then
		kleverschedulercmd()
	Else
		kleverschedulergui()
	EndIf
EndFunc

Func kleverschedulercmd()


EndFunc

Func kleverschedulergui()
	Local $msg
	
	$maingui = GUICreate("Klever Scheduler", 350,230,-1,-1)
	
	$encoderinput = GUICtrlCreateInput("encip", 10, 20, 100, 20)
	$encloginIdinput = GUICtrlCreateInput("loginId", 115, 20, 100, 20)
	$encpasswordinput = GUICtrlCreateInput("password", 220, 20, 100, 20)
	
	$dayinput = GUICtrlCreateInput("day", 10, 60, 50, 20)
	$monthinput = GUICtrlCreateInput("mon", 65, 60, 50, 20)
	$yearinput = GUICtrlCreateInput("year", 120, 60, 50, 20)
	
	$timeinput = GUICtrlCreateInput("00:00", 10, 100, 100, 20)
	
	$testcaseselectionlabel = GUICtrlCreateLabel("selected testcase", 10, 130, 330, 60)
	$testcaseselect = GUICtrlCreateButton("Select"&@crlf&"Case", 20, 170, 50,40, $BS_MULTILINE)
	$sendschedule = GUICtrlCreateButton("Send"&@crlf&"Schedule", 100, 170, 55,40, $BS_MULTILINE)
	
	GUISetState(@SW_SHOW)
	
	While 1
		$msg = GUIGetMsg()
		Select
		Case $msg = $GUI_EVENT_CLOSE
			ExitLoop
		Case $msg = $testcaseselect
			$caseFileSelect=FileOpenDialog("Select Testcase", $kleverTestDir, "TestCase(*.testcase)",1)
			If $caseFileSelect<>"" Then
				GUICtrlSetData($testcaseselectionlabel, $caseFileSelect)
			EndIf
		EndSelect
	WEnd
EndFunc
	