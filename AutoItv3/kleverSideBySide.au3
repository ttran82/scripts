#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <KleverLib.au3>

#Autoit3Wrapper_icon=.\Graphics\sidebyside.ico

Opt("GUICloseOnESC", 0)

If isDeclared("encIp") Then
	Global $sidebysidedir=$kleverWorkingDir&"\"&$encIp
Else
	Global $sidebysidedir=$kleverWorkingDir
EndIf

main()

Func main()
	If isDeclared("leftSide") And isDeclared("rightSide") Then
		MosaicSBS($leftSide,$rightSide)
	Else
		KleverSideBySide()
	EndIf
EndFunc

Func KleverSideBySide()
Local $msgSBS,$mycommand="",$inputcheck
Local $helpinfo1 = 	"file/udp"&@crlf& _
					"1) drag and drop video files from file explorer"&@crlf& _
					"2) udp address using vlc syntax"&@crlf& _
					"	example: udp://@addr:port"&@crlf& _
					"		V"&@crlf& _
					"		V"&@crlf& _
					"		V"

Local $helpinfo2 = 	"**	Support     running in command line mode"&@crlf& _
					"	example: "&@ScriptName&' leftside="c:\file1.ts" rightside="c:\file2.ts"'&@crlf& _
					"	example: "&@ScriptName&" leftside=udp://@1.2.3.3:8433 rightside=udp://@5.6.7.8:8433 "&@crlf& _
					""

$maingui = GUICreate("Klever Side by Side", 600, 270, -1, -1, -1, $WS_EX_ACCEPTFILES)

$infoleft=GUICtrlCreateLabel($helpinfo1,10, 10,180,110)
$inputleft = GUICtrlCreateInput("",10,120, 200,20)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)

$compare = GUICtrlCreateButton("Press to Compare", 250, 120, 100, 30)

$inforight=GUICtrlCreateLabel($helpinfo1,390, 10,180,110)
$inputright = GUICtrlCreateInput("", 390,120, 200, 20)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)

$record = GUICtrlCreateButton("Press to Record", 250, 160, 100, 30)
$recordtimeinput = GUICtrlCreateInput("10", 390,160, 60, 20)
$recordunit = GUICtrlCreateLabel("Sec", 455,165,30,20)
$inforecord = GUICtrlCreateLabel("udp stream only", 390, 185, 80,20)

$extrahelp = GUICtrlCreateLabel($helpinfo2, 10, 210, 500, 80)

GUISetState(@SW_SHOW)

; Just idle around
While 1
		$msgSBS = GUIGetMsg()
		Select
		Case $msgSBS = $GUI_EVENT_CLOSE
			ExitLoop
		Case $msgSBS = $GUI_EVENT_DROPPED
			$dropfileid=@GUI_DropId
			$dragfile=@GUI_DragFile
			If $dropfileid = 3 Then
				GUICtrlSetData($inputleft,$dragfile)
			ElseIf $dragfile = 5 Then
				GUICtrlSetData($inputright,$dragfile)
			EndIf
		Case $msgSBS = $compare
			$leftSide=GUICtrlRead($inputleft)
			$rightSide=GUICtrlRead($inputright)
			MosaicSBS($leftSide,$rightSide)
		Case $msgSBS = $record
			$leftSide=GUICtrlRead($inputleft)
			$rightSide=GUICtrlRead($inputright)
			$recordtime=GUICtrlRead($recordtimeinput)

			If $recordtime="" Or $recordtime<0 Or $recordtime=0 Then
				$recordtime=10
			EndIf

			$inputcheck=""
			$inputcheck = StringInStr($leftSide, "udp://@")
			If ($inputcheck) Then
				$temp1=StringSplit(StringReplace($leftSide, "udp://@", ""), ":")
			Else
				KConsoleWrite("Please input udp ip and port"&@CRLF,1)
			EndIf

			$inputcheck=""
			$inputcheck = StringInStr($rightSide, "udp://@")
			If ($inputcheck) Then
				$temp2=StringSplit(StringReplace($rightSide, "udp://@", ""), ":")
			Else
				KConsoleWrite("Please input udp2 ip and port"&@CRLF,1)
			EndIf
			$mycommand="auto_VLC_Twin_recorder.exe udp1ip="&$temp1[1]&" udp1Port="&$temp1[2]&" udp2ip="&$temp2[1]&" udp2Port="&$temp2[2]&" captureDur="&$recordtime

			RunCommand($mycommand,$sidebysidedir,1,0)
		EndSelect
WEnd
EndFunc

Func MosaicSBS($fileleft,$fileright)
	Local $mycommand=""
	Local $klevermosaicConf=@ScriptName&".conf"
	Local $backgroundpicpath = @scriptdir&"\Graphics\background.jpg"
	FileDelete(@scriptdir&"\"&$klevermosaicConf)

	$mosaicsbsconf=KFileopen(@scriptdir&"\"&$klevermosaicConf,1)

	FileWriteLine($mosaicsbsconf,"del all")
	FileWriteLine($mosaicsbsconf,"new   bg broadcast enabled")
	FileWriteLine($mosaicsbsconf,'setup bg input "file:///' & $backgroundpicpath & '"')
	FileWriteLine($mosaicsbsconf,"setup bg option image-duration=-1")
	FileWriteLine($mosaicsbsconf,"setup bg output #transcode{sfilter=mosaic,vcodec=mp2v,vb=10000,scale=1}:bridge-in:display")

	FileWriteLine($mosaicsbsconf,"new   CH1 broadcast enabled")
	FileWriteLine($mosaicsbsconf,'setup CH1 input     "'&$fileleft&'"')
	FileWriteLine($mosaicsbsconf,"setup CH1 output #duplicate{dst=mosaic-bridge{id=1,width=720,height=480},select=video,dst=bridge-out{id=1}}")

	FileWriteLine($mosaicsbsconf,"new   CH2 broadcast enabled")
	FileWriteLine($mosaicsbsconf,'setup CH2 input     "'&$fileright&'"')
	FileWriteLine($mosaicsbsconf,"setup CH2 output #duplicate{dst=mosaic-bridge{id=2,width=720,height=480},select=video,dst=bridge-out{id=1}}")


	FileWriteLine($mosaicsbsconf,"control bg play")
	FileWriteLine($mosaicsbsconf,"control CH1 play")
	FileWriteLine($mosaicsbsconf,"control CH2 play")

	fileclose($mosaicsbsconf)

	local $mosaic_cmd_options = " --mosaic-width 1440 --mosaic-height 480"
		$mosaic_cmd_options &= " --mosaic-rows 1 --mosaic-cols 2"
		$mosaic_cmd_options &= " --mosaic-position 1"
		$mosaic_cmd_options &= " --mosaic-keep-aspect-ratio"
		$mosaic_cmd_options &= ' --mosaic-order "1,2"'

	$mycommand = "vlc --no-crashdump --color --ttl 12 --udp-caching 800 --vlm-conf "& '"' & $klevermosaicConf & '"' & $mosaic_cmd_options

	RunCommand($mycommand, @ScriptDir, 0,0)

EndFunc