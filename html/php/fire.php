<?php
/*
 * Routines for firing off an internal build for Modulus Video software
 * that is accessible via a web-based user interface.
 *
 * Copyright (C) 2004 Modulus Video, Inc.  All Rights Reserved.
 */

require_once('priv.php');
require_once('dbforms.php');

// database information
$db_host = "localhost";
$db_user = "fire";
$db_pass = "mvfire";
$db_name = "buildfire";

// database connection results
$db = null;
$db_error = "";

// version number for this software
$fire_version = "1.0";

// common strings
$html_blank_name = "<p class=\"warn bottomrule\">Please enter a name.</p>";
$html_blank_package_name = "<p class=\"warn bottomrule\">Please enter a package name.</p>";
$html_dup_name = "<p class=\"warn bottomrule\">That name is already in use, please try a different name.</p>";

// location directories already-built builds, from document root
$build_dir = "nightly";
$package_product_subdir = array("mvenc" => "encoder",
				"mvdec" => "decoder");
// one of these will be in successful build dir
$build_success_filenames = array("commits.html", "logid.txt");



/* ---------------- Database Creation and Connection ---------------- */


// check for the existence of all the fire tables, and create
// them if necessary, fireConnect does this once every time
// you connect, returns true if everything is ok
//
// in order to get the log working properly, it was necessary to increase
// the mysql daemon's maximum allowable packet size from 1M to 16M, because
// sometimes the text output from builds goes over 1M in size, and it could not
// be stored in the log when it was too big.  To fix this, I copied
// /usr/local/mysql/support-files/my-large.cnf to /usr/local/mysql/data/my.cnf
// and edited the max_allowed_packet line in my.cnf to look like this:
//     max_allowed_packet = 16M
// and then I restarted mysqld by running these in the support-files dir:
//     mysql.server stop
//     mysql.server start
//
// schema for the buildfire database:
//  'target' table defines each of the different products you can build, there
//  is a separate row in the table for every version of a target thatc can be
//  built:
//      id: unique id number of target
//      name: name of the target (e.g. ME1000 AVC Encoder Software)
//      kernel_name: output of "uname -r" on system (e.g. 2.6.11-bigphys)
//      package_name: package name for the target (e.g. mvenc)
//      description: description of the target
//      version_number: which version is currently under development
//      release_number: which release is currently under development
//          (can be left blank to build whichever is next default)
//      cvs_branch: which branch to build (or possibly, an old tag, null is ok)
//      allow_release_builds_checkbox: true if release candidates allowed
//      allow_dev_builds_checkbox: true if dev builds are allowed
//      pre_cmdline: a command line containing things like environment variable
//           settings that should be executed before the build begins
//           using the platform's cmdline
//
//  'platform' table defines each of the build platforms available, and there
//  is a separate row in this table for each package that can be built there,
//  even if they are on the same machine.  Targets and platforms are matched
//  by using the package_name field:
//      id: unique id number of the build platform
//      name: name of the build machine (human-readable)
//      kernel_name: output of "uname -r" on system (e.g. 2.6.11-bigphys)
//      package_name: package name for the targets built here (e.g. mvenc)
//      description: description of the build machine
//      hostname: hostname or IP address of the build machine
//      login: login for the user under which builds are made
//      cmdline: the command line for a basic build of the target here
//      is_default_checkbox: true if this platform is preferred
//
// 'log' table contains one row for each build that has ever been requested,
//  some of the fields are copied from the target and platform tables at the
//  time of the built because a record of this build needs to be kept, even if
//  the target and platform later get updated:
//      id: unique id number of the log entry
//      kernel_name: output of "uname -r" on system (e.g. 2.6.11-bigphys)
//      package_name: package name for the target and platform (e.g. mvenc)
//      target_name: name of the target that was built
//      target_description: description of the target that was built
//      target_version_number: version number that was built
//      target_release_number: release number that was built
//      target_pre_cmdline: command line that executed before the build began
//           using the platform_cmdline
//      platform_name: name of the platform that handled the build
//      platform_descriiption: description of the platform that handled it
//      platform_hostname: hostname or IP address of the build machine
//      platform_login: login for the user that made the build
//      platform_cmdline: command line used to make the build
//      requestor: username of the person who requested the build (for email)
//      build_note: a note by the requestor about why the build was made
//      is_released_checkbox: is true if this was a release candidate build
//      request_date: date and time that the build was ordered
//      start_date: date and time that the build was begin at the build machine
//      end_date: date and time that the build finished (successful or not)
//      error_code: is 0 if the build was successful
//      output: textual output of the build process
//
function fireCheckAllTables() {
  global $db, $db_error;

  if ($db) {
    $retval = true;
    $result = mysql_query("SHOW TABLES", $db);
    $num = mysql_num_rows($result);
    $tables = array();
    for ($i = 0; $i < $num; $i++) {
      $tables[$i] = mysql_result($result, $i);
    }
    if (!in_array("target", $tables)) {
      $query = <<<END
CREATE TABLE target (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  kernel_name VARCHAR(100) DEFAULT NULL,
  package_name VARCHAR(100) NOT NULL,
  version_number VARCHAR(50) NOT NULL,
  release_number VARCHAR(50),
  cvs_branch VARCHAR(100),
  allow_release_builds_checkbox TINYINT(1) NOT NULL DEFAULT 1,
  allow_dev_builds_checkbox TINYINT(1) NOT NULL DEFAULT 1,
  pre_cmdline VARCHAR(255)
) COMMENT = 'each different product and version of product you can build';
END;
      $result = mysql_query($query, $db);
      if (!$result) {
	echo mysql_error();
      }
    }
    if (!in_array("platform", $tables)) {
      $query = <<<END
CREATE TABLE platform (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255),
  kernel_name VARCHAR(100) DEFAULT NULL,
  package_name VARCHAR(100) NOT NULL,
  hostname VARCHAR(50) NOT NULL,
  login VARCHAR(50) NOT NULL,
  cmdline VARCHAR(255) NOT NULL,
  is_default_checkbox TINYINT(1) NOT NULL DEFAULT 0
) COMMENT = 'each of the build platforms available';
END;
      $result = mysql_query($query, $db);
      if (!$result) {
	echo mysql_error();
      }
    }
    if (!in_array("log", $tables)) {
      $query = <<<END
CREATE TABLE log (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  kernel_name VARCHAR(100) DEFAULT NULL,
  package_name VARCHAR(100) NOT NULL,
  target_name VARCHAR(100) NOT NULL,
  target_description VARCHAR(255),
  target_version_number VARCHAR(50) NOT NULL,
  target_release_number VARCHAR(50) NOT NULL,
  target_cvs_branch VARCHAR(100), 
  target_pre_cmdline VARCHAR(255),
  platform_name VARCHAR(100) NOT NULL,
  platform_description VARCHAR(255),
  platform_hostname VARCHAR(50) NOT NULL,
  platform_login VARCHAR(50) NOT NULL,
  platform_cmdline VARCHAR(255) NOT NULL,
  mod_name VARCHAR(50),
  requestor VARCHAR(50),
  build_note VARCHAR(255),
  is_released_checkbox TINYINT(1) NOT NULL,
  request_date DATETIME,
  start_date DATETIME,
  end_date DATETIME,
  error_code INT,
  output LONGTEXT
) COMMENT = 'a record of every build requested';
END;
      $result = mysql_query($query, $db);
      if (!$result) {
	echo mysql_error();
      }
    }
  }
  else {
    $retval = false;
  }

  return($retval);
}


// connect to the database and insure that everything is ready,
// returns true if a connection could be made, can be called multiple times
function fireConnect() {
  global $db, $db_host, $db_user, $db_pass, $db_name, $db_error;

  if ($db) {
    return(true);
  }
  else {
    $db = @mysql_connect($db_host, $db_user, $db_pass);
    if ($db) {
      if (@mysql_select_db($db_name, $db)) {
	$db_error = "";
	return(fireCheckAllTables());
      }
      else {
	$db_error = mysql_error();
	fireDisconnect();
	return(false);
      }
    }
    else {
      $db_error = mysql_error();
      return(false);
    }
  }
}


// prints a message when a page cannot work (because there is
// no database connection)
function fireOutputNoConnection() {
  global $db_host, $db_user, $db_name, $db_error;

  print <<<END
<p class="minierror">
Warning: You cannot make a connection to the <strong>$db_name</strong>
database on <strong>$db_host</strong> with user <strong>$db_user</strong>.
The mysql error message was: &quot;$db_error&quot;.
</p>

END;
}


// disconnect from the database
function fireDisconnect() {
  global $db;

  if ($db) {
    @mysql_close($db);
    $db = null;
  }
}


/* ---------------- Form Display and Processing --------------------- */


function fireGetIntro() {
  $retval = <<<END
<h4>Edit Targets and Platforms</h4>
<p>
Here you may edit the available build targets and platforms available when you 
<a href="builds-fire.php">fire off a build</a>.
Please do not alter these targets or platforms unless you understand the
ramifications.  Understand the <a href="builds-fire-info.php">build
instructions</a> and <a href="versioning.php">version numbering</a>
first.
</p>

END;

  $retval .= fireGetTargetTable();
  $retval .= "<br />\n";
  $retval .= fireGetPlatformTable();

  $retval .= <<<END
<div class="navleads">
<p>Add: <a href="?target=add">New Target</a></p>
<p>Add: <a href="?platform=add">New Platform</a></p>
<p>Return to: <a href="/builds-fire.php">Fire Off a Build</a></p>
</div>

END;

  return($retval);
}


// get a string containing the html for a table of the targets
function fireGetTargetTable($header = "Targets") {
  global $db;

  $table_name = "target";
  $query = "SELECT * FROM $table_name ORDER BY package_name,kernel_name,version_number DESC,name";
  $db_columns = array("name", "kernel_name", "package_name", "version_number", "cvs_branch");
  $table_columns = array("Name", "Kernel", "Package", "Version", "Tag/Branch");
  $retval = "<h4>$header</h4>";
  $retval .= dbformsGetTable($db, $table_name, $query, $db_columns, $table_columns);
  return($retval);
}


// get a string containing the html for a table of the targets
function fireGetPlatformTable() {
  global $db;

  $table_name = "platform";
  $query = "SELECT * FROM $table_name ORDER BY package_name,kernel_name,name";
  $db_columns = array("name", "kernel_name", "package_name", "hostname", "cmdline");
  $table_columns = array("Name", "Kernel", "Package", "Hostname", "Cmdline");
  $retval = "<h4>Platforms</h4>";
  $retval .= dbformsGetTable($db, $table_name, $query, $db_columns, $table_columns);
  return($retval);
}


// get a string containing the html for a table of the targets
// when how_much is "all", what you get is actually limited to a reasonable
// number, when it is "every", you get them all back to the beginning of time
function fireGetLogTable($how_much = "all") {
  global $db;

  $table_name = "log";
  if ($how_much == "every") {
    $query = "SELECT * FROM $table_name ORDER BY request_date DESC";
  }
  else {
    $query = "SELECT * FROM $table_name ORDER BY request_date DESC LIMIT 15";
  }
  $db_columns = array("target_name", "requestor", "request_date", "start_date", "end_date", "error_code");
  $table_columns = array("Target", "Requestor", "Requested", "Started", "Finished", "Error");
  $retval = "<h4>Build Log</h4>";
  $retval .= dbformsGetTable($db, $table_name, $query, $db_columns, $table_columns, "log");
  $retval .= "<p>Return to: <a href=\"" . $_SERVER['PHP_SELF']  . "\">Fire Off a Build</a></p>\n";
  return($retval);
}


// show a form you can use to edit build targets, $id is "add" if the
// form is supposed to be for adding
function fireGetTargetForm($id, $post = null) {
  global $db;

  if ($post) {
    $name = $post['name'];
    $kernel_name = $post['kernel_name'];
    $package_name = $post['package_name'];
    $description = $post['description'];
    $version_number = $post['version_number'];
    $release_number = $post['release_number'];
    $cvs_branch = $post['cvs_branch'];
    $allow_release_builds_checkbox = $post['allow_release_builds_checkbox'];
    $allow_dev_builds_checkbox = $post['allow_dev_builds_checkbox'];
    $pre_cmdline = $post['pre_cmdline'];
  }
  else if ($id != "add") {
    $query = "SELECT * FROM target WHERE id = $id";
    $result = mysql_query($query, $db);
    if ($result) {
      $row = mysql_fetch_array($result);
      $name = stripslashes($row['name']);
      $kernel_name = stripslashes($row['kernel_name']);
      $package_name = stripslashes($row['package_name']);
      $description = stripslashes($row['description']);
      $version_number = stripslashes($row['version_number']);
      $release_number = stripslashes($row['release_number']);
      $cvs_branch = stripslashes($row['cvs_branch']);
      $allow_release_builds_checkbox = stripslashes($row['allow_release_builds_checkbox']);
      $allow_dev_builds_checkbox = stripslashes($row['allow_dev_builds_checkbox']);
      $pre_cmdline = stripslashes($row['pre_cmdline']);
    }
  }

  if ($id == "add") {
    $retval = "<h4>Add Target</h4>";
    $delete_button = "";
  }
  else {
    $retval = "<h4>Edit Target</h4>";
    $delete_button = "<input type=\"submit\" name=\"delete\" value=\"Delete\" />\n";
  }

  $allow_release_builds_select =
    dbformsGetFixedSelectOptions("allow_release_builds_checkbox",
				 array("0", "1"), array("no", "yes"),
				 $allow_release_builds_checkbox);

  $allow_dev_builds_select =
    dbformsGetFixedSelectOptions("allow_dev_builds_checkbox",
				 array("0", "1"), array("no", "yes"),
				 $allow_dev_builds_checkbox);


  $retval .= <<<ENDFORM
<form id="target_form" name="target_form" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="stage" value="process" />
<input type="hidden" name="target" value="$id" />
<table class="params" cellspacing="0">
<tr><td>Product Name</td><td><input type="text" name="name" size="40" maxlength="95" value="$name" /></td></tr>
<tr><td>Description</td><td><input type="text" name="description" size="60" maxlength="250" value="$description" /></td></tr>
<tr><td>Kernel Name</td><td><input type="text" name="kernel_name" size="20" maxlength="95" value="$kernel_name" /> <span class="mininote">(e.g. 2.6.11-bigphys)</span></td></tr>
<tr><td>Package Name</td><td><input type="text" name="package_name" size="20" maxlength="95" value="$package_name" /> <span class="mininote">(e.g. mvenc or mvdec)</span></td></tr>
<tr><td>Version Number</td><td><input type="text" name="version_number" size="10" maxlength="45" value="$version_number" /> <span class="mininote">(e.g. 1.0)</span></td></tr>
<tr><td>Release Number</td><td><input type="text" name="release_number" size="10" maxlength="45" value="$release_number" /> <span class="mininote">(e.g. 1, blank means to use the next available)</span></td></tr>
<tr><td>CVS Tag/Branch</td><td><input type="text" name="cvs_branch" size="20" maxlength="95" value="$cvs_branch" /> <span class="mininote">(leave blank to use cvs trunk)</span></td></tr>
<tr><td>Prep Cmdline</td><td><input type="text" name="pre_cmdline" size="25" maxlength="250" value="$pre_cmdline" /> <span class="mininote">(runs before the build begins)</span></td></tr>
<tr><td>Allow Dev Builds</td><td>$allow_dev_builds_select <span class="mininote">(allow new builds to be posted as development builds)</span></td></tr>
<tr><td>Allow Releases</td><td>$allow_release_builds_select <span class="mininote">(allow new builds to be posted as release candidates)</span></td></tr>
<tr><td class="submit" colspan="2">
<input type="submit" name="apply" value="Save Changes" />
$delete_button<input type="submit" name="cancel" value="Cancel" />
</td></tr>
</table>
</form>
<p class="mininote">
Note: the package name listed for a target must match the package name listed
for one of the platforms or there will be nowhere this target can be built.
Note that all command lines should be designed for tcsh and not bash.
</p>

ENDFORM;

  return($retval);
}


// show a form you can use to edit build targets, $id is "add" if the
// form is supposed to be for adding
function fireGetPlatformForm($id, $post = null) {
  global $db;

  if ($post) {
    $name = htmlspecialchars($post['name']);
    $description = htmlspecialchars($post['description']);
    $kernel_name = htmlspecialchars($post['kernel_name']);
    $package_name = htmlspecialchars($post['package_name']);
    $hostname = $post['hostname'];
    $login = $post['login'];
    $cmdline = htmlspecialchars($post['cmdline']);
    $is_default_checkbox = $post['is_default_checkbox'];
  }
  else if ($id != "add") {
    $query = "SELECT * FROM platform WHERE id = $id";
    $result = mysql_query($query, $db);
    if ($result) {
      $row = mysql_fetch_array($result);
      $name = htmlspecialchars(stripslashes($row['name']));
      $description = htmlspecialchars(stripslashes($row['description']));
      $kernel_name = htmlspecialchars(stripslashes($row['kernel_name']));
      $package_name = htmlspecialchars(stripslashes($row['package_name']));
      $hostname = stripslashes($row['hostname']);
      $login = stripslashes($row['login']);
      $cmdline = htmlspecialchars(stripslashes($row['cmdline']));
      $is_default_checkbox = stripslashes($row['is_default_checkbox']);
    }
  }

  if ($id == "add") {
    $retval = "<h4>Add Platform</h4>";
    $delete_button = "";
  }
  else {
    $retval = "<h4>Edit Platform</h4>";
    $delete_button = "<input type=\"submit\" name=\"delete\" value=\"Delete\" />\n";
  }

  $is_default_select =
    dbformsGetFixedSelectOptions("is_default_checkbox",
				 array("0", "1"), array("no", "yes"),
				 $is_default_checkbox);

  $retval .= <<<ENDFORM
<form id="platform_form" name="platform_form" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="stage" value="process" />
<input type="hidden" name="platform" value="$id" />
<table class="params" cellspacing="0">
<tr><td>Platform Name</td><td><input type="text" name="name" size="40" maxlength="95" value="$name" /></td></tr>
<tr><td>Description</td><td><input type="text" name="description" size="60" maxlength="250" value="$description" /></td></tr>
<tr><td>Kernel Name</td><td><input type="text" name="kernel_name" size="20" maxlength="95" value="$kernel_name" /> <span class="mininote">(e.g. 2.6.11-bigphys)</span></td></tr>
<tr><td>Package Name</td><td><input type="text" name="package_name" size="20" maxlength="95" value="$package_name" /> <span class="mininote">(e.g. mvenc or mvdec)</span></td></tr>
<tr><td>Hostname</td><td><input type="text" name="hostname" size="20" maxlength="45" value="$hostname" /> <span class="mininote">(hostname or IP address of build machine)</span></td></tr>
<tr><td>Login</td><td><input type="text" name="login" size="20" maxlength="45" value="$login" /> <span class="mininote">(username on the build machine)</span></td></tr>
<tr><td>Cmdline</td><td><input type="text" name="cmdline" size="30" maxlength="250" value="$cmdline" /> <span class="mininote">(build command)</span></td></tr>
<tr><td>Is Default</td><td>$is_default_select <span class="mininote">(is this the default build platform for the package)</span></td></tr>
<tr><td class="submit" colspan="2">
<input type="submit" name="apply" value="Save Changes" />
$delete_button<input type="submit" name="cancel" value="Cancel" />
</td></tr>
</table>
</form>
<p class="mininote">
Note: the package name listed for a platform must match the package name listed
for one of the targets or there will be nothing to build here.
Note that all command lines should be designed for tcsh and not bash.
</p>

ENDFORM;

  return($retval);
}


// returns a start date, as a string, from the build log entry by the
// given id, or an empty string if there is none
function fireGetStartDateFromLog($id) {
  global $db;

  $retval = "";
  $query = "SELECT start_date FROM log WHERE id = '$id'";
  $result = mysql_query($query, $db);
  if ($result && mysql_num_rows($result) > 0) {
    $row = mysql_fetch_array($result);
    $retval = stripslashes($row['start_date']);
  }
  return($retval);
}


// show a form you can use to view and delete build logs, there is no
// "add" functionality for this form
function fireGetLogForm($id, $post = null) {
  global $db;

  $query = "SELECT * FROM log WHERE id = '$id'";
  $result = mysql_query($query, $db);
  if ($result) {
    $row = mysql_fetch_array($result);
    $kernel_name = stripslashes($row['kernel_name']);
    $package_name = stripslashes($row['package_name']);
    $target_name = htmlspecialchars(stripslashes($row['target_name']));
    $target_description = htmlspecialchars(stripslashes($row['target_description']));
    $target_version_number = stripslashes($row['target_version_number']);
    $target_release_number = stripslashes($row['target_release_number']);
    $target_cvs_branch = stripslashes($row['target_cvs_branch']);
    $target_pre_cmdline = htmlspecialchars(stripslashes($row['target_pre_cmdline']));
    $platform_name = htmlspecialchars(stripslashes($row['platform_name']));
    $platform_description = htmlspecialchars(stripslashes($row['platform_description']));
    $platform_hostname = stripslashes($row['platform_hostname']);
    $platform_login = stripslashes($row['platform_login']);
    $platform_cmdline = htmlspecialchars(stripslashes($row['platform_cmdline']));
    $mod_name = stripslashes($row['mod_name']);
    $requestor = stripslashes($row['requestor']);
    $build_note = htmlspecialchars(stripslashes($row['build_note']));
    $is_released_checkbox = stripslashes($row['is_released_checkbox']);
    $request_date = stripslashes($row['request_date']);
    $start_date = stripslashes($row['start_date']);
    $end_date = stripslashes($row['end_date']);
    $error_code = stripslashes($row['error_code']);
    $output = htmlspecialchars(stripslashes($row['output']));
  }

  $retval = "<h4>Build Log</h4>";

  if (privIsPriviledged()) {
    // NOTE: removed the delete button for now, don't want to delete logs
    // $delete_button = "<input type=\"submit\" name=\"delete\" value=\"Delete\" />\n";
    $delete_button = "";
  }
  else {
    $delete_button = "";
  }

  if ($post && isset($post['show_output']) && $post['show_output'] == "1") {
    // show just a few key items and the output log (which takes much space)
    $ver = $package_name . "-" . $target_version_number . "-" . $target_release_number . $mod_name;
    $retval .= <<<ENDFORM
<form id="log_form" name="log_form" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="log" value="$id" />
<input type="hidden" name="package_name" value="$package_name" />
<input type="hidden" name="target_version_number" value="$target_version_number" />
<input type="hidden" name="target_release_number" value="$target_release_number" />
<input type="hidden" name="mod_name" value="$mod_name" />
<table class="params" cellspacing="0">
<tr><td>Target Name</td><td><input type="text" name="target_name" size="40" maxlength="95" value="$target_name" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Version</td><td><input type="text" name="ver" size="20" maxlength="45" value="$ver" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Start Date</td><td><input type="text" name="start_date" size="30" maxlength="250" value="$start_date" class="readonly" readonly="readonly" /></td></tr>
<tr><td>End Date</td><td><input type="text" name="end_date" size="30" maxlength="250" value="$end_date" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Error Code</td><td><input type="text" name="error_code" size="20" maxlength="45" value="$error_code" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Output</td><td><textarea class="readonly" id="output" name="output" cols="80" rows="20" wrap="virtual" readonly="readonly">$output</textarea></td></tr>
<tr><td>Other</td><td><a href="$_SERVER[PHP_SELF]?log=$id">show other info</a></td></tr>
<tr><td class="submit" colspan="2">
$delete_button<input type="submit" name="apply" value="Ok" />
</td></tr>
</table>
</form>

ENDFORM;
  }
  else {
    // show all the information except the output log
    $retval .= <<<ENDFORM
<form id="log_form" name="log_form" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="log" value="$id" />
<table class="params" cellspacing="0">
<tr><td>Target Name</td><td><input type="text" name="target_name" size="40" maxlength="95" value="$target_name" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Target Description</td><td><textarea class="readonly" id="target_description" name="target_description" cols="60" rows="4" wrap="virtual" readonly="readonly">$target_description</textarea></td></tr>
<tr><td>Requestor</td><td><input type="text" name="requestor" size="20" maxlength="95" value="$requestor" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Build Note</td><td><textarea class="readonly" id="build_note" name="build_note" cols="60" rows="4" wrap="virtual" readonly="readonly">$build_note</textarea></td></tr>
<tr><td>Kernel Name</td><td><input type="text" name="kernel_name" size="20" maxlength="95" value="$kernel_name" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Package Name</td><td><input type="text" name="package_name" size="20" maxlength="95" value="$package_name" class="readonly" readonly="readonly" /></td></tr>
<tr><td>CVS Tag/Branch</td><td><input type="text" name="target_cvs_branch" size="20" maxlength="95" value="$target_cvs_branch" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Version Number</td><td><input type="text" name="target_version_number" size="10" maxlength="45" value="$target_version_number" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Release Number</td><td><input type="text" name="target_release_number" size="10" maxlength="45" value="$target_release_number" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Special Mod Name</td><td><input type="text" name="mod_name" size="20" maxlength="45" value="$mod_name" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Platform Name</td><td><input type="text" name="platform_name" size="40" maxlength="95" value="$platform_name" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Platform Description</td><td><textarea class="readonly" id="platform_description" name="platform_description" cols="60" rows="4" wrap="virtual" readonly="readonly">$platform_description</textarea></td></tr>
<tr><td>Hostname</td><td><input type="text" name="platform_hostname" size="20" maxlength="45" value="$platform_hostname" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Login</td><td><input type="text" name="platform_login" size="20" maxlength="45" value="$platform_login" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Prep Cmdline</td><td><input type="text" name="target_pre_cmdline" size="25" maxlength="250" value="$target_pre_cmdline" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Cmdline</td><td><input type="text" name="platform_cmdline" size="30" maxlength="250" value="$platform_cmdline" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Request Date</td><td><input type="text" name="request_date" size="30" maxlength="250" value="$request_date" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Start Date</td><td><input type="text" name="start_date" size="30" maxlength="250" value="$start_date" class="readonly" readonly="readonly" /></td></tr>
<tr><td>End Date</td><td><input type="text" name="end_date" size="30" maxlength="250" value="$end_date" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Error Code</td><td><input type="text" name="error_code" size="20" maxlength="45" value="$error_code" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Output</td><td><a href="$_SERVER[PHP_SELF]?log=$id&amp;show_output=1">show output log</a></td></tr>
<tr><td class="submit" colspan="2">
$delete_button<input type="submit" name="apply" value="Ok" />
</td></tr>
</table>
</form>

ENDFORM;
  }

  return($retval);
}


// processes a form given the form variables
function fireProcessTargetForm($post) {
  global $db, $html_blank_name, $html_dup_name, $html_blank_package_name;
  $retval ="";
  $id = $post['target'];

  if (isset($post['delete'])) {
    if (isset($post['confirm'])) {
      $retval .= dbformsProcessDelete($db, "target", $id);
      $retval .= fireGetIntro();
    }
    else if (isset($post['cancel'])) {
      $retval .= fireGetIntro();
    }
    else {
      $retval .= dbformsConfirmDeleteForm($post, "Are you sure you want to delete the target <b>" . $post['name'] . "</b>?");
    }
  }
  else if (isset($post['cancel'])) {
    $retval .= fireGetIntro();
  }
  else {
    if ("add" == $id &&
	dbformsAlreadyExists($db, "target", "name", $post['name'])) {
      $retval .= $html_dup_name;
      $retval .= fireGetTargetForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['name'])) {
      $retval .= $html_blank_name;
      $retval .= fireGetTargetForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['package_name'])) {
      $retval .= $html_blank_package_name;
      $retval .= fireGetTargetForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['version_number'])) {
      $retval .= "<p class=\"warn bottomrule\">Please enter a version number.</p>";
      $retval .= fireGetTargetForm($id, $post);
    }
    else {
      $content['name'] = $post['name'];
      $content['kernel_name'] = $post['kernel_name'];
      $content['package_name'] = $post['package_name'];
      $content['description'] = $post['description'];
      $content['version_number'] = $post['version_number'];
      $content['release_number'] = $post['release_number'];
      $content['cvs_branch'] = $post['cvs_branch'];
      $content['allow_release_builds_checkbox'] = $post['allow_release_builds_checkbox'];
      $content['allow_dev_builds_checkbox'] = $post['allow_dev_builds_checkbox'];
      $content['pre_cmdline'] = $post['pre_cmdline'];
      $retval .= dbformsProcessInsertOrUpdate($db, "target", $id, $content);
      $retval .= fireGetIntro();
    }
  }

  return($retval);
}


// processes a form given the form variables
function fireProcessPlatformForm($post) {
  global $db, $html_blank_name, $html_dup_name, $html_blank_package_name;
  $retval ="";
  $id = $post['platform'];

  if (isset($post['delete'])) {
    if (isset($post['confirm'])) {
      $retval .= dbformsProcessDelete($db, "platform", $id);
      $retval .= fireGetIntro();
    }
    else if (isset($post['cancel'])) {
      $retval .= fireGetIntro();
    }
    else {
      $retval .= dbformsConfirmDeleteForm($post, "Are you sure you want to delete the platform <b>" . $post['name'] . "</b>?");
    }
  }
  else if (isset($post['cancel'])) {
    $retval .= fireGetIntro();
  }
  else {
    if ("add" == $id &&
	dbformsAlreadyExists($db, "platform", "name", $post['name'])) {
      $retval .= $html_dup_name;
      $retval .= fireGetPlatformForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['name'])) {
      $retval .= $html_blank_name;
      $retval .= fireGetPlatformForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['package_name'])) {
      $retval .= $html_blank_package_name;
      $retval .= fireGetPlatformForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['hostname'])) {
      $retval .= "<p class=\"warn bottomrule\">Please enter a hostname or IP address.</p>";
      $retval .= fireGetPlatformForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['login'])) {
      $retval .= "<p class=\"warn bottomrule\">Please enter a login username.</p>";
      $retval .= fireGetPlatformForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['cmdline'])) {
      $retval .= "<p class=\"warn bottomrule\">Please enter a cmdline for build.</p>";
      $retval .= fireGetPlatformForm($id, $post);
    }
    else {
      $content['name'] = $post['name'];
      $content['kernel_name'] = $post['kernel_name'];
      $content['package_name'] = $post['package_name'];
      $content['description'] = $post['description'];
      $content['hostname'] = $post['hostname'];
      $content['login'] = $post['login'];
      $content['cmdline'] = $post['cmdline'];
      $content['is_default_checkbox'] = $post['is_default_checkbox'];
      $retval .= dbformsProcessInsertOrUpdate($db, "platform", $id, $content);
      $retval .= fireGetIntro();
    }
  }

  return($retval);
}


function fireProcessLogForm($post) {
  global $db;

  $retval ="";
  $id = $post['log'];

  if (isset($post['delete'])) {
    if (isset($post['confirm'])) {
      $retval .= dbformsProcessDelete($db, "log", $id);
      $retval .= fireGetLogTable();
    }
    else if (isset($post['cancel'])) {
      $retval .= fireGetLogTable();
    }
    else {
      $target = $post['package_name'] . "-" . $post['target_version_number'] . "-" . $post['target_release_number'] . $post['mod_name'];
      $retval .= dbformsConfirmDeleteForm($post, "Are you sure you want to delete the log entry for build <b>" . $target . "</b> of " . $post['target_name'] . "?");
    }
  }
  else if ("every" == $id) {
    $retval .= fireGetLogTable("every");
  }
  else if ("all" == $id || isset($post['apply'])) {
    $retval .= fireGetLogTable();
    $retval .= "<br />Don&apos;t see what you want here? <a href=\"?log=every\">Get Every Log Entry Ever Made</a>\n";
  }
  else {
    $retval .= fireGetLogForm($id, $post);
  }

  return($retval);
}


/* ---------------- Firing Off a Build ------------------------------ */


// returns an array of the id numbers of platforms that can build the
// given package
function fireGetPlatformsForPackage($kernel_name, $package_name, $field_name) {
  global $db;
  $retval = array();
  if ($kernel_name) {
    $kernel_clause = "kernel_name = '$kernel_name'";
  }
  else {
    $kernel_clause = "(kernel_name IS NULL OR kernel_name = '')";
  }
  $query = "SELECT $field_name FROM platform WHERE $kernel_clause AND package_name = '$package_name' ORDER BY id";
  $result = mysql_query($query, $db);
  if ($result) {
    $num_rows = mysql_num_rows($result);
    for ($i = 0; $i < $num_rows; $i++) {
      $retval[] = mysql_result($result, $i);
    }
  }
  return($retval);
}


// returns the new release number that will be assigned for this build
// (development builds get date, release builds get the next available
// release candidate number available for the package)
function fireFigureReleaseNumber($package_name, $version_number,
				 $release_number, $is_release_build) {
  if ($is_release_build) {
    if (strlen($release_number)) {
      $retval = $release_number;
    }
    else {
      // look among the releases in bug track to determine what the current
      // release number is and add one
      $retval = privGetHighReleaseNumber($package_name, $version_number) + 1;
    }
  }
  else {
    if (strlen($release_number)) {
      $dev_release_number = $release_number;
    }
    else {
      // figure out the most recently used release number in bugzilla
      // and use that when none is specified
      $dev_release_number = privGetHighReleaseNumber($package_name, $version_number);
    }

    if (strpos($dev_release_number, ".") === false) {
      // add the date to the release number when it is not already there,
      // since this is a dev build
      $dev_release_number = $dev_release_number . "." . date("ymd");
    }

    $retval = $dev_release_number;
  }

  return($retval);
}


// returns the directory this version and release of the given package would
// be in if it was already built
function fireGetAlreadyBuiltDir($package_name, $version_number,
				$release_number, $mod_name) {
  global $build_dir, $package_product_subdir;

  if (isset($package_product_subdir[$package_name])) {
    $subdir = $package_product_subdir[$package_name];
  }
  else {
    $subdir = $package_name;
  }

  return($_SERVER['DOCUMENT_ROOT'] . "/" . $build_dir . "/" . $subdir . "/" . $version_number . "-" . $release_number . $mod_name);
}


// returns true if this version and release of the given package has
// already been built and building it again would overwrite it
function fireAlreadyBuilt($package_name, $version_number, $release_number,
			  $mod_name) {
  global $build_success_filenames;

  $found = false;
  $dir = fireGetAlreadyBuiltDir($package_name, $version_number,
				$release_number, $mod_name);
  foreach ($build_success_filenames as $filename) {
    $found |= file_exists("$dir/$filename");
  }
  return($found);
}


// returns a log id if this version and release of the given package has
// already been requested for a build but the build isn't done yet, or returns
// 0 if the build has not be requested
function fireAlreadyRequested($package_name, $version_number, $release_number,
			      $mod_name) {
  global $db;

  $query = "SELECT id FROM log WHERE package_name='$package_name' AND target_version_number='$version_number' AND target_release_number='$release_number' AND mod_name='$mod_name' AND end_date IS NULL";
  $result = mysql_query($query, $db);
  if ($result && mysql_num_rows($result) > 0) {
    return(mysql_result($result, 0, "id"));
  }
  else {
    return(0);
  }
}


// handle the fire off a build form, one a target has been selected
// (the post array passed in should contain a 'target' key which is the
// id number of the target in the database
function fireGetBuildForm($post) {
  global $db;

  $id = $post['target'];

  $query = "SELECT * FROM target WHERE id = $id";
  $result = mysql_query($query, $db);
  if ($result) {
    $row = mysql_fetch_array($result);
    $name = stripslashes($row['name']);
    $kernel_name = stripslashes($row['kernel_name']);
    $package_name = stripslashes($row['package_name']);
    $description = stripslashes($row['description']);
    $version_number = stripslashes($row['version_number']);
    $release_number = stripslashes($row['release_number']);
    $cvs_branch = stripslashes($row['cvs_branch']);
    $allow_release_builds_checkbox = stripslashes($row['allow_release_builds_checkbox']);
    $allow_dev_builds_checkbox = stripslashes($row['allow_dev_builds_checkbox']);
    $pre_cmdline = stripslashes($row['pre_cmdline']);
  }

  $platform_ids = fireGetPlatformsForPackage($kernel_name, $package_name, "id");

  if (!$allow_dev_builds_checkbox && !$allow_release_builds_checkbox) {
    $retval = "<p>Sorry, the target <b>$name</b> does not currently allow any builds.  Both development and release builds have been turned off for this target.</p>\n<p>Return to <a href=\"builds-fire.php\">Fire Off a Build</a>.</p>\n";
  }
  else if (count($platform_ids) == 0) {
    $retval = "<p>Sorry, there are currently no platforms defined for building the package <b>$package_name</b> which is required for the target <b>$name</b>.</p>\n<p>Return to <a href=\"builds-fire.php\">Fire Off a Build</a>.</p>\n";
  }
  else {

    $platform_names = fireGetPlatformsForPackage($kernel_name, $package_name, "name");
    $platform_is_default = fireGetPlatformsForPackage($kernel_name, $package_name, "is_default_checkbox");

    // figure out which is the default platform
    $default_platform_id = $platform_ids[0];
    for ($i = 0; $i < count($platform_ids); $i++) {
      if ($platform_is_default[$i]) {
	$default_platform_id = $platform_ids[$i];
	break;
      }
    }

    $platform_select = dbformsGetFixedSelectOptions("platform_id", $platform_ids, $platform_names, $default_platform_id);

    $requestors = privGetAllLoginNames();
    $default_requestor = privGetLoginName();
    $requestor_select = dbformsGetFixedSelectOptions("requestor", $requestors, $requestors, $default_requestor);

    $build_type_nums = array();
    $build_type_names = array();
    if ($allow_dev_builds_checkbox) {
      $build_type_nums[] = "0";
      $build_type_names[] = "development";
    }
    if ($allow_release_builds_checkbox) {
      $build_type_nums[] = "1";
      $build_type_names[] = "release candidate";
    }
    $is_release_build_select = dbformsGetFixedSelectOptions("is_released_checkbox", $build_type_nums, $build_type_names, $build_type_nums[0]);

    // we can figure out the exact release number when we
    // know what kind of build this is going to be
    if (count($build_type_nums) == 1) {
      $release_number = fireFigureReleaseNumber($package_name, $version_number, $release_number, $allow_release_builds_checkbox);
    }

    $descrip_cols = 60;
    $descrip_rows = 4;
    $calc_rows = strlen($description) / $descrip_cols;
    if ($calc_rows < $descrip_rows) {
      $descrip_rows = ($calc_rows > 0) ? $calc_rows : 1;
    }

    $retval = <<<END
<h4>Fire Off a Build</h4>

<p>
<form id="fire1" name="fire1" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="stage" value="process" />
<input type="hidden" name="target" value="$id" />
<table class="params" cellspacing="0">
<tr><td>Product Name</td><td><input type="text" name="name" size="40" maxlength="95" value="$name" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Description</td><td><textarea class="readonly" id="description" name="description" cols="$descrip_cols" rows="$descrip_rows" wrap="virtual" readonly="readonly">$description</textarea></td></tr>
<tr><td>Kernel Name</td><td><input type="text" name="kernel_name" size="20" maxlength="95" value="$kernel_name" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Package Name</td><td><input type="text" name="package_name" size="20" maxlength="95" value="$package_name" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Version Number</td><td><input type="text" name="version_number" size="20" maxlength="45" value="$version_number" class="readonly" readonly="readonly" /></td></tr>
<tr><td>Release Number</td><td><input type="text" name="release_number" size="20" maxlength="45" value="$release_number" class="readonly" readonly="readonly" /> <span class="mininote">(blank means to use next available)</span></td></tr>
<tr><td>CVS Tag/Branch</td><td><input type="text" name="cvs_branch" size="20" maxlength="95" value="$cvs_branch" class="readonly" readonly="readonly" /> <span class="mininote">(blank means to use the main trunk)</span></td></tr>
<tr><td>Prep Cmdline</td><td><input type="text" name="pre_cmdline" size="25" maxlength="250" value="$pre_cmdline" class="readonly" readonly="readonly" /> <span class="mininote">(runs before the build begins)</span></td></tr>
<tr><td>Special Mod Name</td><td><input type="text" name="mod_name" size="20" maxlength="45" value="$mod_name" /> <span class="mininote">(okay to leave blank)</span></td></tr>
<tr><td>Platform</td><td>$platform_select <span class="mininote">(where build will be made)</span></td></tr>
<tr><td>Build Type</td><td>$is_release_build_select <span class="mininote">(what kind of build)</span></td></tr>
<tr><td>Requestor</td><td>$requestor_select <span class="mininote">(identify yourself)</span></td></tr>
<tr><td>Build Note</td><td><textarea id="build_note" name="build_note" cols="45" rows="4" wrap="virtual">$build_note</textarea></td></tr>
<tr><td class="submit" colspan="2">
<input type="submit" name="apply" value="Request Build" />
<input type="submit" name="cancel" value="Cancel" />
</td></tr>
</table>
</form>
</p>

END;
  }

  return($retval);
}


// returns true if the given string is a valid mod name
function fireIsValidModName($s) {
  $validchars = "abcdefghijklmnopqrstuvwxyz";
  $s = strtolower($s);
  return(strspn($s, $validchars) == strlen($s));
}


function fireProcessBuildForm($post) {
  global $db;

  $target_id = $post['target'];
  $platform_id = $post['platform_id'];

  $log['kernel_name'] = $post['kernel_name'];
  $log['package_name'] = $post['package_name'];
  $log['target_name'] = $post['name'];
  $log['target_description'] = $post['description'];
  $log['target_version_number'] = $post['version_number'];
  $log['target_cvs_branch'] = $post['cvs_branch'];
  $log['target_pre_cmdline'] = $post['pre_cmdline'];

  $query = "SELECT * FROM platform WHERE id = '$platform_id'";
  $result = mysql_query($query, $db);
  if ($result) {
    $row = mysql_fetch_array($result);
    $log['platform_name'] = stripslashes($row['name']);
    $log['platform_description'] = stripslashes($row['description']);
    $log['platform_hostname'] = stripslashes($row['hostname']);
    $log['platform_login'] = stripslashes($row['login']);
    $log['platform_cmdline'] = stripslashes($row['cmdline']);
  }

  $log['mod_name'] = $post['mod_name'];
  $log['requestor'] = $post['requestor'];
  $log['build_note'] = $post['build_note'];
  $log['is_released_checkbox'] = $post['is_released_checkbox'];
  $log['request_date'] = date("Y-m-d H:i:s");


  // figure out what the release will actually end up being
  $log['target_release_number'] = fireFigureReleaseNumber($post['package_name'], $post['version_number'], $post['release_number'], $post['is_released_checkbox']);

  // figure out if there is already a build for that release
  $name = $post['package_name'] . "-" . $post['version_number'] . "-" . $log['target_release_number'] . $log['mod_name'];
  if (fireAlreadyBuilt($post['package_name'], $post['version_number'], $log['target_release_number'], $log['mod_name'])) {
    $retval = "<p class=\"warn bottomrule\">Sorry, you cannot build <b>$name</b>, because it has already been built (<a href=\"/builds.php\">see all builds</a>).</p>";
  }
  else if ($requested_log_id = fireAlreadyRequested($post['package_name'], $post['version_number'], $log['target_release_number'], $log['mod_name'])) {
    $retval = "<p class=\"warn bottomrule\">Sorry, you cannot build <b>$name</b>, because it has already been requested and is currently being built (<a href=\"?log=$requested_log_id\">see build log</a>). If you've fixed a build problem and need to request it again, please delete the existing build log first.</p>";
  }
  else if (!fireIsValidModName($log['mod_name'])) {
    $retval = "<p class=\"warn bottomrule\">Sorry, the Special Mod Name <b>" . $log['mod_name'] . "</b> is not valid because it has something other pure alphabetic characters (a thru z) in it.  No spaces, dashes, or even underscores are allowed.  Please pick a different one and try again.</p>";
  }
  else {
    // create an entry in the log table for this build
    $success = dbformsSimpleInsertOrUpdate($db, "log", "add", $log);

    if ($success) {
      // no need to contact the remote machine and schedule the build,
      // because build machines are supposed to check the build log on
      // the database periodically to determine wheteher they should be
      // building anything
      $retval = "<p class=\"bottomrule\">Your <b>$name</b> build has been requested.  Please check the <a href=\"?log=all\">Build Log</a> in a few minutes to see if your build has been started and finished.</p>";
    }
    else {
      $retval = "<p class=\"warn bottomrule\">There was a problem with your request to build <b>$name</b>: " . mysql_error() . ".</p>";
    }
  }

  return($retval);
}
?>
