;#####################################################################################
;Scripting.DIctionary Functions
;Copy from GaryFrost's post in Autoit Forums
;http://www.autoitscript.com/forum/topic/47048-scripting-dictionary/
;#####################################################################################


Func _CreateHashTable()
    Return ObjCreate("Scripting.Dictionary")
EndFunc   ;==>_InitDictionary

; Adds a key and item pair to a Dictionary object.  If key exists, item will change
Func _SetHashItem($hash, $v_key, $v_item)
	If _HashItemExists($hash, $v_key) Then

		$hash.Item ($v_key) = $v_item
	Else
		$hash.ADD ($v_key, $v_item)
	EndIf
    If @error Then Return SetError(1, 1, -1)
EndFunc   ;==>_SetItem



; Adds a key and item pair to a Dictionary object.
Func _AddHashItem($hash, $v_key, $v_item)
    $hash.ADD ($v_key, $v_item)
    If @error Then Return SetError(1, 1, -1)
EndFunc   ;==>_AddItem

; Returns true if a specified key exists in the Dictionary object, false if it does not.
Func _HashItemExists($hash, $v_key)
    Return $hash.Exists ($v_key)
EndFunc   ;==>_ItemExists

; Returns an item for a specified key in a Dictionary object
Func _GetHashItem($hash, $v_key)
    Return $hash.Item ($v_key)
EndFunc   ;==>_Item

; Sets an item for a specified key in a Dictionary object
Func _ChangeHashItem($hash, $v_key, $v_item)
    $hash.Item ($v_key) = $v_item
EndFunc   ;==>_ChangeItem

; Sets a key in a Dictionary object.
Func _ChangeHashKey($hash, $v_key, $v_newKey)
    $hash.Key ($v_key) = $v_newKey
EndFunc   ;==>_ChangeKey

; Removes a key, item pair from a Dictionary object.
Func _RemoveHashItem($hash, $v_removekey)
    $hash.Remove ($v_removekey)
    If @error Then Return SetError(1, 1, -1)
EndFunc   ;==>_ItemRemove

; Returns the number of items in a collection or Dictionary object.
Func _CountHashItem($hash)
    Return $hash.Count
EndFunc   ;==>_ItemCount

; Returns an array containing all the items in a Dictionary object
Func _GetAllHashItem($hash)
    Return $hash.Items
EndFunc   ;==>_GetItems

;Other functions
#cs
$hash.RemoveAll()    Remove all items
$hash.HashVal([in] VARIANT* Key,
					[out, retval] VARIANT* HashVal);
#ce

; Read a file to existed hash table, key and item split by pattern, return 0 if success, 1 if failed
; file is full path
Func ReadFiletoHash($hash,$file,$pattern)
	Local $array
	Local $error = 0
	If FileExists($file) Then
		_FileReadToArray($file,$array)

		If IsArray($array) Then
			For $x=1 to $array[0]
				If $array[$x]="" then ContinueLoop
				$splitline = StringSplit($array[$x],$pattern,1)
				if $splitline[0] = 2 Then
					_SetHashItem($hash,$splitline[1], $splitline[2])
				EndIf
			Next
		Else
			ConsoleWrite("Failed to read "&$file)
			$error = 1
		EndIf
	EndIf
	return $error
EndFunc

Func _DebugPrint($s_Text)
    ConsoleWrite($s_Text & @LF)
EndFunc   ;==>_DebugPrint