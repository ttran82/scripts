#include <MsgBoxConstants.au3>

Local $sText = WinGetTitle("StreamXpert - ")

; Display the window title.
MsgBox($MB_SYSTEMMODAL, "", $sText)
