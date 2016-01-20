<?php
  /*
   * One Layer Navigation System - Written by Van A. Boughner, January 2004,
   * www.floatingedge.com, all clients of Floating Edge, Inc.
   * are granted a non-exclusive right to use this file in any manner
   * they desire.
   *
   * This  navigation system allows you to create a navigation display,
   * one level deep, using whatever markup and styles you wish, as long as the
   * navigation menu markup (the common markup displayed on every page that
   * uses the navigation) is defined in its own file and uses anchor tags
   * with unique id's to list the navigation targets.
   *
   * Note: the anchor tags must not have a class attribute, as this system
   * will be adding one to the anchor tag that is currently selected, and
   * an html sytax error will result of there are two class attributes on the
   * anchor tag.
   *
   * When the navigation markup is included in a page, this system will
   * set the class on the anchor of the currently selected navigation
   * target to whatever you specified when you defined the navigation
   * system, thereby making it possible for you to visually indicate
   * where the user is located within the navigation system by setting a
   * special style for that class.
   *
   * Somewhere near the top of each page that uses this system, you will
   * need to define the navigation system and declare the id of the current
   * page (and it will have to be an id that matches one of those in
   * the navigation menu markup.)
   *
   * For example, you could define your navigation system right after
   * including the top.php file:
   *
   *    <?php
   *      $phpdir = $_SERVER['DOCUMENT_ROOT'] . "/../php";
   *      require("${phpdir}/inc/top.php");
   *      require("${phpdir}/nav.php");
   *      navDefine("faq", "/faq/nav_faq.inc", "current");
   *      navSetCurrent("faq", "faq_cost");
   *    ?>
   *
   * In the above calls to the navDefine and navSetCurrent functions:
   *
   * "faq" is the name of the navigation system (you are allowed to have
   *   more than one in use at a time, I would suggest you use different
   *   style and locations for each one in the page and keep them separate),
   *   you need to use this same name in every call with the system
   * "/faq/nav_faq.inc" is the name of the file that contains the common
   *   navigation markup, in this case it is a list of all the frequently
   *   asked questions
   * "current" is the class that will be used to mark the currently selected
   *   FAQ the visitor is viewing
   * "faq_cost" is the id of the anchor tag in the common navigation
   *   markup that corresponds to the current page, and it will be used
   *   to determine which anchor tag to make a class "current" and which
   *   nearby anchor tags are "next" and "previous" in the navigation.
   *
   * If you like, you can do it all with one call:
   *     navDefine("faq", "/faq/nav_faq.inc", "current", "faq_cost");
   *
   * Later in the page, you will need to make the following kind of call to
   * include the common navigation markup in the page:
   *
   *     navInsertMarkup("faq");
   *
   * which will insert the navigational menu markup file, "/faq/menu.inc",
   * with one of the anchor tags modified to be class "current".  If you
   * have other markup you would also to include, like "next" and "prev"
   * buttons the bottom, you can include it in the page using some php code
   * and finding out what you need to know by calling the following
   * navigation system functions:
   *
   *     $a = navPreviousAnchor("faq");
   *     $a = navNextAnchor("faq");
   *     $a = navFirstAnchor("faq");
   *     $a = navLastAnchor("faq");
   *
   * All of the above return either an empty string (if there is no such
   * anchor) or the html for the next, previous, first, or last anchors,
   * respectively, in the navigation menu (as defined in the common
   * navigation markup.)  You can use these
   * functions to build whatever customized markup you like.  The anchors
   * will be returned just as they are found in the file.
   *
   * Or you can get some standard, somewhat plain next and previous markers,
   * that will end up styled just like your typical content text (the leads
   * are placed within <p> tags), by calling this function:
   *
   *    navInsertLeads("faq");
   *
   * Here's an example of what kind of thing to put in the common
   * navigational markup file for the "faq" navigation system:
   *
   *    <div class="right">
   *      <div class="sidemenu">
   *        <h4>All the FAQs</h4>
   *        <a id="faq_index" href="index.php">What is it?</a>
   *        <a id="faq_when" href="when.php">When is it?</a>
   *        <a id="faq_cost" href="cost.php">How much does it cost?</a>
   *        <a id="faq_bring" href="bring.php">What should I bring?</a>
   *      </div>
   *    </div>
   *
   */

function navAbsToRel($filename) {
  // determine if the filename is absolute (it starts with a slash)
  if (strlen($filename) > 1 && substr($filename, 0, 1) == '/') {

    // if so, count the levels from the top that this document is and
    // manufacture a prefix for the directory name that contains enough
    // '../' sets to get to the document root.  The documentFilename always
    // contains at least one '/' and a valid token, so we skip those
    $prefix = '';
    $documentFilename = substr($_SERVER['PHP_SELF'], 1);
    $token = strtok($documentFilename, '/');
    $token = strtok('/');
    while ($token != '') {
      $prefix .= '../';
      $token = strtok('/');
    }
    return $prefix . substr($filename, 1);
  }
  else {
    // otherwise, do not change the directory name (it's already relative)
    return $filename;
  }
}

function navParseAnchors($content) {
  $pattern = "/<a[^>]+>[^<]*<\/a>/i";
  $matches = array();
  preg_match_all($pattern, $content, $matches);

  // for debugging
  // for ($i = 0; $i < count($matches[0]); $i++) {
  //   printf("navParseAnchors(%d): %s<br />", $i,
  //          htmlspecialchars($matches[0][$i]));
  //  }

  return $matches[0];
}

function navGetIdFromAnchorTag($anchor) {
  $pattern = "/ id=\"([a-zA-Z\-_]+)\"/i";
  $matches = array();
  preg_match($pattern, $anchor, $matches);

  if (count($matches) > 1) {

    // for debugging
    // printf("navGetIdFromAnchorTag: anchor is %s<br />",
    //        htmlspecialchars($anchor));
    // printf("match is: %s<br />", htmlspecialchars($matches[1]));

    return $matches[1];
  }
  else {
    return "";
  }
}

function navFindAnchorIndex($name, $currentId) {
  global $navAnchors;

  for ($i = 0; $i < count($navAnchors[$name]); $i++) {
    $id = navGetIdFromAnchorTag($navAnchors[$name][$i]);
    if (!strcmp($id, $currentId)) {
      return $i;
    }
  }

  return -1;
}

function navSetCurrent($name, $currentId) {
  global $navCommonFileName;
  global $navCurrentId;
  global $navCurrentAnchorIndex;

  // set it, but also check that currentId exists
  $navCurrentId[$name] = $currentId;
  $index = navFindAnchorIndex($name, $currentId);
  $navCurrentAnchorIndex[$name] = $index;
  if ($index == -1) {
    printf("<br /><b>Warning (from navSetCurrent)</b>: cannot find an anchor tag with id=&quot;%s&quot; in the file &quot;%s&quot;<br />", $currentId, $navCommonFileName[$name]);
  }
}

function navDefine($name, $commonFileName, $className, $currentId = "") {
  global $navCommonFileName;
  global $navCommonFileContent;
  global $navClassName;
  global $navAnchors;

  $navCommonFileName[$name] = navAbsToRel($commonFileName);
  $navClassName[$name] = $className;

  $navCommonFileContent[$name] = "";
  $file = @fopen($navCommonFileName[$name], "rb");
  if ($file) {
    while (!feof($file)) {
      $navCommonFileContent[$name] .= fread($file, 1024);
    }
    fclose($file);
    $navAnchors[$name] = navParseAnchors($navCommonFileContent[$name]);
  }
  else {
    printf("<br /><b>Error (from navDefine)</b>: cannot find file &quot;%s&quot;<br />", $navCommonFileName[$name]);
  }

  if (strlen($currentId) > 0) {
    navSetCurrent($name, $currentId);
  }
}

function navPrintVariables() {
  global $navCommonFileName;
  global $navCommonFileContent;
  global $navAnchors;
  global $navClassName;
  global $navCurrentId;
  global $navCurrentAnchorIndex;

  printf("<hr />");
  printf("<p>[navPrintVariables]<br />");
  while ($element = each($navCommonFileName)) {
    printf("navCommonFileName['%s'] = \"%s\"<br />",
           $element['key'], $element['value']);
  }
  while ($element = each($navClassName)) {
    printf("navClassName['%s'] = \"%s\"<br />",
           $element['key'], $element['value']);
  }
  while ($element = each($navCurrentId)) {
    printf("navCurrentId['%s'] = \"%s\", its index is %d<br />",
           $element['key'], $element['value'],
	   $navCurrentAnchorIndex[$element['key']]);
  }
  while ($element = each($navCommonFileContent)) {
    printf("strlen(navCommonFileContent['%s']) = %d<br />",
           $element['key'], strlen($element['value']));
  }
  while ($element = each($navAnchors)) {
    printf("count(navAnchors['%s']) = %d<br />",
           $element['key'], count($element['value']));
    for ($i = 0; $i < count($element['value']); $i++) {
      printf("navAnchors['%s'][%d] = %s<br />", $element['key'], $i,
	     htmlspecialchars($element['value'][$i]));
    }
  }
  printf("</p>");
  printf("<hr />");
}

function navInsertMarkup($name) {
  global $navCommonFileContent;
  global $navAnchors;
  global $navClassName;
  global $navCurrentId;
  global $navCurrentAnchorIndex;

  if (isset($navCommonFileContent[$name])) {
    $content = $navCommonFileContent[$name];
    $anchor = $navAnchors[$name][$navCurrentAnchorIndex[$name]];
    $newAnchor = substr($anchor, 0, 3) . "class=\"" . $navClassName[$name] .
      "\" " . substr($anchor, 3);
    $anchorIndex = strpos($content, $anchor);
    $newContent = substr_replace($content, $newAnchor, $anchorIndex,
				 strlen($anchor));
    print($newContent);
  }
}

function navPreviousAnchor($name, $currentId="") {
  global $navAnchors;
  global $navCurrentId;
  global $navCurrentAnchorIndex;

  if (strlen($currentId) == 0) {
    $index = $navCurrentAnchorIndex[$name];
  }
  else {
    $index = navFindAnchorIndex($name, $currentId);
  }

  if ($index > 0) {
    return $navAnchors[$name][$index - 1];
  }
  else {
    return "";
  }
}

function navNextAnchor($name, $currentId="") {
  global $navAnchors;
  global $navCurrentId;
  global $navCurrentAnchorIndex;

  if (strlen($currentId) == 0) {
    $index = $navCurrentAnchorIndex[$name];
  }
  else {
    $index = navFindAnchorIndex($name, $currentId);
  }

  $len = count($navAnchors[$name]);
  if ($index != -1 && $index < $len - 1) {
    return $navAnchors[$name][$index + 1];
  }
  else {
    return "";
  }
}

function navFirstAnchor($name) {
  global $navAnchors;

  $len = count($navAnchors[$name]);
  if ($len > 0) {
    return $navAnchors[$name][0];
  }
  else {
    return "";
  }
}

function navLastAnchor($name) {
  global $navAnchors;

  $len = count($navAnchors[$name]);
  if ($len > 0) {
    return $navAnchors[$name][$len - 1];
  }
  else {
    return "";
  }
}

function navInsertLeads($name) {
  global $navCommonFileContent;
  global $navAnchors;
  global $navClassName;
  global $navCurrentId;
  global $navCurrentAnchorIndex;

?>
<div class="navleads">
<?php

  $next = navNextAnchor($name);
  if (strlen($next) > 0) {
?>
<p>Next: <?php echo $next; ?></p>
<?php
  }

  $prev = navPreviousAnchor($name);
  if (strlen($prev) > 0) {
?>
<p>Previous: <?php echo $prev; ?></p>
<?php
  }

  if (strlen($next) == 0 && count($navAnchors[$name]) > 2) {
    $first = navFirstAnchor($name);
    if (strlen($first) > 0) {
?>
<p>Top: <?php echo $first; ?></p>
<?php
    }
  }
?>
</div>
<?php
}
?>
