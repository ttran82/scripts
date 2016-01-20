<?php
  /*
   * Breadcrumb System - written by Van A. Boughner, February 2004,
   * www.floatingedge.com, all clients of Floating Edge, Inc.
   * are granted a non-exclusive right to use this file in any manner
   * they desire.
   *
   * Inspired by many similar designs and an example on evolt.org at
   * http://evolt.org/article/Breadcrumbs_for_PHP_Lovers/17/4455/
   *
   * This code may be freely copied and re-used by anyone, please
   * consider leaving a credit to me, since I spent a fair amount of
   * time embellishing this idea.
   *
   * Breadcrumbs are constructed by the code this way:
   *   - determine the path to the current page
   *   - remove the first part, that is identical to the document root,
   *     and replace it with the value of $crumbHome defined below,
   *     usually "Home"
   *   - strip out each directory name, in turn, and add a crumb for that
   *     directory simply using the name of the directory, but making the
   *     following substitutions:
   *       - underline characters will be replaced by spaces
   *       - the first letter of every word in the directory name will be
   *         capitalized (as long as $crumbCapitalize is set to true)
   *       - the first '++' found in each directory name will be
   *         super-scripted, by changing it to <sup>++</sup>
   *       - does special capitalization for the word PlantWise
   *   - the final crumb is specified by the document writer by
   *     making a call to crumbSet("last crumb name") at the top of
   *     of the file
   *   - if the document write does not set a final crumb, one will
   *     be contructed using the file name (with the same substitutions
   *     as directory names get), unless the filename begins with "index",
   *     in which case there will be no final crumb
   *   - the document writer can force there to be no final breadcrumb added
   *     for the file by calling crumbSet(""), creating a zero-length
   *     crumbName, this is useful for use in index files that aren't named
   *     "index_something.something" or where the directory is already
   *     represented and another crumb would be redundant
   *
   * Include this file and set the name of the crumb for the
   * current page at the top of every document, like this:
   *
   *    <?php
   *      require("${phpdir}/crumb.php");
   *      crumbSet("Press Releases");
   *    ?>
   *
   * Later in the page, you will need to make the following call to
   * include the breadcrumb in the page:
   *
   *    <?php
   *      crumbInsertMarkup();
   *    ?>
   *
   * which will insert the breadcrumb for the current page.  This call is
   * probably already included in one of the navigation templates files,
   * so you may not need to place it on every page yourself.
   *
   * Note: if you do not set the crumb for the current page with a
   * call to the crumbSet function, then crumbSetByFileName will be called
   * in order to assign one according to the file name.  It will be as if
   * you placed the following at top of the file instead:
   *
   *    <?php
   *      require("${phpdir}/crumb.php");
   *      crumbSetByFileName();
   *    ?>
   *
   * There is special code in crumbSetByFileName to handle files that
   * contain a date in their name, like this:
   *
   *    YYYY_MM_DD_anything_else.extension
   *
   * The first part of the name, before the third underline, must be formatted
   * according the year, month, and day of the file, here are some examples:
   *
   *    2004_07_19_eventA.php
   *    2003_11_01_about_eventB.htm
   *    2004_09_02_for_eventC.html
   *    2004_10_31.shtml
   *
   * Only the date will show up in the crumb, and not the entire filename,
   * and the date will be formatted MM/DD/YY.
   *
   * The simplest thing to do is to give your files meaningful names,
   * make all your index files start with "index" and leave out these
   * function calls altogether, including only this at the top of your
   * files:
   *
   *    <?php require("${phpdir}/crumb.php"); ?>
   *
   * and later:
   *
   *    <?php crumbInsertMarkup(); ?>
   */

// name of the document root directory
$crumbHome = "Home";

// separator markup to use between elements in breadcrumbs
$crumbSeparator = " > ";

// set to true if directory names should be capitalized when used as crumbs
// (if set to false, the directory names will left as-is)
$crumbCapitalize = true;

// set to true if index files should, by default, have a crumb name,
// an index is any file whose name starts with "index"
$crumbForIndexes = false;


// sets the text of the last element of the bread crumb trail
function crumbSet($name) {
  global $crumbName;
  $crumbName = htmlspecialchars($name);
}


function crumbGet() {
  global $crumbName;

  // if there is no crumb set, try to use the file name of the document
  if (!isset($crumbName)) {
    crumbSetByFileName();
  }

  return($crumbName);
}


// overrides what is considered the path of the current file, useful
// in cases where a frame that contains the crumb wraps a different file,
// must use an absolute link for best results, a relative link will work,
// if relative to the true path of the current file
function crumbOverridePath($path) {
  global $crumbPath;

  if (strlen($path) > 0) {
    if (!strcmp("/", substr($path, 0, 1))) {
      // absolute path
      $crumbPath = $path;
    }
    else {
      // relative path
      $self = $_SERVER['SCRIPT_FILENAME'];
      $root = $_SERVER['DOCUMENT_ROOT'];

      // get rid of any spurious "./"'s in the path
      $path = str_replace("/./", "/", $path);
      if (strlen($path) > 2 && !strcmp("./", substr($path, 0, 2))) {
	$path = substr($path, 2);
      }
      
      // check that $self begins with the same thing as $root, and if so,
      // remove the root section and replace it with the home directory link
      if (strlen($self) > strlen($root) &&
	  !strcmp($root, substr($self, 0, strlen($root)))) {
	$self = substr($self, strlen($root));
	$crumbPath = dirname($self) . "/" . $path;

	// when in the root directory, dirname sometimes puts on an
	// extra back-slash at the beginning
	$crumbPath = str_replace("\\/", "/", $crumbPath);
      }
      else {
	echo "Error: internal error in crumbOverridePath";
      }
    }
  }
  else {
    unset($crumbPath);
  }
}


// returns the absolute path  of the current file (or returns the override
// for the path, asjusted for the document root), the absolute path returned
// always starts with what is in the document root
function crumbGetPath() {
  global $crumbPath;

  if (isset($crumbPath) && strlen($crumbPath) > 0) {
    $retval = $_SERVER['DOCUMENT_ROOT'] . $crumbPath;
  }
  else {
    $retval = $_SERVER['SCRIPT_FILENAME'];
  }

  return($retval);
}


function crumbSmoothFileName($filename) {
  global $crumbCapitalize;

  // get ride of any remaining filename suffixes
  $filename = str_replace(".html", "", $filename);
  $filename = str_replace(".htm", "", $filename);
  $filename = str_replace(".php", "", $filename);
  $filename = str_replace(".txt", "", $filename);

  // replace underlines with spaces
  $filename = str_replace("_", " ", $filename);

  // fix special characters that require html escaping
  $filename = htmlspecialchars($filename);

  // capitalized every word
  if ($crumbCapitalize) {
    $filename = ucwords($filename);
  }

  // superscript the first ++ found
  $filename = str_replace("++", "<sup>++</sup>", $filename);

  // special capitalization for "PlantWise" and "CustomWise"
  $filename = str_replace("Plantwise", "PlantWise", $filename);
  $filename = str_replace("Customwise", "CustomWise", $filename);

  return($filename);
}


function crumbSetByFileName() {
  global $crumbName;
  global $crumbForIndexes;

  // figure out if the filename contains a date (YYYY_MM_DD) and if so,
  // use that, otherwise use the name of the file (treated like directory
  // names as far as the substitutions go)
  $filename = basename(crumbGetPath(), ".php");

  if (!$crumbForIndexes && !strcmp("index", substr($filename, 0, 5))) {
    $crumbName = "";
  }
  else {
    $pattern = "/(\d+)_(\d+)_(\d+)/i";
    $matches = array();
    $num = preg_match($pattern, $filename, $matches);
    if ($num > 0) {
      $day = $matches[3];
      if (strlen($day) == 1) {
	$day = "0" . $day;
      }
      $month = $matches[2];
      if (strlen($month) == 1) {
	$month = "0" . $month;
      }
      $year = $matches[1];
      if (strlen($year) > 2) {
	$year = substr($year, 2);
      }
      $crumbName = $month . "/" . $day . "/" . $year;
    }
    else {
      $crumbName = crumbSmoothFileName($filename);
    }
  }
}


function crumbInsertMarkup() {
  global $crumbHome;
  global $crumbName;
  global $crumbSeparator;

  // if there is no crumb set, try to use the file name of the document
  if (!isset($crumbName)) {
    crumbSetByFileName();
  }

  // get the URL and divide it into directories
  $root = $_SERVER['DOCUMENT_ROOT'];
  $self = crumbGetPath();
  $crumbs = array();
  $anchor = "/";

  // check that $self begins with the same thing as $root, and if so,
  // remove the root section and replace it with the home directory link
  if (strlen($self) > strlen($root) &&
      !strcmp($root, substr($self, 0, strlen($root)))) {
    $self = substr($self, strlen($root));
    $crumbs[count($crumbs)] =
      sprintf("<a href=\"%s\" target=\"_top\">%s</a>", $anchor, $crumbHome);
  }

  // separate all the remaining directories
  $dirs = explode("/", $self);

  // figure out if there is a zero length crumb set, i.e. whether the final
  // element of the bread crumb trail needs to be added
  $addFinalCrumb = (strlen($crumbName) > 0);

  // search for each directory in the list of anchors and
  // build up a list of anchors that should be used in the breadcrumbs,
  // skip the last, because it will be added by adding the crumb for
  // the current page
  for ($i = 0; $i < count($dirs) - 1; $i++) {
    if (strlen($dirs[$i]) > 0) {
      // build up the anchor
      $name = $dirs[$i];
      $anchor .= $name . '/';

      // replace underlines, etc. and smooth out the file name for viewing
      $name = crumbSmoothFileName($name);

      // create the anchor tag, don't make it a link if it is the
      // early final crumb because of the zero length crumbSet call
      if ($addFinalCrumb || $i < count($dirs) - 2) {
	$crumbs[count($crumbs)] =
	  sprintf("<a href=\"%s\" target=\"_top\">%s</a>", $anchor, $name);
      }
      else {
	$crumbs[count($crumbs)] =
	  sprintf("%s", $name);
      }
    }
  }
      
  // debugging
  // while ($element = each($crumbs)) {
  //   printf("crumbs['%s'] = \"%s\"<br />",
  //          $element['key'], $element['value']);
  // }

  // add the crumb for this page, the last crumb
  if ($addFinalCrumb) {
    $crumbs[count($crumbs)] = $crumbName;
  }

  // print out the markup, separating the anchors with the right string
  for ($i = 0; $i < count($crumbs); $i++) {
    printf("%s", $crumbs[$i]);
    if ($i < count($crumbs) - 1) {
      printf("%s", $crumbSeparator);
    }
  }
}
?>
