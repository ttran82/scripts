#!/usr/bin/perl

#Globle variables
$sleep_time = 60;
@chlist = ("5", "7", "9", "11", "26", "36");
$count = 0;

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
   print "Changing SDI mode: $_\n";
   &mvSetConfig("polaris_mode 0");
   sleep $sleep_time;

   foreach (@chlist) {
     &mvSetConfig("polaris_mode 1");
     print "Changing to NTSC Channel: $_\n";
     &mvSetConfig("ntsc_channel $_");
     sleep $sleep_time;
   }
   $count++;
   print "Interation: $count\n";
}

#Available subroutimes
sub mvSetConfig {
  my($param) = @_;
  my($cmd) = "$mvconfig --set $param";
  my($rvalue) = `$cmd`;
}
