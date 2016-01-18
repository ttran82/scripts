#!/usr/bin/perl

use File::Basename;

my($basedir) = dirname($0);
require("$basedir/mvsdlib.pl");

use vars qw($lfile $Statfile $ip $machine_uptime $enc_uptime $servicestatus $logdir);
use vars qw(%config %status %mystatus $key $ip $notes $enc_type);


$lfile = "$logs_dir/sdhostname.lst";
$statfile = "$logs_dir/sdstatus";
$logdir = "/var/log";

#Create file ready for stat output
#&mvCreateFile($statfile, "#IP|Hostname|EncUptime|VideoSource|VideoOut|AudioOut|MultiCast|PIP|Version|Status|AdvanceSetting");
&mvCreateFile("$statfile.new", "");

#open hostname list 
open(FILE, "<$lfile") or die("Cannot open $lfile\n");
while(<FILE>) {
  next if (/#/);
  chomp;
  s|||g;
  ($ip, $notes) = split(/\|/, $_);
  $machine_uptime = &mvHostUptime($ip);
  $servicestatus = &mvServiceStatus($ip);
  $enc_uptime = "down";
  #if ($servicestatus eq "up") {
    &mvScp($ip, "$logdir/mvenc.log", "$logs_dir/$ip.current");
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
    my(%ff) = ("0", "Frame", "1", "Field", "2", "MB-AFF", "3", "Picture-AFF");
    my(%aspect) = ("1", "4:3", "2", "16:9");
    my($aspectratio) = $config{'AspectRatio'};
    my($cc) = "";
    if ($config{'CcEdsEnable'} == "1") {
      $cc = "CC"; 
    }
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
        
    $mystatus{'VIDEOOUT'} = "$config{'SourceWidth'}\@$config{'FrameRate'}$i " . "$aspect{$aspectratio} " . "$ff{$ffenc} " . "$gop{$gcount} " . $config{'TargetBitRate'}/1000000 . "M " . $rate{$ratecontrol} . $cfcbrstrength;

    #get Audio Setting
    my($audio, $ch);
   if ($config{'AudioCompressType'} == "0") {
      $audio = "MPEG";
    }
   elsif ($config{'AudioCompressType'} == "2") {
      $audio = "AC3";
    }
   else {
      $audio = "AAC";
   }

    $ch = &mvChannelNo($config{'AudioSource'});
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
    my($wp, $pip, $db, $em, $pd, $vpp, $scd, $idr) = "";
    my(%entropy) = ("0", "CAVLC", "1", "CABAC"); 
    $em = $config{'SymbolMode'};
    if($config{'TelecineDetect'} == "1") {
      $pd = "3:2";
    }
    if($config{'WeightedPrediction'} == "1") {
      $wp = "WP($config{'WeightedBiprediction'})";
    }
    if($config{'LoopFilterDisable'} == "0") {
      $db = "DB($config{'LoopFilterAlphaC0Offset'},$config{'LoopFilterBetaOffset'})"; 
    }
    $vpp = "VPP($config{'VPPEnable'})";
    if($config{'SceneChangeDetect'} == "1") {
       $scd = "SCD";
    }
    $idr = "IDR($config{'IDRFrequency'})";
    
    $mystatus{'ADVANCE'} = "$entropy{$em} $pd $db $vpp $wp $scd $idr";

    #network
    $mystatus{'NETWORK'} = "$config{'InterfaceParam1'}:$config{'InterfaceParam2'} TR1:$config{'TrapReceiverAddr1'} TR2:$config{'TrapReceiverAddr2'}";

    #get Version
    $mystatus{'VERSION'} = "$status{'RpmVer'}-$status{'RpmRel'}";
    
    #PreFilter value
    $mystatus{'ADVANCEX'} = "RateControl($config{'RateControlMethod'})";

  #}

  #foreach $key (keys %mystatus) {
  #  print("$key = $mystatus{$key}\n");
  #}

  #&mvCreateFile($statfile, "#IP|hostname|enc_uptime|video_source|video_out|audio_out|nic_out|version|status|adv_setting");
  &mvAppendLine("$statfile.new", "$ip|$status{'HOSTNAME'}|$machine_uptime|$enc_uptime|$mystatus{'VIDEOOUT'}|$mystatus{'AUDIOOUT'}|$mystatus{'NETWORK'}|$mystatus{'PIP'}|$mystatus{'VERSION'}|$status{'STATUS'}|$mystatus{'ADVANCE'}|$mystatus{'ADVANCEX'}|$notes");
  (%config, %mystatus, %status) = ();
}
close(FILE);

rename("$statfile.new", "$statfile") or &printError(500, "Server error", "Problem renaming $statfile.new");
