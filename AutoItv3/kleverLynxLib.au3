

Func ReadLynxScript($scriptfile)
	Local $text
	If FileExists($scriptfile) Then
		Local $file = FileOpen($scriptfile,0)
		$text = FileRead($file)
		FileClose($file)
	Else
		KConsoleWrite($scriptfile&" is not existed.",1)
	EndIf
	Return $text
EndFunc


Func ExecLynx($file)
	$mycommand = "auto_lynx.exe scriptFile="&'"'&$file&'"'
	RunCommand($mycommand,@WorkingDir)
EndFunc