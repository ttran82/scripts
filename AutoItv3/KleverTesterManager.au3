#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiComboBox.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GuiListBox.au3>
#include <GuiListView.au3>
#include <ButtonConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <KleverPasswordLib.au3>
#include <Crypt.au3>

Opt("GUICloseOnESC", 0)

;each tester will be on a separate file stored in $projecthome\Configs\Testers folder
;file structure for each tester: passwd,testerName,Testertype,Createddate,email

;argument to this .exe testerDir=<dir>
Global $testerDir = @WorkingDir
Global $guiTesterFound
Global $guiTesterList
Global $guiCurrentDir

;Flow of the main program
ParseArguments()
main()


Func main()
	KleverTesterManager()
EndFunc

Func KleverTesterManager()

	Local $displaystate=BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY)

	$maingui = GUICreate("Klever Tester Manager", 800, 600, -1, -1, BitOr($GUI_SS_DEFAULT_GUI,$WS_OVERLAPPEDWINDOW,$WS_EX_ACCEPTFILES))

	$menuFile = GUICtrlCreateMenu("File")
	$menuFileOpen = GUICtrlCreateMenuItem("Choose Testers Dir", $menuFile)
	$menuFileExit = GUICtrlCreateMenuItem("Exit", $menuFile)

	$guiCurrentDirLabel = GUICtrlCreateLabel("Current Dir:", 10, 10, 60, 20)
	$guiCurrentDir = GUICtrlCreateLabel($testerDir, 80, 10, 520, 20)

	$guiTesterList = GUICtrlCreateListView("", 10, 40, 780, 460,BitOR($LVS_SHOWSELALWAYS, $LVS_SINGLESEL))
	_GUICtrlListView_AddColumn($guiTesterList,"TesterID",100)
	_GUICtrlListView_AddColumn($guiTesterList,"TesterName",100)
	_GUICtrlListView_AddColumn($guiTesterList,"Group",100)
	_GUICtrlListView_AddColumn($guiTesterList,"CreatedDate",100)
	_GUICtrlListView_AddColumn($guiTesterList,"Email",380)

	$guiTesterFoundLabel = GUICtrlCreateLabel("Testers found:", 10, 510, 70, 20)
	$guiTesterFound = GUICtrlCreateLabel("", 90, 510, 100, 20)
	$guiRefreshButton = GUICtrlCreateButton("Refresh", 10, 540, 80, 20)
	$guiAddButton = GUICtrlCreateButton("Add", 100, 540, 80, 20)
	$guiModifyButton = GUICtrlCreateButton("Modify", 190, 540, 80, 20)
	$guiDeleteButton = GUICtrlCreateButton("Delete", 280, 540, 80, 20)

	DisplayTesterList(GUICtrlRead($guiCurrentDir))

	GUISetState(@SW_SHOW)
	_GUICtrlListView_RegisterSortCallBack($guiTesterList)

	; Just idle around
	While 1
	local $nMsg = GUIGetMsg()
	Switch $nMsg
		Case $menuFileOpen
			local $selectedDir = FileSelectFolder("Select the directory where testers will be created", "", 4)
			If $selectedDir Then
				GUICtrlSetData($guiCurrentDir, $selectedDir)
				DisplayTesterList(GUICtrlRead($guiCurrentDir))
			EndIf
		Case $guiRefreshButton
			DisplayTesterList(GUICtrlRead($guiCurrentDir))
		Case $guiAddButton
			GUINewTester()
			DisplayTesterList(GUICtrlRead($guiCurrentDir))
		Case $guiModifyButton
			Local $mytester = ListviewSelection($guiTesterList)
			GUIModifyTester(GUICtrlRead($guiCurrentDir), $mytester)
			DisplayTesterList(GUICtrlRead($guiCurrentDir))
		Case $guiDeleteButton
			Local $mytester = ListviewSelection($guiTesterList)
			DeleteTesterFile(GUICtrlRead($guiCurrentDir), $mytester)
			DisplayTesterList(GUICtrlRead($guiCurrentDir))
		Case $menuFileExit
			Exitloop
		Case $GUI_EVENT_CLOSE
			Exitloop
	EndSwitch
	WEnd

EndFunc

Func ParseArguments()
	AssignVariable($CmdLine)
EndFunc

Func AssignVariable($array)
	Local $larray
	If(isarray($array)) then
		For $arrayIndex = 1 to $array[0]
			$linesplit = StringSplit($array[$arrayIndex], "=", 1)
			If ($linesplit[1] = "parameterList") Then
				_FileReadToArray(@WorkingDir&"\"&$linesplit[2],$larray)
				AssignVariable($larray)
			Else
				Assign($linesplit[1], $linesplit[2], 2)
			EndIf
		Next
	EndIf
EndFunc

Func DisplayTesterList($folder)

	_GUICtrlListView_DeleteAllItems(GUICtrlGetHandle($guiTesterList))
	local $testerlist = _FileListToArray($folder, "*", 1)
	If IsArray($testerlist) Then
		GUICtrlSetData($guiTesterFound, $testerlist[0])
		local $testerinfo
		local $testtempfile = @TempDir&"\.ktempfile"
		For $x=1 to $testerlist[0]
			$currenttesterfile = $folder&"\"&$testerlist[$x]
			_Crypt_DecryptFile($currenttesterfile, $testtempfile, "modulus" , $CALG_AES_128)
			$testerinfo = KFileReadLine($testtempfile)

			If IsArray($testerinfo) Then
				GUICtrlCreateListViewItem($testerlist[$x]&"|"&$testerinfo[2]&"|"&$testerinfo[3]&"|"&$testerinfo[4]&"|"&$testerinfo[5],$guiTesterList)
			EndIf
		Next
		FileDelete($testtempfile)
	Else
		GUICtrlSetData($guiTesterFound, 0)
	EndIf
EndFunc

;FileReadLine
Func KFileReadLine($file, $line=1)
	Local $myfile = FileOpen($file)
	If $myfile = -1 Then
		MsgBox(0, "Error", "Unable to open file " &$file )
		Exit
    EndIf

	local $myline = FileReadLine($myfile, $line)
	FileClose($myfile)

	local $testerinfo = 0
	$testerinfo = StringSplit($myline, ",")
	If $testerinfo[0] = 5 Then
		;good
	Else
		$testerinfo = 0
		MsgBox(0, "Error", "Bad Tester info.  It is recommended to re-create a new tester.")
	EndIf
	return $testerinfo
EndFunc

;Create Add new tester login GUI
Func GUINewTester()
	local $success = 0

	local $addgui = GUICreate("Creating New Klever Tester", 300, 200)

	local $guiloginlabel = GUICtrlCreateLabel("Tester Login ID:", 10, 10, 100, 20)
	local $guilogin = GUICtrlCreateInput("", 120, 10, 150, 20)

	local $guirealnamelabel = GUICtrlCreateLabel("Password:", 10, 40, 100, 20)
	local $guipassword = GUICtrlCreateInput("", 120, 40, 150, 20,$ES_PASSWORD)

	local $guirealnamelabel = GUICtrlCreateLabel("Tester Real Name:", 10, 70, 100, 20)
	local $guirealname = GUICtrlCreateInput("", 120, 70, 150, 20)

	local $guiaccounttypelabel = GUICtrlCreateLabel("Account Type:", 10, 100, 100, 20)
	local $guiaccounttype = GUICtrlCreateCombo("tester", 120, 100, 150, 20)
	GUICtrlSetData($guiaccounttype, "admin")

	local $guiemaillabel = GUICtrlCreateLabel("Email:", 10, 130, 100, 20)
	local $guiemail = GUICtrlCreateInput("", 120, 130, 150, 20)

	local $buttonAdd=GUICtrlCreateButton("Add",10,180,100,20)
	local $buttonCancel=GUICtrlCreateButton("Cancel",180,180,100,20)

	GUISetState()
	While 1
		local $nMsg = GUIGetMsg()
		Switch $nMsg
			Case $buttonAdd
				;read all information from GUI inputs
				local $getlogin = GUICtrlRead($guilogin)
				local $getpass = GUICtrlRead($guipassword)
				local $getrealname = GUICtrlRead($guirealname)
				local $getaccounttype = GUICtrlRead($guiaccounttype)
				local $getemail = GUICtrlRead($guiemail)
				CreateNewTester(GUICtrlRead($guiCurrentDir),$getlogin , $getpass, $getrealname, $getaccounttype,$getemail)
				ExitLoop
			Case $buttonCancel
				Exitloop
			Case $GUI_EVENT_CLOSE
				Exitloop
		EndSwitch
	WEnd

	GUIDelete($addgui)
	return $success
EndFunc

;Create Add new tester login GUI
Func GUIModifyTester($dir, $tester)
	local $success = 0

	;First check if tester db file exists
	local $testerdbfile = $dir & "\" & $tester

	local $testerinfo = KFileReadLine($testerdbfile)

	If IsArray($testerinfo) Then
		local $cpass = $testerinfo[1]

		local $modifygui = GUICreate("Modifying "&$tester&"'s Profile", 300, 200)

		local $guiloginlabel = GUICtrlCreateLabel("Tester Login ID:", 10, 10, 100, 20)
		local $guilogin = GUICtrlCreateInput($tester, 120, 10, 150, 20)

		local $guirealnamelabel = GUICtrlCreateLabel("Password:", 10, 40, 100, 20)
		local $guipassword = GUICtrlCreateInput("", 120, 40, 150, 20,$ES_PASSWORD)

		local $guirealnamelabel = GUICtrlCreateLabel("Tester Real Name:", 10, 70, 100, 20)
		local $guirealname = GUICtrlCreateInput($testerinfo[2], 120, 70, 150, 20)

		local $guiaccounttypelabel = GUICtrlCreateLabel("Account Type:", 10, 100, 100, 20)
		local $guiaccounttype = GUICtrlCreateCombo($testerinfo[3], 120, 100, 150, 20)
		GUICtrlSetData($guiaccounttype, "admin")

		local $guiemaillabel = GUICtrlCreateLabel("Email:", 10, 130, 100, 20)
		local $guiemail = GUICtrlCreateInput($testerinfo[5], 120, 130, 150, 20)

		local $buttonModify=GUICtrlCreateButton("Modify",10,180,100,20)
		local $buttonCancel=GUICtrlCreateButton("Cancel",180,180,100,20)

		GUISetState()
		While 1
			local $nMsg = GUIGetMsg()
			Switch $nMsg
				Case $buttonModify
					local $npass = GUICtrlRead($guipassword)
					If $npass = "" Then
						$npass = $testerinfo[1]
					EndIf
					;delete previvious profile
					DeleteTesterFile($dir, $tester, 0)
					;create new profile
					GenerateTesterFile($dir, GUICtrlRead($guilogin) , KPasswordEncrypt($npass), GUICtrlRead($guirealname), GUICtrlRead($guiaccounttype), GUICtrlRead($guiemail))
					ExitLoop
				Case $buttonCancel
					Exitloop
				Case $GUI_EVENT_CLOSE
					Exitloop
			EndSwitch
		WEnd

		GUIDelete($modifygui)
	EndIf

	return $success
EndFunc

;success = 0/1; 1 = good
Func CreateNewTester($dir, $login, $pass, $name, $type, $email)
	local $success = 1
	local $loginfullpath = $dir & "\" & $login

	If FileExists($loginfullpath) Then
		local $ask = MsgBox(4, "Existing loginID found ", "Do you want to override existing "&$login&"'s profile?")
		If $ask = 6 Then
			$success = GenerateTesterFile($dir, $login , KPasswordEncrypt($pass), $name, $type, $email)
		Else
			;leave existing login file alone
		EndIf
		;Override existing entry
	Else
		;Add new entry
		$success = GenerateTesterFile($dir, $login , KPasswordEncrypt($pass), $name, $type, $email)
	EndIf
	return $success
EndFunc

;success = 0/1; 1 = good
Func GenerateTesterFile($dir, $login, $pass, $name, $type, $email)
	;encrypt the password
	local $success = 1
	local $loginfullpath = $dir & "\" & $login
	local $date = @year&@mon&@Mday
	local $linetowrite = $pass &","& $name &","& $type &","& $date &","& $email
	;Create new file
	Local $file = FileOpen($loginfullpath, 10)
	; Check if file opened for writing OK
	If $file = -1 Then
		MsgBox(0, "Error", "Unable to open file:" & $loginfullpath)
		$success = 0
	Else
		FileWrite($file, $linetowrite)
	EndIf
	FileClose($file)
	;need to encrypt the file for extra security
	_Crypt_EncryptFile($loginfullpath, $loginfullpath&".encrypted", "modulus" , $CALG_AES_128)
	FileMove($loginfullpath&".encrypted", $loginfullpath, 1)
	return $success
EndFunc

;success = 0/1; 1 = good
Func DeleteTesterFile($dir, $login, $prompt=1)
	;encrypt the password
	local $success = 1
	local $loginfullpath = $dir & "\" & $login

	If $prompt = 1 Then
		local $ask = MsgBox(4, "Deleting tester "&$login&" permantly.", "Are you sure?")

		If $ask = 6 Then
			$success = FileDelete($loginfullpath)
		EndIf
	Else
		$success = FileDelete($loginfullpath)
	EndIf

	return $success
EndFunc

Func ListviewSelection($listviewhandle, $subitem=0)
	;Local $itemindex=_GUICtrlListView_GetSelectedIndices(GUICtrlGetHandle($listviewhandle),True)
	Local $itemindex=_GUICtrlListView_GetSelectedIndices(GUICtrlGetHandle($listviewhandle))
	Local $tester = 0
	$tester = _GUICtrlListView_GetItemText(GUICtrlGetHandle($listviewhandle),$itemindex,$subitem)
	return $tester
EndFunc

