<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "releases_matrix");
  navDefine("release", "/nav_release.inc", "current", "release_hdencthree");
  crumbSet("Releases Matrix");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>

<?php 
  require("${phpdir}/build.php");
  $edit_page = buildGetEditOrQueryPage();
  if (strlen($edit_page) > 0) {
    echo $edit_page;
  }
  else {
    navInsertMarkup("release");
?>
<h4>HD Encoder Software for 3RU Chassis</h4>

<p>
You may download HD Encoder software for 3RU installation packages
here and install them using the <em>Versions and Upgrades</em> page
on the Encoder GUI.
</p>
<?php
  $use_rpms = true;
  $releases_only = true;
  $nightly_dir = $_SERVER['DOCUMENT_ROOT'] . "/nightly/hdenc3";
  echo buildGetPage($nightly_dir, $use_rpms, $releases_only);
?>
<ul class="icondefs">
<li>Legend:</li>
<li><img src="/images/wincvs24.gif" width="24" height="24" alt="view cvs digest" /> = view cvs digest</li>
<li><img src="/images/package24.gif" width="24" height="24" alt="download installation package" /> = download installation package</li>
<li><img src="/images/release24.gif" width="24" height="24" alt="get release notes" /> = get release notes</li>
<?php
    if (privIsPriviledged()) {
?>
<li><img src="/images/edit24.gif" width="24" height="24" alt="edit release notes" /> = edit release notes</li>
<li><img src="/images/bugzilla24.gif" width="24" height="24" alt="insert notes into bugzilla" /> = insert release notes into bugzilla</li>
<li><img src="/images/unzip24.gif" width="24" height="24" alt="unzip the install package and insert the release notes" /> = unzip install package and insert release notes</li>
<li><img src="/images/notransfer24.gif" width="24" height="24" alt="remove from release list" /> = remove from release list</li>
<?php
    }
?>
</ul>
<?php
    navInsertLeads("release");
  }
?>

<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
