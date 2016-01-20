<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "test_search");
  crumbSet("MV Search Engine");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc");
      require("${phpdir}/common.php");
      $filename = date('mdY');
?>
<form action="mvsearch_action.php" method="post">
<?php 
  
  $reportdate = date('M d, Y');
  print "<p>Date: $reportdate</p>\n";
?>   
  <p>Hostname/IP:<input type="text" name = "host" value="" rows="1" cols="80"></input></p>
  <p>Login: <input type="text" name = "login" rows="1" value="root" cols="60"></input>
  Password: <input type="text" name = "password" value="password" rows="1" cols="60"></input></p>
  <p>Search Pattern: one search pattern per line</p>
  <p><textarea name = "pattern" rows="6" cols="60"></textarea></p>
  <p>Target files: one path per line</p>
  <p><textarea name = "target" rows="6" value = "/var/log/zenc" cols="60"></textarea></p>
  <p><input type="submit" value="Run"></input></p>
</form>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
