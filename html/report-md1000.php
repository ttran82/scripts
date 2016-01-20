<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "tests_reports");
  navDefine("report", "/nav_report.inc", "current", "report_index");
  crumbSet("MD1000 Test Reports");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>
<?php navInsertMarkup("report"); ?>
<?php require("${phpdir}/common.php");
   $pdir = "md1000";
   $dirname = "$qa_reportdir/$pdir";
?>
<h4>Test Report:</h4>
<p></p>
<p></p>
<p></p>
<?php
   $table = GetFileTable($dirname, $pdir);
   print ($table);
?>
<h4>Bug's Queries:</h4>
<ul>
<li><a href="http://dev/bugzilla/buglist.cgi?product=Firmware+Upgrade+Tools&amp;product=HD+Encoder+3U&amp;product=Internal+Tools&amp;product=Network+Management&amp;product=VAM_X&amp;product=VIM&amp;priority=P1&amp;priority=P2&amp;bug_status=RESOLVED&amp;bug_status=VERIFIED&amp;bug_status=CLOSED" title="Fixed Bugs">Fixed Bugs</a></li>
<li><a href="http://dev/bugzilla/buglist.cgi?product=Firmware+Upgrade+Tools&amp;product=HD+Encoder+3U&amp;product=Internal+Tools&amp;product=Network+Management&amp;product=VAM_X&amp;priority=P1&amp;priority=P2&amp;bug_status=UNCONFIRMED&amp;bug_status=NEW&amp;bug_status=ASSIGNED&amp;bug_status=REOPENED" title="New Bugs">New Bugs</a></li>
</ul>
<?php navInsertLeads("report"); ?>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
