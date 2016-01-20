<?php
  /*
  Adapted by Van A. Boughner, January 2004,
  www.floatingedge.com, all clients of Floating Edge, Inc.
  are granted a non-exclusive right to use this file in any manner
  they desire.

  This file should be included at the top of every document on the site
  by placing the following at the top:

      <?php
        $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/php";
        require("${phpdir}/template/top.inc");
      ?>

  The doctype code in this header provided courtesy of HTML Dog website at
  http://www.htmldog.com/guides/htmladvanced/declarations/

  HTML should be served by the MIME type application/xhtml+xml.
  That's what it is - an XML application. Unfortunately, most browsers
  don't have the first clue what this is. So it is generally accepted
  that it's ok to use the MIME type text/html. According to the W3C,
  and further highlighted by the Web Standards Project, flavours of
  XHTML 1.0 may be served as text/html, but XHTML 1.1 should not,
  which is why the examples across this site are XHTML 1.0 Strict,
  assuming a text/html MIME type. But you can (and perhaps should)
  serve the correct MIME type to those browsers that accept it with a
  bit of server-side fiddling.

  This site uses PHP to serve XHTML 1.1 with an application/xhtml+xml
  MIME type to those browsers that understand and render the type
  (such as Mozilla) and XHTML1.0 Strict with the text/html type to
  other browsers (such as IE). This script should be placed at the top
  of the very top of every page.

  */

  // doctype
  if(stristr($_SERVER["HTTP_ACCEPT"], "application/xhtml+xml")){
    header("Content-Type: application/xhtml+xml; charset=UTF-8");

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<?php

  }
  else {
    header("Content-Type: text/html; charset=UTF-8");

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<?php

  }
?>
