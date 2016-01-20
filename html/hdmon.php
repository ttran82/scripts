<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "hd_monitor");
  crumbSet("HD QA Monitor - Update every 1 mintue");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/common.php"); ?>
<?php require("${phpdir}/template/head.inc"); ?>
<?php print '<meta http-equiv="refresh" content="60;' . $_SERVER['PHP_SELF'] . '" />'?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>
<?php
  $filename = "$qa_logsdir/hdstatus";
  $output = PrintHDMonitorList($filename);
  print $output; 
  $modtime = @filemtime($filename);
  if ($modtime !== false) {
    $date =  strftime('%c', $modtime);
    $footer = "Last updated at $date.\n";
  }
  else {
    $footer = "";
  }
?>
<?php
  print "<p class=\"mininote\">*** WP=weighted prediction, DB=deblocking, PIP=proxy, 3:2=3:2PullDown</p>\n";
  print "<p class=\"mininote\">*** WP(WeightedBiPrediction), DB(LoopFilterAlphaC0Offset,LoopFilterBetaOffset)</p>\n";
  print "<p class=\"mininote\">*** CFCBR(1=weakest, 2=weak, 3=medium, 4=strong, 5=strongest)</p>\n";
  print "<p class=\"mininote\">$footer</p>\n";
  print "<hr></hr>\n";
  $hostfile = "$qa_logsdir/hdhostname.lst";
  if (privIsPriviledged()) {
    print "<li><a href=\"/process_file.php?editfile=$hostfile\" title=\"Edit File\">Edit HD Monitor List</a></li>\n";
  }
?>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
