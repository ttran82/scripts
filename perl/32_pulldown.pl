#!/usr/bin/perl

$count = 300;
$mytime = 30; #second
$value = 0;

for($i=0; $i<$count; $i++) {
  print("Toggle 3:2 pulldown number: $i.\n");
  system("/usr/local/db/mvconfig --set TelecineDetect $value");
  $value = $value ^ 1;
  print("value: $value.\n");
  sleep $mytime;
}

