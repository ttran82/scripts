<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "tests_tools");
  crumbSet("Useful Test Tools");
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
  $flist = GetFileList($qa_toolsdir, false);
  $read_content = GetFileContents("$filename", "", true);
  while($fpath = array_shift($flist)) {
    $filename = basename($fpath);
    print "<li><a href=\"/tests/tools/$filename\" title=\"$filename\">$filename</a></li>\n";
  }
?>
</ul>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
