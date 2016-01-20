<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "main_index");
  crumbSet("QA Welcome");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>

<h4>Modulus Video QA</h4>

<p>The only place where you can find everything about
testing of Modulus Video Encoders and Decoders.
</p>
<p>
If you have any
questions or suggestions about this site, please contact <a
href="mailto:ttran@modulusvideo.com">Tuan</a>.
</p>

<h4>Other useful Links:</h4>
<ul>
<li><p><a href="http://dev/wiki/Releases">Releases Page</a></p></li>
<li><p><a href="http://dev/wiki/QA">Wiki QA Page</a></p></li>
<li><p><a href="http://dev/bugzilla/tr_edittestplans.cgi">Bugzilla Test Runner</a></p></li>
<li><p><a href="/bugzilla_changelog">Bugzilla ChangeLog Generator</a></p></li>
</ul>

<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
