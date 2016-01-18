#!/usr/bin/perl

#Globle variables
$sleep_time = 5;

$|++;

$home_dir = `pwd`;
chop($home_dir);

#Important commands
$nice = "$home_dir/nice";
$mvconfig = "/usr/local/db/mvconfig";
$mvrestart = "service zenc restart";
$save_dir = "/tmp";

while(1) 
{
   $bitrate = rand(4);
   if ($bitrate > 1)
   {
     $bitrate = int($bitrate * 1000) * 1000;
     print "Setting bitrate: $bitrate\n";
     &mvSetConfig("TargetBitRate $bitrate");
   }
   sleep $sleep_time;
}

#Available subroutimes
sub mvSetConfig {
  my($param) = @_;
  my($cmd) = "$mvconfig --set $param";
  my($rvalue) = `$cmd`;
}

