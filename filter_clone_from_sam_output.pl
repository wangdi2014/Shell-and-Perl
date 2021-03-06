#! /usr/bin/perl
## This program goes through the output generated by java_sj_picard.sh which targets a specific site. 
## it removes any hits that conform to the "clone" pattern
## HWUSI-EAS1680_8:1:117:8670:7150 163     12      131948256       36      38M698N63M      =       131948999       8036    ACCACTTCCTTTAGGGGAGATGCCACCACCCCCAGACCCTGTAATCACAATACCTTGGGAGGCCAAGGTGGGAGGATCACTTGATCCCAGGAGTTTTAGAC   IIIBIIIIIIIIIIIIIIIIIDIIIIIIIIIIHIIIHIIIIHGHIIIIIHIIIHFIIIGHHHIIHEIH@HEHCICEIIIHHFGHBHDEGICBF@BC@CBCE   X0:i:2  X1:i:0  MD:Z:53T47      YF:Z:ZNF605andCHFR_gApr07       XG:i:0  YG:i:131949007  AM:i:0  NM:i:1  SM:i:0  XM:i:1  XO:i:0  MQ:i:37 YR:i:54 XT:A:R
## HWUSI-EAS1680_8:1:16:6901:6863  147     12      131948262       0       32M698N69M      =       131948182       -878    TCCTTTAGGGGAGATGCCACCACCCCCAGACCCTGTAATCACAATACCTTGGGAGGCCAAGGTGGGAGGATCACTTGATCCCAGGAGTTTTAGACCAGCCT   EBFBBBECGGHEIGGGGIBHIEHIIIIGI>HIIIGIIIIIHIIIIEIIFIIIIIIIIIIIIIHIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIH   X0:i:2  X1:i:0  MD:Z:47T53      YF:Z:ZNF605andCHFR_eApr07       XG:i:0  YG:i:131949007  AM:i:0  NM:i:1  SM:i:0  XM:i:1  XO:i:0  MQ:i:0  YR:i:48 XT:A:R
## HWUSI-EAS1680_8:1:117:8670:7150 83      12      131948999       37      86M7193N15M     =       131948256       -8036   CACAATACCTTGGGAGGCCAAGGTGGGAGGATCACTTGATCCCAGGAGTTTTAGACCAGCCTGGGCAACACAGCAAGGCACCATCTCACAACTGGAGGAAC   HEFEED?GDEFEHHFIGGHGIHHHIHHHIIIHIEIIHIHHIIHIIIIIIIIIIIHIIIIIIHIIIIIIIIIIIIGIIIHIIIIIHIIDGIIIIIIIIIIII   X0:i:1  X1:i:0  MD:Z:8T92       YF:Z:ZNF605andCHFR_gApr07       XG:i:0  YG:i:131949007  AM:i:0  NM:i:1  SM:i:37 XM:i:1  XO:i:0  MQ:i:36 YR:i:9  XT:A:U

#=============================================
#NOTE NOTE NOTE NOTE NOTE
#strict prevents implicit data definition (eg by typo)
use strict;
#NOTE NOTE NOTE NOTE NOTE
#=============================================



use Getopt::Std;
use Carp;
use File::Basename;
#use vars necessary for getopt if you are using strict
use vars qw/$opt_i $opt_o $opt_c/;
getopt('i:o:c');

my $USAGE="$0 takes the following arguement:\n";
$USAGE .="-i input data file produced by java_sj_picard.sh\n";
$USAGE .="-o Output file name for recording non-repeat\n";
$USAGE .="-c Output file name for recording clone\n";


if(!defined $opt_i ){
  croak $USAGE;
}

if(!defined $opt_o){
  croak $USAGE;
}

if(!defined $opt_c){
  croak $USAGE;
}

my $NAME_INDEX=0;
my $FLAG_INDEX=1;
my $STRAND_INDEX=8;
open(FN, $opt_i) or die "Fail to open the input data file from BLAT output:$opt_i\n";
open(FO, "> $opt_o") or die "Cannot open the output file:$opt_o\n";
open(FC, "> $opt_c") or die "Cannot open the output file for recording reads with clone:$opt_c\n";
undef my %read_info;
while (<FN>) {
  chomp;
  my $line = $_;
  my @items = split "\t", $_;
  my $name=$items[$NAME_INDEX];
  my $flags=$items[$FLAG_INDEX];
  my $strand = ($flags & 0x0010) ? 2 : 1;
##  my $strand_val=$items[$STRAND_INDEX];
##  my $strand = 1;
##  if($strand_val <0)
##  {
##    $strand=2;
##  }
  if(defined $read_info{$name})
  {
    if($read_info{$name}{strand} != $strand)
    {
       $read_info{$name}{strand} = 3;
    }
  }
  else
  {
    $read_info{$name}{strand} = $strand;
    $read_info{$name}{line} = $line;
  }
}
close(FN);

foreach my $name (keys %read_info)
{
  if($read_info{$name}{strand} != 3)
  {
    printf FO "%s\n", $read_info{$name}{line};
  }
  else
  {
    printf FC "%s\n", $read_info{$name}{line};
  }
}
close (FO);
close (FC);

   
