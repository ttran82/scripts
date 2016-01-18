#!/usr/bin/perl


$logs_dir = "/home/ttran/html/tests/logs";
$scripts_dir = "/home/ttran/html/tests/scripts";
$lfile = "$logs_dir/hostname.lst";
$rcmd = "$scripts_dir/rexec.exp";
$rscp = "$scripts_dir/rscp.exp";
$statfile = "$logs_dir/status";

#Check status file
if (-e $statfile) {
  #save it first
  rename($statfile, "$statfile.old"); 
}

open(FD, ">$statfile") or die("Cannot create $statfile\n");
#  print FD "Hostname/IP		Machine's Uptime		Encoder's Uptime\n";
#  print FD "-----------		----------------		----------------\n";

#open file
open(FILE, "<$lfile") or die("Cannot open $lfile\n");
while(<FILE>) {
  next if (/#/);
  chomp;
  s| ||;
  $machine_uptime = &get_uptime("$_");
  $chkstatus = &get_enc_status("$_");
  $enc_uptime = "down....";
  if ($chkstatus eq "up") {
    %mystatus = &get_mvstatus($_);
    $enc_uptime = &get_enc_uptime($_);
    &copy_log($_);
  }

  #print FD "$_\t\t$machine_uptime\t\t\t$enc_uptime\n"
  chomp($_);
  print FD "$_|$machine_uptime|$enc_uptime|$mystatus{'HOSTNAME'}|$mystatus{'VERSION'}|$mystatus{'STATUS'}\n"
}
close(FILE);
close(FD);

#Subroutines start here
#get uptime of the machine
sub get_uptime {
  my($myhost) = @_;
  my($mycmd) = "$rcmd $myhost uptime";
  my($rvalue) = &run_cmd($mycmd);
  my($myuptime) = "down....";
  #if ($rvalue =~ /up (\d+ days),\s+(.*?),/) {
  if ($rvalue =~ /up\s+(.+),\s+\d+ user/) {
      $myuptime =  "$1 $2";
      $myuptime =~ s|,||;
  }
  print STRERR "$myuptime\n";
  return($myuptime);
}

sub get_enc_status {
  my($myhost) = @_;
  my($mycmd) = "$rcmd $myhost \"service hdenc status\"";
  my($rvalue) = &run_cmd($mycmd);
  my($ret) = "down";
  if ($rvalue =~ /running/) {
      $ret = "up";
    }
  return($ret);
}

sub get_enc_uptime {
  my($myhost) = @_;
  my($curlog) = "/var/log/hdenc.log";
  my($oldlog) = "/var/log/hdenc.log.old"; 
  my($curtime, $oldtime, $difftime);
  $mycmd = "$rcmd $myhost \"ls -l --time-style=full-iso $curlog\""; 
  $curtime = &get_enc_log_time($mycmd);
  #print "curtime: $curtime\n";

  $mycmd = "$rcmd $myhost \"ls -l --time-style=full-iso $oldlog\""; 
  $oldtime = &get_enc_log_time($mycmd);
  #print "oldtime: $oldtime\n";
 
  $difftime = &sec_to_hr($curtime - $oldtime);
  #print "difftime: $difftime\n";
  
  return($difftime);
}

sub get_enc_log_time {
  use Time::Local;
  my($mycmd) = @_;
  my($rvalue) = &run_cmd($mycmd);
  my($time);
  if ($rvalue =~ /root root \d+ (\d+)-(\d+)-(\d+) (\d+):(\d+):(\d+)./) {
  }
  #print ("$6 $5 $4 $3 $2 $1\n");
  $time = timelocal($6, $5, $4, $3, $2, $1);  
}

sub sec_to_hr {
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

sub run_cmd {
  my($mycmd) = @_;
  print STDERR "$mycmd\n";
  my(@rvalue) = `$mycmd`;
  my($ret) = "none";
  for (@rvalue) {
    next if /^spawn/;
    next if /^root/;
    next if /^#/;
    $ret = $_;
  }
  print STDERR "$ret\n";
  chomp($ret);
  return($ret);
}

sub copy_log {
  my($host) = @_;
  my($source) = "/var/log/hdenc.log";
  my($target) = "$logs_dir/$host";
  my($mycmd) = "$rscp root\@$host:$source $target.current";
  &run_cmd($mycmd);
  my($mycmd) = "$rscp root\@$host:$source.old $target.old";
  &run_cmd($mycmd);
}

sub get_mvstatus {
  my($myhost) = @_;
  my(%status);
  my($mycmd) = "$rcmd $myhost \"/usr/local/hdenc/mvconfig --status\"";
  my(@rvalue) = `$mycmd`;
  print "@rvalue";
  my($vertmp, $reltemp);
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
  my($mycmd) = "$rcmd $myhost \"/usr/local/hdenc/mvconfig --get InterfaceStandby\"";
  $myvalue = &run_cmd($mycmd);
  if ($myvalue =~ /InterfaceStandby = (\d)/) {
     if ($1 eq "1") {
     $status{'STATUS'} = "Standby";
     }
  }

  return(%status);
}

sub get_setting {
  my($myhost) = @_;
  my($mycmd) = "$rcmd $myhost \"/usr/local/hdenc/mvconfig --status\"";
  my(@rvalue) = `$mycmd`;
  
  for (@rvalue) {
    s/^#//;
  } 
}
