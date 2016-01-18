#!/usr/bin/perl

#Globle variables
$sleep_time = 60;

#ATSC Channel List: a.b, a = channel, b = program number
@chlist = ("12.3", "19.3", "29.1", "24.3", "24.4", "45.1");

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
   foreach (@chlist) {
     &mvSetATSC("$_");
     &mvSleep($sleep_time);
   }
   $count++;
   print "Interation: $count\n";
}

#Available subroutimes
sub mvSetATSC {
  my($param) = @_;
  my($ch, $prog_num) = split(/\./, $param);
  &mvSetConfig("polaris_mode 2");
  &mvSetConfig("atsc_channel $ch");
  &mvSetConfig("atsc_rf_prog_num $prog_num");
  print "Setting ATSC channel: $ch.$prog_num\n";
}

sub mvSetConfig {
  my($param) = @_;
  my($cmd) = "$mvconfig --set $param";
  print "$cmd\n";
  my($rvalue) = `$cmd`;
}

sub mvSleep {
  my($param) = @_;
  while($param > 0) {
    print ".";
    sleep 1;  
    $param--;
  } 
  print "\n";
}
