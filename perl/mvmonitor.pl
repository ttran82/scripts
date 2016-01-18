#!/usr/bin/perl

use File::Basename;

my($basedir) = dirname($0);
require("$basedir/mvlib.pl");

use vars qw($lfile $Statfile $ip $machine_uptime $enc_uptime $servicestatus $logdir);
use vars qw(%config %status %mystatus $key $ip $notes $enc_type);


$lfile = "$logs_dir/hostname.lst";
$statfile = "$logs_dir/status";
$logdir = "/var/log";

#Create file ready for stat output
#&mvCreateFile($statfile, "#IP|Hostname|EncUptime|VideoSource|VideoOut|AudioOut|MultiCast|PIP|Version|Status|AdvanceSetting");
&mvCreateFile($statfile, "");

#open hostname list 
open(FILE, "<$lfile") or die("Cannot open $lfile\n");
while(<FILE>) {
  next if (/#/);
  chomp;
  s|||g;
  ($ip, $notes) = split(/\|/, $_);
  $enc_type = &mvEncType($ip);
  $machine_uptime = &mvHostUptime($ip);
  $servicestatus = &mvServiceStatus($ip);
  $enc_uptime = "down";
  #if ($servicestatus eq "up") {
    &mvCurrentConfigs($ip, \%config);
    &mvCurrentStatus($ip, \%status);
    #&mvPrintConfigs(\%config);
    if ($servicestatus eq "up") {
      $enc_uptime = &mvEncUptime($ip);
    }

    #copy logfile
    #&mvScp($_, "$logdir/hdenc.log", "logs_dir/$_.current");
    #&mvScp($_, "$logdir/hdenc.log.old", "logs_dir/$_.old");

    #get Video Source Setting
    my(%rate) = ("1", "CBR", "4", "CFCBR");
    my(%cfcbr) = ("1", "weakest", "2", "weak", "3", "medium", "4", "strong", "5", "strongest");
    my(%source) = ("2", "1280x720/60p", "3", "1280x720/50p", "4", "1920x1080/60i", "5", "1920x1080/50i");
    my(%ff) = ("0", "Frame", "1", "Field", "2", "MB-AFF");
    my($ratecontrol, $cfcbrstrength) = "";
    $ratecontrol = $config{'RateControlMethod'};
    if($ratecontrol == "4") {
      $cfcbrstrength = "($config{'CFCBRStrength'})"; 
    }
    my($i) = "i";
    if (int($config{'FrameRate'}) > 30) {
      $i = "p";
    }
    my($iformat) = $status{'InputFormat'};
    $mystatus{'VIDEOSOURCE'} = $source{$iformat};
    my($ffenc) = $config{'Interlace'};
    my(%gop) = ("0", "I", "1", "IP", "2", "IBP", "3", "IBBP", "4", "IBBBP");
    my($gcount) = $config{'M'};
    if (($gcount > 0) && ($gcount < 5)) {
      if ($gcount == "1") {
        $gcount = (int($config{'N'}) > 1) ? "1" : "0";
      }
    }
        
    $mystatus{'VIDEOOUT'} = "$config{'ScaledWidth'}x$config{'ScaledHeight'}/$config{'FrameRate'}$i " . "$ff{$ffenc} " . "$gop{$gcount} " . $config{'TargetBitRate'}/1000000 . "M " . $rate{$ratecontrol} . $cfcbrstrength;

    #get Audio Setting
    my($audio, $ch);
   if ($config{'AudioCompressType'} == "0") {
      $audio = "PCM";
    }
    else {
      $audio = "AC-3";
    }
    $ch = &mvChannelNo($config{'AudioSource'});
    print "Channel: $ch\n";
    if ($config{'AudioSource'} == "0") {
      $mystatus{'AUDIOOUT'} = "AudioOff";
    }
    else {
      $mystatus{'AUDIOOUT'} = $audio . " " . $config{'AudioBitrate'}/1000 . "K" . " ${ch}ch";
    }

    #PIP Setting
    my($pip) = "Disabled";
    if($config{'PipEnable'} == "1") {
      $pip = "$config{'PipScalerOutputWidth'}x$config{'PipScalerOutputHeight'} " . $config{'PipBitrate'}/1000 . "K " . $config{'PipInterfaceParam1'};
    }
    $mystatus{'PIP'} = "$pip"; 

    #get Advanced Encoder setting
    my($wp, $pip, $db, $em) = "";
    my(%entropy) = ("0", "CAVLC", "1", "CABAC"); 
    $em = $config{'SymbolMode'};
    if($config{'WeightedPrediction'} == "1") {
      $wp = "WP($config{'WeightedBiprediction'})";
    }
    if($config{'LoopFilterDisable'} == "0") {
      $db = "DB($config{'LoopFilterAlphaC0Offset'},$config{'LoopFilterBetaOffset'})"; 
    }
    
    $mystatus{'ADVANCE'} = "$entropy{$em} $wp $db";

    #get Version
    $mystatus{'VERSION'} = "$status{'RpmVer'}-$status{'RpmRel'}";

  #}

  #foreach $key (keys %mystatus) {
  #  print("$key = $mystatus{$key}\n");
  #}

  #&mvCreateFile($statfile, "#IP|hostname|enc_uptime|video_source|video_out|audio_out|nic_out|version|status|adv_setting");
  &mvAppendLine($statfile, "$ip|$status{'HOSTNAME'}|$machine_uptime|$enc_uptime|$mystatus{'VIDEOOUT'}|$mystatus{'AUDIOOUT'}|$config{'InterfaceParam1'}|$mystatus{'PIP'}|$mystatus{'VERSION'}|$status{'STATUS'}|$mystatus{'ADVANCE'}|$notes");
  (%config, %mystatus, %status) = ();
}
close(FILE);

