<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "web_info");
  crumbSet("Info");
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
<script language="JScript" type="text/jscript" runat="client">
  var WshShell = new ActiveXObject("WScript.Shell");
  WshShell.Run("c:\putty.exe");
</script>
<a href="cmdExec|c:\windows\systems32\taskmgr.exe">Run putty</a>
</ul>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
