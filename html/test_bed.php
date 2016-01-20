<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "test_bed");
  crumbSet("QA Test Bed - IPs/Ports Assignment");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/common.php"); ?>
<?php require("${phpdir}/template/head.inc"); ?>
<?php echo gserveStatusRefreshTag(false); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>
<p></p>
<pre>
<?php
  $filename = "$qa_docsdir/testbed.txt";
  $output = GetFileContents($filename);
  print $output; 
?>
</pre>
<?php
  if (privIsPriviledged()) {
  print "<li><a href=\"/process_file.php?editfile=$filename\" title=\"Edit File\">Edit Testbed</a></li>\n";
  }
?>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
