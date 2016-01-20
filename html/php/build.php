<?php

/*
 * This file contains all of the functions required in order to create
 * a table of all of the nightly builds in a directory.  It looks at every
 * subdirectory of the build directory as an entry in the build table.
 *
 * Just call the following to put a build table in a page:
 *
 *     echo buildGetTable("build_directory_path");
 */

require_once('priv.php');
require_once('dbforms.php');

// names of files expected in each build dir (in addition to the rpms)
$commit_file = "commits.html";
$description_file = "description.txt";
$notes_file = "notes.txt";
$relnotes_file = "relnotes.txt";
$release_file = "release.txt";  // presence indicates this is a released build
$logid_file = "logid.txt";      // contains the id of a log entry for build

// location of script for placing release notes into bugzilla
$relnotes_receiver = "/home/web/tree/DevWebServer/zillacommit/relnotes_receiver.php";

// figure out how many or the most recent builds to display (0 = all)
// (there should be a session variable for this)
$row_limit = 20;    // how many rows to show in the table (0 = no limit)
$file_content_cutoff = 80;   // how many chars fit comfortably in a table cell

// standard executables needed
$gunzip_command = "/bin/gunzip";
$gzip_command = "/bin/gzip";
$tar_command = "/bin/tar";


// gets all the subdirectories of a given directory and returns an array
// of them each specified by its full path, sorted in reverse natural order
// (and since typically these directories are named by version and date, that
// gives us a most-recent first ordering, using an order that "looks natural"
// to humans, which gives the right result for release numbers)
function buildGetAllSubDirs($dir) {
  $retval = array();
  $d = opendir($dir);
  if ($d) {
    while (false !== ($f = readdir($d))) {
      if ($f != "." && $f != ".." && filetype("$dir/$f") == "dir") {
	$retval[] = "$dir/$f";
      }
    }
    closedir($d);
  }
  natsort($retval);
  $retval = array_reverse($retval);
  return($retval);
}


// massages an array of build directories, removing those that are not
// marked as releases and returns a new array, does not enforce a row limit
function buildSelectReleaseSubDirs($dirs) {
  global $release_file;

  $retval = array();
  foreach ($dirs as $value) {
    if (!preg_match("/\.(\d\d\d\d\d\d)/", $value, $matches)) {
      if (file_exists("$value/$release_file")) {
	$retval[] = $value;
      }
    }
  }
  return($retval);
}


// massages an array of build directories, removing those that do not
// fit within the current date criteria and returning a new array,
// also enforces the row limit
function buildSelectDatedSubDirs($dirs) {
  global $row_limit;
  $get_all = $_REQUEST['all'];

  // do nothing, the subdirs will already be order by most recent first
  $retval = $dirs;

  if ($row_limit != 0 && !$get_all) {
    // limits the number of table rows
    array_splice($retval, $row_limit);
  }

  return($retval);
}


// return the html for the beginning of the build table
function buildGetTableBegin($use_rpms = true, $releases_only = false) {
  $rpm_header = ($use_rpms) ? "Downloads" : "EXEs and DLLs";
  $note_header = ($releases_only) ? "" : "<th>Notes</th>";
  $retval = <<<END
<table class="status" style="clear: right;" cellspacing="0">
<tr>
<th class="first">Ver</th>
<th>Release</th>
<th>Mod</th>
<th>CVS</th>
<th>$rpm_header</th>
$note_header
<th class="edge">Actions</th>
</tr>

END;
  return($retval);
}


// return the date (extracted from the full path of the build directory)
function buildGetVersionFromPath($dir) {
  if (preg_match("/([0-9.]+)-/", $dir, $matches)) {
    return($matches[1]);
  }
  else {
    return("unk");
  }
}


// return the release (extracted from the full path of the build directory)
function buildGetReleaseFromPath($dir) {
  if (preg_match("/(\d+)\.(\d\d)(\d\d)(\d\d)/", $dir, $matches)) {
    return($matches[1] . "." . $matches[2] . $matches[3] . $matches[4]);
  }
  else if (preg_match("/-([0-9.]+)[a-zA-Z_]*$/", $dir, $matches)) {
    return($matches[1]);
  }
  else {
    return("unknown");
  }
}


// return the special extension (extracted from path of the build directory)
// of the build name that comes after the name and is all alpha characters
function buildGetSpecExtFromPath($dir) {
  if (preg_match("/\.\d\d\d\d\d\d([a-zA-Z_]+)$/", $dir, $matches)) {
    return($matches[1]);
  }
  else if (preg_match("/-[0-9.]+([a-zA-Z_]*)$/", $dir, $matches)) {
    return($matches[1]);
  }
  else {
    return("");
  }
}


// returns the package name, depending on the path
function buildGetPackageNameFromPath($dir) {
  if (strpos($dir, "encoder") !== false) {
    return("mvenc");
  }
  else if (strpos($dir, "windecoder") !== false) {
    return("windecoder");
  }
  else if (strpos($dir, "decoder") !== false) {
    return("mvdec");
  }
  else if (strpos($dir, "hdenc") !== false) {
    return("hdenc");
  }
  else if (strpos($dir, "decimg") !== false) {
    return("decimg");
  }
  else if (strpos($dir, "fw") !== false) {
    return("fw");
  }
  else {
    return("unknown");
  }
}


// returns the contents of a file, or the alternate string provided as a
// parameter if the file is not available.  When the file is large,
// includes a link for the rest of the file (unless $cutoff is false)
function buildGetFileContents($path, $alternate = "", $cutoff = true) {
  global $file_content_cutoff;
  $fh = @fopen($path, "r");
  if ($fh) {
    $size = filesize($path);
    $retval = ($size > 0) ? trim(fread($fh, $size)) : "";
    fclose($fh);
    if ($cutoff && strlen($retval) > $file_content_cutoff) {
      $link = "<a class=\"more\" href=\"" . buildGetRelativeLink($path) . "\" title=\"View the entire text\">more</a>";
      $retval = substr($retval, 0, $file_content_cutoff) . "... " . $link;
    }
    return($retval);
  }
  else {
    return($alternate);
  }
}


// gets the contents of the description file in the build dir
// if there is one
function buildGetDescription($dir) {
  global $description_file;
  return(buildGetFileContents("$dir/$description_file", "no description available", false));
}


// returns a string suitable for a relative link in the page
// by removing the server document root, or if not found, leaves it alone
function buildGetRelativeLink($path) {
  $s = $_SERVER['DOCUMENT_ROOT'] . "/";
  if (!strcmp(substr($path, 0, strlen($s)), $s)) {
    return(substr($path, strlen($s)));
  }
  else {
    return($path);
  }
}


function buildGetComponentLink($dir) {
  $relativeLink = buildGetRelativeLink($dir);
  return("<a class=\"button\" title=\"See list of individual components in this build\" href=\"?components=$relativeLink\"><img src=\"/images/components24.gif\" height=\"24\" width=\"24\" alt=\"See list of individual components in this build\" title=\"See list of individual components in this build\" /></a>");
}


// returns links to the downloadable files in the build dir
function buildGetDownloadLinks($dir, $use_rpms = true, $releases_only = false) {
  $show_debug = false;

  if (!$releases_only) {
    $pattern[] = "/(.+)-[0-9.]+-[0-9.]+[a-zA-Z_]*\.src\.rpm$/";
    $title[] = "See the RPM components of the installation package";
    $name[] = "<img src=\"/images/components24.gif\" height=\"24\" width=\"24\" alt=\"See the RPM components of the installation package\" title=\"See the RPM components of the installation package\" />";
    $special[] = "components";
  }

  $pattern[] = "/(.+)(_\d\d\d\d\d\d\.exe|\.dll$)/";
  $title[] = "Download Windows Executable or DLL";
  $name[] = "";
  $special[] = "";

  $pattern[] = "/(.+)-[0-9.]+-[0-9.]+[a-zA-Z_]*\.tar\.gz$/";
  $title[] = "Download the entire installation package";
  $name[] = "<img src=\"/images/package24.gif\" height=\"24\" width=\"24\" alt=\"Download installation package for this build\" title=\"Download installation package for this build\" />";
  $special[] = "";

  $pattern[] = "/(.+)[_\-][0-9.]+-[0-9.]+[a-zA-Z_]*\.gz$/";
  $title[] = "Download the entire disk on module file";
  $name[] = "<img src=\"/images/package24.gif\" height=\"24\" width=\"24\" alt=\"Download installation package for this build\" title=\"Download installation package for this build\" />";
  $special[] = "";

  if ($releases_only) {
    $pattern[] = "/relnotes\.txt$/";
    $title[] = "Download the release notes";
    $name[] = "<img src=\"/images/release24.gif\" height=\"24\" width=\"24\" alt=\"Download the release notes for this build\" title=\"Download the release notes for this build\" />";
    $special[] = "";
  }

  $retval = "";
  $d = opendir($dir);
  if ($d) {
    while (false !== ($f = readdir($d))) {
      if ($f != "." && $f != "..") {
	$filelist[] = $f;
      }
    }
    closedir($d);

    natsort($filelist);
    foreach ($filelist as $f) {
      for ($i = 0; $i < count($pattern); $i++) {
	if (preg_match($pattern[$i], $f, $matches)) {
	  if ($show_debug || $name[$i] != "debug") {
	    if (strlen($retval)) {
	      $retval .= " ";
	    }
	    $n = (isset($name[$i]) && strlen($name[$i]) > 0) ? $name[$i] : $matches[1];
	    if (isset($special[$i]) && strlen($special[$i]) > 0) {
	      $retval .= "<a class=\"button\" href=\"" . $_SERVER['PHP_SELF'] . "?" . $special[$i] . "=" . buildGetRelativeLink($dir) . "\" title=\"" . $title[$i] . "\">" . $n . "</a>";
	    }
	    else {
	      $retval .= "<a class=\"button\" href=\"" . buildGetRelativeLink("$dir/$f") . "\" title=\"" . $title[$i] . "\">" . $n . "</a>";
	    }
	  }
	  break;
	}
      }
    }
  }
  return($retval);
}


// returns a link to the commit file if it exists in the build dir
function buildGetDynamicChangesLink($dir, $releases_only) {
  $version = buildGetVersionFromPath($dir);
  $release = buildGetReleaseFromPath($dir);
  $mod = buildGetSpecExtFromPath($dir);
  $full_version = "$version-$release$mod";

  $package_name = buildGetPackageNameFromPath($dir);
  $releases_only = ($releases_only ? "1" : "0");
  $link = "/sources-commit-query.php?product=" . $package_name . "&releasesOnly=" . $releases_only . "&toRelease=" . $full_version;
  $link = htmlspecialchars($link);

  $retval = <<<END
<a class="button" href="$link" title="Show all cvs commits made since the last build or release"><img src="/images/wincvs24.gif" width="24" height="24" alt="Show all cvs commits made since the last build or release" title="Show all cvs commits made since the last build or release" /></a>
END;
  return($retval);
}


// returns a link to the commit file if it exists in the build dir
function buildGetStaticChangesLink($dir) {
  global $commit_file;
  $path = "$dir/$commit_file";
  if (file_exists($path)) {
    $relativeLink = buildGetRelativeLink($path);
    $retval = <<<END
<a class="button" href="$relativeLink" title="Show all cvs commits made within a week of this build"><img src="/images/wincvs24.gif" width="24" height="24" alt="Show all cvs commits made within a week of this build" title="Show all cvs commits made within a week of this build" /></a>
END;
    return($retval);
  }
  else {
    return("");
  }
}


// gets the contents of the notes file in the build dir
// if there is one
function buildGetNotes($dir) {
  global $notes_file;
  $content = buildGetFileContents("$dir/$notes_file");
  return($content);
}


// returns the id number in the build log of the build
// in the given directory, or an empty string if there isn't one
function buildGetLogId($dir) {
  global $logid_file;

  $retval = "";
  $path = "$dir/$logid_file";
  $fh = @fopen($path, "r");
  if ($fh) {
    $size = filesize($path);
    $retval = ($size > 0) ? trim(fread($fh, $size)) : "";
    fclose($fh);
  }
  return($retval);
}


// returns a string representing a link to the build log for the build
// in the given directory, or an empty string if there isn't one
function buildGetLogLink($dir) {
  $retval = "";
  $logid = buildGetLogId($dir);
  if (strlen($logid)) {
    $retval = "<a href=\"/builds-fire.php?log=$logid\">build log</a>";
  }
  return($retval);
}


function buildGetNoteEditLink($dir, $releases_only = false) {
  $relativeLink = buildGetRelativeLink($dir);
  if ($releases_only) {
    $gif_name = "edit24.gif";
    $var_name = "relnotes";
    $title = "Edit the release notes";
  }
  else {
    $gif_name = "edit24.gif";
    $var_name = "build";
    $title = "Edit the note for this build";
  }
  return("<a class=\"button\" title=\"$title\" href=\"?$var_name=$relativeLink\"><img src=\"/images/$gif_name\" height=\"24\" width=\"24\" alt=\"$title\" title=\"$title\" /></a>");
}


function buildGetBugNoteLink($dir, $releases_only = false) {
  $relativeLink = buildGetRelativeLink($dir);
  $gif_name = "bugzilla24.gif";
  $var_name = "bugnotes";
  $title = "Insert release notes into Bugzilla";
  return("<a class=\"button\" title=\"$title\" href=\"?$var_name=$relativeLink\"><img src=\"/images/$gif_name\" height=\"24\" width=\"24\" alt=\"$title\" title=\"$title\" /></a>");
}


function buildGetUnzipLink($dir, $releases_only = false) {
  $relativeLink = buildGetRelativeLink($dir);
  $gif_name = "unzip24.gif";
  $var_name = "unzip";
  $title = "Unzip installation package and insert release notes";
  return("<a class=\"button\" title=\"$title\" href=\"?$var_name=$relativeLink\"><img src=\"/images/$gif_name\" height=\"24\" width=\"24\" alt=\"$title\" title=\"$title\" /></a>");
}


// returns true if a directory refers to a release candidate build
// (one that was created without a date in the build name)
function buildIsReleaseCandidate($dir) {
  return(!(preg_match("/\.(\d\d\d\d\d\d)/", $dir, $matches)));
}


function buildGetReleaseLink($dir, $releases_only = false) {
  global $release_file;

  if (buildIsReleaseCandidate($dir)) {
    $relativeLink = buildGetRelativeLink($dir);
    $show_notransfer = $releases_only;

    // check for the situation where a build is released and we are
    // showing the build page where you may opt to un-release it
    if (!$releases_only && file_exists("$dir/$release_file")) {
      $show_notransfer = true;
    }

    if ($show_notransfer) {
      $gif_name = "notransfer24.gif";
      $var_name = "norelease";
      $title = "Remove this build from the list of released builds";
    }
    else {
      $gif_name = "transfer24.gif";
      $var_name = "release";
      $title = "Add this build to list of released builds";
    }
    return("<a class=\"button\" title=\"$title\" href=\"?$var_name=$relativeLink\"><img src=\"/images/$gif_name\" height=\"24\" width=\"24\" alt=\"$title\" title=\"$title\" /></a>");
  }
  else {
    return("");
  }
}


// return the html for all rows in the table for a directory
function buildGetTableRows($dirs, $use_rpms = true, $releases_only = false) {
  $retval = "";
  $flip = "odd";

  for ($i = 0; $i < count($dirs); $i++) {
    $version = buildGetVersionFromPath($dirs[$i]);
    $release = buildGetReleaseFromPath($dirs[$i]);
    $ext = buildGetSpecExtFromPath($dirs[$i]);
    $desc = buildGetDescription($dirs[$i]);
    $downs = buildGetDownloadLinks($dirs[$i], $use_rpms, $releases_only);
    if ("windecoder" == buildGetPackageNameFromPath($dirs[$i])) {
      $changes = buildGetStaticChangesLink($dirs[$i]);
    }
    else {
      $changes = buildGetDynamicChangesLink($dirs[$i], $releases_only);
    }
    $retval .= <<<END
<tr class="$flip">
<td class="first version" title="$desc">$version</td>
<td class="release" title="$desc">$release</td>
<td class="mod" title="$desc">$ext</td>
<td class="changes">$changes</td>
<td class="downloads">$downs</td>

END;

    if ($releases_only) {
      if (privIsPriviledged()) {
	$editlink = buildGetNoteEditLink($dirs[$i], $releases_only);
	$buglink = buildGetBugNoteLink($dirs[$i], $releases_only);
	$unziplink = buildGetUnzipLink($dirs[$i], $releases_only);
	$noreleaselink = buildGetReleaseLink($dirs[$i], $releases_only);
      }
      else {
	$editlink = privGetPriviledgesTag();
      }
      $retval .= <<<END
<td class="actions">$editlink $buglink $unziplink $noreleaselink</td>

END;
    }
    else {
      $notes = buildGetNotes($dirs[$i]);
      $notes .= " " . buildGetLogLink($dirs[$i]);
      $editlink = buildGetNoteEditLink($dirs[$i], $releases_only);
      if (privIsPriviledged()) {
	$releaselink = buildGetReleaseLink($dirs[$i], $releases_only);
      }
      else {
	$releaselink = "";
      }
      $retval .= <<<END
<td class="descrip">$notes</td>
<td class="actions">$editlink $releaselink</td>

END;

    }
    $retval .= <<<END
</tr>

END;

    $flip = ($flip == "odd") ? "even" : "odd";
  }

  return($retval);
}


// return the html for the end of the build table
function buildGetTableEnd() {
  $retval = <<<END
</table>

END;
  return($retval);
}


// return the html for the entire build table, given a directory that
// contains all of the nightly build sub directories
function buildGetTable($dir, $use_rpms = true, $releases_only = false) {
  if ($releases_only) {
    $alldirs = buildSelectReleaseSubDirs(buildGetAllSubDirs($dir));
  }
  else {
    $alldirs = buildSelectDatedSubDirs(buildGetAllSubDirs($dir));
  }

  if (count($alldirs) > 0) {
    $retval = buildGetTableBegin($use_rpms, $releases_only);
    $retval .= buildGetTableRows($alldirs, $use_rpms, $releases_only);
    $retval .= buildGetTableEnd();
    return($retval);
  }
  else {
    return("<p><b>No builds.</b></p>\n");
  }
}


// returns the html for some links to build tables that start with other
// dates besides just the most recent builds
function buildGetDateLinks($dir) {
  global $row_limit;

  $self = $_SERVER['PHP_SELF'];
  $get_all = $_REQUEST['all'];

  if ($get_all || $row_limit == 0) {
    $retval = <<<END
<p>You are viewing <b>all builds</b>.
Switch to the <a href="$self">most recent builds</a>.</p>

END;
  }
  else {
    $retval = <<<END
<p>You are viewing the <b>$row_limit most recent builds</b>.
Switch to <a href="$self?all=1">all builds</a>.</p>

END;
  }

  return($retval);
}


// returns links to all the downloadable files in one build dir
function buildGetRpmComponentLinks($dir) {
  $pattern[0] = "/(.+-[0-9.]+-[0-9.]+[a-zA-Z_]*\.debug\.i386\.rpm)/";
  $title[0] = "Download debug version of RPM file";
  $class[0] = "lowlight";
  $pattern[1] = "/(.+-[0-9.]+-[0-9.]+[a-zA-Z_]*\.i386\.rpm)/";
  $title[1] = "Download RPM file";
  $pattern[2] = "/(.+-[0-9.]+-[0-9.]+[a-zA-Z_]*\.src\.rpm)/";
  $title[2] = "Download Source Code RPM file";
  $class[2] = "lowlight";

  $retval = "<ul>\n";
  $d = opendir($dir);
  if ($d) {
    while (false !== ($f = readdir($d))) {
      if ($f != "." && $f != "..") {
	for ($i = 0; $i < count($pattern); $i++) {
	  if (preg_match($pattern[$i], $f, $matches)) {
	    $n = $matches[1];
	    $c = (isset($class[$i])) ? $class[$i] : "";
	    $retval .= "<li class=\"$c\"><a href=\"" . buildGetRelativeLink("$dir/$f") . "\" title=\"" . $title[$i] . "\">" . $n . "</a></li>\n";
	    break;
	  }
	}
      }
    }
    closedir($d);
  }
  $retval .= "</ul>\n";
  return($retval);
}


// brings up the component list page instead of the build table whenever
// the right variables have been posted to the page that a component list
// is indicated, returns an empty string if the build table should be
// shown instead
function buildGetComponentList() {
  if (isset($_REQUEST['components'])) {
    $retval = "<h4>Downloadable Build Components</h4>\n";
    $retval .="<p>The following components are downloadable from the <b>" . $_REQUEST['components'] . "</b> directory.  Note that for most upgrades you should download the installation package back on the <a href=\"" . $_SERVER['PHP_SELF'] . "\">build page</a> and use the GUI for an upgrade.  These components are meant to be used in a development environment, for creating an initial disk image, for for installation when the GUI is not available.</p>\n";
    $retval .= buildGetRpmComponentLinks($_REQUEST['components']);
    $retval .="<p>The <span class=\"lowlight\">greyed-out</span> links are the debug and src components not normally used in an installation.</p>\n";
    $retval .= "<p><a href=\"" . $_SERVER['PHP_SELF'] . "\">Return to Build Page</a></p>\n";
    return($retval);
  }
  else {
    return("");
  }
}


// brings up a page for moving the build to the release list whenever
// the right variables have been posted to the page that this is requested,
// returns an empty string if the build table should be shown instead
function buildGetBuildReleaseQuery() {
  global $release_file;

  if (isset($_REQUEST['release'])) {
    $release_wanted = true;
    $release = $_REQUEST['release'];
    $build_dir = $_SERVER['DOCUMENT_ROOT'] . "/" . $release;
    $file = $build_dir . "/" . $release_file;
    $hidden = "<input type=\"hidden\" name=\"release\" value=\"$release\" />";
    $message = "<p>Are you sure you would like to release this build?</p>";
  }
  else if (isset($_REQUEST['norelease'])) {
    $release_wanted = false;
    $norelease = $_REQUEST['norelease'];
    $build_dir = $_SERVER['DOCUMENT_ROOT'] . "/" . $norelease;
    $file = $build_dir . "/" . $release_file;
    $hidden = "<input type=\"hidden\" name=\"norelease\" value=\"$norelease\" />";
    $message = "<p>Are you sure you would like to remove this build from the release page?</p>";
  }
  else {
    return("");
  }

  if ('process' == $_REQUEST['stage']) {
    if (!isset($_REQUEST['cancel'])) {
      // save the changes to the released flag by touching or removing the file
      if ($release_wanted) {
	$old_umask = umask(0000);  // make any new file writeable to all
	touch($file);
	umask($old_umask);
      }
      else {
	unlink($file);
      }
    }
    // whenever the form has been submitted (whether to ok or cancel)
    // drop out to the build table by returning an empty string
    return("");
  }
  else {
    // present the confirmation form
    $version = buildGetVersionFromPath($build_dir);
    $release = buildGetReleaseFromPath($build_dir);
    $mod = buildGetSpecExtFromPath($build_dir);
    $retval = <<<END
<form id="wanted" name="wanted" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="stage" value="process" />
$hidden
<table class="params" cellspacing="0">
<tr>
<td>
<h4 class="notopmar">Decide Release of $version-$release$mod</h4>
$message
</td>
</tr>
<tr>
<td class="submit">
<input type="submit" name="apply" value="Ok" />
<input type="submit" name="cancel" value="Cancel" />
</td>
</tr>
</table>
</form>

END;
    return($retval);
  }
}


// moves a file to a unique 'old' name in a way that can be done many
// times and preserve all old file versions, returns the path to the old
// filename used, returns an empty string when the move could not be made
function buildMoveFileToOld($path) {
  $oldname = "";

  for ($i = 1; $i < 1000; $i++) {
    $attempt = $path . ".old" . $i;
    if (!file_exists($attempt)) {
      $oldname = $attempt;
      $cmdline = "mv $path $oldname";
      $output .= shell_exec($cmdline);
      break;
    }
  }

  return($oldname);
}


// checks to see if the unzipper page has been requested, and if so
// returns the page as a string, otherwise returns an empty string
function buildGetUnzipper() {
  global $relnotes_file, $gunzip_command, $gzip_command, $tar_command;

  if (isset($_REQUEST['unzip'])) {
    $unzip = $_REQUEST['unzip'];
    $build_dir = $_SERVER['DOCUMENT_ROOT'] . "/" . $unzip;
    $file = $build_dir . "/" . $relnotes_file;
    $hidden = "<input type=\"hidden\" name=\"unzip\" value=\"$unzip\" />";
    $rows = 20;
    $cols = 80;
  }
  else {
    return("");
  }

  if ('process' == $_REQUEST['stage']) {
    if (!isset($_REQUEST['cancel'])) {
      // find out what version of the release notes this was for
      $version = buildGetVersionFromPath($build_dir);
      $release = buildGetReleaseFromPath($build_dir);
      $mod = buildGetSpecExtFromPath($build_dir);
      $modarg = ($mod) ? "--special $mod" : "";

      // figure out what user is doing this
      $username = $_REQUEST['requestor'];
      if (!$username) {
	$username = "unknown";
      }

      // save content to temporary file
      $tmpfile = tempnam("/tmp", "unzip-");
      $content = $_REQUEST['notetext'];
      if ($fh = fopen($tmpfile, "w")) {
	fwrite($fh, $content);
	fclose($fh);

	// figure out the name of the gzipped installation file
	$gzip_filename = "";
	$pattern = "/(.+)-[0-9.]+-[0-9.]+[a-zA-Z_]*\.tar\.gz/";
	$d = opendir($build_dir);
	if ($d) {
	  while (false !== ($f = readdir($d))) {
	    if (preg_match($pattern, $f, $matches)) {
	      $package_name = $matches[1];
	      $gzip_filename = $matches[0];
	      break;
	    }
	  }
	  closedir($d);
	}

	if ($gzip_filename) {
	  $tmp_dir = $tmpfile . "-dir";
	  $tmp_gzip_filename = $tmp_dir . "/install.tar.gz";
	  $tmp_gunzip_filename = $tmp_dir . "/install.tar";
	  $tmp_upgrade_dir = $tmp_dir . "/upgrade";

	  // create tmp dirs and unzip
	  $output .= "[UNZIP] source directory is $build_dir\n";
	  $output .= "[UNZIP] creating temporary directory\n";
	  $cmdline = "mkdir $tmp_dir";
	  $output .= shell_exec($cmdline);
	  $cmdline = "mkdir $tmp_upgrade_dir";
	  $output .= shell_exec($cmdline);
	  $output .= "[UNZIP] making a copy of $gzip_filename\n";
	  $cmdline = "cp $build_dir/$gzip_filename $tmp_gzip_filename";
	  $output .= shell_exec($cmdline);
	  $output .= "[UNZIP] unzipping the copy and extracting with tar\n";
	  $cmdline = "$gunzip_command $tmp_gzip_filename";
	  $output .= shell_exec($cmdline);
	  $cmdline = "cd $tmp_upgrade_dir; $tar_command xfsp $tmp_gunzip_filename";
	  $output .= shell_exec($cmdline);

	  // insert or remove the release notes
	  if (strlen(trim($content))) {
	    $output .= "[INSERT] placing release notes into the package\n";
	    $cmdline = "cp $tmpfile $tmp_upgrade_dir/$relnotes_file";
	    $output .= shell_exec($cmdline);
	    $cmdline = "chmod 644 $tmp_upgrade_dir/$relnotes_file";
	    $output .= shell_exec($cmdline);
	  }
	  else {
	    $output .= "[REMOVE] removing release notes from the package\n";
	    $cmdline = "/bin/rm -f $tmp_upgrade_dir/$relnotes_file";
	    $output .= shell_exec($cmdline);
	  }

	  // pack up
	  $output .= "[ZIP] packing up with tar and zipping\n";
	  $cmdline = "cd $tmp_upgrade_dir; $tar_command cfsp $tmp_gunzip_filename * .??*";
	  $output .= shell_exec($cmdline);
	  $cmdline = "$gzip_command $tmp_gunzip_filename";
	  $output .= shell_exec($cmdline);
	  $output .= "[ZIP] copying new gzip file to source directory\n";

	  // move old file to a unique old name and put new file in its place
	  $old_filename = buildMoveFileToOld("$build_dir/$gzip_filename");
	  if ($old_filename) {
	    $output .= "[ZIP] moved old file out of the way to $old_filename\n";
	    $output .= "[ZIP] replacing $gzip_filename with updated version\n";
	    $cmdline = "cp $tmp_gzip_filename $build_dir/$gzip_filename";
	    $output .= shell_exec($cmdline);
	  }
	  else {
	    $output .= "[ERROR] could not move $build_dir/$gzip_filename out of the way, left it intact\n";
	    $error_occurred = true;
	  }

	  // clean up
	  $output .= "[ZIP] removing temporary directory\n";
	  $cmdline = "rm -rf $tmp_dir";
	  $output .= shell_exec($cmdline);
	  if (!$error_occurred) {
	    $output .= "[ZIP] completed the insertion successfully\n";
	  }
	  else {
	    $output .= "[ZIP] insertion not completed, an error occurred (see above)\n";
	  }
	}
	else {
	  $output .= "Unable to perform the insertion because there is no gzip file in the directory $build_dir:\n\n";
	  $cmdline = "ls $build_dir";
	  $output .= "% ls $build_dir\n";
	  $output .= shell_exec($cmdline);
	}

	$output = str_replace("\\\"", "\"", $output);  // fix quote marks
	$output = str_replace("\\'", "'", $output);  // fix single quote
	$retval = <<<END
<form id="unzip" name="unzip" method="post" action="$_SERVER[SCRIPT_NAME]">
<table class="params" cellspacing="0">
<tr>
<td>
<h4 class="notopmar">Report on Release Note Unzip and Insert for $version-$release$mod</h4>

<textarea id="notetext" class="readonly" readonly="readonly" name="notetext" cols="$cols" rows="$rows" wrap="virtual">$output</textarea>
</td>
</tr>
<tr>
<td class="submit">
<input type="submit" name="cancel" value="Return to Releases" />
</td>
</tr>
</table>
</form>

END;
      }
      else {
	$retval = "<p>An error occurred trying to write to $tmpfile</p>";
      }
      unlink($tmpfile);

      return($retval);
    }
    else {
      return("");
    }
  }
  else {
    // present the form for inserting the release notes into install pacakge
    $version = buildGetVersionFromPath($build_dir);
    $release = buildGetReleaseFromPath($build_dir);
    $mod = buildGetSpecExtFromPath($build_dir);
    $content = htmlspecialchars(buildGetFileContents($file, "", false));
    $content = str_replace("\\\"", "\"", $content);  // fix quote marks
    $content = str_replace("\\'", "'", $content);  // fix single quote

    $requestors = privGetAllLoginNames();
    $default_requestor = privGetLoginName();
    $requestor_select = dbformsGetFixedSelectOptions("requestor", $requestors, $requestors, $default_requestor);

    $retval = <<<END
<form id="unzip" name="unzip" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="stage" value="process" />
$hidden
<table class="params" cellspacing="0">
<tr>
<td>
<h4 class="notopmar">Unzip Installation Package and Insert Release Notes for $version-$release$mod</h4>

<textarea id="notetext" name="notetext" cols="$cols" rows="$rows" wrap="virtual">$content</textarea>
<br />Submitter: $requestor_select <span class="mininote">(identify yourself)</span>
</td>
</tr>
<tr>
<td class="submit">
<input type="submit" name="apply" value="Unzip, Insert, and Zip Back Up" />
<input type="submit" name="cancel" value="Cancel" />
</td>
</tr>
</table>
</form>
<p class="mininote">If you submit release
notes for the same release more than once, the later release notes will
overwrite the previous ones. The edits you make
here will not change the release notes stored on the web
site and shown here in the future, but only in the installation package.
If you leave the window
blank, any release notes currently in the installation package will be removed.
</p>

END;
    return($retval);
  }
}


// checks to see if the bug note inserter page has been requested, and
// if so returns the page as a string, otherwise returns an empty string
function buildGetBugNoteInserter() {
  global $relnotes_file, $relnotes_receiver;

  if (isset($_REQUEST['bugnotes'])) {
    $bugnotes = $_REQUEST['bugnotes'];
    $build_dir = $_SERVER['DOCUMENT_ROOT'] . "/" . $bugnotes;
    $file = $build_dir . "/" . $relnotes_file;
    $hidden = "<input type=\"hidden\" name=\"bugnotes\" value=\"$bugnotes\" />";
    $rows = 20;
    $cols = 80;
  }
  else {
    return("");
  }

  if ('process' == $_REQUEST['stage']) {
    if (!isset($_REQUEST['cancel'])) {
      // find out what version of the release notes this was for
      $version = buildGetVersionFromPath($build_dir);
      $release = buildGetReleaseFromPath($build_dir);
      $mod = buildGetSpecExtFromPath($build_dir);
      $modarg = ($mod) ? "--special $mod" : "";

      // figure out what user is doing this
      $username = $_REQUEST['requestor'];
      if (!$username) {
	$username = "unknown";
      }

      // save content to temporary file
      $tmpfile = tempnam("/tmp", "bugnotes-");
      $content = $_REQUEST['notetext'];
      if ($fh = fopen($tmpfile, "w")) {
	fwrite($fh, $content);
	fclose($fh);

	// process the notes and show the output
	$cmdline = "$relnotes_receiver --version $version --release $release $modarg --user $username < $tmpfile";
	$output = shell_exec($cmdline);
	$output = str_replace("\\\"", "\"", $output);  // fix quote marks
	$output = str_replace("\\'", "'", $output);  // fix single quote
	$retval = <<<END
<form id="bugnotes" name="bugnotes" method="post" action="$_SERVER[SCRIPT_NAME]">
<table class="params" cellspacing="0">
<tr>
<td>
<h4 class="notopmar">Report on Bugzilla Insertion for $version-$release$mod</h4>

<textarea id="notetext" class="readonly" readonly="readonly" name="notetext" cols="$cols" rows="$rows" wrap="virtual">$output</textarea>
</td>
</tr>
<tr>
<td class="submit">
<input type="submit" name="cancel" value="Return to Releases" />
</td>
</tr>
</table>
</form>

END;
      }
      else {
	$retval = "<p>An error occurred trying to write to $tmpfile</p>";
      }
      unlink($tmpfile);

      return($retval);
    }
    else {
      return("");
    }
  }
  else {
    // present the form for inserting comments into Bugzilla
    $version = buildGetVersionFromPath($build_dir);
    $release = buildGetReleaseFromPath($build_dir);
    $mod = buildGetSpecExtFromPath($build_dir);
    $content = htmlspecialchars(buildGetFileContents($file, "", false));
    $content = str_replace("\\\"", "\"", $content);  // fix quote marks
    $content = str_replace("\\'", "'", $content);  // fix single quote

    $requestors = privGetAllLoginNames();
    $default_requestor = privGetLoginName();
    $requestor_select = dbformsGetFixedSelectOptions("requestor", $requestors, $requestors, $default_requestor);

    $retval = <<<END
<form id="bugnotes" name="bugnotes" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="stage" value="process" />
$hidden
<table class="params" cellspacing="0">
<tr>
<td>
<h4 class="notopmar">Insert Release Notes into Bugzilla for $version-$release$mod</h4>

<textarea id="notetext" name="notetext" cols="$cols" rows="$rows" wrap="virtual">$content</textarea>
<br />Submitter: $requestor_select <span class="mininote">(identify yourself)</span>
</td>
</tr>
<tr>
<td class="submit">
<input type="submit" name="apply" value="Insert into Bugzilla" />
<input type="submit" name="cancel" value="Cancel" />
</td>
</tr>
</table>
</form>
<p class="mininote">It is generally a good idea to include all release notes
for each release, even if they have been inserted into Bugzilla for a previous
release.  This will insure that every release for which the bug is noted
will be recorded.  If you submit the same release
note for the same release more than once, the duplicates will be ignored.
The edits you make
here will not change the release notes themselves.  Edits here only affect what
gets noted in Bugzilla right now.
</p>

END;
    return($retval);
  }
}


// brings up the note editor page instead of the build table whenever
// the right variables have been posted to the page that a note edit
// is indicated, returns an empty string if the build table should be
// shown instead
function buildGetNoteEditor() {
  global $notes_file, $relnotes_file;

  if (isset($_REQUEST['build'])) {
    $build = $_REQUEST['build'];
    $build_dir = $_SERVER['DOCUMENT_ROOT'] . "/" . $build;
    $file = $build_dir . "/" . $notes_file;
    $what_kind = "Build Notes";
    $hidden = "<input type=\"hidden\" name=\"build\" value=\"$build\" />";
    $rows = 10;
    $cols = 52;
  }
  else if (isset($_REQUEST['relnotes'])) {
    $relnotes = $_REQUEST['relnotes'];
    $build_dir = $_SERVER['DOCUMENT_ROOT'] . "/" . $relnotes;
    $file = $build_dir . "/" . $relnotes_file;
    $what_kind = "Release Notes";
    $hidden = "<input type=\"hidden\" name=\"relnotes\" value=\"$relnotes\" />";
    $rows = 20;
    $cols = 80;
  }
  else {
    return("");
  }

  if ('process' == $_REQUEST['stage']) {
    if (!isset($_REQUEST['cancel'])) {
      // save the changes to the note text
      $notetext = $_REQUEST['notetext'];
      $notetext = str_replace("\\\"", "\"", $notetext);  // fix quote marks
      $notetext = str_replace("\\'", "'", $notetext);  // fix single quote

      // move the old notes file out of the way
      $old_filename = buildMoveFileToOld($file);
      if ($old_filename) {
	if (strlen($notetext) > 0) {
	  $old_umask = umask(0000);  // make any new notes file writeable to all
	  $fh = @fopen($file, "w");
	  if ($fh) {
	    fputs($fh, $notetext);
	    fclose($fh);
	  }
	  else {
	    echo "<p class=\"warn\">Cannot write to '" . $file . "'</p>\n";
	  }
	  umask($old_umask);
	}
	else {
	  // when notes are blank, you would erase the notes file, in this
	  // case, since the old notes files was already moved out of the
	  // way, there is no need to delete it
	}
      }
      else {
	echo "<p class=\"warn\">Cannot move old version of the file '" . $file . "' out of the way</p>\n";
      }
    }
    // whenever the form has been submitted (whether to save or cancel)
    // drop out to the build table
    return("");
  }
  else {
    // present the build note edit form
    $version = buildGetVersionFromPath($build_dir);
    $release = buildGetReleaseFromPath($build_dir);
    $mod = buildGetSpecExtFromPath($build_dir);
    $content = htmlspecialchars(buildGetFileContents($file, "", false));
    $retval = <<<END
<form id="notes" name="notes" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="stage" value="process" />
$hidden
<table class="params" cellspacing="0">
<tr>
<td>
<h4 class="notopmar">Edit $what_kind for $version-$release$mod</h4>

<textarea id="notetext" name="notetext" cols="$cols" rows="$rows" wrap="virtual">$content</textarea>
</td>
</tr>
<tr>
<td class="submit">
<input type="submit" name="apply" value="Save Changes" />
<input type="submit" name="cancel" value="Cancel" />
</td>
</tr>
</table>
</form>
<p class="mininote">The edits you make here will change the release notes
stored on this web site, and will be immediately reflected in the bugzilla
release note and installation package insertion pages when you next use them.
Make all your important
changes here, rather than in either of the release note insertion pages.
</p>

END;
    return($retval);
  }
}


// gets an alternate page than the regular build table if certain
// $_REQUEST situations are met, such as the need for the note editor, etc.
// returns an empty string when no special page is needed
function buildGetEditOrQueryPage() {
  $retval = buildGetNoteEditor();
  if (strlen($retval) == 0) {
    $retval = buildGetComponentList();
  }
  if (strlen($retval) == 0) {
    $retval = buildGetBuildReleaseQuery();
  }
  if (strlen($retval) == 0) {
    $retval = buildGetBugNoteInserter();
  }
  if (strlen($retval) == 0) {
    $retval = buildGetUnzipper();
  }
  return($retval);
}


// gets the entire build page, useful for when a note is being edited,
// assumes the caller has already checked buildGetEditorOrQueryPage and
// if that returned nothing, put up an h4 header line
function buildGetPage($dir, $use_rpms = true, $releases_only = false) {
  $retval = buildGetTable($dir, $use_rpms, $releases_only);
  if (!$releases_only) {
    $retval .= buildGetDateLinks($dir);
  }
  return($retval);
}
?>
