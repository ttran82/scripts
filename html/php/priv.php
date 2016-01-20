<?php

/*
 * This file contains all of the functions required in order to insure
 * that only certain users can perform certain kinds of actions.
 *
 * And at the moment is also a holding place for any other operations that
 * require contact with the bugzilla database.
 */

// bugzilla db information, some of it
// copied from the buzilla/localconfig file
$bug_db_host = "europe";         # where is the database?
$bug_db_name = "bugs";              # name of the MySQL database
$bug_db_user = "dbadmin";              # user to attach to the MySQL database
$bug_db_pass = 'mvmysql';           # datbase password
$bug_db_login_cookie = "Bugzilla_login";  // name of cookie for bugzilla userid
$bug_db_login_name_result = null;         // place to store the result of query

// priviledged users (can edit release notes, etc.)
// $priv_login_names = array("jmorales", "rpon", "ttran", "nnguyen");
$priv_login_names = array("all");


// returns an array of all the usernames that could request the build,
// including an initial blank entry - it gets the list from bugzilla
function privGetAllLoginNames() {
  global $bug_db_host, $bug_db_name, $bug_db_user, $bug_db_pass;

  $retval = array("");
  $db = mysql_connect($bug_db_host, $bug_db_user, $bug_db_pass);
  if ($db) {
    mysql_select_db($bug_db_name, $db);
    $query = "SELECT login_name FROM profiles";
    $result = mysql_query($query, $db);
    if ($result) {
      $num = mysql_num_rows($result);
      for ($i = 0; $i < $num; $i++) {
	$retval[] = mysql_result($result, $i);
      }
    }

    mysql_close($db);
  }
  return($retval);
}


// returns the bugzilla username that the web user is currently logged in
// as on bugzilla, assuming they still have the login cookie, returns
// an empty string if they are not logged in
function privGetLoginName() {
  global $bug_db_host, $bug_db_name, $bug_db_user;
  global $bug_db_pass, $bug_db_login_cookie, $bug_db_login_name_result;

  if ($bug_db_login_name_result === null) {
    $bug_db_login_name_result = "";
    if (isset($_COOKIE[$bug_db_login_cookie])) {
      // get login name from bugzilla database
      $userid = $_COOKIE[$bug_db_login_cookie];
      $db = mysql_connect($bug_db_host, $bug_db_user, $bug_db_pass);
      if ($db) {
	mysql_select_db($bug_db_name, $db);
	$query = "SELECT login_name FROM profiles WHERE userid = '$userid'";
	$result = mysql_query($query, $db);
	if ($result) {
	  $bug_db_login_name_result = mysql_result($result, 0, "login_name");
	  mysql_close($db);
	}
      }
    }
  }

  return($bug_db_login_name_result);
}


// decides whether the current user is priviledged (can edit things)
function privIsPriviledged() {
  global $priv_login_names;

  if (in_array("all", $priv_login_names)) {
    return(true);
  }
  else {
    $login_name = privGetLoginName();
    return(in_array($login_name, $priv_login_names));
  }
}


// returns a link describing current login priviledges
function privGetPriviledgesTag() {
  if (privIsPriviledged()) {
    $retval = "<span class=\"mininote\">priviledged user</span>";
  }
  else {
    if (privGetLoginName()) {
      $retval = "<span class=\"mininote\">no priviledges</span>";
    }
    else {
      $retval = "<span class=\"mininote\">need to <a href=\"http://europe/bugzilla/query.cgi?GoAheadAndLogIn=1\">log in</a></span>";
    }
  }
  return($retval);
}


// fills in the mapping between package names and bugzilla products
// by looking for the package names within the product descriptions,
// returns the bugzilla product id number for the given package
function privGetProductId($db, $package_name) {
  $retval = "";

  $query = "SELECT id,description FROM products WHERE description LIKE '%" . $package_name . "%'";
  $result = mysql_query($query, $db);
  if ($result && mysql_num_rows($result) > 0) {
    $retval = mysql_result($result, 0, "id");
  }

  return($retval);
}


// given a product id, gets all the versions of the product that are known,
// returns an array of them
function privGetAllVersions($db, $product_id) {
  $retval = array();

  $query = "SELECT value FROM versions WHERE product_id = '$product_id'";
  $result = mysql_query($query, $db);
  if ($result) {
    $num = mysql_num_rows($result);
    for ($i = 0; $i < $num; $i++) {
      $retval[] = mysql_result($result, $i, "value");
    }
  }

  return($retval);
}


// returns the highest release number ever used in a build
// for the given package and version
function privGetHighReleaseNumber($package_name, $version_number) {
  global $bug_db_host, $bug_db_name, $bug_db_user, $bug_db_pass;

  // connect to the mysql database
  $db = mysql_connect($bug_db_host, $bug_db_user, $bug_db_pass);
  if ($db) {
    // select the bugzilla database
    mysql_select_db($bug_db_name, $db);

    // figure out the package's product id
    $product_id = privGetProductId($db, $package_name);

    // get all the version numbers ever used for a product
    $all_versions = privGetAllVersions($db, $product_id);

    // figure out the highest release number used with the given version
    $retval = "0";   // 0 is returned when there are no matches
    $pattern = "/^" . $version_number . "-(\d+)/";
    $num = count($all_versions);
    for ($i = 0; $i < $num; $i++) {
      if (preg_match($pattern, $all_versions[$i], $matches)) {
	if ($matches[1] > $retval) {
	  $retval = $matches[1];
	}
      }
    }

    mysql_close($db);
    return($retval);
  }
  else {
    return("0");
  }
}
?>
