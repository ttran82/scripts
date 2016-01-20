<?php
  /*
  Copyright 2004  Modulus Video, Inc.

  This file should be included in every document on the site within and
  at the bottom of the <body> section by including the following line:

      <?php require("${phpdir}/template/foot.inc"); ?>

  Note: this footer contains code at the bottom that disconnects from
  the server at the end of every page.  There is no persistent
  connection.
  */
?>

<p></p>  <!-- work-around: last element in div.boxbody cannot be a table -->
</div>  <!-- div.boxbody -->
</div>  <!-- div#contentbox -->

<div id="footer">
<p><span class="screenonly">
<a href="#top" title="Return to Top of This Page">Top</a> |
<a href="/" title="Welcome">Welcome</a> |
<a href="//europe/bugzilla" title="Bugs">Bugs</a> |
<a href="//dev/cgi-bin/viewcvs.cgi" title="CVSWeb">CVS</a> |
<a href="//europe/devwiki" title="Return to Main Development Server">Main Dev</a> |
<a href="//europe/devwiki/QA" title="Return to QA Wiki">QA Wiki</a>
<br /></span>
Company Confidential and Copyright &#169; 2004-<?php echo date('Y'); ?> Motorola, Inc.<br />
<?php echo date('g:i:s a, F jS, Y T'); ?>
<span class="screenonly"><br />
Site maintained by <a href="mailto:ttran@motorola.com">Tuan Tran</a>
</span>
</p>
<h4>
</h4>
<p class="degrade">
<!-- this text is only visible in older (Netscape 4.x) browsers -->
Please upgrade your browser.  Everything is still available and
functional, but the presentation is plainer than intended.
</p>
</div>  <!-- div#footer -->

</div>  <!-- div#content -->

