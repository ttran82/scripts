<?php
// log display is the same for both encoder and decoder,
// these function facilitate the display, but the page itself must
// call showLog("current"), showLog("old"), or showLog("dmesg") after
// including this file


// above a certain size, we don't want to show the entire log
// (see bug 112 - huge log files are not displayed), so if the size exceeds
// a certain maximum we're going to snip it in the middle, and show a little
// from the beginning of the log and as much of the end of the log as the
// maximum allows
$max_log_bytes = 800000;
$log_beginning_snippet_bytes = 200000;  // must be smaller than $max_log_bytes
$log_snip_message = "\n\n    <snip - log too big, extra lines removed>\n\n";


function getLogContent($filename, $content = "") {
  global $max_log_bytes, $log_beginning_snippet_bytes, $log_snip_message;

  if (file_exists($filename)) {
    $fh = @fopen($filename, "r");
    if ($fh) {
      $size = filesize($filename);
      if ($size > $max_log_bytes) {
	// get the begining of the log
	$content = fread($fh, $log_beginning_snippet_bytes);

	// trim content back from the end to the last newline
	$where = strrpos($content, "\n");
	if ($where !== false) {
	  $content = substr($content, 0, $where);
	}

	// place a message in the middle where lines were omitted
	$content .= $log_snip_message;

	// get the end of the log
	$end_size = $max_log_bytes - $log_beginning_snippet_bytes - strlen($log_snip_message);
	fseek($fh, - ($end_size), SEEK_END);
	$end_part .= fread($fh, $end_size);

	// trim end part at the beginning up to the next newline
	$where = strpos($end_part, "\n");
	if ($where !== false && $where < strlen($end_part) - 1) {
	  $end_part = substr($end_part, $where + 1);
	}

	$content .= $end_part;
      }
      else {
	// it's not too big, just get the entire log
	$content = fread($fh, $size);
      }
      fclose($fh);
    }
    else {
      $content = "\nCould not open $filename";
    }
  }
  return($content);
}


function showLog($logfile) {
  global $gserveLogFile;
  $content = getLogContent($logfile, "\nLog file is empty.");
  $header = "Log file output ";
  $footer = "";

  $reconstructed = "";
  $len = strlen($content);
  for ($i = 0; $i < $len; $i++) {
    if (!ctype_print($content{$i}) && !ctype_cntrl($content{$i})) {
      $reconstructed .= "[unprintable]";
    }
    else {
      $reconstructed .= $content{$i};
    }
  }

  $content = htmlspecialchars($reconstructed);

print <<<END
<form id="debug" name="debug" method="post" action="$_SERVER[PHP_SELF]">
<input type="hidden" name="stage" value="process" />
<table class="params" cellspacing="0" width="100%">
<tr><td>

<h4 class="notopmar">$header</h4>

<textarea name="logtext" id="logtext" readonly="readonly" rows="20" cols="80">$content</textarea>

</td></tr>
</table>
</form>

<p class="mininote">$footer</p>

END;
}
?>
