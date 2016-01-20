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
      $filename = date('mdY');
      print "Report name: $filename\n";
    
  $product = $_POST["product"];
  $lproduct = strtolower($product);
  $filepath = "$qa_reportdir/$lproduct/$filename";
  if (file_exists($filepath)) {
    print " is already existed, please do not try to enter again.\n";
  }
  else {
    $fd = fopen($filepath, 'w') or die("...cannot be created\n");

    $reportdate = date('M d, Y');
    fwrite($fd, "Date: $reportdate\n"); 
    //print "<p>Date: $reportdate\n";
  
    $submitter = $_POST["submitter"];
    fwrite($fd, "Submitted by: $submitter\n");

    $buildno = $_POST["buildno"];
    fwrite($fd, "\nBuild #:\n$buildno\n");
    //print "<p>$buildno\n";  

    $changes = $_POST["changes"];
    fwrite($fd, "\nChanges described by Engineering:\n$changes\n");
    //print "<p>$changes\n";

    $machines = $_POST["machines"];
    fwrite($fd, "\nMachines tested on:\n$machines\n");

    $coverage = $_POST["coverage"];
    fwrite($fd, "\nTests Ran and Coverage:\n$coverage\n");

    $fixes = $_POST["fixes"];
    fwrite($fd, "\nFixes or Features confirmed:\n$fixes\n");

    $issues = $_POST["issues"];
    fwrite($fd, "\nMain issues:\n$issues\n");

    $bugs = $_POST["bugs"];
    fwrite($fd, "\nNew Bugs:\n$bugs\n");

    fclose($fd);

    print "...has successfully saved!\n";
  }
  print "<p>Back to <a href=\"/report-${lproduct}.php\">$product</a> report page ";
?>   
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
