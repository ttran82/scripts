#!/usr/bin/perl

use File::Basename;

my($basedir) = dirname($0);
require("$basedir/mvzodiaclib.pl");

use vars qw($lfile $Statfile $ip $machine_uptime $enc_uptime $servicestatus $logdir);
use vars qw($conf_name);

$conf_name = "qa_autosave";
$lfile = "$logs_dir/zodiachostname.lst";
$logdir = "/var/log";
$hdencdir = "/usr/local/zenc/config";

#open hostname list 
open(FILE, "<$lfile") or die("Cannot open $lfile\n");
while(<FILE>) {
  next if (/#/);
  chomp;
  s|||g;
  ($ip, $notes) = split(/\|/, $_);
  $servicestatus = &mvServiceStatus($ip);
  if ($servicestatus eq "up") {
    &mvSaveCurrentConfig($ip, $conf_name);
  }
}
close(FILE);

sub mvSaveCurrentConfig {
  my($myhost, $conf_name) = @_;
  #Save conf first
  my($cmd) = "$rcmd $myhost \"mv $hdencdir/$conf_name.conf $hdencdir/${conf_name}_old.conf\"";
  print "$cmd\n";
  `$cmd`;
  #Save new config
  my($cmd) = "$rcmd $myhost \"/usr/local/zenc/mvconfig > $hdencdir/$conf_name.conf\"";
  print "$cmd\n";
  `$cmd`;
}
