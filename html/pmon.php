<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "p_monitor");
  crumbSet("Polaris QA Monitor - Update every 1 mintue");
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
<b>
<li>View: <a href="/cgi-bin/drraw.cgi?Mode=view;Graph=1154738181.25897">Current Bugs Status Chart</a> | <a href="http://dev/bugzilla/buglist.cgi?product=Polaris&amp;bug_status=NEW&amp;bug_status=ASSIGNED&amp;bug_status=REOPENED">Open Bugs</a> | <a href="http://dev/bugzilla/buglist.cgi?product=Polaris&amp;bug_status=RESOLVED&amp;resolutions=FIXED">Fixed Bugs</a></li>
</b>
<?php
  $filename = "$qa_logsdir/polarisstatus";
  $output = PrintZMonitorList($filename);
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
  $hostfile = "$qa_logsdir/polarishostname.lst";
  print privGetPriviledgesTag();
  if (privIsPriviledged()) {
    print "<li><a href=\"/process_file.php?editfile=$hostfile\" title=\"Edit File\">Edit Polaris Monitor List</a></li>\n";
    print "<li><a href=\"/cgi-bin/drraw.cgi\" title=\"Edit Bugs Chart\">Edit Polaris Bugs Chart</a></li>\n";
  }
?>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
