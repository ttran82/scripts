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
<?php require("${phpdir}/common.php"); ?>
<?php require("${phpdir}/template/head.inc"); ?>
<?php print '<meta http-equiv="refresh" content="60;' . $_SERVER['PHP_SELF'] . '" />'?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>
<?php
  $script = "$qa_scriptdir/mvssh.exp";
  $dir = "$qa_searchdir";
  $d = opendir($dir);

  print "<table class=\"status\" style=\"clear: right;\" cellspacing=\"0\">";
  print "<tr>\n";
  print "<th>Search Name</th>\n";
  print "<th>Description</th>\n";
  print "</tr>\n";

  if ($d) {
    while (false !== ($f = readdir($d))) {
      if ($f != "." && $f != ".." && filetype("$dir/$f") == "dir") {
        print"<td>$f</td>\n";
        $read_content = GetFileContents("$dir/$f/description", "", true);
        print"<td>$read_content</td>\n";
      }
    }
    closedir($d);
  }

  print"</table>\n";

?>
<?php
  print "<p class=\"mininote\">*** Usage: To start a search, select your Search Name from table above.</p>\n";
  print "<hr></hr>\n";
?>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
