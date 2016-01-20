<?php

ini_set ("expect.loguser", "Off");

$stream = popen ("expect://ssh root@192.168.8.168 uptime", "r");

$cases = array (
  array (0 => "password:", 1 => "PASSWORD")
);

switch (expect_expectl ($stream, $cases))
{
 case PASSWORD:
  fwrite ($stream, "password\n");
  break;
 
 default:
  die ("Error was occurred while connecting to the remote host!\n");
}

while ($line = fgets ($stream)) {
  print $line;
}
fclose ($stream);
?> 
