#!/usr/bin/perl

#Globle variables
$sleep_time = 30;
@brlist = ("192000", "128000", "256000");
$count = 0;

$|++;

$home_dir = `pwd`;
chop($home_dir);

#Important commands
$nice = "$home_dir/nice";
$mvconfig = "/usr/local/db/mvconfig";
$mvrestart = "service zenc restart";
$save_dir = "/tmp";

print "Make sure Audio 1 is enabled$_\n";
&mvSetConfig("Audio1Enable 1");
&mvSetConfig("Audio1CompressType 0");
&mvSetConfig("Audio1Bitrate 192000");
sleep $sleep_time;

while(1) 
{
   #print "Make sure Audio 1 is enabled$_\n";
   #&mvSetConfig("Audio1Enable 1");
   #&mvSetConfig("Audio1CompressType 0");
   #&mvSetConfig("Audio1Bitrate 192000");

   foreach (@brlist) {
     print "Changing Audio1 Bitrate to $_.\n";
     &mvSetConfig("Audio1Bitrate $_");
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
