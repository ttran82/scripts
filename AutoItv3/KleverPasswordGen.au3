#include <GUIConstantsEx.au3>
#include <KleverPasswordLib.au3>

_Main()

Func _Main()
	Local $WinMain, $EditText, $InputPass, $InputLevel, $EncryptButton, $DecryptButton, $string
	; GUI and String stuff
	$WinMain = GUICreate('Klever Password Generator', 400, 200)
	; Creates window
	$EditText = GUICtrlCreateEdit('', 5, 5, 380, 150)
	; Creates main edit
	$InputPass = GUICtrlCreateInput('', 5, 160, 100, 20, 0x21)
	; Creates the password box with blured/centered input
	$InputLevel = GUICtrlCreateInput(1, 110, 160, 50, 20, 0x2001)
	GUICtrlSetLimit(GUICtrlCreateUpdown($InputLevel), 10, 1)
	; These two make the level input with the Up|Down ability
	$EncryptButton = GUICtrlCreateButton('Generate', 170, 160, 105, 35)
	; Encryption button
	$DecryptButton = GUICtrlCreateButton('Decrypt', 285, 160, 105, 35)
	; Decryption button
	GUICtrlCreateLabel('Password', 5, 185)
	GUICtrlCreateLabel('Level', 110, 185)
	; Simple text labels so you know what is what
	GUISetState()
	; Shows window

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $EncryptButton
				$string = GUICtrlRead($InputPass) ;
				;Use the string as the encrypt password
				GUICtrlSetData($EditText, KPasswordEncrypt($string, GUICtrlRead($InputLevel)))
			Case $DecryptButton
				$string = GUICtrlRead($EditText) ; Saves the editbox for later
				GUICtrlSetData($EditText, KPasswordDecrypt($string, GUICtrlRead($InputPass), GUICtrlRead($InputLevel)))
		EndSwitch
	WEnd ; Continue loop untill window is closed
	Exit
EndFunc   ;==>_Main