#!/usr/bin/perl

@hlist = ("rqa1-eth1", "rqa2-eth0", "rqa3-eth1", "rqa4-eth0", "rqa5-eth0", "rqa6-eth0", "rqa7-eth0", "rqa8a-eth0", "rqa9a-eth0", "rqa10a-eth1", "rqa11a-eth0", "rqa12a-eth1", "rqa13a-eth1", "rqa14a-eth1", "rqa15a-eth1", "rqa17a-eth1", "rqa18a-eth1", "se-6k-1", "se-6k-2", "se-6k-3", "se-6k-4", "se-6k-5", "se-6k-6", "se-6k-7", "se-6k-8", "se-6k-9");
#@hlist = ("rqa1-eth0");

$arg = "cat /proc/zemps";

foreach (@hlist) {
   print "\n";
   print "===================\n";
   print "$_\n";
   print "===================\n";
   $cmd = "./mvprexec.exp $_ '$arg'";
   my(@result) = &mvCmdRaw($cmd);
  # foreach (@result) {
  #   if (/^\# /) {
  #      print ($_);
  #   }
  #   if (/\#\# (\w+\s*\w*)/) {
  #      print ("$1 ");
  #   }
  #   if (/Version:/) {
  #      print ($_);
  #      }
  # }
   print @result;

}


sub mvCmdRaw {
  my($mycmd) = @_;
  #print STDERR "$mycmd\n";
  my(@rvalue) = `$mycmd`;
  for (@rvalue) {
  tr/^spawn//;
  tr/^root//;
  tr/^ssh//;
  tr/^#//;
  tr/^Permission denied//;
  }
  return(@rvalue);
}

