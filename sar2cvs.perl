#!/usr/bin/perl
use strict;
use Getopt::Std;

# Name:         quasar (Qualitatite Sar)
# Version:      1.0.0
# Release:      1
# License:      Open Source
# Group:        System
# Source:       N/A
# URL:          https://github.com/richardatlateralblast/quasar/blob/master/quasar
# Distribution: Solaris
# Vendor:       UNIX
# Packager:     Richard Spindler
# Description:  Sar graphing tool

# Changes       1.0.0 Tuesday, 13 November 2012  5:27:55 AM EST
#               Initial commit to github

#
# Script to process sar data
# This script has support to process multiple days of sar output
# An example of a command to capture all the sar output to a single file:
# cd /var/adm/sa ; for i in `ls sa[0-9]*` ; do sar -A -f $i >> /tmp/`hostname`.sarout ; done
# The -s switch will do this for you if you want
# This output file then can be input into this script using a command like:
# ./sar2cvs -i /tmp/sarout -o /tmp/sarcvs
# This will generate a number of files /tmp/sarcvs_METRIC.cvs
# METRIC is the the name of the first column pulled from the sar data
# For example /tmp/sarcvs_runq-sz
# An output file will be generated for each disk device
#

my %option=();
getopts("i:o:t:s:d:w:DhSg",\%option);

my $script_name="quasar";
my $sar_file;
my $date; my $time;
my $tmp_dir="/tmp/$script_name";
my $tmp_file="$tmp_dir/rawdata";
my $mins; my $hours;

if ($option{'h'}) {
  usage();
  exit;
}

if ($option{'s'}) {
  $date=$option{'s'};
}

if ($option{'w'}) {
  $tmp_dir=$option{'w'};
}

# Some help on using the script

sub usage {
  print "\n";
  print "Usage:\n";
  print "$script_name [OPTION] -i [INPUT] -o [OUTPUT] -s [START] -d [DELTA]\n";
  print "-h: Help\n";
  print "-D: Do disk stats (takes some time thus not done by default)\n";
  print "-i: Input file\n";
  print "-o: Output file\n";
  print "-g: Output Google Graphs Javascript\n";
  print "-s: Start Date (used for data from mpstat etc)\n";
  print "-d: Delta in secs (user for data from mpstat etc)\n";
  print "-S: Process directly from sar and output to directory $tmp_dir\n";
  print "-w: Set work directory (overrides $tmp_dir)\n";
  print "\n";
  print "Example: Process raw sar output from a file\n";
  print "\n";
  print "sar2cvs -i RAW_SAR_INPUT -o CVS_OUTPUT\n";
  print "\n";
  print "Example: Process sar directly\n";
  print "\n";
  print "sar2cvs -S\n";
  print "\n";
  print "Example: Process mpstat output\n";
  print "\n";
  print "sar2cvs -i RAW_INPUT -o CVS_OUTPUT -s START -d DELTA\n";
  print "\n";
  return;
}

# If the sar data exists start processing

if ((-e "$option{'i'}")||($option{'S'})) {
  process_sar();
}
else {
  # If the input file doesn't exist exit
  print "File $option{'i'} does not exist.\n";
}

# Process the disk header

sub process_device_header {

  my $record=$_[0];
  my $device_header;

  if ($record=~/device/) {
    $device_header=$record;
    $device_header=~s/device\,//g;
    $device_header=~s/00\:00\:01\,//g;
  }
  $device_header=~s/busy/ Busy/g;
  $device_header=~s/avqueue/Average queue/g;
  $device_header=~s/,r+w/,Reads and writes/g;
  $device_header=~s/,blks/,Blocks/g;
  $device_header=~s/,avwait/,Average wait time in ms/g;
  $device_header=~s/,avserv/,Average service time in ms/g;
  return($device_header);
}

sub process_header {

  my $record=$_[0];

  $record=~s/,atch/,Page faults/g;
  $record=~s/,write/,Writes/g;
  $record=~s/,bread/,Buffer reads/g;
  $record=~s/,bwrit/,Buffer writes/g;
  $record=~s/,lread/,System buffer reads/g;
  $record=~s/,lwrit/,System buffer writes/g;
  $record=~s/rcache/ Read cache hit ratio/g;
  $record=~s/wcache/ Write cache hit ratio/g;
  $record=~s/,pread/,Physical reads/g;
  $record=~s/,pwrit/,Physical writes/g;
  $record=~s/,scall/,System calls/g;
  $record=~s/,sread/,System reads/g;
  $record=~s/,swrit/,System writes/g;
  $record=~s/,fork/,Process forks/g;
  $record=~s/,exec/,Process execs/g;
  $record=~s/,rchar/,System read character transfers/g;
  $record=~s/,wchar/,System write character transfers/g;
  $record=~s/busy/ Busy/g;
  $record=~s/,avque/,Average queue/g;
  $record=~s/,blks/,Blocks/g;
  $record=~s/,reads/,Reads/g;
  $record=~s/,ppgout/,Pages paged out/g;
  $record=~s/,pgout/,Page out requests/g;
  $record=~s/,pgfree/,Pages freed/g;
  $record=~s/,pgscan/,Pages scanned/g;
  $record=~s/ufs\_ipf/ UFS inodes taken off free list/g;
  $record=~s/,sml\_mem,alloc,fail/,Small memory pool in bytes,Small memory pool allocated,Small memory allocation fails/g;
  $record=~s/,lg\_mem,alloc,fail/,Large memory pool in bytes,Large memory pool allocated,Large memory allocation fails/g;
  $record=~s/,ovsz\_alloc,fail/,Oversize memory allocation in bytes,Oversize memory allocation fails/g;
  $record=~s/,ppgin/,Pages paged in/g;
  $record=~s/,pgin/,Page in requests/g;
  $record=~s/,pflt/,Page faults/g;
  $record=~s/,vflt/,Page address translation faults/g;
  $record=~s/,slock/,Software lock requests requiring IO/g;
  $record=~s/,runq-sz/,Run queue size/g;
  $record=~s/,swpq-sz/,Swap queue size/g;
  $record=~s/runocc/ Run queue occupied/g;
  $record=~s/swpocc/ Swap queue occupied/g;
  # The google charts code displays memory in GB
  if ($option{'g'}) {
    $record=~s/,freemem/,Pages available to user processes [GB]/g;
    $record=~s/,freeswap/,Disk blocks available for page swapping [GB]/g;
  }
  else {
    $record=~s/,freemem/,Pages available to user processes/g;
    $record=~s/,freeswap/,Disk blocks available for page swapping/g;
  }
  $record=~s/usr/ CPU used in user mode/g;
  $record=~s/sys/ CPU used in system mode/g;
  $record=~s/wio/ CPU used waiting on IO/g;
  $record=~s/,iget/,inodes not in DNLC/g;
  $record=~s/,dirblk/,Directory block reads/g;
  $record=~s/,namei/,Filesystem path searches/g;
  $record=~s/,msg/,Messages/g;
  $record=~s/,sema/,Semaphores/g;
  $record=~s/idle/ CPU idle/g;
  $record=~s/,swpin/,Swap ins/g;
  $record=~s/,swpot/,Swap outs/g;
  $record=~s/,bswin/,512 byte swap ins/g;
  $record=~s/,bswot/,512 byte swap outs/g;
  $record=~s/,pswch/,Process switches/g;
  $record=~s/,proc-sz/,Process table size/g;
  $record=~s/,inod-sz/,inode table size/g;
  $record=~s/,file-sz/,File table size/g;
  $record=~s/,lock-sz/,Lock table size/g;
  #$record=~s///g;
  return($record);
}

sub create_html_header {

  my $out_file=$_[0];

  open OUTPUT,">>$out_file";
  print  OUTPUT "\n";
  print  OUTPUT "  \n";
  print  OUTPUT "    \n";
  print  OUTPUT "    \n";
  print OUTPUT "  \n";
  print OUTPUT "  \n";
  print OUTPUT "
\n";
  print OUTPUT "  \n";
  print OUTPUT "\n";
  close OUTPUT;
  return;
}
