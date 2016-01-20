<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "tests_plans");
  crumbSet("Current Test Documents");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>
<p></p>
<ul>
<?php 
  require("${phpdir}/common.php");
  $flist = GetFileList($qa_docsdir, false);
  $read_content = GetFileContents("$filename", "", true);
  while($fpath = array_shift($flist)) {
    $filename = basename($fpath);
    print "<li><a href=\"/tests/docs/$filename\" title=\"$filename\">$filename</a></li>\n";
  }
?>
</ul>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
