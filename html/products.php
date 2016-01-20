<?php
  $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
  require("${phpdir}/template/top.inc");
  require("${phpdir}/template/includes.inc");
  navDefine("main", "/nav_main.inc", "current", "product_matrix");
  navDefine("product", "/nav_product.inc", "current", "product_index");
  crumbSet("Product Matrix");
?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
<title><?php echo crumbGet(); ?></title>
<?php require("${phpdir}/template/head.inc"); ?>
</head>
<body>
<?php require("${phpdir}/template/body.inc"); ?>

<?php navInsertMarkup("product"); ?>

<h4>Product Matrix</h4>

<p>
Under construction...
...
</p>

<?php navInsertLeads("product"); ?>

<?php require("${phpdir}/template/foot.inc"); ?>
</body>
</html>
