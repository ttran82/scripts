<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "main_index");
  crumbSet("File");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>
<p></p>
<?php require("${phpdir}/common.php"); ?>
<?php
  if (isset($_REQUEST['readfile'])) {
    $filename = $_GET["readfile"];
    $read_content = htmlspecialchars(GetFileContents("$filename", "", true));
    print "<pre>\n";
    if (strlen($read_content) > 0) {
      print $read_content;
    }
    print "</pre>\n";
  }
  if ('process' == $_REQUEST['stage']) {
    if (!isset($_REQUEST['cancel'])) {
      $filename = $_REQUEST['filename'];
      rename($filename, "$filename.old");
      $filetext = $_REQUEST['filetext'];
      $filetext = str_replace("\\\"", "\"", $filetext);  // fix quote marks
      $filetext = str_replace("\\'", "'", $filetext);  // fix single quote
      $filetext = str_replace("", "", $filetext);  // fix single quote
      $fh = fopen($filename, "w");
      if ($fh) {
        fputs($fh, $filetext);
        fclose($fh);
      }
      print "File modified.\n";
    }
  }
  if (isset($_REQUEST['editfile'])) {
    $filename = $_GET["editfile"];
    $filecontent = htmlspecialchars(GetFileContents($filename));
print <<<END
    <form name="files" method="post" action="$_SERVER[PHP_SELF]">
    <input type="hidden" name="stage" value="process"/>
    <input type="hidden" name="filename" value="$filename"/>
    <table class="params" cellspacing="0">
    <tr>
    <td>
    <textarea id="filetext" name="filetext" rows="40" cols="80">$filecontent</textarea>
    </td>
    </tr>
    <tr>
    <td clase="submit">
    <input type="submit" name="apply" value="Save Chages"/>
    <input type="submit" name="cancel" value="Cancel"/>
    </td>
    </tr>
    </table>
    </form>
END;
    }
?>

<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
