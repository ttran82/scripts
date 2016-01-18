#!/usr/bin/perl

use strict;

use vars qw($logs_dir $scripts_dir $rcmd $rscp $logfile $enchome $enclog);
use vars qw($exclusive_lock $unlock_lock);

#Glogal variable definitions
$logs_dir = "/home/ttran/html/tests/logs";
$scripts_dir = "/home/ttran/html/tests/scripts";
$rcmd = "$scripts_dir/mvhdrexec.exp";
$rscp = "$scripts_dir/mvhdrscp.exp";
$enchome = "/usr/local/hdenc";
$enclog = "/var/log/hdenc.log";

#Constants for file-locking
$exclusive_lock = 2;
$unlock_lock = 8;

#Subroutines defined here
sub mvCreateFile {
  my($file, $initdata) = @_;
  #save it first if it existed
#  if (-e $file) {
#    rename($file, "$file.old") or &printError(500, "Server error", "Problem saving $file.old"); 
#  }
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

#Get machine uptime
sub mvHostUptime {
  my($myhost) = @_;
  my($mycmd) = "$rcmd $myhost uptime";
  my($rvalue) = &mvCmd($mycmd);
  my($myuptime) = "down";
  #if ($rvalue =~ /up (\d+ days),\s+(.*?),/) {
  if ($rvalue =~ /up\s+(.+),\s+\d+ user/) {
      $myuptime =  "$1 $2";
      $myuptime =~ s|,||;
  }
  print STRERR "$myuptime\n";
  return($myuptime);
}

#Get encoder service status
sub mvServiceStatus {
  my($myhost) = @_;
  my($mycmd) = "$rcmd $myhost \"service hdenc status\"";
  my($rvalue) = &mvCmd($mycmd);
  my($ret) = "down";
  if ($rvalue =~ /running/) {
      $ret = "up";
    }
  return($ret);
}

#Get encoder uptime
sub mvEncUptime {
  my($myhost) = @_;
  my($curlog) = "$enclog";
  my($oldlog) = "$enclog.old"; 
  my($curtime, $oldtime, $difftime, $mycmd);
  #$mycmd = "$rcmd $myhost \"ls -l --time-style=full-iso $curlog\""; 
  $curtime = &mvEncCurTime($myhost);
  #print "curtime: $curtime\n";

  $mycmd = "$rcmd $myhost \"ls -l --time-style=full-iso $oldlog\""; 
  $oldtime = &mvEncLogTime($mycmd);
  if($oldtime == "0") {
    $mycmd = "$rcmd $myhost \"head -n 500 $curlog\""; 
    $oldtime = &mvEncLogTimeLong($mycmd);
  }
  #print "oldtime: $oldtime\n";
 
  $difftime = &mvSecToHr($curtime - $oldtime);
  #print "difftime: $difftime\n";
  
  return($difftime);
}

sub mvEncCurTime {
  use Time::Local;
  my($myhost) = @_;
  my($mycmd) = "$rcmd $myhost \"date +'%S %M %H %e %m %y'\"";
  my($rvalue) = &mvCmd($mycmd);
  my($time) = "0";
  my($sec, $min, $hr, $day, $month, $year) = split(" ", $rvalue);
  $time = timelocal($sec, $min, $hr, $day, $month-1, $year);
  return($time);
}

#Get time of current log
sub mvEncLogTime {
  use Time::Local;
  my($mycmd) = @_;
  my($rvalue) = &mvCmd($mycmd);
  my($time) = "0";
  if ($rvalue =~ /root root \d+ (\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)./) {
    $time = timelocal($6, $5, $4, $3, $2-1, $1);  
  }
  return($time);
}

sub mvEncLogTimeLong {
  use Time::Local;
  my($mycmd) = @_;
  my(@rvalue) = `$mycmd`;
  my($time);
  for (@rvalue) {
    next if /^spawn/;
    next if /^root/;
    next if /^#/;
    print $_;
    if (/(\d+):(\d+):(\d+) NEWDAY (\d+)\/(\d+)\/(\d+)/) {
      $time = timelocal($3, $2, $1, $5, $4-1, $6);  
      last;
    }
  }
  return($time);
}

#convert seconds to hr
sub mvSecToHr {
  my($sec) = @_;
  my($min, $hr);
  my($rvalue);

  $hr = int($sec/3600);
  $sec = $sec - $hr*3600;
  $min = int($sec/60);
  $sec = $sec - $min*60;
   
  $rvalue = sprintf("%02d:%02d:%02d", $hr, $min, $sec);
  return($rvalue);
}

sub mvGetConfig {
  my($myhost, $getwhat) = @_;
  my($mycmd) = "$rcmd $myhost \"$enchome/mvconfig --get $getwhat\"";
  my($rvalue) = &mvCmd($mycmd);
  my($temp);
  ($temp ,$rvalue) = split(" = ", $rvalue);
  chomp($rvalue);
  $rvalue =~ s| ||;
  return($rvalue);
}

#Run command
sub mvCmd {
  my($mycmd) = @_;
  print STDERR "$mycmd\n";
  my(@rvalue) = `$mycmd`;
  my($ret) = "none";
  for (@rvalue) {
    next if /^spawn/;
    next if /^root/;
    next if /^#/;
    next if /Permission denied/;
    $ret = $_;
  }
  print STDERR "$ret\n";
  chomp($ret);
  return($ret);
}

#Copy file
sub mvScp {
  my($host, $source, $target) = @_;
  my($mycmd) = "$rscp root\@$host:$source $target";
  `$mycmd`;
}

#Get encoder status from mvconfig
sub mvConfigStatus {
  my($myhost) = @_;
  my($mycmd) = "$rcmd $myhost \"$enchome/mvconfig --status\"";
  my(@rvalue) = `$mycmd`;
  my(%status, $vertmp, $reltmp, $myvalue);
  for (@rvalue) {
    next if /^#/;
    if (/HOSTNAME = \"(.+)\"/) {
       $status{'HOSTNAME'} = $1;
       }
    if (/RpmVer = \"(.+)\"/) {
       $vertmp = $1;
       }
    if (/RpmRel = \"(.+)\"/) {
       $reltmp = $1;
       }
    if (/STATUS = \"(.+)\"/) {
       $status{'STATUS'} = $1;
    }
  }
  $status{'VERSION'} = "$vertmp-$reltmp";
  my($mycmd) = "$rcmd $myhost \"$enchome/mvconfig --get InterfaceStandby\"";
  $myvalue = &mvCmd($mycmd);
  if ($myvalue =~ /InterfaceStandby = (\d)/) {
     if ($1 eq "1") {
     $status{'STATUS'} = "Standby";
     }
  }

  return(%status);
}

#######################################
#Print Error
#######################################
sub printError {
  my($status, $keyw, $message) = @_;
  
  #print "Content-type: text/html\n";
  print ("Status: $status, $keyw, $message.\n\n");
  exit;
}

#Getting all default configs
#rconfig is hash passed by reference
sub mvConfigCmd {
  my($myhost, $rconfig, $mydefault) = @_;
  my($mycmd) = "$rcmd $myhost \"$enchome/mvconfig $mydefault\"";
  my($mykey, $myvalue);
  print ("$mycmd\n");
  my(@value) = `$mycmd`;
  for (@value) {
    next if /^spawn/;
    next if /^root/;
    next if /^#/;
    next if /^Logo/;
    chop;
    s|||g;

    ($mykey, $myvalue) = split(" = ", $_);
    chomp($mykey);
    chomp($myvalue);
    #skip any thing that is returned null
    #next if /""/;
    $myvalue =~ s|"||g;
    $$rconfig{$mykey} = $myvalue; 
  } 
}

sub mvPrintConfigs {
  my($rconfig) = @_;
  my($key);
  foreach $key (keys %$rconfig) {
    print("$key = $$rconfig{$key}\n");
  }
}

sub mvCurrentConfigs {
  my($myhost, $rconfig) = @_;
  &mvConfigCmd($myhost, $rconfig, "--defaults");
  &mvConfigCmd($myhost, $rconfig, "");
}

sub mvCurrentStatus {
  my($myhost, $rstatus) = @_;
  &mvConfigCmd($myhost, $rstatus, "--status");
}

sub mvDec2Bin {
  my $str = unpack("B32", pack("N", shift));
  $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
  return $str;
}

sub mvBin2Dec {
  return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}

sub mvChannelNo {
  my($bin) = &mvDec2Bin(shift);
  my($count) = 0;
  $count++ while $bin =~ /1/g;
  return $count 
}

sub mvEncType {
  my($myhost) = @_;
  my($retval) = "hdenc";
  my($mycmd) = "$rcmd $myhost \"ls -lrt $enclog\"";
  my($tmp) = &mvCmd($mycmd); 
  if($tmp =~ /mv/) {
    $retval = "mvenc"
  }
  return($retval);
}
