<?php
  /*
  Copyright 2004  Modulus Video, Inc.

  This file should be included in every document on the site within and
  at the top of the <body> section by including the following line:

      <?php require("${phpdir}/template/body.inc"); ?>
  */
?>
<a id="top"></a>

<div id="leftside">
<?php navInsertMarkup("main"); ?>
</div>  <!-- div#leftside -->

<div id="logo"><a href="http://www.motorola.com/"><img src="/images/motorola_logo.gif" width="228" height="48" alt="Motorola" title="Motorola" /></a></div>

<div id="content">
<div id="contentbox" class="boxouter">
<div class="boxtop"><h2><?php echo crumbGet(); ?></h2></div>
<div class="boxbody">

