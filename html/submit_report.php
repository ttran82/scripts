<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "mehd_tests_reports");
  crumbSet("Latest Test Reports");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>
<pre>
<?php 
  $htmlroot = $_SERVER['DOCUMENT_ROOT'] . "/tests/reports/me6000";
  $filename = "01252006";
  echo "<h4>$filename:</h4>\n";
  $filename = "/home/ttran/html/tt";
  //echo "<h4>$filename:</h4>\n";
  //echo file_get_contents($filename);
  $file_content = fread(fopen($filename, "r"), filesize($filename)); 
  fclose($handle);
  echo $file_content;
?>
</pre>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
