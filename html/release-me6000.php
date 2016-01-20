<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "release_matrix");
  navDefine("release", "/nav_release.inc", "current", "release_index");
  crumbSet("ME6000 Release");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>

<?php navInsertMarkup("release"); ?>

<?php require("${phpdir}/common.php");
   $pdir = "me6000";
   $dirname = "$qa_reportdir/$pdir";
   $flist = GetFileList($dirname);
?>
<h4>Release matrix</h4>

<p>Under construction</p>

<?php navInsertLeads("release"); ?>

<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
