<?php
/*
 * Routines for helping with display and processing of forms based on
 * information in a database.
 *
 * Copyright (C) 2004 Modulus Video, Inc.  All Rights Reserved.
 */

// return the value of a column cell in a row, and if a
// column name ends in "_id", that means it is an id number in another table
// and an attempt should be made to fetch the "name" column from that
// other table and display it instead, along with a link to the page for that
// table (the name of that table comes before the "_id"), or, if a column
// name ends in "_email", format the entry as an email link
function dbformsGetTableColumnValue($db, $row, $colname) {
  $retval = stripslashes($row[$colname]);

  if (strlen($colname) > 9 &&
      !strcmp(substr($colname, strlen($colname) - 9), "_checkbox")) {
    $retval = ($row[$colname]) ? "yes" : "no";
  }
  else if (strlen($retval) && strlen($colname) > 6 &&
	   !strcmp(substr($colname, strlen($colname) - 6), "_email")) {
    $chunks = split("@", $retval);
    $retval = "<a href=\"mailto:" . $retval . "\" class=\"email\">" . $chunks[0] . "@...</a>";
  }
  else if (!strcmp($colname, "description")) {
    if (strlen($retval) > 35) {
      $retval = substr($retval, 0, 35) . " ...";
    }
    $retval = "<span class=\"description\">" . $retval . "</span>";
  }
  else if ($db && !strcmp(substr($colname, strlen($colname) - 3), "_id")) {
    $id = $row[$colname];
    $table = substr($colname, 0, strlen($colname) - 3);
    $query = "SELECT name FROM " . $table . " WHERE id = '" . $id . "'";
    $result = mysql_query($query, $db);
    if ($result) {
      if (mysql_num_rows($result) > 0) {
	$anchor = "<a href=\"" . $table . ".php?edit=" . $id . "\">";
	$retval = $anchor . stripslashes(mysql_result($result, 0)) . "</a>";
      }
    }
  }

  return($retval);
}


// returns the html for the rows in a table, given a mysql query to make and
// an array of elements to retreive from the results. special case: if a
// column name ends in "_id", that means it is an id number in another table
// and an attempt should be made to fetch the "name" column from that
// other table and display it instead, along with a link to the page for that
// table (the name of that table comes before the "_id")
function dbformsGetTableRows($db, $query, $columns, $edit_field = "edit") {

  $retval = "";
  $result = @mysql_query($query, $db);
  $flip = "odd";

  if ($result) {
    $num = mysql_num_rows($result);
    if ($num > 0) {
      for ($i = 0; $i < $num; $i++) {
	$row = mysql_fetch_array($result);
	$retval .= "<tr class=\"" . $flip . "\">\n";
	$id = (isset($row['id'])) ? $row['id'] : "unknown";
	$edit_anchor = "<a href=\"" . $_SERVER['PHP_SELF'] . "?" . $edit_field . "=" . $id . "\">";
	for ($j = 0; $j < count($columns); $j++) {
	  $colname = $columns[$j];
	  $edge = ($j == count($columns) - 1) ? " class=\"edge\"" : "";
	  $edge = ($j == 0) ? " class=\"first\"" : "";

	  // check for the need to look up another table
	  $value = dbformsGetTableColumnValue($db, $row, $colname);

	  // place a link for editing the row on value in leftmost column
	  $value = ($j == 0) ? $edit_anchor . $value . "</a>" : $value;

	  $retval .= "<td" . $edge . ">" . $value . "</td>\n";
	}
	$retval .= "</tr>\n";
	$flip = ($flip == "odd") ? "even" : "odd";
      }
    }
    else {
      $retval .= <<<ENDNOTE
<tr><td colspan="3" class="note">None are defined.</td></tr>

ENDNOTE;
    }
  }
  else {
    $error = mysql_error();
    $retval .= <<<ENDERROR
<tr><td colspan="3" class="error">$error</td></tr>

ENDERROR;
  }
  return($retval);
}


// get a string containing html for an entire table
function dbformsGetTable($db, $name, $query, $db_columns, $table_columns, $edit_field = "edit") {

  if ($db) {
    $retval = "<table id=\"" . $name .
      "\" class=\"status\" cellspacing=\"0\" width=\"100%\">\n";
    $retval .= "<tr>\n";
    for ($i = 0; $i < count($table_columns); $i++) {
      $colname = $table_columns[$i];
      $edge = ($i == count($table_columns) - 1) ? " class=\"edge\"" : "";
      $edge = ($i == 0) ? " class=\"first\"" : "";
      $retval .= "<th" . $edge . ">" . $colname . "</th>\n";
    }
    $retval .= "</tr>\n";
    $retval .= dbformsGetTableRows($db, $query, $db_columns, $name, $edit_field);
    $retval .= "</table>\n";
    return($retval);
  }
  else {
    return("<p>No db connection.</p>");
  }
}


function dbformsGetCheckbox($name, $checked = false) {
  $checked_attr = ($checked) ? " checked=\"checked\"" : "";
  $checked_value = ($checked) ? 1 : 0;
  $retval = "<input name=\"$name\" value=\"$checked_value\" type=\"checkbox\"$checked_attr />";
  return($retval);
}


// returns a select tag with options from the $values array, with
// the $selected option already selected.  The name/id of the select tag
// will be the given $name parameter
function dbformsGetFixedSelectOptions($name, $values, $text, $selected = 0) {
  $num = count($values);
  $retval = "<select name=\"" . $name . "\">";
  for ($i = 0; $i < $num; $i++) {
    $selected_attr = ($values[$i] == $selected) ? " selected=\"selected\" " : "";
    $retval .= "<option value=\"" . $values[$i] . "\"$selected_attr>" . $text[$i] . "</option>";
  }
  $retval .= "</select>";
  return($retval);
}


// returns a select tag with options that reflects what choices are
// available from a given table and the given named column from that
// table, the table is assumed to have an "id" field that, if equal to the
// given id, is the default selected option
function dbformsGetSelectOptions($db, $table, $name, $id) {
  $query = "SELECT id,$name FROM $table";
  $result = mysql_query($query, $db);
  $num = mysql_num_rows($result);
  $select_name = $table . "_id";
  $retval = "<select name=\"" . $select_name . "\">";
  $retval .= "<option value=\"0\"> </option>";
  for ($i = 0; $i < $num; $i++) {
    $row = mysql_fetch_array($result);
    $option_id = $row['id'];
    $option_name = stripslashes($row[$name]);
    $selected = ($option_id == $id) ? " selected=\"selected\" " : "";
    $retval .= "<option value=\"" . $option_id . "\"$selected>" . $option_name . "</option>";
  }
  $retval .= "</select>";

  return($retval);
}


// confirms a deletion
function dbformsConfirmDeleteForm($post, $message) {
  $retval = <<<END
<form id="wanted" name="wanted" method="post" action="$_SERVER[PHP_SELF]">

END;

  foreach ($post as $key => $value) {
    $retval .= "<input type=\"hidden\" name=\"$key\" value=\"" . htmlspecialchars($value) . "\" />\n";
  }

  $retval .= <<<END
<table class="params" cellspacing="0">
<tr>
<td>
<h4 class="notopmar">Confirm Deletion</h4>
$message
</td>
</tr>
<tr>
<td class="submit">
<input type="submit" name="confirm" value="Delete" />
<input type="submit" name="cancel" value="Cancel" />
</td>
</tr>
</table>
</form>

END;
  return($retval);
}


// deletes a table row by id and returns message html concerning the action
function dbformsProcessDelete($db, $table, $id) {
  $query = "DELETE FROM " . $table . " WHERE id='" . $id . "'";
  $result = mysql_query($query, $db);
  if ($result) {
    $retval =
      "<p class=\"note bottomrule\">Deleted.</p>";
  }
  else {
    $retval =
      "<p class=\"warn bottomrule\">" . mysql_error() . ".  Query was " . htmlspecialchars($query) . "</p>";
  }
  return($retval);
}


// returns true if a row exists in the given table where the given column
// has the given value (typically to insure that unique values are used
// in that column)
function dbformsAlreadyExists($db, $table, $column, $value) {
  $query = "SELECT * FROM " . $table . " WHERE " . $column . "='" . addslashes($value) . "'";
  $result = mysql_query($query, $db);
  $retval = (mysql_num_rows($result) > 0);
  return($retval);
}


// inserts or updates a table row, depending on the $id (which is "add" if
// this should be an insert), the $content array is an associative array of
// the column values that should be set, returns true on success
function dbformsSimpleInsertOrUpdate($db, $table, $id, $content) {
  $set = "SET ";
  foreach ($content as $key => $value) {
    $set .= $key . "='" . addslashes($value) . "', ";
  }
  $set = substr($set, 0, strlen($set) - 2);   // remove final ", "

  if ("add" == $id) {
    $query = "INSERT INTO " . $table . " " . $set;
    }
  else {
    $query = "UPDATE " . $table . " " . $set . " WHERE id='" . $id . "'";
  }
  $result = mysql_query($query, $db);

  return($result);
}


// inserts or updates a table row, depending on the $id (which is "add" if
// this should be an insert), the $content array is an associative array of
// the column values that should be set, returns a string of html that
// is used to display the result of the action
function dbformsProcessInsertOrUpdate($db, $table, $id, $content) {
  if (dbformsSimpleInsertOrUpdate($db, $table, $id, $content)) {
    $retval = "<p class=\"note bottomrule\">Your changes have been saved.</p>";
  }
  else {
    $retval = "<p class=\"warn bottomrule\">" . mysql_error() . ".</p>";
  }
  return($retval);
}
?>
