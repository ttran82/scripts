#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_au_decode.exe
Tool to automate: Decoding au descriptor as per scte 128 spec
Argument Requirements:
	<require argument>
   [optional argument]
Input requirement:
   data=12 bytes of data in hex to be decode
Output requirement:
   outputFile=[default={scriptname}.out]
#ce
;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>

;Global Common Defintions

;Global Defintions unique to this script only

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.
;Here is the example
$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Au Descriptor Decoder"&@crlf& _
			""&@crlf& _
			" Get Syntax: Decode au descriptor as described in SCTE128 spec"&@crlf& _
			"   "&@scriptname&" privateData=<12 bytes of data in hex> outputFile=[output file to store decoded data.]"&@crlf& _
			""&@crlf& _
			" data"&@TAB&"<Required> 12 bytes of private data in hex as provided by Packet analyzer software"&@crlf& _
			" outputFile"&@TAB&"(Optional) This file contains the output of the analysis Default=["& @ScriptName &".out"&@crlf& _
			""

;Main Flow of the program
;Everything starts here

;This argument checks for the parameters which should not be a part of iimSet command.


;This CheckArguments functions is where you determine if those parsed arguments satisfy your input and output requirements
CheckArguments()

;Program Start
ProgramStart()

;Your main program
main()

;Program End
ProgramEnd()


Func CheckArguments()
	;This first check is standard and is required in every scripts
	If isDeclared ("usage") Then
		consoleWrite($usageMsg)
		Exit
	EndIf

	;Your checks start here

	;Checking data
	if not isDeclared("privateData") Then
		KConsoleWrite("User did not provide 12 bytes of private data.", 1)
	EndIf

	;Checking Output Options
	if Not IsDeclared("outputFile") Then
		Assign("outputFile", @ScriptName & ".out", 2)
	EndIf




EndFunc


Func main()
	DecodeAuDescriptor(eval("privateData"))
EndFunc

Func AuWrite($text)
	KConsoleWrite($text, 0, 2)
	FileWriteLine(eval("outputFile"), $text)
EndFunc

Func DecodeAuDescriptor($pdata)
	local $myData = StringStripWS ($pdata, 8)
	local $myarray = StringSplit($myData, "")
	If $myarray[0] < 24 Then
		KConsoleWrite("User did not provide 24+ bytes of private data in hex.", 1)
	EndIf

	AuWrite("AU Private Raw Data = 0x" & $myData)

	;now check scte128 semantics
	AuWrite("AU Information:")

	;data_field_tag(8) = 0x02
	local $data_field_tag = $myarray[1]&$myarray[2]
	If StringCompare($data_field_tag, "02") == 0 Then
		AuWrite(@TAB & "data_field_tag, 8bits: 0x" & $data_field_tag & " -> always")
	Else
		AuWrite(@TAB & "Invalid data_field_tag value: " & $data_field_tag)
		$programExitCode=1
	EndIf

	;data_field_length(8) = 0x0A, we use all 10 bytes for the descriptor
	local $data_field_length = $myarray[3] & $myarray[4]
	If Dec($data_field_length) >= 10 Then
		AuWrite(@TAB & "data_field_length, 8bits: 0x" & $data_field_length & " -> number of descriptor bytes: " & Dec($data_field_length))
	Else
		AuWrite(@TAB & "Invalid data_field_length value: " & $data_field_length)
		$programExitCode=1
	EndIf

	local $au_coding_format = $myarray[5]
	If Int(Dec($data_field_length)) >= 1 Then
		AuWrite(@TAB & @TAB & "data_field_length >= 1")
		;AU_coding_format(4) =
		;						0	Undefined
		;						1	Forbidden
		;						2	AVC
		;						3	Used by DVB
		;						4-F	reserved
		Switch Int($au_coding_format)
			Case 0
					AuWrite(@TAB & @TAB & "AU_coding_format, 4bits: 0x" & $au_coding_format & " is undefined"  & " -> failed")
					$programExitCode=1
			Case 1
					AuWrite(@TAB & @TAB & "AU_coding_format, 4bits: 0x" &  $au_coding_format & " is Forbidden"  & " -> failed")
					$programExitCode=1
			Case 2
					AuWrite(@TAB & @TAB & "AU_coding_format, 4bits: 0x" & $au_coding_format & " -> AVC")
			Case 3
					AuWrite(@TAB & @TAB & "AU_coding_format, 4bits: 0x" & $au_coding_format & " is Used by DVB"  & " -> failed")
					$programExitCode=1
			Case Else
					AuWrite(@TAB & @TAB & "AU_coding_format, 4bits: 0x" & $au_coding_format & " is reserved " & " -> failed")
					$programExitCode=1
		EndSwitch

		;AU_coding_type_information
		local $AU_coding_type_information = _HexToBinaryString($myarray[6])
		local $coding_type_array = StringSplit($AU_coding_type_information, "")
		If $coding_type_array[0] == 4 Then
			AuWrite(@TAB & @TAB & "AU_coding_type_information, 4bits: 0x" & $myarray[6] & " => " & $AU_coding_type_information)
			AuWrite(@TAB & @TAB & @TAB & "AU_IDR_slice_present_flag: " & $coding_type_array[1])
			AuWrite(@TAB & @TAB & @TAB & "AU_I_slice_present_flag: " & $coding_type_array[2])
			AuWrite(@TAB & @TAB & @TAB & "AU_P_slice_present_flag: " & $coding_type_array[3])
			AuWrite(@TAB & @TAB & @TAB & "AU_B_slice_present_flag: " & $coding_type_array[4])
		Else
			AuWrite(@TAB & @TAB & "invalid AU_coding_type_information: " & $myarray[6])
			$programExitCode=1
		EndIf

	EndIf

	;if (data_field_length >= 2) {
	;AU_ref_pic_idc 2 uimsbf
	;AU_pic_struct 2 bsblf
	;AU_PTS_present_flag 1 bslbf
	;AU_profile_info_present_flag 1 bslbf
	;AU_stream_info_present_flag 1 bslbf
	;AU_trick_mode_info_present_flag 1 bslbf
	If Int(Dec($data_field_length)) >= 2 Then
		AuWrite(@TAB & @TAB & "data_field_length >= 2")
		local $tinformation = _HexToBinaryString($myarray[7])
		local $tarray = StringSplit($tinformation, "")
		;AU_ref_pic_idc 2 bits
		local $AU_ref_pic_idc = $tarray[1] & $tarray[2]
		AuWrite(@TAB & @TAB & @TAB & "AU_ref_pic_idc, 2 bits: 0b" & $AU_ref_pic_idc)
		;AU_pic_struct
		local $AU_pic_struct = $tarray[3] & $tarray[4]
		AuWrite(@TAB & @TAB & @TAB & "AU_pic_struct, 2 bits: 0b" & $AU_pic_struct)

		$tinformation = _HexToBinaryString($myarray[8])
		$tarray = StringSplit($tinformation, "")
		;AU_PTS_present_flag
		local $AU_PTS_present_flag  = $tarray[1]
		AuWrite(@TAB & @TAB & @TAB & "AU_PTS_present_flag: " & $AU_PTS_present_flag)
		local $AU_profile_info_present_flag = $tarray[2]
		AuWrite(@TAB & @TAB & @TAB & "AU_profile_info_present_flag: " & $AU_profile_info_present_flag)
		local $AU_stream_info_present_flag = $tarray[3]
		AuWrite(@TAB & @TAB & @TAB & "AU_stream_info_present_flag: " & $AU_stream_info_present_flag)
		local $AU_trick_mode_info_present_flag = $tarray[4]
		AuWrite(@TAB & @TAB & @TAB & "AU_trick_mode_info_present_flag: " & $AU_trick_mode_info_present_flag)
	EndIf

	;if (AU_PTS_present_flag == '1') {
	;AU_PTS_32 32
	If Int($AU_PTS_present_flag) == 1 Then
		AuWrite(@TAB & @TAB & "AU_PTS_present_flag == 1")
		local $AU_PTS_32 = _ArrayToString($myarray, "", 9, 16)
		AuWrite(@TAB & @TAB & @TAB & "AU_PTS_32, 32 bits: 0x" & $AU_PTS_32 & ", PTS = " & Dec($AU_PTS_32, 2))
	EndIf

	;if (AU_stream_info_present_flag == '1') {
	;reserved_zero 4 '0000'
	;AU_frame_rate_code 4 uismbf
	;}
	If Int($AU_stream_info_present_flag) == 1 Then
		AuWrite(@TAB & @TAB & "AU_stream_info_present_flag == 1")
		local $reserved_zero = $myarray[17]
		AuWrite(@TAB & @TAB & @TAB & "reserved_zero, 4 bits: 0b" & _HexToBinaryString($reserved_zero))
		local $AU_frame_rate_code = $myarray[18]
		local $AU_frame_rate_code_ext = "Reserved"
		Switch Int($AU_frame_rate_code)
			Case 0
				$AU_frame_rate_code_ext = "Forbidden"
			Case 1
				$AU_frame_rate_code_ext = "23.97"
			Case 2
				$AU_frame_rate_code_ext = "24"
			Case 3
				$AU_frame_rate_code_ext = "25"
			Case 4
				$AU_frame_rate_code_ext = "29.97"
			Case 5
				$AU_frame_rate_code_ext = "30"
			Case 6
				$AU_frame_rate_code_ext = "50"
			Case 7
				$AU_frame_rate_code_ext = "59.94"
			Case 8
				$AU_frame_rate_code_ext = "60"
			Case Else
				$AU_frame_rate_code_ext = "Reserved"
			EndSwitch
		AuWrite(@TAB & @TAB & @TAB & "AU_frame_rate_code, 4 bits: " & $AU_frame_rate_code & " -> " & $AU_frame_rate_code_ext)
	EndIf

	;if (AU_profile_info_present_flag == ‘1’) {
	;AU_profile 8 uismbf
	;AU_constraint_set0_flag 1 bslbf
	;AU_constraint_set1_flag 1 bslbf
	;AU_constraint_set2_flag 1 bslbf
	;AU_AVC_compatible_flags 5 bslbf
	;AU_level 8 uismbf
	;}
	If Int($AU_profile_info_present_flag) == 1 Then
		AuWrite(@TAB & @TAB & "AU_profile_info_present_flag == 1")
		local $AU_profile = $myarray[19] & $myarray[20]
		If (Dec($AU_profile) == 100) or (Dec($AU_profile) == 77) Then
			If Dec($AU_profile) == 100 Then
				local $AU_profile_ext = "High"
			Else
				local $AU_profile_ext = "Main"
			EndIf
			AuWrite(@TAB & @TAB & @TAB & "AU_profile, 8 bits: 0x" & $AU_profile & " -> " & Dec($AU_profile) & " " & $AU_profile_ext)
		Else
			AuWrite(@TAB & @TAB & @TAB & "Invalid AU_profile, 8 bits: " & $AU_profile & " -> " & Dec($AU_profile) & " Only 100 or 77.")
			$programExitCode = 1
		EndIf

		local $tinformation = _HexToBinaryString($myarray[21])
		local $tarray = StringSplit($tinformation, "")
		local $AU_constraint_set0_flag = $tarray[1]
		If Int($AU_constraint_set0_flag) == 0 Then
			AuWrite(@TAB & @TAB & @TAB & "AU_constraint_set0_flag: " & $AU_constraint_set0_flag)
		Else
			AuWrite(@TAB & @TAB & @TAB & "Invalid AU_constraint_set0_flag: " & $AU_constraint_set0_flag & " Should be 0.")
		EndIf

		local $AU_constraint_set1_flag = $tarray[2]
		;constraint_set1_flag 0 (when profile_idc is 100) and 1 (when profile_idc is 77)
		Switch Dec($AU_profile)
			Case 77
				If Dec($AU_constraint_set1_flag) == 1 Then
					AuWrite(@TAB & @TAB & @TAB & "AU_constraint_set1_flag: " & $AU_constraint_set1_flag)
				Else
					AuWrite(@TAB & @TAB & @TAB & "Invalid AU_constraint_set1_flag: " & $AU_constraint_set1_flag & " Should be 1 when profile_idc=77")
					$programExitCode = 1
				EndIf
			Case 100
				If Dec($AU_constraint_set1_flag) == 0 Then
					AuWrite(@TAB & @TAB & @TAB & "AU_constraint_set1_flag: " & $AU_constraint_set1_flag)
				Else
					AuWrite(@TAB & @TAB & @TAB & "Invalid AU_constraint_set1_flag: " & $AU_constraint_set1_flag & " Should be 0 when profile_idc=100")
					$programExitCode = 1
				EndIf
			Case Else
				AuWrite(@TAB & @TAB & @TAB & "Invalid AU_profile, 8 bits: " & $AU_profile & " -> " & Dec($AU_profile) & "Only 100 or 77.")
				$programExitCode = 1
		EndSwitch

		local $AU_constraint_set2_flag = $tarray[3]
		If Int($AU_constraint_set2_flag) == 0 Then
			AuWrite(@TAB & @TAB & @TAB & "AU_constraint_set2_flag: " & $AU_constraint_set2_flag)
		Else
			AuWrite(@TAB & @TAB & @TAB & "Invalid AU_constraint_set2_flag: " & $AU_constraint_set2_flag & " Should be 0.")
			$programExitCode = 1
		EndIf

		If Dec($AU_profile) == 100 Then
			local $AU_constraint_set3_flag = $tarray[4]
			If Dec($AU_constraint_set3_flag) == 0 Then
				AuWrite(@TAB & @TAB & @TAB & "AU_constraint_set3_flag: " & $AU_constraint_set3_flag)
			Else
				AuWrite(@TAB & @TAB & @TAB & "Invalid AU_constraint_set3_flag: " & $AU_constraint_set3_flag & " Should be 0.")
				$programExitCode = 1
			EndIf

			local $temp = _HexToBinaryString($myarray[22])
			local $tt = StringSplit($temp, "")

			local $AU_constraint_set4_flag = $tt[1]
			If Dec($AU_constraint_set4_flag) == 0 Then
				AuWrite(@TAB & @TAB & @TAB & "AU_constraint_set4_flag: " & $AU_constraint_set4_flag)
			Else
				AuWrite(@TAB & @TAB & @TAB & "Invalid AU_constraint_set4_flag: " & $AU_constraint_set4_flag & " Should be 0.")
				$programExitCode = 1
			EndIf

			local $AU_constraint_set5_flag = $tt[2]
			If Dec($AU_constraint_set5_flag) == 0 Then
				AuWrite(@TAB & @TAB & @TAB & "AU_constraint_set5_flag: " & $AU_constraint_set5_flag)
			Else
				AuWrite(@TAB & @TAB & @TAB & "Invalid AU_constraint_set5_flag: " & $AU_constraint_set5_flag & " Should be 0.")
				$programExitCode = 1
			EndIf

			local $AU_reserved_zero = $tt[3] & $tt[4]
			AuWrite(@TAB & @TAB & @TAB & "AU_reserved_zero, 2 bits: 0b" & $AU_reserved_zero)
		Else
			local $AU_AVC_compatible_flags = $tarray[4] & _HexToBinaryString($myarray[22])
			AuWrite(@TAB & @TAB & @TAB & "AU_AVC_compatible_flags, 5 bits: " & $AU_AVC_compatible_flags)
		EndIf

		local $AU_level = $myarray[23] & $myarray[24]
		AuWrite(@TAB & @TAB & @TAB & "AU_level, 8 bits: 0x" & $AU_level & " -> " & Dec($AU_level))

	EndIf
	;if (AU_trick_mode_info_present_flag == ‘1’) {
	;AU_max_I_picture_size 12 uismbf
	;AU_nominal_I_period 8 uismbf
	;AU_max_I_period 8 uismbf
	;Reserved_zero 4 '0000'18
	;Syntax No. of Bits Mnemonic
	;}
	If Dec($AU_trick_mode_info_present_flag) == 1 Then

		AuWrite(@TAB & @TAB & "AU_trick_mode_info_present_flag == 1")
		local $AU_max_I_picture_size = $myarray[25] & $myarray[26] & $myarray[27]
		AuWrite(@TAB & @TAB & @TAB & "AU_max_I_picture_size, 12 bits: 0x" & $AU_max_I_picture_size & " -> " & Dec($AU_max_I_picture_size, 2))

		local $AU_nominal_I_period = $myarray[28] & $myarray[29]
		AuWrite(@TAB & @TAB & @TAB & "AU_nominal_I_period, 8 bits: 0x" & $AU_nominal_I_period & " -> " & Dec($AU_nominal_I_period, 2))

		local $AU_max_I_period = $myarray[30] & $myarray[31]
		AuWrite(@TAB & @TAB & @TAB & "AU_max_I_period, 8 bits: 0x" & $AU_max_I_period & " -> " & Dec($AU_max_I_period, 2))

		local $Reserved_zero = _HexToBinaryString($myarray[32])
		AuWrite(@TAB & @TAB & @TAB & "Reserved_zero, 4 bits: 0b" & $Reserved_zero)
	EndIf

	;if (data parsed < data_field_length) {
	;AU_Pulldown_info_present_flag 1 bslbf
	;reserved_zero 6 ‘00’
	;AU_flags_extension_1 1 bslbf
	;}
	;if (AU_Pulldown_info_present_flag == ‘1’) {
	;reserved 4 ‘000’
	;AU_Pulldown_info 4 bslbf
	;}
	;for(i=0; i<n; i++) {
	;AU_reserved_byte 8 bslbf
	;}
	AuWrite(@TAB & @TAB & "data parsed < data_field_length")
	local $temp1 = _HexToBinaryString($myarray[33])
	local $temp1array = StringSplit($temp1, "")
	local $AU_Pulldown_info_present_flag = $temp1array[1]
	AuWrite(@TAB & @TAB & @TAB & "AU_Pulldown_info_present_flag: " & $AU_Pulldown_info_present_flag)
	local $temp2 = _HexToBinaryString($myarray[34])
	local $temp2array = StringSplit($temp2, "")
	local $Reserved_zero = $temp1array[2] & $temp1array[3] & $temp1array[4] & $temp2array[1] & $temp2array[2] & $temp2array[3]
	AuWrite(@TAB & @TAB & @TAB & "Reserved_zero, 6 bits: 0b" & $Reserved_zero)
	local $AU_flags_extension_1 = $temp2array[4]
	AuWrite(@TAB & @TAB & @TAB & "AU_flags_extension_1: " & $AU_flags_extension_1)
	If Dec($AU_Pulldown_info_present_flag) == 1 Then
		AuWrite(@TAB & @TAB & @TAB & "AU_Pulldown_info_present_flag == 1")
		local $reserved = _HexToBinaryString($myarray[35])
		AuWrite(@TAB & @TAB & @TAB & @TAB & "reserved, 4 bits: 0b" & $reserved)
		local $AU_Pulldown_info = _HexToBinaryString($myarray[36])

		local $AU_Pulldown_info_ext;
		Switch Dec($myarray[36])
			;progressive picture
			Case 0
				$AU_Pulldown_info_ext = "progressive picture"
			;top field picture
			Case 1
				$AU_Pulldown_info_ext = "top field picture"
			;bottom field picture
			Case 2
				$AU_Pulldown_info_ext = "bottom field picture"
			;reserved
			Case 3
				$AU_Pulldown_info_ext = "reserved"
			Case Else
				AuWrite(@TAB & @TAB & @TAB & "Invalid AU_Pulldown_info, 4 bits: " & $AU_Pulldown_info)
				$programExitCode = 1
		EndSwitch
		AuWrite(@TAB & @TAB & @TAB & @TAB & "AU_Pulldown_info, 4 bits: 0b" & $AU_Pulldown_info & " -> " & $AU_Pulldown_info_ext)


	EndIf


EndFunc

; Hex To Binary
Func _HexToBinaryString($HexValue)
	Local $Allowed = '0123456789ABCDEF'
	Local $Test,$n
	Local $Result = ''
	if $hexValue = '' then
	SetError(-2)
	Return
	EndIf

	$hexvalue = StringSplit($hexvalue,'')
	for $n = 1 to $hexValue[0]
	if not StringInStr($Allowed,$hexvalue[$n]) Then
	SetError(-1)
	return 0
	EndIf
	Next

	Local $bits = "0000|0001|0010|0011|0100|0101|0110|0111|1000|1001|1010|1011|1100|1101|1110|1111"
	$bits = stringsplit($bits,'|')
	for $n = 1 to $hexvalue[0]
	$Result &= $bits[Dec($hexvalue[$n])+1]
	Next

	Return $Result
EndFunc