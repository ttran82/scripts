#!/usr/bin/perl

#Globle variables
$sleep_time = 300;
$count = 0;

$|++;

#Important commands
$nice = "$home_dir/nice";
$mvconfig = "/usr/local/db/mvconfig";
$mvrestart = "service zenc restart";
$save_dir = "/tmp";

while(1) 
{
   print "Restarting number $count..._\n";
   `$mvrestart`;
   sleep $sleep_time;
   $count++;
}
