#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GuiListBox.au3>
#include <ButtonConstants.au3>

Opt("GUICloseOnESC", 0)

Func KWinClose($title, $text="")
	; Closing any previous opening program
	While WinExists($title)
		WinClose($title)
	WEnd
EndFunc

Func KWinActivate($title, $text="", $retry=5)
	local $timeout = 0
	local $wait = 1000
	local $whdl = WinActivate($title, $text)

	While $whdl = 0 And $timeout < $retry
		Sleep($wait)
		$timeout = $timeout + 1
		$whdl = WinActivate($title, $text)
	WEnd

	if $whdl = 0 Then
		KConsoleWrite("Failed to get windows handle " & $timeout & " after " & $retry & " retries.", 1)
	EndIf

	return $whdl
EndFunc

Func KWinWait($title, $text="", $timeout=60)
	local $whdl = WinWait($title, $text, $timeout)

	if $whdl = 0 Then
		KConsoleWrite("Failed to wait for " & $title & " after " & $timeout & " seconds", 1)
	EndIf

	return $whdl
EndFunc

Func KControlCheck($return, $text)
	If $return = 0 Then
		KConsoleWrite($text & " failed.", 1)
	EndIf
	KConsoleWrite("ControlClick return: " & $return, 0, 3)
	sleep(1000)
EndFunc

Func KDisplayEditArea($wh, $file)
	;now display output
	local $itemcontent = FileOpen($file, 0)
	If $itemcontent = -1 Then
		MsgBox(0, "Error", "Unable to open "&$file&" file.")
	EndIf
	GUICtrlSetData($wh, FileRead($itemcontent))
	FileClose($itemcontent)
EndFunc

Func KMouseClick($button, $x, $y, $speed)
	MouseMove($x, $y, $speed)
	MouseMove($x, $y, 10)
	MouseClick($button, $x, $y, 2)
	sleep(1000)
EndFunc

Func KWinSetState($title, $text, $flag)
	if WinSetState($title, $text, $flag) then
		KConsoleWrite("Windows changed state successfully.", 0, 2)
	Else
		KConsoleWrite("Failed to change windows state", 1)
	EndIf

EndFunc


