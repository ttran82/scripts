If $CmdLine[0]  = 1 Then
	$t = $CmdLine[1]
ElseIf $CmdLine[0] = 2 Then
	$t = $CmdLine[1]
	$d = $CmdLine[2]
Else
	$t = 1
EndIf

If $CmdLine[0] = 2 And StringCompare($CmdLine[2], "-d") = 0 Then;
	ProgressOn("Wait Meter", "Decrements every second", "0 percent",-1,-1,16)
	For $i = 1 to $t step 1
		sleep(1000)
		ProgressSet( $i/$t*100, $t-$i & " seconds")
	Next
	ProgressSet(100 , "Done", "Complete")
	sleep(500)
	ProgressOff()
Else
	sleep ($t * 1000)
EndIf