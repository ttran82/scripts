#include <File.au3>

$mypath = '\\10.77.164.121\export\KleverHome\ProjectSHome\TestRuns\ME7000_1.0'
$newarray = StringSplit($mypath, '\')

MsgBox(0, "TT", $newarray[$newarray[0]])