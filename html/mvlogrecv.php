<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "test_log");
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
<form action="mvlogrecv_action.php" method="post">
<?php 
  
  $reportdate = date('M d, Y');
  print "<p>Date: $reportdate</p>\n";
?>   
  <p>Log Multicase Address:<input type="text" name = "address" value="239.4.1.2" rows="1" cols="60"></input>
  Port:<input type="text" name = "port" value="8412" rows="1" cols="60"></input></p>
  <p>Output File:<input type="text" name = "file" value="zenc_log_enc01" rows="1" cols="80"></input></p>
  <p><input type="submit" value="Run"></input></p>
</form>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
