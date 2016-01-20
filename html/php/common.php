<?php

/*
 * This file contains all of the common functions
 */

require_once('priv.php');
// location of all commont directories
$qa_homedir = "/home/ttran/html";
$qa_testdir = "$qa_homedir/tests";
$qa_scriptdir = "$qa_testdir/scripts";
$qa_reportdir = "$qa_testdir/reports";
$qa_searchdir = "$qa_testdir/search";
$qa_docsdir = "$qa_testdir/docs";
$qa_toolsdir = "$qa_testdir/tools";
$qa_logsdir = "$qa_testdir/logs";

$qa_members = array("rpon", "jmorales", "ttran", "nnguyen");
$qa_products = array("ME6000", "ME1000", "MD6000", "MD1000", "Zodiac1.0");

$row_limit = 20;    // how many rows to show in the table (0 = no limit)
$file_content_cutoff = 8192;   // how many chars fit comfortably in a table cell

// standard executables needed
$gunzip_command = "/bin/gunzip";
$gzip_command = "/bin/gzip";
$tar_command = "/bin/tar";

//Refressh
$gserveDefaultRefreshRate = 60;
// actual gserveRefreshRate of the status page
$gserveRefreshRate = $gserveDefaultRefreshRate;
// default gserveRefreshMethod is javascript
$gserveDefaultRefreshMethod = "javascript";
// actual gserveRefreshMethod, is either "javascript" or "refresh",
// because when javascript is not available you have to use a meta tag
$gserveRefreshMethod = $gserveDefaultRefreshMethod;


//Get File contents
function GetFileContents($path, $alternate = "", $cutoff = true) {
  global $file_content_cutoff;
  $fh = @fopen($path, "r");
  if ($fh) {
    $size = filesize($path);
    $retval = ($size > 0) ? trim(fread($fh, $size)) : "";
    fclose($fh);
    if ($cutoff && strlen($retval) > $file_content_cutoff) {
      $link = "<a class=\"more\" href=\"" . GetRelativeLink($path) . "\" title=\"View the entire text\">more</a>";
      $retval = substr($retval, 0, $file_content_cutoff) . "... " . $link;
    }
    return($retval);
  }
  else {
    return($alternate);
  }
}

// returns a string suitable for a relative link in the page
// by removing the server document root, or if not found, leaves it alone
function GetRelativeLink($path) {
  $s = $_SERVER['DOCUMENT_ROOT'] . "/";
  if (!strcmp(substr($path, 0, strlen($s)), $s)) {
    return(substr($path, strlen($s)));
  }
  else {
    return($path);
  }
}


// get file list from directory name  
function GetFileList($dir, $reverse = true) {
  $retval = array();
  $d = opendir($dir);
  if ($d) {
    while (false !== ($f = readdir($d))) {
      if ($f != "." && $f != ".." && $f != "CVS"  && !ereg(".old", $f)) {
        $retval[] = "$dir/$f";
      }
    }
    closedir($d);
  }
  natsort($retval);
  if ($reverse) {
    $retval = array_reverse($retval);
  }
  return($retval);
}

// 

// returns directory tree 
function DisplayDirTree($path, $top = true) {
  $flist = GetFileList($path);
  if ($top === false) { 
  //get rid first array item 
    array_shift($flist);
  }
  while($fname = array_shift($flist)) {
    $fname = basename($fname);
    print "$fname\n";
  }
  //now print the rest
}

function GetFileTable($dir, $readonly = true) {

  $allfiles = GetFileList($dir); 
  if (count($allfiles) > 0) {
    $retval = GetTableBegin();
    $retval .= GetTableRows($allfiles);
    $retval .= GetTableEnd();
    return($retval);
  } 
  else {
    return("<p><b>No files.</b></p>\n");
  }
}

function GetTableBegin() {
  $retval = <<<END
<table class="status" style="clear: right;" cellspacing="0">
<tr>
<th>Filename</th>
<th>Actions</th>
</tr>
END;

  return($retval);
}

function GetTableEnd() {
$retval = <<<END
</table>

END;
  return($retval);
}

function GetTableRows($files) {
  while($fname = array_shift($files)) {
  $displayname = basename($fname);
  $flink = "<a href=\"/process_file.php?readfile=$fname\" title=\"$displayname\">$displayname</a>";
  if (privIsPriviledged()) {
    $editlink = "<a href=\"/process_file.php?editfile=$fname\" title=\"Edit File\"><img src=\"/images/edit24.gif\" width=\"18\" height=\"18\"/></a>";
  }
  else {
    $editlink = "ReadOnly";
  }
  $retval .= <<<END
<tr>
<td>$flink</td>
<td>$editlink</td>
</tr>
END;
  }
  return($retval);
}

function GetEditOrEnterPage() {
  $retval = GetFileEditor();
  if (strlen($retval) == 0) {
    $retval = GetFileEnter();
  }
  else {
    $retval = ("");
  }
  return($retval);
}

function GetFileEditor() {
  if (isset($_REQUEST['editfile'])) {
    $retval = "GetFileEditor Page";
    $newfile = $_REQUEST['editfile'];
  }
  else {
    return("");
  } 
  if ('process' == $_REQUEST['stage']) {
    if (!isset($_REQUEST['cancel'])) {
    //save changes to file
      $filetext = $_REQUEST['filetext'];
      $filetext = str_replace("\\\"", "\"", $filetext);  // fix quote marks
      $filetext = str_replace("\\'", "'", $filetext);  // fix single quote
 
      $oldfile = MoveFileToOld($newfile);
      if ($old_filename) {
        if (strlen($filetext) > 0) {
          $old_umask = umask(0000);  // make any new notes file writeable to all
          $fh = @fopen($newfile, "w");
          if ($fh) {
            fputs($fh, $filetext);
            fclose($fh);
          }
          else {
            echo "<p class=\"warn\">Cannot write to '" . $newfile . "'</p>\n";
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
    $filecontent = htmlspecialchars(GetFileContents($newfile));   
    $retval = <<<END
<form id="notes" name="notes" method="post" action="$_SERVER[PHP_SELF]">
<input type="text" name="stage" value="process" />
<table class="params" cellspacing="0">
<tr>
<td>
<h4 class="notopmar">Edit $what_kind for $version-$release$mod</h4>

<textarea id="filetext" name="filetext" cols="$cols" rows="$rows" wrap="virtual">$filecontent</textarea>
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
<p class="mininote">The edits you make here will change the report stored
 in this release page.  Please check carefully before saving. </p>

END;
    return($retval);
  }
}


function MoveFileToOld($path) {
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

function GetStatus($filepath) {
  $fh = @fopen($filepath, "r");  
  while($line = fgets($fh)) {
    print "$line\n";
  }
}

function PrintHDMonitorList($filepath) {
global $qa_logsdir;
$retval = <<<END
<table class="status" style="clear: right;" cellspacing="0">
<tr>
<th>IP</th>
<th>EncStatus</th>
<th>VideoSetup</th>
<th>AudioSetup</th>
<th>Network</th>
<th>Advanced</th>
<th>PiP</th>
<th>Notes</th>
</tr>
END;

  $fh = @fopen($filepath, "r");
  while($line = fgets($fh)) {
    list($ip, $hostname, $machine_up, $enc_uptime, $mem_usage, $disk_usage, $vout, $aout, $nic, $pip, $version, $status, $adv, $advx, $notes) = split("\|", $line);
    $retval .= "<tr>\n";
    $retval .= "<td><a href=\"http://$ip/status.php\" title=\"$hostname\n$version\n$status\">$ip</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/mvdebug/log.php\" title=\"Hostuptime:$machine_up\">Host:$machine_up hdenc:$enc_uptime mem:$mem_usage disk:$disk_usage</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/video.php\" title=\"Video Setting\">$vout</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/new_audio.php\" title=\"Audio Setting\">$aout</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/network.php\" title=\"Network Setting\">$nic</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/advanced.php\" title=\"$advx\">$adv</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/proxy.php\" title=\"Proxy Setting\">$pip</a></td>\n";
    $retval .= "<td>$notes</td>\n";
    $retval .= "</tr>";
  }

$retval .= <<<END
</table>
END;
  return($retval);
}

function PrintZMonitorList($filepath) {
global $qa_logsdir;
$retval = <<<END
<table class="status" style="clear: right;" cellspacing="0">
<tr>
<th>IP</th>
<th>Hw Spec</th>
<th>Version</th>
<th>EncStatus</th>
<th>VideoSetup</th>
<th>AudioSetup</th>
<th>Network</th>
<th>Advanced</th>
<th>PiP</th>
<th>Notes</th>
</tr>
END;

  $fh = @fopen($filepath, "r");
  while($line = fgets($fh)) {
    list($ip, $hostname, $cpu, $domrev, $fwrev, $machine_up, $encuptime, $memusage, $diskuage, $zrestart, $vout, $aout, $nic, $pip, $version, $status, $adv, $advx, $notes) = split("\|", $line);
    $retval .= "<tr>\n";
    $retval .= "<td><a href=\"http://$ip/status.php\" title=\"Hostname\">$ip</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/index.php\" title=\"Hardware Spec\">CPU=$cpu MEM=$memusage</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/upgrade.php\" title=\"Version\">DOMrev=$domrev FWrev=$fwrev Software=$version</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/support/log.php\" title=\"Hostuptime: $machine_up\nMemoryUsage: $memusage\">host:$machine_up zenc:$encuptime mem:$memusage disk:$diskuage zrestart:$zrestart</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/video.php\" title=\"Video Setting\">$vout</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/new_audio.php\" title=\"Audio Setting\">$aout</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/network.php\" title=\"Network Setting\">$nic</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/advanced.php\" title=\"$advx\">$adv</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/proxy.php\" title=\"Proxy Setting\">$pip</a></td>\n";
    $retval .= "<td>$notes</td>\n";
    $retval .= "</tr>";
  }

$retval .= <<<END
</table>
END;
  return($retval);
}

function PrintStatmuxMonitorList($filepath) {
global $qa_logsdir;
$retval = <<<END
<table class="status" style="clear: right;" cellspacing="0">
<tr>
<th>IP</th>
<th>EncStatus</th>
<th>VideoSetup</th>
<th>AudioSetup</th>
<th>Network</th>
<th>Advanced</th>
<th>PiP</th>
<th>Notes</th>
</tr>
END;

  $fh = @fopen($filepath, "r");
  while($line = fgets($fh)) {
    list($ip, $hostname, $machine_up, $encuptime, $memusage, $zrestart, $vout, $aout, $nic, $pip, $version, $status, $adv, $advx, $notes) = split("\|", $line);
    $retval .= "<tr>\n";
    $retval .= "<td><a href=\"http://$ip/status.php\" title=\"$hostname\n$version\n$status\">$ip</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/support/log.php\" title=\"Hostuptime: $machine_up\nMemoryUsage: $memusage\">zremux:$encuptime host:$machine_up mem:$memusage zrestart:$zrestart</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/video.php\" title=\"Video Setting\">$vout</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/new_audio.php\" title=\"Audio Setting\">$aout</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/network.php\" title=\"Network Setting\">$nic</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/advanced.php\" title=\"$advx\">$adv</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/proxy.php\" title=\"Proxy Setting\">$pip</a></td>\n";
    $retval .= "<td>$notes</td>\n";
    $retval .= "</tr>";
  }

$retval .= <<<END
</table>
END;
  return($retval);
}



function PrintSDMonitorList($filepath) {
global $qa_logsdir;
$retval = <<<END
<table class="status" style="clear: right;" cellspacing="0">
<tr>
<th>IP</th>
<th>EncUptime</th>
<th>VideoSetup</th>
<th>AudioSetup</th>
<th>Network</th>
<th>Advanced</th>
<th>PiP</th>
<th>Notes</th>
</tr>
END;

  $fh = @fopen($filepath, "r");
  while($line = fgets($fh)) {
    list($ip, $hostname, $machine_up, $encuptime, $vout, $aout, $nic, $pip, $version, $status, $adv, $advx, $notes) = split("\|", $line);
    $retval .= "<tr>\n";
    $retval .= "<td><a href=\"http://$ip/status.php\" title=\"$hostname\n$version\n$status\">$ip</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/mvdebug/log.php\" title=\"Hostuptime:$machine_up\">$encuptime</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/video.php\" title=\"Video Setting\">$vout</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/audio.php\" title=\"Audio Setting\">$aout</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/network.php\" title=\"Network Setting\">$nic</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/advanced.php\" title=\"RateControl($advx)\">$adv</a></td>\n";
    $retval .= "<td><a href=\"http://$ip/proxy.php\" title=\"Proxy Setting\">$pip</a></td>\n";
    $retval .= "<td>$notes</td>\n";
    $retval .= "</tr>";
  }

$retval .= <<<END
</table>
END;
  return($retval);
}






function PrintTableList($filepath) {
  $retval = <<<END
<table class="status" style="clear: right;" cellspacing="0">
<tr>
END;

  $fh = @fopen($filepath, "r");
  while($line = fgets($fh)) {
    list($hostname, $machine, $encoder) = split("\|", $line);
    
  }

  $retval .= <<<END
</tr>
</table>
END;
  return($retval);
}

function gserveStatusRefreshTag($slow = false) {
  global $gserveRefreshRate;
  global $gserveRefreshMethod;

  if ($gserveRefreshMethod == "refresh" && $gserveRefreshRate > 0) {
    $rate = ($slow) ? ($gserveRefreshRate * 5) : $gserveRefreshRate;
    return '<meta http-equiv="refresh" content="' . $rate . ';url=' . formatSelfSessionURL() . '" />' . "\n";
  }
  else {
    return '';
  }
}


?>


