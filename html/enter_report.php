<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "enter_tests_reports");
  crumbSet("Entering a new test report");
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
<form action="enter_report_action.php" method="post">
<?php 
  
  $reportdate = date('M d, Y');
  print "<p>Date: $reportdate</p>\n";
?>   
  <p>Product: 
  <select name="product">
<?php
  while($product = array_shift($qa_products)) {
    print "<option value=\"$product\">$product</option>\n";
  }
?>
  </select>
  </p>
  <p>Build #:</p>
  <p><textarea name = "buildno" rows="4" cols="80"></textarea></p>
  <p>Changes described by Engineering:</p>          
  <p><textarea name = "changes" rows="4" cols="80"></textarea></p>
  <p>Machines tested on:</p>
  <p><textarea name = "machines" rows="4" cols="80"></textarea></p>
  <p>Tests Ran and Coverage:</p>
  <p><textarea name = "coverage" rows="6" cols="80"></textarea></p>
  <p>Fixed or Features confirmed:</p>
  <p><textarea name = "fixes" rows="6" cols="80"></textarea></p>
  <p>Main issues with this build:</p>
  <p><textarea name = "issues" rows="4" cols="80"></textarea></p>
  <p>New Bugs:</p>
  <p><textarea name = "bugs" rows="6" cols="80"></textarea></p>
  <p>Submitter: 
  <select name="submitter">
  <?php
  while($member = array_shift($qa_members)) {
    print "<option value=\"$member\">$member</option>\n";
  }
  ?>
  </select>
  </p>
  <p><input type="submit" value="Submit"></input></p>
</form>
<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
