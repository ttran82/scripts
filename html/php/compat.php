<?php
/*
 * Routines for handling the storage and display of a compatibility
 * matrix of software, hardware, etc. that is accessible via a
 * web-based user interface.
 *
 * Copyright (C) 2005 Modulus Video, Inc.  All Rights Reserved.
 */

require_once('priv.php');
require_once('dbforms.php');

// database information
$db_host = "localhost";
$db_user = "compat";
$db_pass = "mvcompat";
$db_name = "compat";

// database connection results
$db = null;
$db_error = "";

// version number for this software
$compat_version = "1.0";

// common strings
$html_blank_name = "<p class=\"warn bottomrule\">Please enter a name.</p>";
$html_dup_name = "<p class=\"warn bottomrule\">That name is already in use, please try a different name.</p>";


/* ---------------- Database Creation and Connection ---------------- */


// check for the existence of all the compat tables, and create
// them if necessary, compatConnect does this once every time
// you connect, returns true if everything is ok
//
// equip table contain a list of all the kinds of equipment there are
//
// item table contains a list of the compatibility columns in the table
//
// status table defines the difference kinds of compatibility between items
//
// matrix table defines individual compatibilities between unique items
//
function compatCheckAllTables() {
  global $db, $db_error;

  if ($db) {
    $retval = true;
    $result = mysql_query("SHOW TABLES", $db);
    $num = mysql_num_rows($result);
    $tables = array();
    for ($i = 0; $i < $num; $i++) {
      $tables[$i] = mysql_result($result, $i);
    }
    if (!in_array("equip", $tables)) {
      $query = <<<END
CREATE TABLE equip (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255)
) COMMENT = 'each kind of equipment that can have a compatibility matrix';
END;
      $result = mysql_query($query, $db);
      if (!$result) {
	echo mysql_error();
      }
    }
    if (!in_array("item", $tables)) {
      $query = <<<END
CREATE TABLE item (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  equipId INT UNSIGNED NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255)
) COMMENT = 'each kind of column in the compatibility table';
END;
      $result = mysql_query($query, $db);
      if (!$result) {
	echo mysql_error();
      }
    }
    if (!in_array("status", $tables)) {
      $query = <<<END
CREATE TABLE status (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  symbol VARCHAR(100) NOT NULL,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255)
) COMMENT = 'all the difference kinds of compatibility statuses';
END;
      $result = mysql_query($query, $db);
      if (!$result) {
	echo mysql_error();
      }
    }
    if (!in_array("matrix", $tables)) {
      $query = <<<END
CREATE TABLE matrix (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  itemId1 INT UNSIGNED NOT NULL,
  itemId2 INT UNSIGNED NOT NULL,
  statusId INT UNSIGNED NOT NULL,
  previousStatusId INT UNSIGNED NOT NULL,
  submitter VARCHAR(50),
  whenSubmitted DATETIME
) COMMENT = 'defines how items go together compatibility-wise';
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
function compatConnect() {
  global $db, $db_host, $db_user, $db_pass, $db_name, $db_error;

  if ($db) {
    return(true);
  }
  else {
    $db = @mysql_connect($db_host, $db_user, $db_pass);
    if ($db) {
      if (@mysql_select_db($db_name, $db)) {
	$db_error = "";
	return(compatCheckAllTables());
      }
      else {
	$db_error = mysql_error();
	compatDisconnect();
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
function compatOutputNoConnection() {
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
function compatDisconnect() {
  global $db;

  if ($db) {
    @mysql_close($db);
    $db = null;
  }
}


/* ---------------- Form Display and Processing --------------------- */


// returns an associative array of all the equipment currently in the
// compatability matrix in the database, with ids as keys and names as
// values
function compatGetEquipList() {
  global $db;

  $retval = array();
  $query = "SELECT id,name FROM equip ORDER BY name";
  $result = mysql_query($query, $db);
  if ($result) {
    $num = mysql_num_rows($result);
    for ($i = 0; $i < $num; $i++) {
      $row = mysql_fetch_array($result);
      $retval[$row['id']] = $row['name'];
    }
  }
  return($retval);
}


// returns a form you can use to edit records in the equip table,
// $id is "add" if the form is supposed to be for adding
function compatGetEquipForm($id, $post = null) {
  global $db;

  if ($post) {
    $name = htmlspecialchars($post['name']);
    $description = htmlspecialchars($post['description']);
  }
  else if ($id != "add") {
    $query = "SELECT * FROM equip WHERE id = $id";
    $result = mysql_query($query, $db);
    if ($result) {
      $row = mysql_fetch_array($result);
      $name = htmlspecialchars(stripslashes($row['name']));
      $description = htmlspecialchars(stripslashes($row['description']));
    }
  }

  if ($id == "add") {
    $retval = "<h4>Add Equipment</h4>";
    $delete_button = "";
  }
  else {
    $retval = "<h4>Edit Equipment</h4>";
    // $delete_button = "<input type=\"submit\" name=\"delete\" value=\"Delete\" />\n";
  }

  $retval .= <<<ENDFORM
<form id="equip_form" name="equip_form" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="stage" value="process" />
<input type="hidden" name="equipId" value="$id" />
<table class="params" cellspacing="0">
<tr><td>Name</td><td><input type="text" name="name" size="40" maxlength="95" value="$name" /></td></tr>
<tr><td>Description</td><td><input type="text" name="description" size="60" maxlength="250" value="$description" /></td></tr>
<tr><td class="submit" colspan="2">
<input type="submit" name="apply" value="Save Changes" />
$delete_button<input type="submit" name="cancel" value="Cancel" />
</td></tr>
</table>
</form>

ENDFORM;

  return($retval);
}


// processes a form given the form variables
function fireProcessEquipForm($post) {
  global $db, $html_blank_name, $html_dup_name;
  $retval ="";
  $id = $post['equip'];

  if (isset($post['delete'])) {
    if (isset($post['confirm'])) {
      $retval .= dbformsProcessDelete($db, "equip", $id);
      $retval .= fireGetIntro();
    }
    else if (isset($post['cancel'])) {
      $retval .= fireGetIntro();
    }
    else {
      $retval .= dbformsConfirmDeleteForm($post, "Are you sure you want to delete the equip <b>" . $post['name'] . "</b>?");
    }
  }
  else if (isset($post['cancel'])) {
    $retval .= fireGetIntro();
  }
  else {
    if ("add" == $id &&
	dbformsAlreadyExists($db, "equip", "name", $post['name'])) {
      $retval .= $html_dup_name;
      $retval .= fireGetEquipForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['name'])) {
      $retval .= $html_blank_name;
      $retval .= fireGetEquipForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['package_name'])) {
      $retval .= $html_blank_package_name;
      $retval .= fireGetEquipForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['hostname'])) {
      $retval .= "<p class=\"warn bottomrule\">Please enter a hostname or IP address.</p>";
      $retval .= fireGetEquipForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['login'])) {
      $retval .= "<p class=\"warn bottomrule\">Please enter a login username.</p>";
      $retval .= fireGetEquipForm($id, $post);
    }
    else if ("add" == $id && !strlen($post['cmdline'])) {
      $retval .= "<p class=\"warn bottomrule\">Please enter a cmdline for build.</p>";
      $retval .= fireGetEquipForm($id, $post);
    }
    else {
      $content['name'] = $post['name'];
      $content['package_name'] = $post['package_name'];
      $content['description'] = $post['description'];
      $content['hostname'] = $post['hostname'];
      $content['login'] = $post['login'];
      $content['cmdline'] = $post['cmdline'];
      $content['is_default_checkbox'] = $post['is_default_checkbox'];
      $retval .= dbformsProcessInsertOrUpdate($db, "equip", $id, $content);
      $retval .= fireGetIntro();
    }
  }

  return($retval);
}
