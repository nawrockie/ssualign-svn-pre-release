#! /usr/bin/perl
#
# Integrated test number 1 of the SSU-ALIGN scripts.
#
# Usage:     ./sa.itest.1.pl <directory with all 5 SSU-ALIGN scripts> <fasta file> <tmpfile and tmpdir prefix>
# Example:   ./sa.itest.1.pl ../src/ ./seed-4.fa ../testsuite/trna-5.stk foo
#
# EPN, Fri Feb 26 11:29:22 2010

$scriptdir = shift;
$fafile  = shift;
$tmppfx   = shift;

$ssualign = $scriptdir . "/ssu-align";
$ssubuild = $scriptdir . "/ssu-build";
$ssudraw  = $scriptdir . "/ssu-draw";
$ssumask  = $scriptdir . "/ssu-mask";
$ssumerge = $scriptdir . "/ssu-merge";

if (! -x "$ssualign") { die "FAIL: ssu-align script $ssualign is not executable"; }
if (! -x "$ssubuild") { die "FAIL: ssu-build script $ssubuild is not executable"; }
if (! -x "$ssudraw")  { die "FAIL: ssu-draw script $ssudraw is not executable"; }
if (! -x "$ssumask")  { die "FAIL: ssu-mask script $ssumask is not executable"; }
if (! -x "$ssumerge") { die "FAIL: ssu-merge script $ssumerge is not executable"; }
if (! -e "$ssualign") { die "FAIL: didn't find ssu-align script $ssualign"; }
if (! -e "$ssubuild") { die "FAIL: didn't find ssu-build script $ssubuild"; }
if (! -e "$ssudraw")  { die "FAIL: didn't find ssu-draw script $ssudraw"; }
if (! -e "$ssumask")  { die "FAIL: didn't find ssu-mask script $ssumask"; }
if (! -e "$ssumerge") { die "FAIL: didn't find ssu-merge script $ssumerge"; }
$ctr = 1;

system("$ssualign -F $fafile $tmppfx > /dev/null");
if ($? != 0) { die "FAIL: ssu-align failed unexpectedly on pass $pass2write";}
run_mask($tmppfx, $ctr);
run_draw($tmppfx, $ctr);
$ctr++;

system("$ssualign -F -m archaea $fafile $tmppfx > /dev/null");
if ($? != 0) { die "FAIL: ssu-align failed unexpectedly on pass $pass2write";}
run_mask($tmppfx, $ctr);
run_draw($tmppfx, $ctr);
$ctr++;

system("$ssualign -F -b 300 $fafile $tmppfx > /dev/null");
if ($? != 0) { die "FAIL: ssu-align failed unexpectedly on pass $pass2write";}
run_mask($tmppfx, $ctr);
run_draw($tmppfx, $ctr);
$ctr++;

system("$ssualign -F -l 300 $fafile $tmppfx > /dev/null");
if ($? != 0) { die "FAIL: ssu-align failed unexpectedly on pass $pass2write";}
run_mask($tmppfx, $ctr);
run_draw($tmppfx, $ctr);
$ctr++;

system("$ssualign -F -i $fafile $tmppfx > /dev/null");
if ($? != 0) { die "FAIL: ssu-align failed unexpectedly on pass $pass2write";}
run_mask($tmppfx, $ctr);
run_draw($tmppfx, $ctr);
$ctr++;

system("$ssualign -F --dna $fafile $tmppfx > /dev/null");
if ($? != 0) { die "FAIL: ssu-align failed unexpectedly on pass $pass2write";}
run_mask($tmppfx, $ctr);
run_draw($tmppfx, $ctr);
$ctr++;

system("$ssualign -F --keep $fafile $tmppfx > /dev/null");
if ($? != 0) { die "FAIL: ssu-align failed unexpectedly on pass $pass2write";}
run_mask($tmppfx, $ctr);
run_draw($tmppfx, $ctr);
$ctr++;

system("$ssualign -F --rfonly $fafile $tmppfx > /dev/null");
if ($? != 0) { die "FAIL: ssu-align failed unexpectedly on pass $pass2write";}
run_mask($tmppfx, $ctr);
run_draw($tmppfx, $ctr);
$ctr++;

system("$ssualign -F --only eukarya $fafile $tmppfx > /dev/null");
if ($? != 0) { die "FAIL: ssu-align failed unexpectedly on pass $pass2write";}
run_mask($tmppfx, $ctr);
run_draw($tmppfx, $ctr);
$ctr++;


#####################################################
sub run_mask { 
    ($pfx, $ctr) = @_;
    system("$ssumask $pfx > /dev/null");
    if ($? != 0) { die "FAIL: ssu-mask $ctr failed unexpectedly"; }
    return;
}
#####################################################
sub run_draw {
    ($pfx, $ctr) = @_;
    system("$ssudraw $pfx > /dev/null");
    if ($? != 0) { die "FAIL: ssu-draw $ctr failed unexpectedly"; }
}
#####################################################
