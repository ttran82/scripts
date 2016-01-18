#!/usr/bin/perl

use File::Basename;

my($basedir) = dirname($0);
require("$basedir/mvrockstarlib.pl");

use vars qw($lfile $Statfile $ip $machine_uptime $enc_uptime $mem_usage $disk_usage $restart_count $temp_sensors $servicestatus $logdir);
use vars qw(%config %status %mystatus $key $ip $notes $enc_type);


$lfile = "$logs_dir/rockstarhostname.lst";
$statfile = "$logs_dir/rockstarstatus";
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
  $enc_type = &mvEncType($ip);
  $machine_uptime = &mvHostUptime($ip);
  $servicestatus = &mvServiceStatus($ip);
  $enc_uptime = "down";
  #if ($servicestatus eq "up") {
    &mvCurrentConfigs($ip, \%config);
    #for Zodiac
    &mvCurrentStatus($ip, \%status);
    #&mvPrintConfigs(\%config);
    if ($servicestatus eq "up") {
      $enc_uptime = &mvEncUptime($ip);
      $mem_usage = &mvMemoryUsage($ip);
      $disk_usage = &mvDiskUsage($ip);
      $restart_count = &mvZencRestartCount($ip);
      $time = `date +\'%d-%m-%y %H:%M:%S\'`;
      chop($time);
      chomp($time);
      #$temp_sensors = &mvTempSensors($ip);
      #&mvAppendLine("$logs_dir/zodiac/$ip", "$time $temp_sensors");
    }
    
    #Get CPU Info
    $mystatus{'CPU'} = &mvCpuInfo($ip);

    #copy logfile
    #&mvScp($_, "$logdir/hdenc.log", "logs_dir/$_.current");
    #&mvScp($_, "$logdir/hdenc.log.old", "logs_dir/$_.old");

    #get Video Source Setting
    my(%input) = ("0", "SDI", "1", "NTSC", "2", "ATSC", "3", "UDP", "4", "SDI-Framesync", "5", "ASI");
    my(%rate) = ("1", "CBR", "4", "CFCBR");
    my(%cfcbr) = ("1", "weakest", "2", "weak", "3", "medium", "4", "strong", "5", "strongest");
    my(%source) = ("2", "1280x720/60p", "3", "1280x720/50p", "4", "1920x1080/60i", "5", "1920x1080/50i");
    my(%ff) = ("0", "Frame", "1", "Field", "2", "MB-AFF");
    my($ratecontrol, $cfcbrstrength, $input_signal, $channel_num) = "";
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

    my($bref) = "";
    if ($config{'RefBFrameEnable'} == "1") {
      $bref = "+"; 
    }

    $input_signal = "SDI";
    if ($config{'polaris_mode'} == "1") {
      $channel_num = $config{'ntsc_channel'};
      $input_signal = $input{$config{'polaris_mode'}} . "(" . $channel_num . ")"; 
    }
    if ($config{'polaris_mode'} == "2") {
      $channel_num = $config{'atsc_channel'} . "." . $config{'atsc_rf_prog_num'}; 
      $input_signal = $input{$config{'polaris_mode'}} . "(" . $channel_num . ")"; 
    }
    if ($config{'polaris_mode'} == "3") {
      $channel_num = $config{'atsc_udpin_interface'} . ":" . $config{'atsc_udpin_ip_address'} . "/" . $config{'atsc_udpin_prog_num'}; 
      $input_signal = $input{$config{'polaris_mode'}} . "(" . $channel_num . ")"; 
    }
    if ($config{'polaris_mode'} == "5") {
      $channel_num = $config{'asi_prog_num'};
      $input_signal = $input{$config{'polaris_mode'}} . "(" . $channel_num . ")";
    }
        
        
        
    $mystatus{'VIDEOOUT'} = "$input_signal $config{'ScaledWidth'}x$config{'ScaledHeight'}/$config{'FrameRate'}$i " . "$ff{$ffenc} " . $gop{$gcount} . "$bref " . $config{'TargetBitRate'}/1000000 . "M " . $rate{$ratecontrol} . $cfcbrstrength;

    #get Audio Setting
    my(%audiotype) = ("0", "MPEG", "1", "AAC", "2", "AC3-PT", "3", "AC3-ENC");
    my(%audioenable);
    my($chnum) = 4;
    my($audio) = "";

    my($i, $renable, $rtype, $pid) = "";
    for ($i = 1; $i < 5; $i++) {
      $renable = "Audio" . $i . "Enable"; 
      #$renable = &mvGetConfig($ip, "Audio" . $i . "Enable"); 
      #print ("Audio" . $i . "Enable:" . $rvalue . "\n");
      if ( $config{$renable} == "1") {
        $rtype = $config{"Audio" . $i . "CompressType"};
        $pid = "Audio" . $i . "PID";
        $audio .= "Pid$config{$pid}\=$audiotype{$rtype}";
        #print ("Audio" . $i . "CompressType:" . $rvalue . "\n"); 
        $rtype = "Audio" . $i . "Bitrate";
        $audio .= "(" . $config{$rtype}/1000 . "K) ";
      }
    }

    $mystatus{'AUDIOOUT'} = $audio;

    #PIP Setting
    my($pip) = "Disabled";
    if($config{'PipEnable'} == "1") {
      $pip = "$config{'PipScalerOutputWidth'}x$config{'PipScalerOutputHeight'} " . $config{'PipBitrate'}/1000 . "K " . "$config{'PipInterfaceName'}:$config{'PipInterfaceParam1'}";
      if ($config{'PipBackupInterfaceName'} =~ /eth/) {
        $pip = $pip . " $config{'PipBackupInterfaceName'}:$config{'PipBackupInterfaceParam1'}";
      }
    }
    $mystatus{'PIP'} = "$pip"; 

    #get Advanced Encoder setting
    my($wp, $pip, $db, $em, $pd, $idr) = "";
    my(%entropy) = ("0", "CAVLC", "1", "CABAC"); 
    if($config{'TelecineDetect'} == "1") {
      $pd = "3:2";
    }

    $em = $config{'SymbolMode'};
    if($config{'WeightedPrediction'} == "1") {
      $wp = "WP($config{'WeightedBiprediction'})";
    }
    if($config{'LoopFilterDisable'} == "2") {
      $db = "DB($config{'LoopFilterAlphaC0Offset'},$config{'LoopFilterBetaOffset'})"; 
    }

    $idr = "IDR($config{'IDRFrequency'})";
    
    $mystatus{'ADVANCE'} = "$entropy{$em} $pd $db $wp $idr";
    
    #network parameters
    $mystatus{'NETWORK'} = "$config{'InterfaceName'}:$config{'InterfaceParam1'}:$config{'InterfaceParam2'} ";

    if ($config{'BackupInterfaceName'} =~ /eth/) {
      $mystatus{'NETWORK'} = $mystatus{'NETWORK'} . "$config{'BackupInterfaceName'}:$config{'BackupInterfaceParam1'}:$config{'BackupInterfaceParam2'} ";
    }
    if ($config{'StatmuxEnable'} == "1") {
      $mystatus{'NETWORK'} = $mystatus{'NETWORK'} . "MUX1:" . "$config{'StatmuxCtrlrAddress1'} " . "MUX2:" . "$config{'StatmuxCtrlrAddress2'} ";
    }

    $mystatus{'NETWORK'} = $mystatus{'NETWORK'} . "TR1:$config{'TrapReceiverAddr1'} TR2:$config{'TrapReceiverAddr2'} TR3:$config{'TrapReceiverAddr3'} TR4:$config{'TrapReceiverAddr4'}";

    #get Version
    $mystatus{'VERSION'} = "$status{'RpmVer'}-$status{'RpmRel'}";

    #PreFilter value
    $mystatus{'ADVANCEX'} = "PreFilter($config{'PreFilter'}) RateControlMethod($config{'RateControlMethod'})";


  #}

  #foreach $key (keys %mystatus) {
  #  print("$key = $mystatus{$key}\n");
  #}

  #&mvCreateFile($statfile, "#IP|hostname|enc_uptime|video_source|video_out|audio_out|nic_out|version|status|adv_setting");
  &mvAppendLine("$statfile.new", "$ip|$status{'HOSTNAME'}|$mystatus{'CPU'}|$status{'DOM_rev'}|$status{'ZEM_firmware_rev'}|$machine_uptime|$enc_uptime|$mem_usage|$disk_usage|$restart_count|$mystatus{'VIDEOOUT'}|$mystatus{'AUDIOOUT'}|$mystatus{'NETWORK'}|$mystatus{'PIP'}|$mystatus{'VERSION'}|$status{'STATUS'}|$mystatus{'ADVANCE'}|$mystatus{'ADVANCEX'}|$notes");
  (%config, %mystatus, %status) = ();
}
close(FILE);

rename("$statfile.new", "$statfile") or &printError(500, "Server error", "Problem renaming $statfile.new");
