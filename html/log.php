<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "log");
  crumbSet("Log File");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo encoderTitleText(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>
<?php
  require("${phpdir}/log_file.inc");
  $logfile = $_POST["logfile"];
  showLog($logfile);
?>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
