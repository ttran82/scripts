<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "tests_reports");
  navDefine("report", "/nav_report.inc", "current", "report_index");
  crumbSet("Zodiac1.0 Test Reports");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>

<?php 
   require("${phpdir}/common.php");
   $pdir = "zodiac1.0";
   $dirname = "$qa_reportdir/$pdir";
   navInsertMarkup("report");
?>
<h4>Test Report:</h4>
<p></p>
<p></p>
<p></p>
<?php
   $table = GetFileTable($dirname);
   print ($table);
?>
<h4>Bug's Queries:</h4>
<ul>
<li><a href="http://dev/bugzilla/buglist.cgi?keywords=zodiac-1.0&amp;bug_status=NEW&amp;bug_status=ASSIGNED&amp;bug_status=REOPENED">Open Bugs</a></li>
<li><a href="http://dev/bugzilla/buglist.cgi?product=Zodiac&amp;bug_status=RESOLVED&amp;resolutions=FIXED">Fixed Bugs</a></li>
</ul>

<?php navInsertLeads("report"); ?>

<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
