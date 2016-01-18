#!/usr/bin/perl

use File::Basename;

my($basedir) = dirname($0);

use vars qw($lfile $Statfile $ofile);
use vars qw($openbugscmd $fixedbugscmd $closedbugscmd);
use vars qw($openbugs $fixedbugs $closedbugs $totalbugs);
use vars qw($lynxcmd $header $date $rrdtool $rrdfile);

$date = `date \"+%D %R\"`;
chomp($date);
print STDERR "Today's date: $date\n";
$lfile = "$basedir/../logs/rockstarbugs.log";
$ofile = "$basedir/../reports/rockstarbugs.txt";

$header = "#Date\t\tOpenBugs\tFixedBugs\tClosedBugs\tTotal";
$openbugscmd = "http://ca117europe.am.mot.com/bugzilla/buglist.cgi?product=Rockstar&bug_status=NEW&bug_status=ASSIGNED&bug_status=REOPENED";
$fixedbugscmd = "http://ca117europe.am.mot.com/bugzilla/buglist.cgi?product=Rockstar&bug_status=RESOLVED&resolutions=FIXED";
$closedbugscmd = "http://ca117europe.am.mot.com/bugzilla/buglist.cgi?product=Rockstar&bug_status=VERIFIED&bug_status=CLOSED";
$lynxcmd = "lynx -dump";
$rrdtool = "/usr/local/rrdtool/bin/rrdtool";
$rrdfile = "/home/ttran/html/drraw/data/rockstarbug.rrd";

#Create file ready for stat output
#&mvCreateFile($statfile, "#IP|Hostname|EncUptime|VideoSource|VideoOut|AudioOut|MultiCast|PIP|Version|Status|AdvanceSetting");
&mvCreateFile("$ofile", $header);
$openbugs = &mvGetBugs("$lynxcmd \"$openbugscmd\" | grep found");
$fixedbugs = &mvGetBugs("$lynxcmd \"$fixedbugscmd\" | grep found");
$closedbugs = &mvGetBugs("$lynxcmd \"$closedbugscmd\" | grep found");
$total = $openbugs + $fixedbugs + $closedbugs;
&mvAppendLine($ofile, "$date\t$openbugs\t\t$fixedbugs\t\t$closedbugs\t\t$total");

my($cmd) = "$rrdtool update $rrdfile \"N:$openbugs:$fixedbugs:$closedbugs:$total\"";
print "Running: $cmd\n";
system($cmd);

#Subroutines defined here
sub mvCreateFile {
  my($file, $initdata) = @_;
  #save it first if it existed
  if (-e $file) {
  return 0;
  }
  open(FILE, ">$file") or &printError(500, "Server error", "Cannot create file $file");
  print FILE "$initdata\n";
  close(FILE);
}

sub mvAppendLine{
  my($filename, $line) = @_;
  #check if file is writable
  open(FD, ">>$filename") or &printError(500, "Server error", "Cannot open file $filename for append");
  #lock file
  flock(FD,$exclusive_lock);
  seek(FD, 0, 2);
  print FD "$line\n";
  #unlock file
  flock(FD,$unlock_lock);
  close(FD);
}

#Run command
sub mvGetBugs {
  my($mycmd) = @_;
  my(%num) = ("one", 1, "two", 2, "three", 3, "four", 4, "five", 5, "six", 6, "seven", 7, "eight", 8, "nine", 9);
  print STDERR "$mycmd\n";
  my(@rvalue) = `$mycmd`;
  my($ret) = 0;
  for (@rvalue) {
    next if /^spawn/;
    next if /^root/;
    next if /^#/;
    next if /Permission denied/;
    $ret = $_;
  }
  chomp($ret);
  ($ret,,) = split(" ", $ret);
  $ret =~ tr/A-Z/a-z/; 
  if($num{$ret}) {
    $ret = $num{$ret};
  }
  print STDERR "$ret\n";
  return($ret);
}

