#! /usr/bin/perl
#
# Integrated test of the SSU-ALIGN package that focuses on the ssu-align script.
#
# Usage:     ./ssu-align.itest.pl <directory with all 5 SSU-ALIGN scripts> <data directory with fasta files etc.> <tmpfile and tmpdir prefix> <test number to perform, if blank do all tests>
# Examples:  ./ssu-align.itest.pl ../src/ data/ foo   (do all tests)
#            ./ssu-align.itest.pl ../src/ data/ foo 4 (do only test 4)
#
# EPN, Fri Feb 26 11:29:22 2010

$usage = "perl ssu-align.itest.pl\n\t<directory with all 5 SSU-ALIGN scripts>\n\t<data directory with fasta files etc.>\n\t<tmpfile and tmpdir prefix>\n\t<test number to perform, if blank, do all tests>\n";
$testnum = "";
if(scalar(@ARGV) == 3) { 
    ($scriptdir, $datadir, $dir) = @ARGV;
}
elsif(scalar(@ARGV) == 4) { 
    ($scriptdir, $datadir, $dir, $testnum) = @ARGV;
}
else { 
    printf("$usage\n");
    exit 0;
}
$scriptdir =~ s/\/$//; # remove trailing "/" 
$datadir   =~ s/\/$//; # remove trailing "/" 

$ssualign = $scriptdir . "/ssu-align";
$ssubuild = $scriptdir . "/ssu-build";
$ssudraw  = $scriptdir . "/ssu-draw";
$ssumask  = $scriptdir . "/ssu-mask";
$ssumerge = $scriptdir . "/ssu-merge";
$ssu_itest_module = "ssu.itest.pm";

if (! -e "$ssualign")         { die "FAIL: didn't find ssu-align script $ssualign"; }
if (! -e "$ssubuild")         { die "FAIL: didn't find ssu-build script $ssubuild"; }
if (! -e "$ssudraw")          { die "FAIL: didn't find ssu-draw script $ssudraw"; }
if (! -e "$ssumask")          { die "FAIL: didn't find ssu-mask script $ssumask"; }
if (! -e "$ssumerge")         { die "FAIL: didn't find ssu-merge script $ssumerge"; }
if (! -x "$ssualign")         { die "FAIL: ssu-align script $ssualign is not executable"; }
if (! -x "$ssubuild")         { die "FAIL: ssu-build script $ssubuild is not executable"; }
if (! -x "$ssudraw")          { die "FAIL: ssu-draw script $ssudraw is not executable"; }
if (! -x "$ssumask")          { die "FAIL: ssu-mask script $ssumask is not executable"; }
if (! -x "$ssumerge")         { die "FAIL: ssu-merge script $ssumerge is not executable"; }
if (! -e "$ssu_itest_module") { die "FAIL: didn't find required Perl module $ssu_itest_module in current directory"; }

require $ssu_itest_module;

$fafile      = $datadir . "/v6-4.fa";
$fafile_full = $datadir . "/seed-4.fa";
@name_A =     ("archaea", "bacteria", "eukarya");
@arc_only_A = ("archaea");
@bac_only_A = ("bacteria");
@euk_only_A = ("eukarya");
$key_out = "181";

if (! -e "$fafile")      { die "FAIL: didn't find required fasta file $fafile"; }
if (! -e "$fafile_full") { die "FAIL: didn't find required fasta file $fafile"; }
$testctr = 1;

#######################################
# Basic options (single letter options)
#######################################
# Test -h
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-h", $testctr);
    if ($? != 0) { die "FAIL: ssu-align -h failed unexpectedly"; }
}
$testctr++;

# Test default (no options) alignment
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test -b 100, we should only have 1 hit, the euk
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f -b 100", $testctr);
    check_for_files($dir, $dir, $testctr, \@euk_only_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@euk_only_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@euk_only_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@euk_only_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@euk_only_A, ".cmalign");
    if(! -e ("$dir/$dir.nomatch"))  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+0/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+0/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test -l 100, we should only have 1 hit, one of the bacs
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f -l 100", $testctr);
    check_for_files($dir, $dir, $testctr, \@bac_only_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@bac_only_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@bac_only_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@bac_only_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@bac_only_A, ".cmalign");
    if(! -e ("$dir/$dir.nomatch"))  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+0/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+1/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+0/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test -i, (check for --ileaved in cmalign output
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f -i", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.archaea.cmalign`;
    if($output !~ /command\:.+cmalign.+\-\-ileaved\s+/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test -n bacteria, should get the 2 bacteria guys, that's it
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f -n bacteria", $testctr);
    check_for_files($dir, $dir, $testctr, \@bac_only_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@bac_only_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@bac_only_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@bac_only_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@bac_only_A, ".cmalign");
    if(! -e ("$dir/$dir.nomatch"))  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output =~ /\s+archaea\s+/)   { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output =~ /\s+eukarya\s+/)   { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --dna (check for --dna in the cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f --dna", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.archaea.cmalign`;
    if($output !~ /command\:.+cmalign.+\-\-dna\s+/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --keep-int
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f --keep-int", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    if(! -e ("$dir/$dir.cmsearch"))  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --rfonly (check for --matchonly in cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f --rfonly", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.archaea.cmalign`;
    if($output !~ /command\:.+cmalign.+\-\-matchonly\s+/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --no-align
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f --no-align", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    if(-e ("$dir/$dir.archaea.stk"))     { die "ERROR, problem with aligning" }
    if(-e ("$dir/$dir.archaea.ifile"))   { die "ERROR, problem with aligning" }
    if(-e ("$dir/$dir.archaea.cmalign")) { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --no-search (requires -n or --aln-one)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f --no-search -n eukarya", $testctr);
    check_for_files($dir, $dir, $testctr, \@euk_only_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@euk_only_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@euk_only_A, ".cmalign");
    if(-e ("$dir/$dir.archaea.stk"))     { die "ERROR, problem with aligning" }
    if(-e ("$dir/$dir.bacteria.stk"))    { die "ERROR, problem with aligning" }
    if(-e ("$dir/$dir.eukarya.fa"))      { die "ERROR, problem with aligning" }
    if(-e ("$dir/$dir.eukarya.hitlist")) { die "ERROR, problem with aligning" }
    if(-e ("$dir/$dir.archaea.cmalign")) { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+eukarya\s+4/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --toponly (look for --toponly in cmsearch tab output)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f --toponly", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.tab`;
    if($output !~ /command\:.+cmsearch.+\-\-toponly/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --forward (look for --forward in cmsearch tab output)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f --forward", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.tab`;
    if($output !~ /command\:.+cmsearch.+\-\-forward/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --global (look for -g in cmsearch tab output) and search $fafile_full,
# which has full length seqs, should hit 2 archys, 1 bac
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile_full, $dir, "-f --global", $testctr);
    check_for_files($dir, $dir, $testctr, \@arc_only_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@arc_only_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@arc_only_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@arc_only_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@arc_only_A, ".cmalign");
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+2/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+1/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+0/)  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.tab`;
    if($output !~ /command\:.+cmsearch.+\s+\-g\s+/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --no-trunc (use $fafile_full)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile_full, $dir, "-f --no-trunc", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+2.+\s+1\.00/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+1.+\s+1\.00/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1.+\s+1\.00/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --aln-one archaea
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f --aln-one archaea", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@arc_only_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@arc_only_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@arc_only_A, ".cmalign");
    if(-e ("$dir/$dir.bacteria.cmalign")) { die "ERROR, problem with aligning" }
    if(-e ("$dir/$dir.eukarya.stk"))      { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1\s+/)   { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2\s+/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1\s+/)   { die "ERROR, problem with aligning" }
    if($output !~ /\s+alignment\s+1\s+/) { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --no-prob (check for --no-prob in cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f --no-prob", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.archaea.cmalign`;
    if($output !~ /command\:.+cmalign.+\-\-no\-prob/)  { die "ERROR, problem with aligning" }
}
$testctr++;

# Test --mxsize 256 (check for --mxsize 256 in cmalign output)
if(($testnum eq "") || ($testnum == $testctr)) {
    run_align($ssualign, $fafile, $dir, "-f --mxsize 256", $testctr);
    check_for_files($dir, $dir, $testctr, \@name_A, ".hitlist");
    check_for_files($dir, $dir, $testctr, \@name_A, ".fa");
    check_for_files($dir, $dir, $testctr, \@name_A, ".stk");
    check_for_files($dir, $dir, $testctr, \@name_A, ".ifile");
    check_for_files($dir, $dir, $testctr, \@name_A, ".cmalign");
    $output = `cat $dir/$dir.ssu-align.sum`;
    if($output !~ /\s+archaea\s+1/)  { die "ERROR, problem with aligning" }
    if($output !~ /\s+bacteria\s+2/) { die "ERROR, problem with aligning" }
    if($output !~ /\s+eukarya\s+1/)  { die "ERROR, problem with aligning" }
    $output = `cat $dir/$dir.archaea.cmalign`;
    if($output !~ /command\:.+cmalign.+\-\-mxsize\s+256\s+/)  { die "ERROR, problem with aligning" }
}
$testctr++;



printf("All commands completed successfully.\n");
exit 0;

    
