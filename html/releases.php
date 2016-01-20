<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "release_matrix");
  navDefine("release", "/nav_release.inc", "current", "release_index");
  crumbSet("Release Matrix");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>

<?php navInsertMarkup("release"); ?>

<h4>Release Matrix</h4>

<p>
This releases matrix contains default configurations, releases notes for each releases software package.
</p>

<?php navInsertLeads("release"); ?>

<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
