#cs
Provided Script requirement as requested by QA Team
ScriptName: auto_snmp_util.exe
Tool to automate:
	snmpget.exe -m MV-ME-ENCODER-MIB  -M "c:\program files\Kaffeine\tools\mibs" -v 2c -c public -OQs 10.77.165.22 avcBitrate.1
		List of Modulus Mibs:
			MV-ME-ENCODER-MIB (default)
			MV-CHASSIS-MIB
			MV-COMPONENT-MIB
			MV-HEARTBEAT-MIB
			MV-IDENTITY-MIB
			MV-LOGS-MIB
			MV-ME-MULTICHANNEL-MIB
			MV-ME-MUX-MIB
			MV-MUX-TRAPS-MIB
			MV-STATE-MIB
			MV-TRAP-DEBUG-MIB
			MV-TRAPS-MIB

	snmpset.exe -m MV-ME-ENCODER-MIB  -M "c:\program files\Kaffeine\tools\mibs" -v 2c -c public -OQs 10.77.165.22 avcBitrate.1 i 4000
		Types:
			i: INTEGER, u: unsigned INTEGER, t: TIMETICKS, a: IPADDRESS
			o: OBJID, s: STRING, x: HEX STRING, d: DECIMAL STRING, b: BITS
			U: unsigned int64, I: signed int64, F: float, D: double

	snmpwalk.exe -m MV-ME-ENCODER-MIB  -M ":\program files\Kaffeine\tools\mibs" -v 2c -c public -OQs 10.77.165.22 avcBitrate

Parameter requirements:
   mibCmd=snmpget deviceIp=[ip] mibName=[name] mibDir=[dir] mibParam=[oid oid ...] comparison=equal pattern=[string string ...] outputFile=[file] display=[text/number]
   mibCmd=snmpset deviceIp=[ip] mibName=[name] mibDir=[dir] mibParam=[oid type value oid type value ...] outputFile=[file] display=[text/number]
   mibCmd=snmpwalk deviceIp=[ip] mibName=[name] mibDir=[dir] mibParam=[oid] outputFile=[file] display=[text/number]

   <require argument>
   [optional argument]
Functional requirements:
	Read Tool to automate section from above
#ce

;Standard normal included definitions
;Standard Common Scripting library
#include <..\KleverLib.au3>

;Global Defintions unique to this script only

;A very detail of usage for this script.
;The requirement only give the outline.
;This usage should give a complete description of every options in the command line
;First line should give the summary of the script
;Second line should be the full @scriptname with all possible arguments available
;The rest will explains what each argument means and how to use them.
;Here is the example
$usageMsg = ""&@crlf& _
			@scriptname&@TAB&"Provide three basic snmp commands: snmpget, snmpset, and snmpwalk."&@crlf& _
			""&@crlf& _
			"Works in three mode:"&@crlf& _
			@scriptname&" snmpCmd=snmpget snmpVer=[] snmpCommunity=[] deviceIp=[ip] mibName=[name] mibDir=[dir] mibParam=[oid oid ...] Comparison=[equal] Pattern=[string string ...] outputFile=[file] display=[text/number]"&@crlf& _
			@scriptname&" snmpCmd=snmpset snmpVer=[] snmpCommunity=[] deviceIp=[ip] mibName=[name] mibDir=[dir] mibParam=[oid type value oid type value ...] outputFile=[file] display=[text/number]"&@crlf& _
			@scriptname&" snmpCmd=snmpwalk snmpVer=[] snmpCommunity=[] deviceIp=[ip] mibName=[name] mibDir=[dir] mibParam=[oid] outputFile=[file] display=[text/number]"&@crlf& _
			""&@crlf& _
			" <snmpCmd>"&@TAB&"snmpget, snmpset, or snmpwalk"&@crlf& _
			" [snmpVer]"&@TAB&"set SNMP version protocol to use.  Options: 1,2c.  Default = 2c"&@crlf& _
			" [snmpCommunity]"&@TAB&"set SNMP community string.  Default = public"&@crlf& _
			" [deviceIp]"&@TAB&"Ip address of snmp agent/host.  Default will be env{encIp}"&@crlf& _
			" [mibName]"&@TAB&"Name of device mib for query.  The following is the list of names for Encoder Family:"&@crlf& _
			@TAB&@TAB&"MV-ME-ENCODER-MIB (default)"&@crlf& _
			@TAB&@TAB&"MV-CHASSIS-MIB"&@crlf& _
			@TAB&@TAB&"MV-COMPONENT-MIB"&@crlf& _
			@TAB&@TAB&"MV-HEARTBEAT-MIB"&@crlf& _
			@TAB&@TAB&"MV-IDENTITY-MIB"&@crlf& _
			@TAB&@TAB&"MV-LOGS-MIB"&@crlf& _
			@TAB&@TAB&"MV-ME-MULTICHANNEL-MIB"&@crlf& _
			@TAB&@TAB&"MV-ME-MUX-MIB"&@crlf& _
			@TAB&@TAB&"MV-MUX-TRAPS-MIB"&@crlf& _
			@TAB&@TAB&"MV-STATE-MIB"&@crlf& _
			@TAB&@TAB&"MV-TRAP-DEBUG-MIB"&@crlf& _
			@TAB&@TAB&"MV-TRAPS-MIB"&@crlf& _
			" [mibDir]"&@TAB&@TAB&"Directory of mibs.  By default this mib dir will be currenttestscriptdir\mibs.  If it's missing, it is then point to kaffeine\tools\mibs."&@crlf& _
			" [mibParam]"&@TAB&"This is the list of paramaters that will pass onto snmp*.exe cli."&@crlf& _
			@TAB&@TAB&"For snmpget, mibParam = oid [oid]"&@crlf& _
			@TAB&@TAB&"For snmpset, mibParam = oid type value [oid type value]"&@crlf& _
			@TAB&@TAB&@TAB&"Types:"&@crlf& _
			@TAB&@TAB&@TAB&"i: INTEGER, u: unsigned INTEGER, t: TIMETICKS, a: IPADDRESS"&@crlf& _
			@TAB&@TAB&@TAB&"o: OBJID, s: STRING, x: HEX STRING, d: DECIMAL STRING, b: BITS"&@crlf& _
			@TAB&@TAB&@TAB&"U: unsigned int64, I: signed int64, F: float, D: double"&@crlf& _
			@TAB&@TAB&"For snmpwalk, mibParam = oid"&@crlf& _
			" [Comparison]"&@TAB&"only valid when running with snmpget.  Options: equal,lessthan,greater"&@crlf& _
			" [Pattern]"&@TAB&@TAB&"only valid when running with snmpget.  Options: string/number to compare to"&@crlf& _
			" [outputFile]"&@TAB&"Default to " & @ScriptName & ".out" &@crlf& _
			" [displayOption]"&@TAB&@TAB&"Display mib value as string or numerically.  Options: text/number.  Default=string" & @ScriptName & ".out" &@crlf& _
			""

;Main Flow of the program
;Everything starts here

;This CheckArguments functions is where you determine if those parsed arguments satisfy your input and output requirements
CheckArguments()

;Program Start
ProgramStart()

;Your main program
main()

;Program End
ProgramEnd()

func main()
	Global $cmd = eval("snmpcmd") & " -m " & EnvGet("mibName") & " -M " & Chr(34) & eval("mibDir") & Chr(34) & " -v " & EnvGet("snmpVer") & " -c "& EnvGet("snmpCommunity") & " -OQs" & eval("display") & " " & eval("deviceIp") & " " & eval("mibParam") & " >" &eval("outputFile") & " 2>&1"
	KConsoleWrite($cmd,0,2)

	Switch eval("snmpCmd")
	Case "snmpget"
		snmpget()
	Case "snmpset"
		snmpset()
	Case "snmpwalk"
		snmpwalk()
	Case Else
		KConsoleWrite("Invalid snmpCmd option: "&eval("snmpCmd"),1)
	EndSwitch

EndFunc


Func CheckArguments()
	;This check is standard.  Do not change
	if isDeclared ("usage") Then
		;this is the only time you will use consolewrite.  After Programe start, use Kconsolewrite will write to log
		;this is for klever GUI script display function use
		consoleWrite($usageMsg)
		Exit
	EndIf
	;This is your check.  Any arguments that you needed for your program to run
	if not isDeclared("snmpCmd")  Then
		KConsoleWrite("Missing Parameters: snmpCmd",1)
	EndIf
	CheckCommand(eval("snmpCmd"))

	if EnvGet("snmpVer")=""  Then
		AssignVariable("snmpVer", "2c")
	EndIf

	if EnvGet("snmpCommunity")=""  Then
		AssignVariable("snmpCommunity", "public")
	EndIf

	If not isDeclared("deviceIp") Then
		Assign("deviceIp", EnvGet("encIp"), 2)
		If Eval("deviceIp") = "" Then
			KConsoleWrite("Parameter not found: deviceIp",1)
		EndIf
	EndIf

	if EnvGet("mibName")="" Then
		AssignVariable("mibName", "MV-ME-ENCODER-MIB")
	EndIf

	if EnvGet("mibDir")="" Then
		if FileExists($kleverTestScriptsDir & "\mibs") Then
			Assign("mibDir", $kleverTestScriptsDir & "\mibs", 2)
		Else
			Assign("mibDir", $kleverCommonScriptsDir & "\mibs", 2)
		EndIf
	EndIf

	if not isDeclared("outputFile") Then
		Assign("outputFile", @scriptname&"_"&Eval("snmpCmd")&".out", 2)
	EndIf

	;Handle the way mib values get to display as text or numerically
	if not isDeclared("display") Then
		Assign("display", "", 2)
	EndIf
	if eval("display") = "number" Then
		Assign("display", "e", 2)
	EndIf
	if eval("display") = "number" Then
		Assign("display", "", 2)
	EndIf

EndFunc

Func snmpget()
	;snmpget.exe -m MV-ME-ENCODER-MIB  -M "c:\program files\Kaffeine\tools\mibs" -v 2c -c public -OQs 10.77.165.22 avcBitrate.1
	KConsoleWrite($cmd,0,2)
	RunCommand($cmd, @WorkingDir)
	;send output to log
	KFileWriteToLog($kleverCurrentDir&"\"&Eval("outputFile"),2)
	;Handle comparison pat
	If IsDeclared("Comparison") Then
		If not IsDeclared("Pattern") Then
			KConsoleWrite("Comparison is declared without Pattern",1)
		EndIf

		;parse mibParam, Pattern for comparison
		local $mibParamArray = Stringsplit(eval("mibParam"), " ")
		local $patternArray = Stringsplit(eval("Pattern"), " ")

		;check if the number of get values equal to number of items in comparison
		If $mibParamArray[0] <> $patternArray[0] Then
			KConsoleWrite("Number of items in Pattern is not the same as the number of items in mibParam",1)
		EndIf

		;Read in get output
		local $valueArray = KFileReadToArray($kleverCurrentDir&"\"&Eval("outputFile"))
		If $valueArray[0] <> $patternArray[0] Then
			KConsoleWrite("Number of items in outputfile is not the same as the number of items in mibParam",1)
		EndIf

		For $arrayIndex=1 to $patternArray[0]
			;First strip any white spaces
			$valueArray[$arrayIndex] = StringStripWS($valueArray[$arrayIndex], 8)

			local $mibLine = StringSplit($valueArray[$arrayIndex], "=")

			local $result = "Failed"

			Switch eval("Comparison")
				Case "equal"
					if $mibLine[2] = $patternArray[$arrayIndex] Then
						$result = "Passed"
					Else
						$programExitCode=1
					EndIf
				Case "lessthan"
					if int($mibLine[2]) < int($patternArray[$arrayIndex]) Then
						$result = "Passed"
					Else
						$programExitCode=1
					EndIf
				Case "greater"
					if int($mibLine[2]) > int($patternArray[$arrayIndex]) Then
						$result = "Passed"
					Else
						$programExitCode=1
					EndIf
				Case Else
					KConsoleWrite("Invalid Compare option: "&eval("Compare"),1)
			EndSwitch

			KConsoleWrite("Expecting " & $mibLine[1] & " " & Chr(34) & eval("Comparison") & Chr(34) & " " & $patternArray[$arrayIndex] & ".  Returned value: " &$mibLine[2] & ".  Result = " & $result , 0 )

		Next

	EndIf
EndFunc

Func snmpset()
	;KConsoleWrite($cmd,0)
	;snmpset.exe -m MV-ME-ENCODER-MIB  -M "c:\program files\Kaffeine\tools\mibs" -v 2c -c public -OQs 10.77.165.22 avcBitrate.1 i 4000
	RunCommand($cmd, @WorkingDir)

	KFileWriteToLog($kleverCurrentDir&"\"&Eval("outputFile"), 2)

EndFunc

Func snmpwalk()
	;KConsoleWrite($cmd, 2))
	;snmpwalk.exe -m MV-ME-ENCODER-MIB  -M ":\program files\Kaffeine\tools\mibs" -v 2c -c public -OQs 10.77.165.22 avcBitrate
	RunCommand($cmd, @WorkingDir)
	;send output to log
	KFileWriteToLog($kleverCurrentDir&"\"&Eval("outputFile"), 2)
EndFunc
