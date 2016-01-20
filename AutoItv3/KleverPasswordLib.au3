#include <String.au3>

;$string = text to generate the encrypted password
Func KPasswordEncrypt($string, $level=1)
	local $pass = _StringEncrypt(1, $string, $string, $level)
	return $pass
EndFunc

;$string = stored passwd string
;$pass = passwd provided by user
Func KPasswordDecrypt($string, $pass, $level=1)
	local $dpass = _StringEncrypt(0, $string, $pass, $level)
	return $dpass
EndFunc

;$string = stored passwd string
;$pass = passwd to compare against
Func KPasswordCheck($string, $pass, $level=1)
	local $match = 0
	;first need to decrypt the stored passed
	local $mypass = KPasswordDecrypt($string, $pass, $level)
	If StringCompare($mypass, $pass, 1)=0 Then
		$match = 1
	EndIf
	return $match
EndFunc
