<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "tests_reports");
  navDefine("report", "/nav_report.inc", "current", "report_index");
  crumbSet("Test Reports");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>

<?php navInsertMarkup("report"); ?>

<h4>Test Reports</h4>

<p> This page contains test reports for all current testing products.</p>
<p>
.
.
</p>

<?php navInsertLeads("report"); ?>

<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
