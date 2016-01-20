#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GuiListBox.au3>
#include <ButtonConstants.au3>
#include <Array.au3>
#include <File.au3>

Opt("GUICloseOnESC", 0)

Global $searchDir=@WorkingDir
Global $searchPattern="*.*"
Global $kleverHome = @ScriptDir

;Flow of the main program
ParseArguments()
main()


Func main()
	KleverSimpleEditor()
EndFunc

Func KleverSimpleEditor()
	Local $msgkse
	Local $displaystate=BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY)
	Local $currentitem=""

	$maingui = GUICreate("Klever Editor", 800, 600, -1, -1, BitOr($GUI_SS_DEFAULT_GUI,$WS_OVERLAPPEDWINDOW,$WS_EX_ACCEPTFILES))
	;create search related
	Global $guisearchDir = GUICtrlCreateinput($searchDir,5, 5, 465, 20)
	$guisearchDirButton = GUICtrlCreateButton("Select Folder", 480, 5, 70,20)
	Global $guisearchPattern = GUICtrlCreateInput($searchPattern, 560, 5, 150, 20)
	$guisearchstartbutton = GUICtrlCreateButton("Start Search", 720, 5, 70,20)
	;create a list for search result
	Global $guisearchresulttotal = GUICtrlCreateLabel("0 Found", 5, 30, 60,20)

	Global $guisearchresultlist = GUICtrlCreateList("",5, 50, 250, 490,BitOR($LBS_SORT, $WS_HSCROLL, $WS_VSCROLL, $WS_BORDER, $LBS_EXTENDEDSEL))

	$searchresult = SESearchFile($searchDir, $searchPattern)
	For $lop = 1 to $searchresult[0]
		GUICtrlSetData($guisearchresultlist, $searchresult[$lop])
	Next
	GUICtrlSetData($guisearchresulttotal, $searchresult[0]&" found")

	$guiFilelabel = GUICtrlCreateLabel("Current File:",255,30,60,20)
	Global $guiFileselectedlabel = GUICtrlCreateLabel("",325,30,465,20)

	;create an editbox
	Global $guidisplayeditbox = GUICtrlCreateEdit("Display",255, 50, 540, 490 ,$displaystate)
	;create buttons
	$guiopensearchdir = GUICtrlCreateButton("Open Folder", 140,550,50,30,$BS_MULTILINE)
	$guirefreshlist = GUICtrlCreateButton("Refresh",200,550, 50, 30)
	$guinewfile = GUICtrlCreateButton("New File", 260, 550, 50, 30)
	$guimodifyfile = GUICtrlCreateButton("Modify", 320, 550, 50, 30)
	$guisavefile = GUICtrlCreateButton("Save File", 380, 550, 50, 30)
	$guiRenameFile = GUICtrlCreateButton("Rename",440,550,50,30)
	$guiDeleteFile = GUICtrlCreateButton("Delete",500,550,50,30)


	GUISetState(@SW_SHOW)

	; Just idle around
	While 1
			$msgkse = GUIGetMsg()
			Select
				Case $msgkse = $GUI_EVENT_CLOSE
					ExitLoop
				Case $msgkse = $guisearchresultlist
					$searchresultlistitem = GUICtrlRead($guisearchresultlist)
					If $searchresultlistitem = "" Then ContinueLoop

					$searchDir = GUICtrlRead($guisearchDir)
					If Not FileExists($searchDir) Then
						msgbox(0,"Search Path Error","Search Path is not exist or not valid")
						ContinueLoop
					EndIf
					$searchPattern = GUICtrlRead($guisearchPattern)
					If $searchPattern = "" Then
						$searchPattern = "*.*"
					EndIf
					;asking for save before next step
					If $displaystate = -1 Then
						$msgboxselection = msgbox(4,"Save File","Do you want to save your work?")
						if $msgboxselection = 6 Then
							$savecontent = GUICtrlRead($guidisplayeditbox)
							SEFileSave("Save File", $searchDir, "All (*.*)", 16, $currentitem, $savecontent)
							GUICtrlSetData($guisearchresultlist,"")
							$searchresultlist = SESearchFile($searchDir,$searchPattern)
							GUICtrlSetData($guisearchresulttotal, $searchresultlist[0]&" found")
							For $lop = 1 to $searchresultlist[0]
								GUICtrlSetData($guisearchresultlist, $searchresultlist[$lop])
							Next
						EndIf
						$displaystate=BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY)
						GUICtrlSetStyle($guidisplayeditbox,$ES_READONLY)
						;GUICtrlDelete($guidisplayeditbox)
						;$guidisplayeditbox = GUICtrlCreateEdit("Display", 255, 50, 540, 490 ,$displaystate)
					EndIf
					;display the testcase content
					GUICtrlSetData($guiFileselectedlabel, $searchDir&"\"&$searchresultlistitem)
					$itemcontent = FileOpen($searchDir&"\"&$searchresultlistitem, 0)
					If $itemcontent = -1 Then
						MsgBox(0, "Error", "Unable to open "&$itemcontent&" file.")
					EndIf
					GUICtrlSetData($guidisplayeditbox, FileRead($itemcontent))
					FileClose($itemcontent)
					$currentitem = $searchresultlistitem
				Case $msgkse = $guisearchDirbutton
					$selectedDir = FileSelectFolder("Select the search folder", "", 1+2+4, $kleverHome)
					GUICtrlSetData($guisearchDir,$selectedDir)

				Case $msgkse = $guisearchstartbutton Or $msgkse = $guirefreshlist;scan the searchdir with search pattern
					SEDisplayFileList()

				Case $msgkse = $guiopensearchdir; open the searchdir
					$searchDir = GUICtrlRead($guisearchDir)
					If Not FileExists($searchDir) Then
						msgbox(0,"Path Error","Path is not exist or not valid")
						ContinueLoop
					EndIf
					run("explorer.exe "&'"'&$searchDir&'"')
				Case $msgkse = $guinewfile;open new file
					$searchDir = GUICtrlRead($guisearchDir)
					If Not FileExists($searchDir) Then
						$searchDir = @ScriptDir
					EndIf
					$searchPattern = GUICtrlRead($guisearchPattern)
					If $searchPattern = "" Then
						$searchPattern = "*.*"
					EndIf
					$currentitem = "NewFile.txt"
					;asking for save before next step
					If $displaystate = -1 Then
						$msgboxselection = msgbox(4,"Save File","Do you want to save your work?")
						if $msgboxselection = 6 Then
							$savecontent = GUICtrlRead($guidisplayeditbox)
							SEFileSave("Save File", $searchDir, "All (*.*)", 16, $currentitem, $savecontent)
							GUICtrlSetData($guisearchresultlist,"")
							$searchresultlist = SESearchFile($searchDir,$searchPattern)
							GUICtrlSetData($guisearchresulttotal, $searchresultlist[0]&" found")
							For $lop = 1 to $searchresultlist[0]
								GUICtrlSetData($guisearchresultlist, $searchresultlist[$lop])
							Next
						EndIf
					EndIf
					$displaystate=-1
					;GUICtrlDelete($guidisplayeditbox)
					;$guidisplayeditbox = GUICtrlCreateEdit("", 255, 50, 540, 490 ,$displaystate)
					GUICtrlSetData($guidisplayeditbox, "")
					GUICtrlSetState($guidisplayeditbox,$GUI_DROPACCEPTED)
					GUICtrlSetStyle($guidisplayeditbox,$GUI_SS_DEFAULT_EDIT)
					GUICtrlSetData($guiFileselectedlabel, "")
				Case $msgkse = $guimodifyfile;set the read mode to write mode
					If $displaystate = -1 Then ContinueLoop

					$displaystate = -1
					GUICtrlSetState($guidisplayeditbox,$GUI_ONTOP+$GUI_DROPACCEPTED)
					GUICtrlSetStyle($guidisplayeditbox,$GUI_SS_DEFAULT_EDIT)

				Case $msgkse = $guisavefile

					$currentitem = GUICtrlRead($guiFileselectedlabel)

					If $currentitem = "" Then
						$currentitem = "NewFile.txt"
					EndIf

					$searchDir = GUICtrlRead($guisearchDir)
					If Not FileExists($searchDir) Then
						$searchDir = @ScriptDir
					EndIf
					$searchPattern = GUICtrlRead($guisearchPattern)
					If $searchPattern = "" Then
						$searchPattern = "*.*"
					EndIf

					If $displaystate = -1 Then
						$saveflag = SESaveModifiedFile($currentitem,$searchDir)
						If $saveflag = 0 and $currentitem = "NewFile.txt" Then
							SEDisplayFileList()
						EndIf
					EndIf

					$displaystate=BitOR($GUI_SS_DEFAULT_EDIT, $ES_READONLY)
					GUICtrlSetStyle($guidisplayeditbox,$ES_READONLY)

				Case $msgkse = $guiRenameFile;rename selected file
					$searchresultlistitem = GUICtrlRead($guisearchresultlist)
					If $searchresultlistitem = "" Then ContinueLoop
					$splitname = StringSplit(StringReplace($searchresultlistitem,".","#t#",-1),"#t#",1)
					$filename = $splitname[1]
					$fileextension = $splitname[2]

					$errorcheck = RenameFile($searchDir&"\"&$searchresultlistitem,$filename,$fileextension)

					;input new name, inputbox has a timeout of 20sec
					;$newfilename = InputBox("New Name","Please input new name for "&$searchDir&"\"&$searchresultlistitem,$filename," M",-1,-1,Default,Default,20)
					;If $newfilename = "" Or $newfilename = $filename Then
					;	ContinueLoop
					;Else

					;	$errorcheck = RenameFile($searchDir&"\"&$searchresultlistitem,$searchDir&"\"&$newfilename&"."&$fileextension)
					;	If $errorcheck = 0 Then
					;		msgbox(0,"Error renaming file","Can not rename file "&$searchresultlistitem&", new file name already exists or can not copy to "&$searchDir,15)
					;	EndIf
					;EndIf
				Case $msgkse = $guiDeleteFile;delete current file
					$currentitem = _GUICtrlListBox_GetSelItemsText($guisearchresultlist)
					$currentfolder = GUICtrlRead($guisearchDir)

					If $currentitem[0] > 0 Then
						local $msgboxyesno = Msgbox(20, "Delete File", "The following files will be deleted:"&@CRLF&@CRlf& _ArrayToString($currentitem, @CRLF, 1))
						If $msgboxyesno = 6 Then
							For $i = 1 To $currentitem[0]
								SEFileDelete($currentfolder, $currentitem[$i])
							Next
							SEDisplayFileList()
						EndIf
					EndIf


			EndSelect
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

Func SESearchFile($searchdir,$searchpattern)
	Local $filenamelist[1]
	Local $lastindex=0
	$search = FileFindFirstFile($searchdir&"\"&$searchpattern)
	while 1
		$searchresult = FileFindNextFile($search)
		If @error Then ExitLoop
		$lastindex = _ArrayAdd($filenamelist, $searchresult)
	WEnd
	$filenamelist[0]=$lastindex
	FileClose($search)
	FileClose($searchresult)
	Return $filenamelist
EndFunc

Func SEDisplayFileList()
	local $searchDir = GUICtrlRead($guisearchDir)
	local $searchPattern = GUICtrlRead($guisearchPattern)
	If Not FileExists($searchDir) Then
		msgbox(0,"Search Path Error","Search Path is not exist or not valid")
	EndIf
	If $searchPattern = "" Then
		$searchPattern = "*.*"
	EndIf
	GUICtrlSetData($guisearchresultlist, "")
	local $searchresult = SESearchFile($searchDir, $searchPattern)
	For $lop = 1 to $searchresult[0]
		GUICtrlSetData($guisearchresultlist, $searchresult[$lop])
	Next
	GUICtrlSetData($guisearchresulttotal, $searchresult[0]&" found")
EndFunc

Func SESaveModifiedFile($file,$savepath)
	local $newfile = ""
	local $msgboxselection = msgbox(4,"Save","Do you want to save your current file?")
	if $msgboxselection = 6 Then
		$savecontent = GUICtrlRead($guidisplayeditbox)
		$newfile = SEFileSave("Save File", $savepath, "All (*.*)", 16, $file, $savecontent)
		If IsString($newfile) Then
			;$newfile = StringReplace($newfile, $savepath, "")
			;$newfile = StringReplace($newfile, "\", "")
			GUICtrlSetData($guiFileselectedlabel, $newfile)
		Endif
		return 0 ;file been saved, need to refresh testcaselist
	Else
		return 1 ; file save cancelled
	EndIf
EndFunc

;#################################################################
;$option	2 = Path must Exist
;			16 = Prompt to OverWrite File
;Return		0 = save success
;			1 = selection failed
;			2 = bad file filter
;#################################################################
Func SEFileSave($filetype,$defaultsavedir, $filter,$option, $defaultname, $datatosave)
	local $saveto=FileSaveDialog("Save "&$filetype&" to", $defaultsavedir, $filter, $option, $defaultname)
	$filesaveerror = @error
	if $filesaveerror = 1 Then
		;KConsoleWrite($saveto&" selection failed", 0)
		Msgbox(0, "File Save", $saveto & " selection failed")
		Return 1
	Elseif $filesaveerror = 2 Then
		;KConsoleWrite("Bad file filter", 0)
		Msgbox(0, "File Save", "Bad file filter")
		Return 2
	Else
		;_FileWriteLog($logFile, "File Save="&$saveto)
		$savefile = FileOpen($saveto, 2)
		FileWrite($savefile, $datatosave)
		FileClose($savefile)
		Return $saveto
	EndIf
EndFunc

Func SEFileDelete($path, $file)
	;If filename is a testcase, we need to delete path\Info\testcase.*
	If StringRegExp($file, ".testcase") = 1 Then
		FileDelete($path&"\Info\"&$file&".*")
	EndIf
	FileDelete($path&"\"&$file)
EndFunc

;filefullname contains extension
;filename only the name
Func RenameFile($filefullname,$filename,$fileextension)
	Local $renameresult = 1
	Local $errorcheck = 1
	Local $testcasedir = GUICtrlRead($guisearchDir)
	$newfilename = InputBox("New Name","Please input/modify new name.  Do not add any extension"&$filefullname&".", $filename, " M", -1, -1, Default, Default, 20)

	If $newfilename = "" Or $newfilename = $filename Then
		$renameresult = 0

	ElseIf FileExists($testcasedir&"\"&$newfilename&"."&$fileextension) Then
		msgbox(0,"Error renaming testcase","The new name already existed. Please use another name.",10)
		$renameresult = 0
	Else
		$errorcheck = FileMove($testcasedir&"\"&$filename&"."&$fileextension,$testcasedir&"\"&$newfilename&"."&$fileextension)
		If $errorcheck = 0 Then
			msgbox(0,"Error renaming testcase","Can not rename file "&$filefullname&", Can not copy to "&$testcasedir&"\"&$newfilename&"."&$fileextension,15)
			$renameresult = 0
		Else
			;If fileextension is .testcase, we need to
			If StringCompare($fileextension, "testcase") == 0 Then
				FileMove($testcasedir&"\Info\"&$filename&"."&$fileextension&".last",$testcasedir&"\Info\"&$newfilename&"."&$fileextension&".last")
				FileMove($testcasedir&"\Info\"&$filename&"."&$fileextension&".ran",$testcasedir&"\Info\"&$newfilename&"."&$fileextension&".ran")
				FileMove($testcasedir&"\CaseId\"&$filename&"."&$fileextension&".caseId",$testcasedir&"\CaseId\"&$newfilename&"."&$fileextension&".caseId")
			EndIf

			;GUICtrlSetData($guiTestcaseselectedlabel, $newfilename&"."&$fileextension)
		EndIf
	EndIf
	Return $renameresult
EndFunc