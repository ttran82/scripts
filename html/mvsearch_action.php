<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "enter_tests_reports");
  crumbSet("Test report submission");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc");
      require("${phpdir}/common.php");

    $script = "$qa_scriptdir/mvssh.exp";
    
    $host = $_POST["host"];
    $login = $_POST["login"];
    $password = $_POST["password"];

    $pattern = $_POST["pattern"];
    $pattern = preg_replace('/\r\n/', '|', $pattern);

    $target = $_POST["target"];
    $target = preg_replace('/\r\n/', ' ', $target);

    $grep = "grep -E \\\"$pattern\\\" $target";
    $cmd = "$script $host $login $password \"$grep\"";
    print "<p>CMD = $cmd</p>\n";

    print"<p>Output:</p>\n<pre>\n";
    exec($cmd, $output, $status);
    foreach ($output as $line) {
             preg_match('/^spawn|^root|^RSA|^Are you sure|^The authenticity|^Warning: Permanently/', $line, $matches);
             if ($matches) {
                }
             else {
                print "$line\n";
                }
             }
    print"</pre>\n";

?>   
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
